classdef LFP < matnwb.types.core.NWBDataInterface & matnwb.types.untyped.GroupClass
% LFP LFP data from one or more channels. The electrode map in each published ElectricalSeries will identify which channels are providing LFP data. Filter properties should be noted in the ElectricalSeries 'filtering' attribute.


% REQUIRED PROPERTIES
properties
    electricalseries; % REQUIRED (ElectricalSeries) ElectricalSeries object(s) containing LFP data for one or more channels.
end

methods
    function obj = LFP(varargin)
        % LFP Constructor for LFP
        obj = obj@matnwb.types.core.NWBDataInterface(varargin{:});
        [obj.electricalseries, ivarargin] = matnwb.types.util.parseConstrained(obj,'electricalseries', 'matnwb.types.core.ElectricalSeries', varargin{:});
        varargin(ivarargin) = [];
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        matnwb.misc.parseSkipInvalidName(p, varargin);
        if strcmp(class(obj), 'matnwb.types.core.LFP')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
        end
    end
    %% SETTERS
    function set.electricalseries(obj, val)
        obj.electricalseries = obj.validate_electricalseries(val);
    end
    %% VALIDATORS
    
    function val = validate_electricalseries(obj, val)
        namedprops = struct();
        constrained = {'matnwb.types.core.ElectricalSeries'};
        matnwb.types.util.checkSet('electricalseries', namedprops, constrained, val);
    end
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@matnwb.types.core.NWBDataInterface(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
        refs = obj.electricalseries.export(fid, fullpath, refs);
    end
end

end