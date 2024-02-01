classdef VectorIndex < matnwb.types.hdmf_common.VectorData & matnwb.types.untyped.DatasetClass
% VECTORINDEX Used with VectorData to encode a ragged array. An array of indices into the first dimension of the target VectorData, and forming a map between the rows of a DynamicTable and the indices of the VectorData. The name of the VectorIndex is expected to be the name of the target VectorData object followed by "_index".


% OPTIONAL PROPERTIES
properties
    target; %  (Object Reference to VectorData) Reference to the target dataset that this index applies to.
end

methods
    function obj = VectorIndex(varargin)
        % VECTORINDEX Constructor for VectorIndex
        obj = obj@matnwb.types.hdmf_common.VectorData(varargin{:});
        
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        addParameter(p, 'data',[]);
        addParameter(p, 'target',[]);
        matnwb.misc.parseSkipInvalidName(p, varargin);
        obj.data = p.Results.data;
        obj.target = p.Results.target;
        if strcmp(class(obj), 'matnwb.types.hdmf_common.VectorIndex')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
        end
    end
    %% SETTERS
    function set.target(obj, val)
        obj.target = obj.validate_target(val);
    end
    %% VALIDATORS
    
    function val = validate_data(obj, val)
        val = matnwb.types.util.checkDtype('data', 'uint8', val);
    end
    function val = validate_target(obj, val)
        % Reference to type `VectorData`
        val = matnwb.types.util.checkDtype('target', 'matnwb.types.untyped.ObjectView', val);
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
        matnwb.io.writeAttribute(fid, [fullpath '/target'], obj.target);
    end
end

end