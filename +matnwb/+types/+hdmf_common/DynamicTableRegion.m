classdef DynamicTableRegion < matnwb.types.hdmf_common.VectorData & matnwb.types.untyped.DatasetClass
% DYNAMICTABLEREGION DynamicTableRegion provides a link from one table to an index or region of another. The `table` attribute is a link to another `DynamicTable`, indicating which table is referenced, and the data is int(s) indicating the row(s) (0-indexed) of the target array. `DynamicTableRegion`s can be used to associate rows with repeated meta-data without data duplication. They can also be used to create hierarchical relationships between multiple `DynamicTable`s. `DynamicTableRegion` objects may be paired with a `VectorIndex` object to create ragged references, so a single cell of a `DynamicTable` can reference many rows of another `DynamicTable`.


% OPTIONAL PROPERTIES
properties
    table; %  (Object Reference to DynamicTable) Reference to the DynamicTable object that this region applies to.
end

methods
    function obj = DynamicTableRegion(varargin)
        % DYNAMICTABLEREGION Constructor for DynamicTableRegion
        obj = obj@matnwb.types.hdmf_common.VectorData(varargin{:});
        
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        addParameter(p, 'data',[]);
        addParameter(p, 'description',[]);
        addParameter(p, 'table',[]);
        matnwb.misc.parseSkipInvalidName(p, varargin);
        obj.data = p.Results.data;
        obj.description = p.Results.description;
        obj.table = p.Results.table;
        if strcmp(class(obj), 'matnwb.matnwb.types.hdmf_common.DynamicTableRegion')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
        end
    end
    %% SETTERS
    function set.table(obj, val)
        obj.table = obj.validate_table(val);
    end
    %% VALIDATORS
    
    function val = validate_data(obj, val)
        val = matnwb.types.util.checkDtype('data', 'int8', val);
    end
    function val = validate_description(obj, val)
        val = matnwb.types.util.checkDtype('description', 'char', val);
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
        validshapes = {[1]};
        matnwb.types.util.checkDims(valsz, validshapes);
    end
    function val = validate_table(obj, val)
        % Reference to type `DynamicTable`
        val = matnwb.types.util.checkDtype('table', 'matnwb.types.untyped.ObjectView', val);
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
        validshapes = {[1]};
        matnwb.types.util.checkDims(valsz, validshapes);
    end
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@matnwb.types.hdmf_common.VectorData(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
        matnwb.io.writeAttribute(fid, [fullpath '/table'], obj.table);
    end
end

end