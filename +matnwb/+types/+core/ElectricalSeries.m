classdef ElectricalSeries < matnwb.types.core.TimeSeries & matnwb.types.untyped.GroupClass
% ELECTRICALSERIES A time series of acquired voltage data from extracellular recordings. The data field is an int or float array storing data in volts. The first dimension should always represent time. The second dimension, if present, should represent channels.


% READONLY PROPERTIES
properties(SetAccess = protected)
    channel_conversion_axis; %  (int32) The zero-indexed axis of the 'data' dataset that the channel-specific conversion factor corresponds to. This value is fixed to 1.
end
% REQUIRED PROPERTIES
properties
    electrodes; % REQUIRED (DynamicTableRegion) DynamicTableRegion pointer to the electrodes that this time series was generated from.
end
% OPTIONAL PROPERTIES
properties
    channel_conversion; %  (single) Channel-specific conversion factor. Multiply the data in the 'data' dataset by these values along the channel axis (as indicated by axis attribute) AND by the global conversion factor in the 'conversion' attribute of 'data' to get the data values in Volts, i.e, data in Volts = data * data.conversion * channel_conversion. This approach allows for both global and per-channel data conversion factors needed to support the storage of electrical recordings as native values generated by data acquisition systems. If this dataset is not present, then there is no channel-specific conversion factor, i.e. it is 1 for all channels.
    filtering; %  (char) Filtering applied to all channels of the data. For example, if this ElectricalSeries represents high-pass-filtered data (also known as AP Band), then this value could be "High-pass 4-pole Bessel filter at 500 Hz". If this ElectricalSeries represents low-pass-filtered LFP data and the type of filter is unknown, then this value could be "Low-pass filter at 300 Hz". If a non-standard filter type is used, provide as much detail about the filter properties as possible.
end

methods
    function obj = ElectricalSeries(varargin)
        % ELECTRICALSERIES Constructor for ElectricalSeries
        varargin = [{'channel_conversion_axis' matnwb.types.util.correctType(1, 'int32') 'data_unit' 'volts'} varargin];
        obj = obj@matnwb.types.core.TimeSeries(varargin{:});
        
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        addParameter(p, 'channel_conversion',[]);
        addParameter(p, 'channel_conversion_axis',[]);
        addParameter(p, 'data',[]);
        addParameter(p, 'data_unit',[]);
        addParameter(p, 'electrodes',[]);
        addParameter(p, 'filtering',[]);
        matnwb.misc.parseSkipInvalidName(p, varargin);
        obj.channel_conversion = p.Results.channel_conversion;
        obj.channel_conversion_axis = p.Results.channel_conversion_axis;
        obj.data = p.Results.data;
        obj.data_unit = p.Results.data_unit;
        obj.electrodes = p.Results.electrodes;
        obj.filtering = p.Results.filtering;
        if strcmp(class(obj), 'matnwb.types.core.ElectricalSeries')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
        end
    end
    %% SETTERS
    function set.channel_conversion(obj, val)
        obj.channel_conversion = obj.validate_channel_conversion(val);
    end
    function set.electrodes(obj, val)
        obj.electrodes = obj.validate_electrodes(val);
    end
    function set.filtering(obj, val)
        obj.filtering = obj.validate_filtering(val);
    end
    %% VALIDATORS
    
    function val = validate_channel_conversion(obj, val)
        val = matnwb.types.util.checkDtype('channel_conversion', 'single', val);
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
        validshapes = {[Inf,Inf,Inf], [Inf,Inf], [Inf]};
        matnwb.types.util.checkDims(valsz, validshapes);
    end
    function val = validate_electrodes(obj, val)
        val = matnwb.types.util.checkDtype('electrodes', 'matnwb.types.hdmf_common.DynamicTableRegion', val);
    end
    function val = validate_filtering(obj, val)
        val = matnwb.types.util.checkDtype('filtering', 'char', val);
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
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@matnwb.types.core.TimeSeries(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
        if ~isempty(obj.channel_conversion)
            if startsWith(class(obj.channel_conversion), 'matnwb.types.untyped.')
                refs = obj.channel_conversion.export(fid, [fullpath '/channel_conversion'], refs);
            elseif ~isempty(obj.channel_conversion)
                matnwb.io.writeDataset(fid, [fullpath '/channel_conversion'], obj.channel_conversion, 'forceArray');
            end
        end
        if ~isempty(obj.channel_conversion) && ~isa(obj.channel_conversion, 'matnwb.types.untyped.SoftLink') && ~isa(obj.channel_conversion, 'matnwb.types.untyped.ExternalLink')
            matnwb.io.writeAttribute(fid, [fullpath '/channel_conversion/axis'], obj.channel_conversion_axis);
        end
        refs = obj.electrodes.export(fid, [fullpath '/electrodes'], refs);
        if ~isempty(obj.filtering)
            matnwb.io.writeAttribute(fid, [fullpath '/filtering'], obj.filtering);
        end
    end
end

end