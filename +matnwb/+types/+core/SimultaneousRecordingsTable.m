classdef SimultaneousRecordingsTable < matnwb.types.hdmf_common.DynamicTable & matnwb.types.untyped.GroupClass
% SIMULTANEOUSRECORDINGSTABLE A table for grouping different intracellular recordings from the IntracellularRecordingsTable table together that were recorded simultaneously from different electrodes.


% REQUIRED PROPERTIES
properties
    recordings; % REQUIRED (DynamicTableRegion) A reference to one or more rows in the IntracellularRecordingsTable table.
    recordings_index; % REQUIRED (VectorIndex) Index dataset for the recordings column.
end

methods
    function obj = SimultaneousRecordingsTable(varargin)
        % SIMULTANEOUSRECORDINGSTABLE Constructor for SimultaneousRecordingsTable
        obj = obj@matnwb.types.hdmf_common.DynamicTable(varargin{:});
        
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        addParameter(p, 'recordings',[]);
        addParameter(p, 'recordings_index',[]);
        matnwb.misc.parseSkipInvalidName(p, varargin);
        obj.recordings = p.Results.recordings;
        obj.recordings_index = p.Results.recordings_index;
        if strcmp(class(obj), 'matnwb.types.core.SimultaneousRecordingsTable')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
        end
        if strcmp(class(obj), 'matnwb.types.core.SimultaneousRecordingsTable')
            matnwb.types.util.dynamictable.checkConfig(obj);
        end
    end
    %% SETTERS
    function set.recordings(obj, val)
        obj.recordings = obj.validate_recordings(val);
    end
    function set.recordings_index(obj, val)
        obj.recordings_index = obj.validate_recordings_index(val);
    end
    %% VALIDATORS
    
    function val = validate_recordings(obj, val)
        val = matnwb.types.util.checkDtype('recordings', 'matnwb.matnwb.types.hdmf_common.DynamicTableRegion', val);
    end
    function val = validate_recordings_index(obj, val)
        val = matnwb.types.util.checkDtype('recordings_index', 'matnwb.types.hdmf_common.VectorIndex', val);
    end
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@matnwb.types.hdmf_common.DynamicTable(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
        refs = obj.recordings.export(fid, [fullpath '/recordings'], refs);
        refs = obj.recordings_index.export(fid, [fullpath '/recordings_index'], refs);
    end
end

end