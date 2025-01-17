classdef EventDetection < matnwb.types.core.NWBDataInterface & matnwb.types.untyped.GroupClass
% EVENTDETECTION Detected spike events from voltage trace(s).


% READONLY PROPERTIES
properties(SetAccess = protected)
    times_unit; %  (char) Unit of measurement for event times, which is fixed to 'seconds'.
end
% REQUIRED PROPERTIES
properties
    detection_method; % REQUIRED (char) Description of how events were detected, such as voltage threshold, or dV/dT threshold, as well as relevant values.
    source_idx; % REQUIRED (int32) Indices (zero-based) into source ElectricalSeries::data array corresponding to time of event. ''description'' should define what is meant by time of event (e.g., .25 ms before action potential peak, zero-crossing time, etc). The index points to each event from the raw data.
    times; % REQUIRED (double) Timestamps of events, in seconds.
end
% OPTIONAL PROPERTIES
properties
    source_electricalseries; %  ElectricalSeries
end

methods
    function obj = EventDetection(varargin)
        % EVENTDETECTION Constructor for EventDetection
        varargin = [{'times_unit' 'seconds'} varargin];
        obj = obj@matnwb.types.core.NWBDataInterface(varargin{:});
        
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        addParameter(p, 'detection_method',[]);
        addParameter(p, 'source_electricalseries',[]);
        addParameter(p, 'source_idx',[]);
        addParameter(p, 'times',[]);
        addParameter(p, 'times_unit',[]);
        matnwb.misc.parseSkipInvalidName(p, varargin);
        obj.detection_method = p.Results.detection_method;
        obj.source_electricalseries = p.Results.source_electricalseries;
        obj.source_idx = p.Results.source_idx;
        obj.times = p.Results.times;
        obj.times_unit = p.Results.times_unit;
        if strcmp(class(obj), 'matnwb.types.core.EventDetection')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
        end
    end
    %% SETTERS
    function set.detection_method(obj, val)
        obj.detection_method = obj.validate_detection_method(val);
    end
    function set.source_electricalseries(obj, val)
        obj.source_electricalseries = obj.validate_source_electricalseries(val);
    end
    function set.source_idx(obj, val)
        obj.source_idx = obj.validate_source_idx(val);
    end
    function set.times(obj, val)
        obj.times = obj.validate_times(val);
    end
    %% VALIDATORS
    
    function val = validate_detection_method(obj, val)
        val = matnwb.types.util.checkDtype('detection_method', 'char', val);
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
    function val = validate_source_electricalseries(obj, val)
        val = matnwb.types.util.checkDtype('source_electricalseries', 'matnwb.types.core.ElectricalSeries', val);
    end
    function val = validate_source_idx(obj, val)
        val = matnwb.types.util.checkDtype('source_idx', 'int32', val);
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
    function val = validate_times(obj, val)
        val = matnwb.types.util.checkDtype('times', 'double', val);
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
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@matnwb.types.core.NWBDataInterface(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
        if startsWith(class(obj.detection_method), 'matnwb.types.untyped.')
            refs = obj.detection_method.export(fid, [fullpath '/detection_method'], refs);
        elseif ~isempty(obj.detection_method)
            matnwb.io.writeDataset(fid, [fullpath '/detection_method'], obj.detection_method);
        end
        refs = obj.source_electricalseries.export(fid, [fullpath '/source_electricalseries'], refs);
        if startsWith(class(obj.source_idx), 'matnwb.types.untyped.')
            refs = obj.source_idx.export(fid, [fullpath '/source_idx'], refs);
        elseif ~isempty(obj.source_idx)
            matnwb.io.writeDataset(fid, [fullpath '/source_idx'], obj.source_idx, 'forceArray');
        end
        if startsWith(class(obj.times), 'matnwb.types.untyped.')
            refs = obj.times.export(fid, [fullpath '/times'], refs);
        elseif ~isempty(obj.times)
            matnwb.io.writeDataset(fid, [fullpath '/times'], obj.times, 'forceArray');
        end
        if ~isempty(obj.times) && ~isa(obj.times, 'matnwb.types.untyped.SoftLink') && ~isa(obj.times, 'matnwb.types.untyped.ExternalLink')
            matnwb.io.writeAttribute(fid, [fullpath '/times/unit'], obj.times_unit);
        end
    end
end

end