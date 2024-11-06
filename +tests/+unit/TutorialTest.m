classdef TutorialTest <  matlab.unittest.TestCase
% TutorialTest - Unit test for testing the matnwb tutorials.
%
%   This test will test most tutorial files (while skipping tutorials with 
%   dependencies) If the tutorial creates an nwb file, the test will also try 
%   to open this with pynwb.
%   
%   Note: 
%       - Requires MATLAB XXXX to run py.* commands.
%       - pynwb must be installed in the python environment returned by
%         pyenv()

    properties
        MatNwbDirectory
    end

    properties (Constant)
        NwbInspectorSeverityLevel = 1
    end

    properties (TestParameter)
        % TutorialFile - A cell array where each cell is the name of a
        % tutorial file. testTutorial will run on each file individually
        tutorialFile = listTutorialFiles();
    end

    properties (Constant)
        SkippedTutorials = {...
            'basicUsage.mlx', ...  % depends on external data
            'convertTrials.m', ... % depends on basicUsage output
            'formatStruct.m', ...  % Actually a utility script, not a tutorial
            'read_demo.mlx', ...   % depends on external data
            'remote_read.mlx'};    % Uses nwbRead on s3 url, potentially very slow
        
        % SkippedFiles - Name of exported nwb files to skip reading with pynwb
        SkippedFiles = {'testFileWithDataPipes.nwb'} % does not produce a valid nwb file

        % PythonDependencies - Package dependencies for running pynwb tutorials
        PythonDependencies = {'nwbinspector'}
    end

    methods (TestClassSetup)
        function setupClass(testCase)
            % Get the root path of the matnwb repository
            rootPath = getMatNwbRootDirectory();
            tutorialsFolder = fullfile(rootPath, 'tutorials');
            
            testCase.MatNwbDirectory = rootPath;

            % Use a fixture to add the folder to the search path
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(rootPath));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(tutorialsFolder));
            
            % Note: The following seems to not be working on the azure pipeline
            % Keep for reference

            % % % Make sure pynwb is installed in MATLAB's Python Environment
            % % args = py.list({py.sys.executable, "-m", "pip", "install", "pynwb"});
            % % py.subprocess.check_call(args);
            % % 
            % % % Add pynwb to MATLAB's python environment path
            % % pynwbPath = getenv('PYNWB_PATH');
            % % if count(py.sys.path, pynwbPath) == 0
            % %     insert(py.sys.path,int32(0),pynwbPath);
            % % end


            % % Alternative: Use python script for reading file with pynwb
            tests.util.addFolderToPythonPath( fileparts(mfilename('fullpath')) )

            installNWBInspector()

            disp(pyenv)

            generator = py.pkgutil.iter_modules();

            py.dir(generator)
            methodNext = py.getattr(generator, '__next__');
            finished = false;
            moduleNames = string.empty;
            while ~finished
                try
                    module = methodNext();
                    moduleNames(end+1) = string(module.name);
                catch;
                    finished = true;
                end
            end
            moduleNames'

            py.nwbinspector.inspect_nwbfile('test.nwb')

            nwbClearGenerated()
            testCase.addTeardown(@generateCore)
        end
    end

    methods (TestMethodSetup)
        function setupMethod(testCase)
            testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture);
            generateCore('savedir', '.');
        end
    end
    
    methods (Test)
        function testTutorial(testCase, tutorialFile) %#ok<INUSD>
            % Intentionally capturing output, in order for tests to cover
            % code which overloads display methods for nwb types/objects.
            C = evalc( 'run(tutorialFile)' ); %#ok<NASGU>
            
            testCase.readTutorialNwbFileWithPynwb()
            testCase.inspectTutorialFileWithNwbInspector()
        end
    end

    methods 
        function readTutorialNwbFileWithPynwb(testCase)

            % Retrieve all files generated by tutorial
            nwbFileNameList = testCase.listNwbFiles();
            for nwbFilename = nwbFileNameList
                try
                    try
                        io = py.pynwb.NWBHDF5IO(nwbFilename);
                        nwbObject = io.read();
                        testCase.verifyNotEmpty(nwbObject, 'The NWB file should not be empty.');
                        io.close()
                    catch ME
                        if strcmp(ME.identifier, 'MATLAB:undefinedVarOrClass') && ...
                                contains(ME.message, 'py.pynwb.NWBHDF5IO')

                            pythonExecutable = tests.util.getPythonPath();
                            cmd = sprintf('"%s" -B -m read_nwbfile_with_pynwb %s',...
                                            pythonExecutable, nwbFilename);
                            status = system(cmd);

                            if status ~= 0
                                error('Failed to read NWB file "%s" using pynwb', nwbFilename)
                            end
                        else
                            rethrow(ME)
                        end
                    end
                catch ME
                    error(ME.message)
                    %testCase.verifyFail(sprintf('Failed to read file %s with error: %s', nwbListing(i).name, ME.message));
                end
            end
        end
    
        function inspectTutorialFileWithNwbInspector(testCase)
            % Retrieve all files generated by tutorial
            nwbFileNameList = testCase.listNwbFiles();
            for nwbFilename = nwbFileNameList
                try
                    results = py.list(py.nwbinspector.inspect_nwbfile(nwbfile_path=nwbFilename));
                catch
                    [s,m] = system(sprintf('nwbinspector %s', nwbFilename))
                    disp(m)
                end
                
                if isempty(cell(results))
                    return
                end
                
                results = testCase.convertNwbInspectorResultsToStruct(results);
                T = struct2table(results); disp(T)

                for j = 1:numel(results)
                    testCase.verifyLessThan(results(j).importance, testCase.NwbInspectorSeverityLevel, ...
                        sprintf('Message: %s\nLocation: %s\n File: %s\n', ...
                        string(results(j).message), results(j).location, results(j).filepath))
                end
            end
        end
    end

    methods (Access = private)
        function nwbFileNames = listNwbFiles(testCase)
            nwbListing = dir('*.nwb');
            nwbFileNames = string( {nwbListing.name} );
            nwbFileNames = setdiff(nwbFileNames, testCase.SkippedFiles);
            assert(isrow(nwbFileNames), 'Expected output to be a row vector')
            if ~isscalar(nwbFileNames)
                if iscolumn(nwbFileNames)
                    nwbFileNames = transpose(nwbFileNames);
                end
            end
        end
    end

    methods (Static)
        function resultsOut = convertNwbInspectorResultsToStruct(resultsIn)
            CHECK_IGNORE = [...
                "check_image_series_external_file_valid", ...
                "check_regular_timestamps"
                ];
            
            C = cell(resultsIn);
        
            resultsOut = struct(...
                'importance', {}, ...
                'severity', {}, ...
                'location', {}, ...
                'filepath', {}, ...
                'check_name', {}, ...
                'ignore', {});
        
            for i = 1:numel(C)
                resultsOut(i).importance = double( py.getattr(C{i}.importance, 'value') );
                resultsOut(i).severity = double( py.getattr(C{i}.severity, 'value') );
        
                try
                    resultsOut(i).location =  string(C{i}.location);
                catch
                    resultsOut(i).location = "N/A";
                end
        
                resultsOut(i).message = string(C{i}.message);
                resultsOut(i).filepath = string(C{i}.file_path);
                resultsOut(i).check_name = string(C{i}.check_function_name);
                resultsOut(i).ignore = any(strcmp(CHECK_IGNORE, resultsOut(i).check_name));

                % Special case to ignore
                if resultsOut(i).location == "/acquisition/ExternalVideos" && ...
                        resultsOut(i).check_name == "check_timestamps_match_first_dimension"
                    resultsOut(i).ignore = true;
                end
            end
            resultsOut([resultsOut.ignore]) = [];
        end
    end
