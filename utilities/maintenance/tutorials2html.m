function tutorials2html()

    IGNORE = ["formatStruct"];

    rootPath = matnwb.misc.getMatnwbDir();
    
    L = dir(fullfile(rootPath, 'tutorials'));

    for i = 1:numel(L)
        [~, fileName, fileExtension] = fileparts(L(i).name);

        if ~(strcmp(fileExtension, '.m') || strcmp(fileExtension, '.mlx'))
            continue
        end

        if any(strcmp(IGNORE, fileName))
            continue
        end

        % Build export path and export to html:
        savePath = fullfile(rootPath, 'tutorials', 'html', [fileName, '.html']);
        switch fileExtension
            case '.mlx'
                export(fullfile(L(i).folder, L(i).name), savePath);
            case '.m'
                continue
                publish(fullfile(L(i).folder, L(i).name));
        end
        fprintf('Exported "%s"\n', L(i).name)
    end
end
