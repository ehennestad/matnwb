classdef CSRMatrix < matnwb.types.hdmf_common.Container & matnwb.types.untyped.GroupClass
% CSRMATRIX A compressed sparse row matrix. Data are stored in the standard CSR format, where column indices for row i are stored in indices[indptr[i]:indptr[i+1]] and their corresponding values are stored in data[indptr[i]:indptr[i+1]].


% REQUIRED PROPERTIES
properties
    data; % REQUIRED (any) The non-zero values in the matrix.
    indices; % REQUIRED (uint) The column indices.
    indptr; % REQUIRED (uint) The row index pointer.
end
% OPTIONAL PROPERTIES
properties
    shape; %  (uint) The shape (number of rows, number of columns) of this sparse matrix.
end

methods
    function obj = CSRMatrix(varargin)
        % CSRMATRIX Constructor for CSRMatrix
        obj = obj@matnwb.types.hdmf_common.Container(varargin{:});
        
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        addParameter(p, 'data',[]);
        addParameter(p, 'indices',[]);
        addParameter(p, 'indptr',[]);
        addParameter(p, 'shape',[]);
        matnwb.misc.parseSkipInvalidName(p, varargin);
        obj.data = p.Results.data;
        obj.indices = p.Results.indices;
        obj.indptr = p.Results.indptr;
        obj.shape = p.Results.shape;
        if strcmp(class(obj), 'matnwb.types.hdmf_common.CSRMatrix')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
        end
    end
    %% SETTERS
    function set.data(obj, val)
        obj.data = obj.validate_data(val);
    end
    function set.indices(obj, val)
        obj.indices = obj.validate_indices(val);
    end
    function set.indptr(obj, val)
        obj.indptr = obj.validate_indptr(val);
    end
    function set.shape(obj, val)
        obj.shape = obj.validate_shape(val);
    end
    %% VALIDATORS
    
    function val = validate_data(obj, val)
    
    end
    function val = validate_indices(obj, val)
        val = matnwb.types.util.checkDtype('indices', 'uint', val);
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
    function val = validate_indptr(obj, val)
        val = matnwb.types.util.checkDtype('indptr', 'uint', val);
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
    function val = validate_shape(obj, val)
        val = matnwb.types.util.checkDtype('shape', 'uint', val);
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
        validshapes = {[2]};
        matnwb.types.util.checkDims(valsz, validshapes);
    end
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@matnwb.types.hdmf_common.Container(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
        if startsWith(class(obj.data), 'matnwb.types.untyped.')
            refs = obj.data.export(fid, [fullpath '/data'], refs);
        elseif ~isempty(obj.data)
            matnwb.io.writeDataset(fid, [fullpath '/data'], obj.data, 'forceArray');
        end
        if startsWith(class(obj.indices), 'matnwb.types.untyped.')
            refs = obj.indices.export(fid, [fullpath '/indices'], refs);
        elseif ~isempty(obj.indices)
            matnwb.io.writeDataset(fid, [fullpath '/indices'], obj.indices, 'forceArray');
        end
        if startsWith(class(obj.indptr), 'matnwb.types.untyped.')
            refs = obj.indptr.export(fid, [fullpath '/indptr'], refs);
        elseif ~isempty(obj.indptr)
            matnwb.io.writeDataset(fid, [fullpath '/indptr'], obj.indptr, 'forceArray');
        end
        matnwb.io.writeAttribute(fid, [fullpath '/shape'], obj.shape, 'forceArray');
    end
end

end