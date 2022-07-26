function tests = tutorialTest()
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
rootPath = fullfile(fileparts(mfilename('fullpath')), '..', '..');
testCase.applyFixture(matlab.unittest.fixtures.PathFixture(rootPath));
tutorialPath = fullfile(rootPath, 'tutorials');
testCase.TestData.path = tutorialPath;
testCase.TestData.listing = dir(tutorialPath);
end

function testTutorials(testCase)
skippedTutorials = {...
    'basicUsage.mlx', ...
    'convertTrials.m', ...
    'dynamically_loaded_filters.mlx'};
for i = 1:length(testCase.TestData.listing)
    listing = testCase.TestData.listing(i);
    if listing.isdir || any(strcmp(skippedTutorials, listing.name))
        continue;
    end
    run(fullfile(listing.folder, listing.name));
end
end