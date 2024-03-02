function tests = multipleConstrainedTest()
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
        '+matnwb', '+tests', '+unit', 'multipleConstrainedSchema', 'mcs.namespace.yaml');
    generateExtension(schemaPath, 'savedir', '.');
    rehash();
end

function testRoundabout(testCase)
    MultiSet = matnwb.types.mcs.MultiSetContainer();
    MultiSet.something.set('A', matnwb.types.mcs.ArbitraryTypeA());
    MultiSet.something.set('B', matnwb.types.mcs.ArbitraryTypeB());
    MultiSet.something.set('Data', matnwb.types.mcs.DatasetType());
    nwbExpected = NwbFile(...
        'identifier', 'MCS', ...
        'session_description', 'multiple constrained schema testing', ...
        'session_start_time', datetime());
    nwbExpected.acquisition.set('multiset', MultiSet);
    nwbExport(nwbExpected, 'testmcs.nwb');

    matnwb.tests.util.verifyContainerEqual(testCase, nwbRead('testmcs.nwb', 'ignorecache'), nwbExpected);
end