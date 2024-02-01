function template = fillClass(name, namespace, processed, classprops, inherited)
    %name is the name of the scheme
    %namespace is the namespace context for this class

    %% PROCESSING
    class = processed(1);

    allProperties = keys(classprops);
    required = {};
    optional = {};
    readonly = {};
    defaults = {};
    dependent = {};
    hidden = {}; % special hidden properties for hard-coded workarounds
    %separate into readonly, required, and optional properties
    for iGroup = 1:length(allProperties)
        propertyName = allProperties{iGroup};
        prop = classprops(propertyName);

        isRequired = ischar(prop) || isa(prop, 'containers.Map') || isstruct(prop);
        isPropertyRequired = false;
        if isa(prop, 'matnwb.file.interface.HasProps')
            isPropertyRequired = false(size(prop));
            for iProp = 1:length(prop)
                p = prop(iProp);
                isPropertyRequired(iProp) = p.required;
            end
        end

        if isRequired || all(isPropertyRequired)
            required = [required {propertyName}];
        else
            optional = [optional {propertyName}];
        end

        if isa(prop, 'matnwb.file.Attribute')
            if prop.readonly
                readonly = [readonly {propertyName}];
            end

            if ~isempty(prop.value)
                defaults = [defaults {propertyName}];
            end

            if ~isempty(prop.dependent)
                %extract prefix
                parentName = strrep(propertyName, ['_' prop.name], '');
                parent = classprops(parentName);
                if ~parent.required
                    dependent = [dependent {propertyName}];
                end
            end

            if strcmp(namespace.name, 'hdmf_common') ...
                && strcmp(name, 'VectorData') ...
                && any(strcmp(prop.name, {'unit', 'sampling_rate', 'resolution'}))
                hidden{end+1} = propertyName;
            end
        end
    end
    nonInherited = setdiff(allProperties, inherited);
    readonly = intersect(readonly, nonInherited);
    exclusivePropertyGroups = union(readonly, hidden);
    required = setdiff(intersect(required, nonInherited), exclusivePropertyGroups);
    optional = setdiff(intersect(optional, nonInherited), exclusivePropertyGroups);

    %% CLASSDEF
    if length(processed) <= 1
        depnm = 'matnwb.types.untyped.MetaClass'; %WRITE
    else
        parentName = processed(2).type; %WRITE
        depnm = namespace.getFullClassName(parentName);
    end

    if isa(processed, 'matnwb.file.Group')
        classTag = 'matnwb.types.untyped.GroupClass';
    else
        classTag = 'matnwb.types.untyped.DatasetClass';
    end

    %% return classfile string
    classDefinitionHeader = [...
        'classdef ' name ' < ' depnm ' & ' classTag newline... %header, dependencies
        '% ' upper(name) ' ' class.doc]; %name, docstr
    hiddenAndReadonly = intersect(hidden, readonly);
    hidden = setdiff(hidden, hiddenAndReadonly);
    readonly = setdiff(readonly, hiddenAndReadonly);
    PropertyGroups = struct(...
        'Function', {...
        @()matnwb.file.fillProps(classprops, hiddenAndReadonly, 'PropertyAttributes', 'Hidden, SetAccess = protected') ...
        , @()matnwb.file.fillProps(classprops, hidden, 'PropertyAttributes', 'Hidden') ...
        , @()matnwb.file.fillProps(classprops, readonly, 'PropertyAttributes', 'SetAccess = protected') ...
        , @()matnwb.file.fillProps(classprops, required, 'IsRequired', true) ...
        , @()matnwb.file.fillProps(classprops, optional)...
        } ...
        , 'Separator', { ...
        '% HIDDEN READONLY PROPERTIES' ...
        , '% HIDDEN PROPERTIES' ...
        , '% READONLY PROPERTIES' ...
        , '% REQUIRED PROPERTIES' ...
        , '% OPTIONAL PROPERTIES' ...
        } ...
        );
    fullPropertyDefinition = '';
    for iGroup = 1:length(PropertyGroups)
        Group = PropertyGroups(iGroup);
        propertyDefinitionBody = Group.Function();
        if isempty(propertyDefinitionBody)
            continue;
        end
        fullPropertyDefinition = strjoin({...
            fullPropertyDefinition ...
            , Group.Separator ...
            , propertyDefinitionBody ...
            }, newline);
    end

    constructorBody = matnwb.file.fillConstructor(...
        name,...
        depnm,...
        defaults,... %all defaults, regardless of inheritance
        classprops,...
        namespace);
    setterFcns = matnwb.file.fillSetters(setdiff(nonInherited, union(readonly, hiddenAndReadonly)));
    validatorFcns = matnwb.file.fillValidators(allProperties, classprops, namespace);
    exporterFcns = matnwb.file.fillExport(nonInherited, class, depnm);
    methodBody = strjoin({constructorBody...
        '%% SETTERS' setterFcns...
        '%% VALIDATORS' validatorFcns...
        '%% EXPORT' exporterFcns}, newline);

    if strcmp(name, 'DynamicTable')
        methodBody = strjoin({methodBody, '%% TABLE METHODS', matnwb.file.fillDynamicTableMethods()}, newline);
    end

    fullMethodBody = strjoin({'methods' ...
        matnwb.file.addSpaces(methodBody, 4) 'end'}, newline);
    template = strjoin({classDefinitionHeader fullPropertyDefinition fullMethodBody 'end'}, ...
        [newline newline]);
end

