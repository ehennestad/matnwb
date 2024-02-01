classdef RoiResponseSeries < matnwb.types.core.TimeSeries & matnwb.types.untyped.GroupClass
% ROIRESPONSESERIES ROI responses over an imaging plane. The first dimension represents time. The second dimension, if present, represents ROIs.


% REQUIRED PROPERTIES
properties
    rois; % REQUIRED (DynamicTableRegion) DynamicTableRegion referencing into an ROITable containing information on the ROIs stored in this timeseries.
end

methods
    function obj = RoiResponseSeries(varargin)
        % ROIRESPONSESERIES Constructor for RoiResponseSeries
        obj = obj@matnwb.types.core.TimeSeries(varargin{:});
        
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        addParameter(p, 'data',[]);
        addParameter(p, 'rois',[]);
        matnwb.misc.parseSkipInvalidName(p, varargin);
        obj.data = p.Results.data;
        obj.rois = p.Results.rois;
        if strcmp(class(obj), 'matnwb.types.core.RoiResponseSeries')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
        end
    end
    %% SETTERS
    function set.rois(obj, val)
        obj.rois = obj.validate_rois(val);
    end
    %% VALIDATORS
    
    function val = validate_data(obj, val)
        val = matnwb.types.util.checkDtype('data', 'numeric', val);
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
        validshapes = {[Inf,Inf], [Inf]};
        matnwb.types.util.checkDims(valsz, validshapes);
    end
    function val = validate_rois(obj, val)
        val = matnwb.types.util.checkDtype('rois', 'matnwb.types.hdmf_common.DynamicTableRegion', val);
    end
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@matnwb.types.core.TimeSeries(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
        refs = obj.rois.export(fid, [fullpath '/rois'], refs);
    end
end

end