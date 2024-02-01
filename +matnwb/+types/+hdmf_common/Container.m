classdef Container < matnwb.types.untyped.MetaClass & matnwb.types.untyped.GroupClass
% CONTAINER An abstract data type for a group storing collections of data and metadata. Base type for all data and metadata containers.



methods
    function obj = Container(varargin)
        % CONTAINER Constructor for Container
        obj = obj@matnwb.types.untyped.MetaClass(varargin{:});
        if strcmp(class(obj), 'matnwb.types.hdmf_common.Container')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
        end
    end
    %% SETTERS
    
    %% VALIDATORS
    
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@matnwb.types.untyped.MetaClass(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
    end
end

end