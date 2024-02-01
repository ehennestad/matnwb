function nwbClearGenerated()
    %% NWBCLEARGENERATED clears generated class files.
    nwbDir = matnwb.misc.getMatnwbDir();
    typesPath = fullfile(nwbDir, '+matnwb', '+types');
    listing = dir(typesPath);
    moduleNames = setdiff({listing.name}, {'+untyped', '+util', '.', '..'});
    generatedPaths = fullfile(typesPath, moduleNames);
    for i=1:length(generatedPaths)
        rmdir(generatedPaths{i}, 's');
    end
end