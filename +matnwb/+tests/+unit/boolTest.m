function tests = boolTest()
    tests = functiontests(localfunctions);
end

function setupOnce(testCase)
    rootPath = fullfile(fileparts(mfilename('fullpath')), '..', '..', '..');
    testCase.applyFixture(matlab.unittest.fixtures.PathFixture(rootPath));
end

function setup(testCase)
    testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture);
    generateCore('savedir', '.');
    schemaPath = fullfile(matnwb.misc.getMatnwbDir(),...
        '+matnwb', '+tests', '+unit', 'boolSchema', 'bool.namespace.yaml');
    generateExtension(schemaPath, 'savedir', '.');
    rehash();
end

function testIo(testCase)
    nwb = NwbFile(...
        'identifier', 'BOOL',...
        'session_description', 'test bool',...
        'session_start_time', datetime());
    boolContainer = matnwb.types.bool.BoolContainer(...
        'data', logical(randi([0,1], 100, 1)), ...
        'attribute', false);
    scalarBoolContainer = matnwb.types.bool.BoolContainer(...
        'data', false, ...
        'attribute', true);
    nwb.acquisition.set('bool', boolContainer);
    nwb.acquisition.set('scalarbool', scalarBoolContainer);
    nwb.export('test.nwb');
    nwbActual = nwbRead('test.nwb', 'ignorecache');
    matnwb.tests.util.verifyContainerEqual(testCase, nwbActual, nwb);
end
