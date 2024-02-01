classdef SimpleMultiContainer < matnwb.types.hdmf_common.Container & matnwb.types.untyped.GroupClass
% SIMPLEMULTICONTAINER A simple Container for holding onto multiple containers.


% OPTIONAL PROPERTIES
properties
    container; %  (Container) Container objects held within this SimpleMultiContainer.
    data; %  (Data) Data objects held within this SimpleMultiContainer.
end

methods
    function obj = SimpleMultiContainer(varargin)
        % SIMPLEMULTICONTAINER Constructor for SimpleMultiContainer
        obj = obj@matnwb.types.hdmf_common.Container(varargin{:});
        [obj.container, ivarargin] = matnwb.types.util.parseConstrained(obj,'container', 'matnwb.types.hdmf_common.Container', varargin{:});
        varargin(ivarargin) = [];
        [obj.data, ivarargin] = matnwb.types.util.parseConstrained(obj,'data', 'matnwb.types.hdmf_common.Data', varargin{:});
        varargin(ivarargin) = [];
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        matnwb.misc.parseSkipInvalidName(p, varargin);
        if strcmp(class(obj), 'matnwb.types.hdmf_common.SimpleMultiContainer')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
        end
    end
    %% SETTERS
    function set.container(obj, val)
        obj.container = obj.validate_container(val);
    end
    function set.data(obj, val)
        obj.data = obj.validate_data(val);
    end
    %% VALIDATORS
    
    function val = validate_container(obj, val)
        namedprops = struct();
        constrained = {'matnwb.types.hdmf_common.Container'};
        matnwb.types.util.checkSet('container', namedprops, constrained, val);
    end
    function val = validate_data(obj, val)
        constrained = { 'matnwb.types.hdmf_common.Data' };
        matnwb.types.util.checkSet('data', struct(), constrained, val);
    end
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@matnwb.types.hdmf_common.Container(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
        if ~isempty(obj.container)
            refs = obj.container.export(fid, fullpath, refs);
        end
        if ~isempty(obj.data)
            refs = obj.data.export(fid, fullpath, refs);
        end
    end
end

end