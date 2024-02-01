classdef ImageReferences < matnwb.types.core.NWBData & matnwb.types.untyped.DatasetClass
% IMAGEREFERENCES Ordered dataset of references to Image objects.



methods
    function obj = ImageReferences(varargin)
        % IMAGEREFERENCES Constructor for ImageReferences
        obj = obj@matnwb.types.core.NWBData(varargin{:});
        
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        addParameter(p, 'data',[]);
        matnwb.misc.parseSkipInvalidName(p, varargin);
        obj.data = p.Results.data;
        if strcmp(class(obj), 'matnwb.matnwb.types.core.ImageReferences')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
        end
    end
    %% SETTERS
    
    %% VALIDATORS
    
    function val = validate_data(obj, val)
        % Reference to type `Image`
        val = matnwb.types.util.checkDtype('data', 'matnwb.types.untyped.ObjectView', val);
    end
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@matnwb.types.core.NWBData(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
    end
end

end