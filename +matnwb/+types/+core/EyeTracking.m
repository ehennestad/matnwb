classdef EyeTracking < matnwb.types.core.NWBDataInterface & matnwb.types.untyped.GroupClass
% EYETRACKING Eye-tracking data, representing direction of gaze.


% OPTIONAL PROPERTIES
properties
    spatialseries; %  (SpatialSeries) SpatialSeries object containing data measuring direction of gaze.
end

methods
    function obj = EyeTracking(varargin)
        % EYETRACKING Constructor for EyeTracking
        obj = obj@matnwb.types.core.NWBDataInterface(varargin{:});
        [obj.spatialseries, ivarargin] = matnwb.types.util.parseConstrained(obj,'spatialseries', 'matnwb.types.core.SpatialSeries', varargin{:});
        varargin(ivarargin) = [];
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        matnwb.misc.parseSkipInvalidName(p, varargin);
        if strcmp(class(obj), 'matnwb.types.core.EyeTracking')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
        end
    end
    %% SETTERS
    function set.spatialseries(obj, val)
        obj.spatialseries = obj.validate_spatialseries(val);
    end
    %% VALIDATORS
    
    function val = validate_spatialseries(obj, val)
        namedprops = struct();
        constrained = {'matnwb.types.core.SpatialSeries'};
        matnwb.types.util.checkSet('spatialseries', namedprops, constrained, val);
    end
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@matnwb.types.core.NWBDataInterface(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
        if ~isempty(obj.spatialseries)
            refs = obj.spatialseries.export(fid, fullpath, refs);
        end
    end
end

end