classdef PupilTracking < matnwb.matnwb.types.core.NWBDataInterface & matnwb.types.untyped.GroupClass
% PUPILTRACKING Eye-tracking data, representing pupil size.


% REQUIRED PROPERTIES
properties
    timeseries; % REQUIRED (TimeSeries) TimeSeries object containing time series data on pupil size.
end

methods
    function obj = PupilTracking(varargin)
        % PUPILTRACKING Constructor for PupilTracking
        obj = obj@matnwb.matnwb.types.core.NWBDataInterface(varargin{:});
        [obj.timeseries, ivarargin] = matnwb.types.util.parseConstrained(obj,'timeseries', 'matnwb.types.core.TimeSeries', varargin{:});
        varargin(ivarargin) = [];
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        matnwb.misc.parseSkipInvalidName(p, varargin);
        if strcmp(class(obj), 'matnwb.types.core.PupilTracking')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
        end
    end
    %% SETTERS
    function set.timeseries(obj, val)
        obj.timeseries = obj.validate_timeseries(val);
    end
    %% VALIDATORS
    
    function val = validate_timeseries(obj, val)
        namedprops = struct();
        constrained = {'matnwb.types.core.TimeSeries'};
        matnwb.types.util.checkSet('timeseries', namedprops, constrained, val);
    end
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@matnwb.matnwb.types.core.NWBDataInterface(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
        refs = obj.timeseries.export(fid, fullpath, refs);
    end
end

end