end

function tutorialNames = listTutorialFiles()
% listTutorialFiles - List names of all tutorial files (exclude skipped files)
    rootPath = getMatNwbRootDirectory();
    L = cat(1, ...
        dir(fullfile(rootPath, 'tutorials', '*.mlx')), ...
        dir(fullfile(rootPath, 'tutorials', '*.m')) ...
        );

    L( [L.isdir] ) = []; % Ignore folders
    tutorialNames = setdiff({L.name}, tests.unit.TutorialTest.SkippedTutorials);
end

function folderPath = getMatNwbRootDirectory()
    folderPath = fileparts(fileparts(fileparts(mfilename('fullpath'))));
end

function installNWBInspector()
    pythonInfo = pyenv;
    pythonExecutable = pythonInfo.Executable;
    systemCommand = sprintf("%s -m pip install %s", pythonExecutable, 'nwbinspector');
    [status, ~]  = system(systemCommand);
    systemCommand = sprintf("%s -m pip show nwbinspector | grep ^Location: | awk '{print $2}'", pythonExecutable);
    [~, nwbInspectorPath]  = system(systemCommand);
    checkAndUpdatePythonPath(strtrim(nwbInspectorPath), 'nwbinspector')
end

function checkAndUpdatePythonPath(installLocation, packageName)
    pyPath = py.sys.path();
    pyPath = string(pyPath);
    pyPath(pyPath=="") = [];

    if ~any( contains(pyPath, installLocation) )
        fprintf("Adding %s location to pythonpath\n", packageName)
        py.sys.path().append(installLocation) 
    end
    disp('py path')
    disp( py.sys.path() )
end
