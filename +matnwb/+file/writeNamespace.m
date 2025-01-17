function writeNamespace(namespaceName, saveDir)
%check/load dependency namespaces
Namespace = matnwb.schemes.loadNamespace(namespaceName, saveDir);

classFileDir = fullfile(saveDir, '+matnwb', '+types', ['+' matnwb.misc.str2validName(Namespace.name)]);

if 7 ~= exist(classFileDir, 'dir')
    mkdir(classFileDir);
end

classes = keys(Namespace.registry);
pregenerated = containers.Map; %generated nodes and props for faster dependency resolution
for i=1:length(classes)
    className = classes{i};
    [processed, classprops, inherited] = matnwb.file.processClass(className, Namespace, pregenerated);
    
    if isempty(processed)
        continue;
    end
    
    fid = fopen(fullfile(classFileDir, [className '.m']), 'W');
    try
        fwrite(fid, matnwb.file.fillClass(className, Namespace, processed, ...
            classprops, inherited), 'char');
    catch ME
        fclose(fid);
        rethrow(ME)
    end
    fclose(fid);
end
end