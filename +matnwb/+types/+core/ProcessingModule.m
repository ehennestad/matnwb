classdef ProcessingModule < matnwb.types.core.NWBContainer & matnwb.types.untyped.GroupClass
% PROCESSINGMODULE A collection of processed data.


% OPTIONAL PROPERTIES
properties
    description; %  (char) Description of this collection of processed data.
    dynamictable; %  (DynamicTable) Tables stored in this collection.
    nwbdatainterface; %  (NWBDataInterface) Data objects stored in this collection.
end

methods
    function obj = ProcessingModule(varargin)
        % PROCESSINGMODULE Constructor for ProcessingModule
        obj = obj@matnwb.types.core.NWBContainer(varargin{:});
        [obj.dynamictable, ivarargin] = matnwb.types.util.parseConstrained(obj,'dynamictable', 'matnwb.types.hdmf_common.DynamicTable', varargin{:});
        varargin(ivarargin) = [];
        [obj.nwbdatainterface, ivarargin] = matnwb.types.util.parseConstrained(obj,'nwbdatainterface', 'matnwb.matnwb.types.core.NWBDataInterface', varargin{:});
        varargin(ivarargin) = [];
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        addParameter(p, 'description',[]);
        matnwb.misc.parseSkipInvalidName(p, varargin);
        obj.description = p.Results.description;
        if strcmp(class(obj), 'matnwb.types.core.ProcessingModule')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
        end
    end
    %% SETTERS
    function set.description(obj, val)
        obj.description = obj.validate_description(val);
    end
    function set.dynamictable(obj, val)
        obj.dynamictable = obj.validate_dynamictable(val);
    end
    function set.nwbdatainterface(obj, val)
        obj.nwbdatainterface = obj.validate_nwbdatainterface(val);
    end
    %% VALIDATORS
    
    function val = validate_description(obj, val)
        val = matnwb.types.util.checkDtype('description', 'char', val);
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
        validshapes = {[1]};
        matnwb.types.util.checkDims(valsz, validshapes);
    end
    function val = validate_dynamictable(obj, val)
        namedprops = struct();
        constrained = {'matnwb.types.hdmf_common.DynamicTable'};
        matnwb.types.util.checkSet('dynamictable', namedprops, constrained, val);
    end
    function val = validate_nwbdatainterface(obj, val)
        namedprops = struct();
        constrained = {'matnwb.matnwb.types.core.NWBDataInterface'};
        matnwb.types.util.checkSet('nwbdatainterface', namedprops, constrained, val);
    end
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@matnwb.types.core.NWBContainer(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
        matnwb.io.writeAttribute(fid, [fullpath '/description'], obj.description);
        if ~isempty(obj.dynamictable)
            refs = obj.dynamictable.export(fid, fullpath, refs);
        end
        if ~isempty(obj.nwbdatainterface)
            refs = obj.nwbdatainterface.export(fid, fullpath, refs);
        end
    end
end

end