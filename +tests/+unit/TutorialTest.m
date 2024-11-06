classdef TutorialTest <  matlab.unittest.TestCase
% TutorialTest - Unit test for testing the matnwb tutorials.
%
%   This test will test most tutorial files (while skipping tutorials with 
%   dependencies) If the tutorial creates an nwb file, the test will also try 
%   to open this with pynwb and run nwbinspector on the file.

%   Notes: 
%   - Requires MATLAB 2019b or later to run py.* commands.
%
%   - pynwb must be installed in the python environment returned by pyenv()
%
%   - Running NWBInspector as a Python package within MATLAB on GitHub runners 
%     currently encounters compatibility issues between the HDF5 library and 
%     h5py. As a workaround in this test, the CLI interface is used to run 
%     NWBInspector and the results are manually parsed. This approach is not 
%     ideal, and hopefully can be improved upon.

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
    
    properties (Access = private)
        NWBInspectorMode = "python"
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
            
            % Note: The following seems to not be working on the azure
            % pipeline / github runner.
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

            % Todo: More explicitly check if this is run on a github runner
            % or not?
            try
                py.nwbinspector.is_module_installed('nwbinspector')
            catch
                testCase.NWBInspectorMode = "CLI";
            end

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
                    if testCase.NWBInspectorMode == "python"
                        io = py.pynwb.NWBHDF5IO(nwbFilename);
                        nwbObject = io.read();
                        testCase.verifyNotEmpty(nwbObject, 'The NWB file should not be empty.');
                        io.close()
                    elseif testCase.NWBInspectorMode == "CLI"
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
                end
            end
        end
    
        function inspectTutorialFileWithNwbInspector(testCase)
            % Retrieve all files generated by tutorial
            nwbFileNameList = testCase.listNwbFiles();
            for nwbFilename = nwbFileNameList
                if testCase.NWBInspectorMode == "python"
                    results = py.list(py.nwbinspector.inspect_nwbfile(nwbfile_path=nwbFilename));
                    results = testCase.convertNwbInspectorResultsToStruct(results);
                elseif testCase.NWBInspectorMode == "CLI"
                    [~, m] = system(sprintf('nwbinspector %s --levels importance', nwbFilename));
                    results = testCase.parseInspectorTextOutput(m);
                end
                
                if isempty(results)
                    return
                end

                results = testCase.filterResults(results);
                % T = struct2table(results); disp(T)

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
            
            resultsOut = tests.unit.TutorialTest.getEmptyNwbInspectorResultStruct();
                    
            C = cell(resultsIn);
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
            end
        end
    
        function resultsOut = parseInspectorTextOutput(systemCommandOutput)
            resultsOut = tests.unit.TutorialTest.getEmptyNwbInspectorResultStruct();
            
            importanceLevels = containers.Map(...
                ["BEST_PRACTICE_SUGGESTION", ...
                "BEST_PRACTICE_VIOLATION", ...
                "CRITICAL", ...
                "PYNWB_VALIDATION", ...
                "ERROR"], 0:4 );

            lines = splitlines(systemCommandOutput);
            count = 0;
            for i = 1:numel(lines)
                % Example line:
                % '.0  Importance.BEST_PRACTICE_VIOLATION: behavior_tutorial.nwb - check_regular_timestamps - 'SpatialSeries' object at location '/processing/behavior/Position/SpatialSeries'
                %                                        ^2                      ^1                         ^2                        ^ ^ ^ 3 
                %      [-----------importance------------]  [------filepath------]  [------check_name------]                                                                           [-----------------location----------------]   
                % Splitting and components is exemplified above. 
                
                if ~isempty(regexp( lines{i}, '^\.\d{1}', 'once' ) )
                    count = count+1;
                    % Split line into separate components
                    splitLine = strsplit(lines{i}, ':');
                    splitLine = [...
                        strsplit(splitLine{1}, ' '), ...
                        strsplit(splitLine{2}, '-') ...
                        ];
            
                    resultsOut(count).importance = importanceLevels( extractAfter(splitLine{2}, 'Importance.') );
                    resultsOut(count).filepath = string(strtrim( splitLine{3} ));
                    resultsOut(count).check_name = string(strtrim(splitLine{4} ));
                    try
                        locationInfo = strsplit(splitLine{end}, 'at location');
                        resultsOut(count).location = string(strtrim(eval(locationInfo{2})));
                    catch 
                        resultsOut(count).location = 'N/A';
                    end
                    resultsOut(count).message = string(strtrim(lines{i+1}));
                end
            end
        end

        function emptyResults = getEmptyNwbInspectorResultStruct()
            emptyResults = struct(...
                'importance', {}, ...
                'severity', {}, ...
                'location', {}, ...
                'filepath', {}, ...
                'check_name', {}, ...
                'ignore', {});
        end
    
        function resultsOut = filterResults(resultsIn)
            CHECK_IGNORE = [...
                "check_image_series_external_file_valid", ...
                "check_regular_timestamps"
                ];
            
            for i = 1:numel(resultsIn)
                resultsIn(i).ignore = any(strcmp(CHECK_IGNORE, resultsIn(i).check_name));
            
                % Special case to ignore
                if resultsIn(i).location == "/acquisition/ExternalVideos" && ...
                        resultsIn(i).check_name == "check_timestamps_match_first_dimension"
                    resultsIn(i).ignore = true;
                end
            end
            resultsOut = resultsIn;
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
