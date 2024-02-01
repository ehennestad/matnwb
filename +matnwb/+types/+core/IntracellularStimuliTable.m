classdef IntracellularStimuliTable < matnwb.types.hdmf_common.DynamicTable & matnwb.types.untyped.GroupClass
% INTRACELLULARSTIMULITABLE Table for storing intracellular stimulus related metadata.


% REQUIRED PROPERTIES
properties
    stimulus; % REQUIRED (TimeSeriesReferenceVectorData) Column storing the reference to the recorded stimulus for the recording (rows).
end

methods
    function obj = IntracellularStimuliTable(varargin)
        % INTRACELLULARSTIMULITABLE Constructor for IntracellularStimuliTable
        varargin = [{'description' 'Table for storing intracellular stimulus related metadata.'} varargin];
        obj = obj@matnwb.types.hdmf_common.DynamicTable(varargin{:});
        
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        addParameter(p, 'description',[]);
        addParameter(p, 'stimulus',[]);
        matnwb.misc.parseSkipInvalidName(p, varargin);
        obj.description = p.Results.description;
        obj.stimulus = p.Results.stimulus;
        if strcmp(class(obj), 'matnwb.types.core.IntracellularStimuliTable')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
        end
        if strcmp(class(obj), 'matnwb.types.core.IntracellularStimuliTable')
            matnwb.types.util.dynamictable.checkConfig(obj);
        end
    end
    %% SETTERS
    function set.stimulus(obj, val)
        obj.stimulus = obj.validate_stimulus(val);
    end
    %% VALIDATORS
    
    function val = validate_stimulus(obj, val)
        val = matnwb.types.util.checkDtype('stimulus', 'matnwb.types.core.TimeSeriesReferenceVectorData', val);
    end
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@matnwb.types.hdmf_common.DynamicTable(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
        refs = obj.stimulus.export(fid, [fullpath '/stimulus'], refs);
    end
end

end