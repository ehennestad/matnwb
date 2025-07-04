classdef Images < types.core.NWBDataInterface & types.untyped.GroupClass
% IMAGES - A collection of images with an optional way to specify the order of the images using the "order_of_images" dataset. An order must be specified if the images are referenced by index, e.g., from an IndexSeries.
%
% Required Properties:
%  description, image


% REQUIRED PROPERTIES
properties
    description; % REQUIRED (char) Description of this collection of images.
    image; % REQUIRED (Image) Images stored in this collection.
end
% OPTIONAL PROPERTIES
properties
    order_of_images; %  (ImageReferences) Ordered dataset of references to Image objects stored in the parent group. Each Image object in the Images group should be stored once and only once, so the dataset should have the same length as the number of images.
end

methods
    function obj = Images(varargin)
        % IMAGES - Constructor for Images
        %
        % Syntax:
        %  images = types.core.IMAGES() creates a Images object with unset property values.
        %
        %  images = types.core.IMAGES(Name, Value) creates a Images object where one or more property values are specified using name-value pairs.
        %
        % Input Arguments (Name-Value Arguments):
        %  - description (char) - Description of this collection of images.
        %
        %  - image (Image) - Images stored in this collection.
        %
        %  - order_of_images (ImageReferences) - Ordered dataset of references to Image objects stored in the parent group. Each Image object in the Images group should be stored once and only once, so the dataset should have the same length as the number of images.
        %
        % Output Arguments:
        %  - images (types.core.Images) - A Images object
        
        obj = obj@types.core.NWBDataInterface(varargin{:});
        [obj.image, ivarargin] = types.util.parseConstrained(obj,'image', 'types.core.Image', varargin{:});
        varargin(ivarargin) = [];
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        addParameter(p, 'description',[]);
        addParameter(p, 'order_of_images',[]);
        misc.parseSkipInvalidName(p, varargin);
        obj.description = p.Results.description;
        obj.order_of_images = p.Results.order_of_images;
        if strcmp(class(obj), 'types.core.Images')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            types.util.checkUnset(obj, unique(cellStringArguments));
        end
    end
    %% SETTERS
    function set.description(obj, val)
        obj.description = obj.validate_description(val);
    end
    function set.image(obj, val)
        obj.image = obj.validate_image(val);
    end
    function set.order_of_images(obj, val)
        obj.order_of_images = obj.validate_order_of_images(val);
    end
    %% VALIDATORS
    
    function val = validate_description(obj, val)
        val = types.util.checkDtype('description', 'char', val);
        types.util.validateShape('description', {[1]}, val)
    end
    function val = validate_image(obj, val)
        constrained = { 'types.core.Image' };
        types.util.checkSet('image', struct(), constrained, val);
    end
    function val = validate_order_of_images(obj, val)
        val = types.util.checkDtype('order_of_images', 'types.core.ImageReferences', val);
    end
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@types.core.NWBDataInterface(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
        io.writeAttribute(fid, [fullpath '/description'], obj.description);
        refs = obj.image.export(fid, fullpath, refs);
        if ~isempty(obj.order_of_images)
            refs = obj.order_of_images.export(fid, [fullpath '/order_of_images'], refs);
        end
    end
end

end