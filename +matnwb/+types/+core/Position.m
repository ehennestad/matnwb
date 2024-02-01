classdef Position < matnwb.matnwb.types.core.NWBDataInterface & matnwb.types.untyped.GroupClass
% POSITION Position data, whether along the x, x/y or x/y/z axis.


% REQUIRED PROPERTIES
properties
    spatialseries; % REQUIRED (SpatialSeries) SpatialSeries object containing position data.
end

methods
    function obj = Position(varargin)
        % POSITION Constructor for Position
        obj = obj@matnwb.matnwb.types.core.NWBDataInterface(varargin{:});
        [obj.spatialseries, ivarargin] = matnwb.types.util.parseConstrained(obj,'spatialseries', 'matnwb.types.core.SpatialSeries', varargin{:});
        varargin(ivarargin) = [];
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        matnwb.misc.parseSkipInvalidName(p, varargin);
        if strcmp(class(obj), 'matnwb.types.core.Position')
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
        refs = export@matnwb.matnwb.types.core.NWBDataInterface(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
        refs = obj.spatialseries.export(fid, fullpath, refs);
    end
end

end