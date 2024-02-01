classdef Fluorescence < matnwb.types.core.NWBDataInterface & matnwb.types.untyped.GroupClass
% FLUORESCENCE Fluorescence information about a region of interest (ROI). Storage hierarchy of fluorescence should be the same as for segmentation (ie, same names for ROIs and for image planes).


% REQUIRED PROPERTIES
properties
    roiresponseseries; % REQUIRED (RoiResponseSeries) RoiResponseSeries object(s) containing fluorescence data for a ROI.
end

methods
    function obj = Fluorescence(varargin)
        % FLUORESCENCE Constructor for Fluorescence
        obj = obj@matnwb.types.core.NWBDataInterface(varargin{:});
        [obj.roiresponseseries, ivarargin] = matnwb.types.util.parseConstrained(obj,'roiresponseseries', 'matnwb.types.core.RoiResponseSeries', varargin{:});
        varargin(ivarargin) = [];
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        matnwb.misc.parseSkipInvalidName(p, varargin);
        if strcmp(class(obj), 'matnwb.types.core.Fluorescence')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
        end
    end
    %% SETTERS
    function set.roiresponseseries(obj, val)
        obj.roiresponseseries = obj.validate_roiresponseseries(val);
    end
    %% VALIDATORS
    
    function val = validate_roiresponseseries(obj, val)
        namedprops = struct();
        constrained = {'matnwb.types.core.RoiResponseSeries'};
        matnwb.types.util.checkSet('roiresponseseries', namedprops, constrained, val);
    end
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@matnwb.types.core.NWBDataInterface(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
        refs = obj.roiresponseseries.export(fid, fullpath, refs);
    end
end

end