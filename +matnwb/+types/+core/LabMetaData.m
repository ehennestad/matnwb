classdef LabMetaData < matnwb.types.core.NWBContainer & matnwb.types.untyped.GroupClass
% LABMETADATA Lab-specific meta-data.



methods
    function obj = LabMetaData(varargin)
        % LABMETADATA Constructor for LabMetaData
        obj = obj@matnwb.types.core.NWBContainer(varargin{:});
        if strcmp(class(obj), 'matnwb.types.core.LabMetaData')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
        end
    end
    %% SETTERS
    
    %% VALIDATORS
    
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@matnwb.types.core.NWBContainer(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
    end
end

end