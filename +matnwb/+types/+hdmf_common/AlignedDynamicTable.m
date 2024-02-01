classdef AlignedDynamicTable < matnwb.types.hdmf_common.DynamicTable & matnwb.types.untyped.GroupClass
% ALIGNEDDYNAMICTABLE DynamicTable container that supports storing a collection of sub-tables. Each sub-table is a DynamicTable itself that is aligned with the main table by row index. I.e., all DynamicTables stored in this group MUST have the same number of rows. This type effectively defines a 2-level table in which the main data is stored in the main table implemented by this type and additional columns of the table are grouped into categories, with each category being represented by a separate DynamicTable stored within the group.


% OPTIONAL PROPERTIES
properties
    categories; %  (char) The names of the categories in this AlignedDynamicTable. Each category is represented by one DynamicTable stored in the parent group. This attribute should be used to specify an order of categories and the category names must match the names of the corresponding DynamicTable in the group.
    dynamictable; %  (DynamicTable) A DynamicTable representing a particular category for columns in the AlignedDynamicTable parent container. The table MUST be aligned with (i.e., have the same number of rows) as all other DynamicTables stored in the AlignedDynamicTable parent container. The name of the category is given by the name of the DynamicTable and its description by the description attribute of the DynamicTable.
end

methods
    function obj = AlignedDynamicTable(varargin)
        % ALIGNEDDYNAMICTABLE Constructor for AlignedDynamicTable
        obj = obj@matnwb.types.hdmf_common.DynamicTable(varargin{:});
        [obj.dynamictable, ivarargin] = matnwb.types.util.parseConstrained(obj,'dynamictable', 'matnwb.types.hdmf_common.DynamicTable', varargin{:});
        varargin(ivarargin) = [];
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        addParameter(p, 'categories',[]);
        matnwb.misc.parseSkipInvalidName(p, varargin);
        obj.categories = p.Results.categories;
        if strcmp(class(obj), 'matnwb.types.hdmf_common.AlignedDynamicTable')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
        end
        if strcmp(class(obj), 'matnwb.types.hdmf_common.AlignedDynamicTable')
            matnwb.types.util.dynamictable.checkConfig(obj);
        end
    end
    %% SETTERS
    function set.categories(obj, val)
        obj.categories = obj.validate_categories(val);
    end
    function set.dynamictable(obj, val)
        obj.dynamictable = obj.validate_dynamictable(val);
    end
    %% VALIDATORS
    
    function val = validate_categories(obj, val)
        val = matnwb.types.util.checkDtype('categories', 'char', val);
        if isa(val, 'matnwb.types.untyped.DataStub')
            if 1 == val.ndims
                valsz = [val.dims 1];
            else
                valsz = val.dims;
            end
        elseif istable(val)
            valsz = [height(val) 1];
        elseif ischar(val)
            valsz = [size(val, 1) 1];
        else
            valsz = size(val);
        end
        validshapes = {[Inf]};
        matnwb.types.util.checkDims(valsz, validshapes);
    end
    function val = validate_dynamictable(obj, val)
        namedprops = struct();
        constrained = {'matnwb.types.hdmf_common.DynamicTable'};
        matnwb.types.util.checkSet('dynamictable', namedprops, constrained, val);
    end
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@matnwb.types.hdmf_common.DynamicTable(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
        matnwb.io.writeAttribute(fid, [fullpath '/categories'], obj.categories, 'forceArray');
        if ~isempty(obj.dynamictable)
            refs = obj.dynamictable.export(fid, fullpath, refs);
        end
    end
end

end