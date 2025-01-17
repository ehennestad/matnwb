classdef OptogeneticSeries < matnwb.types.core.TimeSeries & matnwb.types.untyped.GroupClass
% OPTOGENETICSERIES An optogenetic stimulus.


% OPTIONAL PROPERTIES
properties
    site; %  OptogeneticStimulusSite
end

methods
    function obj = OptogeneticSeries(varargin)
        % OPTOGENETICSERIES Constructor for OptogeneticSeries
        varargin = [{'data_unit' 'watts'} varargin];
        obj = obj@matnwb.types.core.TimeSeries(varargin{:});
        
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        addParameter(p, 'data',[]);
        addParameter(p, 'data_unit',[]);
        addParameter(p, 'site',[]);
        matnwb.misc.parseSkipInvalidName(p, varargin);
        obj.data = p.Results.data;
        obj.data_unit = p.Results.data_unit;
        obj.site = p.Results.site;
        if strcmp(class(obj), 'matnwb.types.core.OptogeneticSeries')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
        end
    end
    %% SETTERS
    function set.site(obj, val)
        obj.site = obj.validate_site(val);
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
        validshapes = {[Inf]};
        matnwb.types.util.checkDims(valsz, validshapes);
    end
    function val = validate_site(obj, val)
        val = matnwb.types.util.checkDtype('site', 'matnwb.types.core.OptogeneticStimulusSite', val);
    end
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@matnwb.types.core.TimeSeries(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
        refs = obj.site.export(fid, [fullpath '/site'], refs);
    end
end

end