classdef BehavioralEvents < matnwb.types.core.NWBDataInterface & matnwb.types.untyped.GroupClass
% BEHAVIORALEVENTS TimeSeries for storing behavioral events. See description of <a href="#BehavioralEpochs">BehavioralEpochs</a> for more details.


% OPTIONAL PROPERTIES
properties
    timeseries; %  (TimeSeries) TimeSeries object containing behavioral events.
end

methods
    function obj = BehavioralEvents(varargin)
        % BEHAVIORALEVENTS Constructor for BehavioralEvents
        obj = obj@matnwb.types.core.NWBDataInterface(varargin{:});
        [obj.timeseries, ivarargin] = matnwb.types.util.parseConstrained(obj,'timeseries', 'matnwb.types.core.TimeSeries', varargin{:});
        varargin(ivarargin) = [];
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        matnwb.misc.parseSkipInvalidName(p, varargin);
        if strcmp(class(obj), 'matnwb.types.core.BehavioralEvents')
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
        refs = export@matnwb.types.core.NWBDataInterface(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
        if ~isempty(obj.timeseries)
            refs = obj.timeseries.export(fid, fullpath, refs);
        end
    end
end

end