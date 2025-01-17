function tests = smokeTest()
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
rootPath = fullfile(fileparts(mfilename('fullpath')), '..', '..', '..');
testCase.applyFixture(matlab.unittest.fixtures.PathFixture(rootPath));
end

function setup(testCase)
testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture);
generateCore('savedir', '.');
rehash();
end

%TODO rewrite namespace instantiation check
function testSmokeInstantiateCore(testCase)
% classes = fieldnames(testCase.TestData.registry);
% for i = 1:numel(classes)
%     c = classes{i};
%     try
%         types.(c);
%     catch e
%         testCase.verifyFail(['Could not instantiate types.' c ' : ' e.message]);
%     end
% end
end

function testSmokeReadWrite(testCase)
epochs = matnwb.types.core.TimeIntervals(...
    'colnames', {'start_time' 'stop_time'} .',...
    'id', matnwb.types.hdmf_common.ElementIdentifiers('data', 1),...
    'description', 'test TimeIntervals',...
    'start_time', matnwb.types.hdmf_common.VectorData('data', 0, 'description', 'start time'),...
    'stop_time', matnwb.types.hdmf_common.VectorData('data', 1, 'description', 'stop time'));
file = NwbFile('identifier', 'st', 'session_description', 'smokeTest', ...
    'session_start_time', datetime, 'intervals_epochs', epochs,...
    'timestamps_reference_time', datetime);

nwbExport(file, 'epoch.nwb');
readFile = nwbRead('epoch.nwb', 'ignorecache');
% testCase.verifyEqual(testCase, readFile, file, ...
%     'Could not write and then read a simple file');
matnwb.tests.util.verifyContainerEqual(testCase, readFile, file);
end