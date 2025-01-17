classdef NwbFile < matnwb.types.core.NWBFile
    % NWBFILE Root object representing data read from an NWB file.
    %
    % Requires that core and extension NWB types have been generated
    % and reside in a 'types' package on the matlab path.
    %
    % Example. Construct an object from scratch for export:
    %    nwb = NwbFile;
    %    nwb.epochs = types.core.Epochs;
    %    nwbExport(nwb, 'epoch.nwb');
    %
    % See also NWBREAD, GENERATECORE, GENERATEEXTENSION

    methods
        function obj = NwbFile(varargin)
            obj = obj@matnwb.types.core.NWBFile(varargin{:});
            if strcmp(class(obj), 'NwbFile')
                cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
                matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
            end
        end

        function export(obj, filename)
            %add to file create date
            
            if isa(obj.file_create_date, 'matnwb.types.untyped.DataStub')
                obj.file_create_date = obj.file_create_date.load();
            end

            current_time = {datetime('now', 'TimeZone', 'local')};
            if isempty(obj.file_create_date)
                obj.file_create_date = current_time;
            elseif iscell(obj.file_create_date)
                obj.file_create_date(end+1) = current_time;
            else
                % obj.file_create_date could be a datetime array
                obj.file_create_date = num2cell(obj.file_create_date);
                obj.file_create_date(end+1) = current_time;
            end

            %equate reference time to session_start_time if empty
            if isempty(obj.timestamps_reference_time)
                obj.timestamps_reference_time = obj.session_start_time;
            end

            try
                output_file_id = H5F.create(filename);
                isEditingFile = false;
            catch ME % if file exists, open and edit
                if verLessThan('matlab', '9.9') % < 2020b
                    isEditingFile = strcmp(ME.identifier, 'MATLAB:imagesci:hdf5lib:libraryError')...
                        && contains(ME.message, '''File exists''');
                else
                    isEditingFile = strcmp(ME.identifier, 'MATLAB:imagesci:hdf5io:resourceAlreadyExists');
                end

                if isEditingFile
                    output_file_id = H5F.open(filename, 'H5F_ACC_RDWR', 'H5P_DEFAULT');
                else
                    rethrow(ME);
                end
            end

            try
                obj.embedSpecifications(output_file_id);
                refs = export@matnwb.types.core.NWBFile(obj, output_file_id, '/', {});
                obj.resolveReferences(output_file_id, refs);
                H5F.close(output_file_id);
            catch ME
                obj.file_create_date(end) = [];
                H5F.close(output_file_id);
                if ~isEditingFile
                    delete(filename);
                end
                rethrow(ME);
            end
        end

        function o = resolve(obj, path)
            if ischar(path)
                path = {path};
            end
            o = cell(size(path));
            for i = 1:numel(path)
                o{i} = matnwb.io.resolvePath(obj, path{i});
            end
            if isscalar(o)
                o = o{1};
            end
        end

        function objectMap = searchFor(obj, typename, varargin)
            % Searches this NwbFile object for a given typename
            % Including the full namespace is optional.
            % WARNING: The returned paths are resolvable but do not necessarily
            % indicate a real HDF5 path. Their only function is to be resolvable.
            objectMap = searchProperties(...
                containers.Map,...
                obj,...
                '',...
                typename,...
                varargin{:});
        end
    end

    %% PRIVATE
    methods(Access=private)
        function resolveReferences(obj, fid, references)
            while ~isempty(references)
                resolved = false(size(references));
                for iRef = 1:length(references)
                    refSource = references{iRef};
                    sourceObj = obj.resolve(refSource);
                    unresolvedRefs = sourceObj.export(fid, refSource, {});
                    exportSuccess = isempty(unresolvedRefs);
                    resolved(iRef) = exportSuccess;
                end

                if ~any(resolved)
                    errorFormat = ['object(s) could not be created:\n%s\n\nThe '...
                        'listed object(s) above contain an ObjectView, '...
                        'RegionView , or SoftLink object that has failed to resolve itself. '...
                        'Please check for any references that were not assigned to the root '...
                        ' NwbFile or if any of the above paths are incorrect.'];
                    unresolvedRefs = strjoin(references, newline);
                    error('NWB:NwbFile:UnresolvedReferences',...
                        errorFormat, matnwb.file.addSpaces(unresolvedRefs, 4));
                end

                references(resolved) = [];
            end
        end

        function embedSpecifications(~, fid)
            try
                attrId = H5A.open(fid, '/.specloc');
                specLocation = H5R.get_name(fid, 'H5R_OBJECT', H5A.read(attrId));
                H5A.close(attrId);
            catch
                specLocation = '/specifications';
                matnwb.io.writeGroup(fid, specLocation);
                specView = matnwb.types.untyped.ObjectView(specLocation);
                matnwb.io.writeAttribute(fid, '/.specloc', specView);
            end

            JsonData = matnwb.schemes.exportJson();
            for iJson = 1:length(JsonData)
                JsonDatum = JsonData(iJson);
                schemaNamespaceLocation = strjoin({specLocation, JsonDatum.name}, '/');
                namespaceExists = matnwb.io.writeGroup(fid, schemaNamespaceLocation);
                if namespaceExists
                    namespaceGroupId = H5G.open(fid, schemaNamespaceLocation);
                    names = getVersionNames(namespaceGroupId);
                    H5G.close(namespaceGroupId);
                    for iNames = 1:length(names)
                        H5L.delete(fid, [schemaNamespaceLocation '/' names{iNames}],...
                            'H5P_DEFAULT');
                    end
                end
                schemaLocation =...
                    strjoin({schemaNamespaceLocation, JsonDatum.version}, '/');
                matnwb.io.writeGroup(fid, schemaLocation);
                Json = JsonDatum.json;
                schemeNames = keys(Json);
                for iScheme = 1:length(schemeNames)
                    name = schemeNames{iScheme};
                    path = [schemaLocation '/' name];
                    matnwb.io.writeDataset(fid, path, Json(name));
                end
            end
        end
    end
