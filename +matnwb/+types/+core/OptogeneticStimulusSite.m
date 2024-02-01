classdef OptogeneticStimulusSite < matnwb.types.core.NWBContainer & matnwb.types.untyped.GroupClass
% OPTOGENETICSTIMULUSSITE A site of optogenetic stimulation.


% REQUIRED PROPERTIES
properties
    description; % REQUIRED (char) Description of stimulation site.
    excitation_lambda; % REQUIRED (single) Excitation wavelength, in nm.
    location; % REQUIRED (char) Location of the stimulation site. Specify the area, layer, comments on estimation of area/layer, stereotaxic coordinates if in vivo, etc. Use standard atlas names for anatomical regions when possible.
end
% OPTIONAL PROPERTIES
properties
    device; %  Device
end

methods
    function obj = OptogeneticStimulusSite(varargin)
        % OPTOGENETICSTIMULUSSITE Constructor for OptogeneticStimulusSite
        obj = obj@matnwb.types.core.NWBContainer(varargin{:});
        
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        addParameter(p, 'description',[]);
        addParameter(p, 'device',[]);
        addParameter(p, 'excitation_lambda',[]);
        addParameter(p, 'location',[]);
        matnwb.misc.parseSkipInvalidName(p, varargin);
        obj.description = p.Results.description;
        obj.device = p.Results.device;
        obj.excitation_lambda = p.Results.excitation_lambda;
        obj.location = p.Results.location;
        if strcmp(class(obj), 'matnwb.types.core.OptogeneticStimulusSite')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
        end
    end
    %% SETTERS
    function set.description(obj, val)
        obj.description = obj.validate_description(val);
    end
    function set.device(obj, val)
        obj.device = obj.validate_device(val);
    end
    function set.excitation_lambda(obj, val)
        obj.excitation_lambda = obj.validate_excitation_lambda(val);
    end
    function set.location(obj, val)
        obj.location = obj.validate_location(val);
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
    function val = validate_device(obj, val)
        val = matnwb.types.util.checkDtype('device', 'matnwb.types.core.Device', val);
    end
    function val = validate_excitation_lambda(obj, val)
        val = matnwb.types.util.checkDtype('excitation_lambda', 'single', val);
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
    function val = validate_location(obj, val)
        val = matnwb.types.util.checkDtype('location', 'char', val);
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
        refs = obj.device.export(fid, [fullpath '/device'], refs);
        if startsWith(class(obj.excitation_lambda), 'matnwb.types.untyped.')
            refs = obj.excitation_lambda.export(fid, [fullpath '/excitation_lambda'], refs);
        elseif ~isempty(obj.excitation_lambda)
            matnwb.io.writeDataset(fid, [fullpath '/excitation_lambda'], obj.excitation_lambda);
        end
        if startsWith(class(obj.location), 'matnwb.types.untyped.')
            refs = obj.location.export(fid, [fullpath '/location'], refs);
        elseif ~isempty(obj.location)
            matnwb.io.writeDataset(fid, [fullpath '/location'], obj.location);
        end
    end
end

end