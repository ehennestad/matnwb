function tests = regionViewTest()
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
rootPath = fullfile(fileparts(mfilename('fullpath')), '..', '..');
testCase.applyFixture(matlab.unittest.fixtures.PathFixture(rootPath));
end

function setup(testCase)
testCase.applyFixture(matlab.unittest.fixtures.WorkingFolderFixture);
generateCore('savedir', '.');
schemaPath = fullfile(matnwb.misc.getMatnwbDir(),...
    '+tests', '+unit', 'regionReferenceSchema', 'rrs.namespace.yaml');
generateExtension(schemaPath, 'savedir', '.');
rehash();
end

function testRegionViewIo(testCase)
nwb = NwbFile(...
    'identifier', 'REGIONREF',...
    'session_description', 'region ref test',...
    'session_start_time', datetime());

rcContainer = types.rrs.RefContainer('data', types.rrs.RefData('data', rand(10, 10, 10, 10, 10)));
nwb.acquisition.set('refdata', rcContainer);

for i = 1:100
    rcAttrRef = matnwb.types.untyped.RegionView(...
        rcContainer.data,...
        getRandInd(10),...
        getRandInd(10),...
        getRandInd(10),...
        getRandInd(10),...
        getRandInd(10));
    rcDataRef = matnwb.types.untyped.RegionView(...
        rcContainer.data,...
        1:getRandInd(10),...
        1:getRandInd(10),...
        1:getRandInd(10),...
        1:getRandInd(10),...
        1:getRandInd(10));
    nwb.acquisition.set(sprintf('ref%d', i),...
        types.rrs.ContainerReference(...
        'attribute_regref', rcAttrRef,...
        'data_regref', rcDataRef));
end
nwb.export('test.nwb');
nwbActual = nwbRead('test.nwb', 'ignorecache');
matnwb.tests.util.verifyContainerEqual(testCase, nwbActual, nwb);

for i = 1:100
    refName = sprintf('ref%d', i);
    Reference = nwb.acquisition.get(refName);
    testCase.verifyEqual(Reference.attribute_regref.refresh(nwb),...
        Reference.attribute_regref.refresh(nwbActual));
end
end

function ind = getRandInd(indEnd)
ind = round(rand() * (indEnd - 1)) + 1;
end