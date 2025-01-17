classdef NWBContainer < matnwb.types.hdmf_common.Container & matnwb.types.untyped.GroupClass
% NWBCONTAINER An abstract data type for a generic container storing collections of data and metadata. Base type for all data and metadata containers.



methods
    function obj = NWBContainer(varargin)
        % NWBCONTAINER Constructor for NWBContainer
        obj = obj@matnwb.types.hdmf_common.Container(varargin{:});
        if strcmp(class(obj), 'matnwb.types.core.NWBContainer')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
        end
    end
    %% SETTERS
    
    %% VALIDATORS
    
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@matnwb.types.hdmf_common.Container(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
    end
end

end