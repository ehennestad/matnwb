classdef ImageSegmentation < matnwb.types.core.NWBDataInterface & matnwb.types.untyped.GroupClass
% IMAGESEGMENTATION Stores pixels in an image that represent different regions of interest (ROIs) or masks. All segmentation for a given imaging plane is stored together, with storage for multiple imaging planes (masks) supported. Each ROI is stored in its own subgroup, with the ROI group containing both a 2D mask and a list of pixels that make up this mask. Segments can also be used for masking neuropil. If segmentation is allowed to change with time, a new imaging plane (or module) is required and ROI names should remain consistent between them.


% REQUIRED PROPERTIES
properties
    planesegmentation; % REQUIRED (PlaneSegmentation) Results from image segmentation of a specific imaging plane.
end

methods
    function obj = ImageSegmentation(varargin)
        % IMAGESEGMENTATION Constructor for ImageSegmentation
        obj = obj@matnwb.types.core.NWBDataInterface(varargin{:});
        [obj.planesegmentation, ivarargin] = matnwb.types.util.parseConstrained(obj,'planesegmentation', 'matnwb.types.core.PlaneSegmentation', varargin{:});
        varargin(ivarargin) = [];
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        matnwb.misc.parseSkipInvalidName(p, varargin);
        if strcmp(class(obj), 'matnwb.types.core.ImageSegmentation')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
        end
    end
    %% SETTERS
    function set.planesegmentation(obj, val)
        obj.planesegmentation = obj.validate_planesegmentation(val);
    end
    %% VALIDATORS
    
    function val = validate_planesegmentation(obj, val)
        namedprops = struct();
        constrained = {'matnwb.types.core.PlaneSegmentation'};
        matnwb.types.util.checkSet('planesegmentation', namedprops, constrained, val);
    end
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@matnwb.types.core.NWBDataInterface(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
        refs = obj.planesegmentation.export(fid, fullpath, refs);
    end
end

end