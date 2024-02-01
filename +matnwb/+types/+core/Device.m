classdef Device < matnwb.types.core.NWBContainer & matnwb.types.untyped.GroupClass
% DEVICE Metadata about a data acquisition device, e.g., recording system, electrode, microscope.


% OPTIONAL PROPERTIES
properties
    description; %  (char) Description of the device (e.g., model, firmware version, processing software version, etc.) as free-form text.
    manufacturer; %  (char) The name of the manufacturer of the device.
end

methods
    function obj = Device(varargin)
        % DEVICE Constructor for Device
        obj = obj@matnwb.types.core.NWBContainer(varargin{:});
        
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        addParameter(p, 'description',[]);
        addParameter(p, 'manufacturer',[]);
        matnwb.misc.parseSkipInvalidName(p, varargin);
        obj.description = p.Results.description;
        obj.manufacturer = p.Results.manufacturer;
        if strcmp(class(obj), 'matnwb.types.core.Device')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
        end
    end
    %% SETTERS
    function set.description(obj, val)
        obj.description = obj.validate_description(val);
    end
    function set.manufacturer(obj, val)
        obj.manufacturer = obj.validate_manufacturer(val);
    end
    %% VALIDATORS
    
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
    function val = validate_manufacturer(obj, val)
        val = matnwb.types.util.checkDtype('manufacturer', 'char', val);
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
        refs = export@matnwb.types.core.NWBContainer(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
        if ~isempty(obj.description)
            matnwb.io.writeAttribute(fid, [fullpath '/description'], obj.description);
        end
        if ~isempty(obj.manufacturer)
            matnwb.io.writeAttribute(fid, [fullpath '/manufacturer'], obj.manufacturer);
        end
    end
end

end