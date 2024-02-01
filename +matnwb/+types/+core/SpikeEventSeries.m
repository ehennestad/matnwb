classdef SpikeEventSeries < matnwb.types.core.ElectricalSeries & matnwb.types.untyped.GroupClass
% SPIKEEVENTSERIES Stores snapshots/snippets of recorded spike events (i.e., threshold crossings). This may also be raw data, as reported by ephys hardware. If so, the TimeSeries::description field should describe how events were detected. All SpikeEventSeries should reside in a module (under EventWaveform interface) even if the spikes were reported and stored by hardware. All events span the same recording channels and store snapshots of equal duration. TimeSeries::data array structure: [num events] [num channels] [num samples] (or [num events] [num samples] for single electrode).



methods
    function obj = SpikeEventSeries(varargin)
        % SPIKEEVENTSERIES Constructor for SpikeEventSeries
        varargin = [{'data_unit' 'volts' 'timestamps_interval' matnwb.types.util.correctType(1, 'int32') 'timestamps_unit' 'seconds'} varargin];
        obj = obj@matnwb.types.core.ElectricalSeries(varargin{:});
        
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        addParameter(p, 'data',[]);
        addParameter(p, 'data_unit',[]);
        addParameter(p, 'timestamps',[]);
        addParameter(p, 'timestamps_interval',[]);
        addParameter(p, 'timestamps_unit',[]);
        matnwb.misc.parseSkipInvalidName(p, varargin);
        obj.data = p.Results.data;
        obj.data_unit = p.Results.data_unit;
        obj.timestamps = p.Results.timestamps;
        obj.timestamps_interval = p.Results.timestamps_interval;
        obj.timestamps_unit = p.Results.timestamps_unit;
        if strcmp(class(obj), 'matnwb.types.core.SpikeEventSeries')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
        end
    end
    %% SETTERS
    
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
        validshapes = {[Inf,Inf,Inf], [Inf,Inf]};
        matnwb.types.util.checkDims(valsz, validshapes);
    end
    function val = validate_timestamps(obj, val)
        val = matnwb.types.util.checkDtype('timestamps', 'double', val);
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
        refs = export@matnwb.types.core.ElectricalSeries(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
    end
end

end