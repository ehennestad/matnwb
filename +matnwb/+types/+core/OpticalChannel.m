classdef OpticalChannel < matnwb.types.core.NWBContainer & matnwb.types.untyped.GroupClass
% OPTICALCHANNEL An optical channel used to record from an imaging plane.


% REQUIRED PROPERTIES
properties
    description; % REQUIRED (char) Description or other notes about the channel.
    emission_lambda; % REQUIRED (single) Emission wavelength for channel, in nm.
end

methods
    function obj = OpticalChannel(varargin)
        % OPTICALCHANNEL Constructor for OpticalChannel
        obj = obj@matnwb.types.core.NWBContainer(varargin{:});
        
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        addParameter(p, 'description',[]);
        addParameter(p, 'emission_lambda',[]);
        matnwb.misc.parseSkipInvalidName(p, varargin);
        obj.description = p.Results.description;
        obj.emission_lambda = p.Results.emission_lambda;
        if strcmp(class(obj), 'matnwb.types.core.OpticalChannel')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
        end
    end
    %% SETTERS
    function set.description(obj, val)
        obj.description = obj.validate_description(val);
    end
    function set.emission_lambda(obj, val)
        obj.emission_lambda = obj.validate_emission_lambda(val);
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
    function val = validate_emission_lambda(obj, val)
        val = matnwb.types.util.checkDtype('emission_lambda', 'single', val);
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
        if startsWith(class(obj.description), 'matnwb.types.untyped.')
            refs = obj.description.export(fid, [fullpath '/description'], refs);
        elseif ~isempty(obj.description)
            matnwb.io.writeDataset(fid, [fullpath '/description'], obj.description);
        end
        if startsWith(class(obj.emission_lambda), 'matnwb.types.untyped.')
            refs = obj.emission_lambda.export(fid, [fullpath '/emission_lambda'], refs);
        elseif ~isempty(obj.emission_lambda)
            matnwb.io.writeDataset(fid, [fullpath '/emission_lambda'], obj.emission_lambda);
        end
    end
end

end