classdef ElementIdentifiers < matnwb.types.hdmf_common.Data & matnwb.types.untyped.DatasetClass
% ELEMENTIDENTIFIERS A list of unique identifiers for values within a dataset, e.g. rows of a DynamicTable.



methods
    function obj = ElementIdentifiers(varargin)
        % ELEMENTIDENTIFIERS Constructor for ElementIdentifiers
        obj = obj@matnwb.types.hdmf_common.Data(varargin{:});
        
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        addParameter(p, 'data',[]);
        matnwb.misc.parseSkipInvalidName(p, varargin);
        obj.data = p.Results.data;
        if strcmp(class(obj), 'matnwb.types.hdmf_common.ElementIdentifiers')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
        end
    end
    %% SETTERS
    
    %% VALIDATORS
    
    function val = validate_data(obj, val)
        val = matnwb.types.util.checkDtype('data', 'int8', val);
    end
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@matnwb.types.hdmf_common.Data(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
    end
end

end