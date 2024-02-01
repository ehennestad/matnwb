classdef DynamicTable < matnwb.types.hdmf_common.Container & matnwb.types.untyped.GroupClass
% DYNAMICTABLE A group containing multiple datasets that are aligned on the first dimension (Currently, this requirement if left up to APIs to check and enforce). These datasets represent different columns in the table. Apart from a column that contains unique identifiers for each row, there are no other required datasets. Users are free to add any number of custom VectorData objects (columns) here. DynamicTable also supports ragged array columns, where each element can be of a different size. To add a ragged array column, use a VectorIndex type to index the corresponding VectorData type. See documentation for VectorData and VectorIndex for more details. Unlike a compound data type, which is analogous to storing an array-of-structs, a DynamicTable can be thought of as a struct-of-arrays. This provides an alternative structure to choose from when optimizing storage for anticipated access patterns. Additionally, this type provides a way of creating a table without having to define a compound type up front. Although this convenience may be attractive, users should think carefully about how data will be accessed. DynamicTable is more appropriate for column-centric access, whereas a dataset with a compound type would be more appropriate for row-centric access. Finally, data size should also be taken into account. For small tables, performance loss may be an acceptable trade-off for the flexibility of a DynamicTable.


% REQUIRED PROPERTIES
properties
    id; % REQUIRED (ElementIdentifiers) Array of unique identifiers for the rows of this dynamic table.
end
% OPTIONAL PROPERTIES
properties
    colnames; %  (char) The names of the columns in this table. This should be used to specify an order to the columns.
    description; %  (char) Description of what is in this dynamic table.
    vectordata; %  (VectorData) Vector columns, including index columns, of this dynamic table.
end

methods
    function obj = DynamicTable(varargin)
        % DYNAMICTABLE Constructor for DynamicTable
        obj = obj@matnwb.types.hdmf_common.Container(varargin{:});
        [obj.vectordata, ivarargin] = matnwb.types.util.parseConstrained(obj,'vectordata', 'matnwb.types.hdmf_common.VectorData', varargin{:});
        varargin(ivarargin) = [];
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        addParameter(p, 'colnames',[]);
        addParameter(p, 'description',[]);
        addParameter(p, 'id',[]);
        matnwb.misc.parseSkipInvalidName(p, varargin);
        obj.colnames = p.Results.colnames;
        obj.description = p.Results.description;
        obj.id = p.Results.id;
        if strcmp(class(obj), 'matnwb.types.hdmf_common.DynamicTable')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
        end
    end
    %% SETTERS
    function set.colnames(obj, val)
        obj.colnames = obj.validate_colnames(val);
    end
    function set.description(obj, val)
        obj.description = obj.validate_description(val);
    end
    function set.id(obj, val)
        obj.id = obj.validate_id(val);
    end
    function set.vectordata(obj, val)
        obj.vectordata = obj.validate_vectordata(val);
    end
    %% VALIDATORS
    
    function val = validate_colnames(obj, val)
        val = matnwb.types.util.checkDtype('colnames', 'char', val);
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
    function val = validate_id(obj, val)
        val = matnwb.types.util.checkDtype('id', 'matnwb.types.hdmf_common.ElementIdentifiers', val);
    end
    function val = validate_vectordata(obj, val)
        constrained = { 'matnwb.types.hdmf_common.VectorData' };
        matnwb.types.util.checkSet('vectordata', struct(), constrained, val);
    end
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@matnwb.types.hdmf_common.Container(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
        matnwb.io.writeAttribute(fid, [fullpath '/colnames'], obj.colnames, 'forceArray');
        matnwb.io.writeAttribute(fid, [fullpath '/description'], obj.description);
        refs = obj.id.export(fid, [fullpath '/id'], refs);
        if ~isempty(obj.vectordata)
            refs = obj.vectordata.export(fid, fullpath, refs);
        end
    end
    %% TABLE METHODS
    function addRow(obj, varargin)
        matnwb.types.util.dynamictable.addRow(obj, varargin{:});
    end
    
    function addColumn(obj, varargin)
        matnwb.types.util.dynamictable.addColumn(obj, varargin{:});
    end
    
    function row = getRow(obj, id, varargin)
        row = matnwb.types.util.dynamictable.getRow(obj, id, varargin{:});
    end
    
    function table = toTable(obj, varargin)
        table = matnwb.types.util.dynamictable.nwbToTable(obj, varargin{:});
    end
    
    function clear(obj)
        matnwb.types.util.dynamictable.clear(obj);
    end
end

end