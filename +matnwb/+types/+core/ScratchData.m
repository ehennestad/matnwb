classdef ScratchData < matnwb.types.core.NWBData & matnwb.types.untyped.DatasetClass
% SCRATCHDATA Any one-off datasets


% OPTIONAL PROPERTIES
properties
    notes; %  (char) Any notes the user has about the dataset being stored
end

methods
    function obj = ScratchData(varargin)
        % SCRATCHDATA Constructor for ScratchData
        obj = obj@matnwb.types.core.NWBData(varargin{:});
        
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        addParameter(p, 'data',[]);
        addParameter(p, 'notes',[]);
        matnwb.misc.parseSkipInvalidName(p, varargin);
        obj.data = p.Results.data;
        obj.notes = p.Results.notes;
        if strcmp(class(obj), 'matnwb.types.core.ScratchData')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
        end
    end
    %% SETTERS
    function set.notes(obj, val)
        obj.notes = obj.validate_notes(val);
    end
    %% VALIDATORS
    
    function val = validate_data(obj, val)
    end
    function val = validate_notes(obj, val)
        val = matnwb.types.util.checkDtype('notes', 'char', val);
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
        refs = export@matnwb.types.core.NWBData(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
        matnwb.io.writeAttribute(fid, [fullpath '/notes'], obj.notes);
    end
end

end