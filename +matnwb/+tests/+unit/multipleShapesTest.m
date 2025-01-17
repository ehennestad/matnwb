function tests = multipleShapesTest()
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
    '+matnwb', '+tests', '+unit', 'multipleShapesSchema', 'mss.namespace.yaml');
generateExtension(schemaPath, 'savedir', '.');
rehash();
end

function testMultipleShapesDataset(testCase)
msd = matnwb.types.mss.MultiShapeDataset('data', rand(3, 1));
msd.data = rand(1, 5, 7);
roundabout(testCase, msd);
end

function testNullShapeDataset(testCase)
nsd = matnwb.types.mss.NullShapeDataset;
randiMax = intmax('int8') - 1;
for i=1:100
    %test validation
    nsd.data = rand(randi(randiMax) + 1, 3);
end
roundabout(testCase, nsd);
end

function testMultipleNullShapesDataset(testCase)
mnsd = matnwb.types.mss.MultiNullShapeDataset;
randiMax = intmax('int8');
for i=1:100
    if rand() > 0.5
        mnsd.data = rand(randi(randiMax), 1);
    else
        mnsd.data = rand(randi(randiMax), randi(randiMax));
    end
end
roundabout(testCase, mnsd);
end

function testInheritedDtypeDataset(testCase)
nid = matnwb.types.mss.NarrowInheritedDataset;
nid.data = 'Inherited Dtype Dataset';
roundabout(testCase, nid);
end

%% Convenience
function roundabout(testCase, dataset)
nwb = NwbFile('identifier', 'MSS', 'session_description', 'test',...
    'session_start_time', '2017-04-15T12:00:00.000000-08:00',...
    'timestamps_reference_time', '2017-04-15T12:00:00.000000-08:00');
wrapper = matnwb.types.mss.MultiShapeWrapper('shaped_data', dataset);
nwb.acquisition.set('wrapper', wrapper);
filename = 'multipleShapesTest.nwb';
nwbExport(nwb, filename);
matnwb.tests.util.verifyContainerEqual(testCase, nwbRead(filename, 'ignorecache'), nwb);
end