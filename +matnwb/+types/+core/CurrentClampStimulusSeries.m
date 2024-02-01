classdef CurrentClampStimulusSeries < matnwb.types.core.PatchClampSeries & matnwb.types.untyped.GroupClass
% CURRENTCLAMPSTIMULUSSERIES Stimulus current applied during current clamp recording.



methods
    function obj = CurrentClampStimulusSeries(varargin)
        % CURRENTCLAMPSTIMULUSSERIES Constructor for CurrentClampStimulusSeries
        varargin = [{'data_unit' 'amperes'} varargin];
        obj = obj@matnwb.types.core.PatchClampSeries(varargin{:});
        
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        addParameter(p, 'data',[]);
        addParameter(p, 'data_unit',[]);
        matnwb.misc.parseSkipInvalidName(p, varargin);
        obj.data = p.Results.data;
        obj.data_unit = p.Results.data_unit;
        if strcmp(class(obj), 'matnwb.types.core.CurrentClampStimulusSeries')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
        end
    end
    %% SETTERS
    
    %% VALIDATORS
    
    function val = validate_data(obj, val)
    
    end
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@matnwb.types.core.PatchClampSeries(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
    end
end

end