end

function versionNames = getVersionNames(namespaceGroupId)
    [~, ~, versionNames] = H5L.iterate(namespaceGroupId,...
        'H5_INDEX_NAME', 'H5_ITER_NATIVE',...
        0, @removeGroups, {});
    function [status, versionNames] = removeGroups(~, name, versionNames)
        versionNames{end+1} = name;
        status = 0;
    end
end

function tf = metaHasType(mc, typeSuffix)
    assert(isa(mc, 'meta.class'));
    tf = false;
    if contains(mc.Name, typeSuffix, 'IgnoreCase', true)
        tf = true;
        return;
    end

    for i = 1:length(mc.SuperclassList)
        sc = mc.SuperclassList(i);
        if metaHasType(sc, typeSuffix)
            tf = true;
            return;
        end
    end
end

function pathToObjectMap = searchProperties(...
        pathToObjectMap,...
        obj,...
        basePath,...
        typename,...
        varargin)
    assert(all(iscellstr(varargin)),...
        'NWB:NwbFile:SearchProperties:InvalidVariableArguments',...
        'Optional keywords for searchFor must be char arrays.');
    shouldSearchSuperClasses = any(strcmpi(varargin, 'includeSubClasses'));

    if isa(obj, 'matnwb.types.untyped.MetaClass')
        propertyNames = properties(obj);
        getProperty = @(x, prop) x.(prop);
    elseif isa(obj, 'matnwb.types.untyped.Set')
        propertyNames = obj.keys();
        getProperty = @(x, prop) x.get(prop);
    elseif isa(obj, 'matnwb.types.untyped.Anon')
        propertyNames = {obj.name};
        getProperty = @(x, prop) x.value;
    else
        error('NWB:NwbFile:SearchProperties:InvalidType',...
            'Invalid object type passed %s', class(obj));
    end

    searchTypename = @(obj, typename) contains(class(obj), typename, 'IgnoreCase', true);
    if shouldSearchSuperClasses
        searchTypename = @(obj, typename) metaHasType(metaclass(obj), typename);
    end

    for i = 1:length(propertyNames)
        propName = propertyNames{i};
        propValue = getProperty(obj, propName);
        fullPath = [basePath '/' propName];
        if searchTypename(propValue, typename)
            pathToObjectMap(fullPath) = propValue;
        end

        if isa(propValue, 'matnwb.types.untyped.GroupClass')...
                || isa(propValue, 'matnwb.types.untyped.Set')...
                || isa(propValue, 'matnwb.types.untyped.Anon')
            % recursible (even if there is a match!)
            searchProperties(pathToObjectMap, propValue, fullPath, typename, varargin{:});
        end
    end
end