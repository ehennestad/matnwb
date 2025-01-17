%% NWB File Conversion Tutorial
% How to convert trial-based experimental data to the Neurodata Without Borders file format using MatNWB.
% This example uses the <https://crcns.org/data-sets/motor-cortex/alm-3 CRCNS ALM-3>
% data set.  Information on how to download the data can be found on the 
% <https://crcns.org/data-sets/motor-cortex/download CRCNS Download Page>.  One should
% first familiarize themselves with the file format, which can be found on the
% <https://crcns.org/data-sets/motor-cortex/alm-3/about-alm-3 ALM-3 About Page> under
% the Documentation files.
% 
%  author: Lawrence Niu
%  contact: lawrence@vidriotech.com
%  last updated: May 27, 2021

%% Script Configuration
% The following details configuration parameters specific to the publishing script,
% and can be skipped when implementing your own conversion.
% The parameters can be changed to fit any of the available sessions.

animal = 'ANM255201';
session = '20141124';

identifier = [animal '_' session];

metadata_loc = fullfile('data','metadata', ['meta_data_' identifier '.mat']);
datastructure_loc = fullfile('data','data_structure_files',...
    ['data_structure_' identifier '.mat']);
rawdata_loc = fullfile('data', 'RawVoltageTraces', [identifier '.tar']);
%%
% The animal and session specifier can be changed with the |animal| and |session|
% variable name respectively.  |metadata_loc|, |datastructure_loc|, and |rawdata_loc|
% should refer to the metadata .mat file, the data structure .mat file, 
% and the raw .tar file.

outloc = 'out';

if 7 ~= exist(outloc, 'dir')
    mkdir(outloc);
end

source_file = [mfilename() '.m'];
[~, source_script, ~] = fileparts(source_file);
%%
% The NWB file will be saved in the output directory indicated by |outdir|

%% General Information

nwb = NwbFile();
nwb.identifier = identifier;
nwb.general_source_script = source_script;
nwb.general_source_script_file_name = source_file;
nwb.general_lab = 'Svoboda';
nwb.general_keywords = {'Network models', 'Premotor cortex', 'Short-term memory'};
nwb.general_institution = ['Janelia Research Campus,'...
    ' Howard Huges Medical Institute, Ashburn, Virginia 20147, USA'];
nwb.general_related_publications = ...
    ['Li N, Daie K, Svoboda K, Druckmann S (2016).',...
    ' Robust neuronal dynamics in premotor cortex during motor planning.',...
    ' Nature. 7600:459-64. doi: 10.1038/nature17643'];
nwb.general_stimulus = 'photostim';
nwb.general_protocol = 'IACUC';
nwb.general_surgery = ['Mice were prepared for photoinhibition and ',...
    'electrophysiology with a clear-skull cap and a headpost. ',...
    'The scalp and periosteum over the dorsal surface of the skull were removed. ',...
    'A layer of cyanoacrylate adhesive (Krazy glue, Elmer''s Products Inc.) ',...
    'was directly applied to the intact skull. A custom made headpost ',...
    'was placed on the skull with its anterior edge aligned with the suture lambda ',...
    '(approximately over cerebellum) and cemented in place ',...
    'with clear dental acrylic (Lang Dental Jet Repair Acrylic; 1223-clear). ',...
    'A thin layer of clear dental acrylic was applied over the cyanoacrylate adhesive ',...
    'covering the entire exposed skull, ',...
    'followed by a thin layer of clear nail polish (Electron Microscopy Sciences, 72180).'];
nwb.session_description = sprintf('Animal `%s` on Session `%s`', animal, session);
%%
% All properties with the prefix |general| contain context for the entire experiment
% such as lab, institution, and experimentors.  For session-delimited data from the
% same experiment, these fields will all be the same.  Note that most of this
% information was pulled from the publishing paper and not from any of the downloadable data.
%%
% The only required property is the |identifier|, which distinguishes one session from
% another within an experiment.  In our case, the ALM-3 data uses a combination of
% session date and animal ID.

%% The ALM-3 File Structure
% Each ALM-3 session has three files: a metadata .mat file describing the experiment, a
% data structures .mat file containing analyzed data, and a raw .tar archive
% containing multiple raw electrophysiology data separated by trial as .mat files.
% All files will be merged into a single NWB file.

%% Metadata
% ALM-3 Metadata contains information about the reference times, experimental context,
% methodology, as well as details of the electrophysiology, optophysiology, and behavioral
% portions of the experiment.  A vast majority of these details are placed in |general|
% prefixed properties in NWB.
fprintf('Processing Meta Data from `%s`\n', metadata_loc);
loaded = load(metadata_loc, 'meta_data');
meta = loaded.meta_data;

%experiment-specific treatment for animals with the ReaChR gene modification
isreachr = any(cell2mat(strfind(meta.animalGeneModification, 'ReaChR')));

%sessions are separated by date of experiment.
nwb.general_session_id = meta.dateOfExperiment;

%ALM-3 data start time is equivalent to the reference time.
nwb.session_start_time = datetime([meta.dateOfExperiment meta.timeOfExperiment],...
    'InputFormat', 'yyyyMMddHHmmss');
nwb.timestamps_reference_time = nwb.session_start_time;

nwb.general_experimenter = strjoin(meta.experimenters, ', ');

%%
nwb.general_subject = matnwb.types.core.Subject(...
    'species', meta.species{1}, ...
    'subject_id', meta.animalID{1}(1,:), ... %weird case with duplicate Animal ID
    'sex', meta.sex, ...
    'age', meta.dateOfBirth, ...
    'description', [...
        'Whisker Config: ' strjoin(meta.whiskerConfig, ', ') newline...
        'Animal Source: ' strjoin(meta.animalSource, ', ')]);
%%
% Ideally, if a raw data field does not correspond directly to a NWB field, one would
% create their own using a
% <https://pynwb.readthedocs.io/en/latest/extensions.html custom NWB extension class>.
% However, since these fields are mostly experimental annotations, we instead pack the
% extra values into the |description| field as a string.

%The formatStruct function simply prints the field and values given the struct.
%An optional cell array of field names specifies whitelist of fields to print.  This
%function is provided with this script in the tutorials directory.
nwb.general_subject.genotype = formatStruct(...
    meta, ...
    {'animalStrain'; 'animalGeneModification'; 'animalGeneCopy';...
    'animalGeneticBackground'});

weight = {};
if ~isempty(meta.weightBefore)
    weight{end+1} = 'weightBefore';
end
if ~isempty(meta.weightAfter)
    weight{end+1} = 'weightAfter';
end
weight = weight(~cellfun('isempty', weight));
if ~isempty(weight)
    nwb.general_subject.weight = formatStruct(meta, weight);
end

% general/experiment_description
nwb.general_experiment_description = [...
    formatStruct(meta, {'experimentType'; 'referenceAtlas'}), ...
    newline, ...
    formatStruct(meta.behavior, {'task_keyword'})];

% Miscellaneous collection information from ALM-3 that didn't quite fit any NWB properties
% are stored in general/data_collection.
nwb.general_data_collection = formatStruct(meta.extracellular,...
    {'extracellularDataType';'cellType';'identificationMethod';'amplifierRolloff';...
    'spikeSorting';'ADunit'});

% Device objects are essentially just a list of device names.  We store the probe
% and laser hardware names here.
probetype = meta.extracellular.probeType{1};
probeSource = meta.extracellular.probeSource{1};
deviceName = [probetype ' (' probeSource ')'];
nwb.general_devices.set(deviceName, matnwb.types.core.Device());

if isreachr
    laserName = 'laser-594nm (Cobolt Inc., Cobolt Mambo 100)';
else
    laserName = 'laser-473nm (Laser Quantum, Gem 473)';
end
nwb.general_devices.set(laserName, matnwb.types.core.Device());

%%
structDesc = {'recordingCoordinates';'recordingMarker';'recordingType';'penetrationN';...
    'groundCoordinates'};
if ~isempty(meta.extracellular.referenceCoordinates)
    structDesc{end+1} = 'referenceCoordinates';
end
recordingLocation = meta.extracellular.recordingLocation{1};
egroup = matnwb.types.core.ElectrodeGroup(...
    'description', formatStruct(meta.extracellular, structDesc),...
    'location', recordingLocation,...
    'device', matnwb.types.untyped.SoftLink(['/general/devices/' deviceName]));
nwb.general_extracellular_ephys.set(deviceName, egroup);
%%
% The NWB *ElectrodeGroup* object stores experimental information regarding a group of
% probes.  Doing so requires a *SoftLink* to the probe specified under
% |general_devices|.  SoftLink objects are direct maps to
% <https://portal.hdfgroup.org/display/HDF5/H5L_CREATE_SOFT HDF5 Soft Links> on export,
% and thus, require a true HDF5 path.

% you can specify column names and values as key-value arguments in the DynamicTable
% constructor.
dtColNames = {'x', 'y', 'z', 'imp', 'location', 'filtering','group',...
    'group_name'};
dynTable = matnwb.types.hdmf_common.DynamicTable(...
    'colnames', dtColNames,...
    'description', 'Electrodes',...
    'x', matnwb.types.hdmf_common.VectorData('description', 'x coordinate of the channel location in the brain (+x is posterior).'),...
    'y', matnwb.types.hdmf_common.VectorData('description', 'y coordinate of the channel location in the brain (+y is inferior).'),...
    'z', matnwb.types.hdmf_common.VectorData('description', 'z coordinate of the channel location in the brain (+z is right).'),...
    'imp', matnwb.types.hdmf_common.VectorData('description', 'Impedance of the channel.'),...
    'location', matnwb.types.hdmf_common.VectorData('description', ['Location of the electrode (channel). '...
    'Specify the area, layer, comments on estimation of area/layer, stereotaxic coordinates if '...
    'in vivo, etc. Use standard atlas names for anatomical regions when possible.']),...
    'filtering', matnwb.types.hdmf_common.VectorData('description', 'Description of hardware filtering.'),...
    'group', matnwb.types.hdmf_common.VectorData('description', 'Reference to the ElectrodeGroup this electrode is a part of.'),...
    'group_name', matnwb.types.hdmf_common.VectorData('description', 'Name of the ElectrodeGroup this electrode is a part of.'));

%raw HDF5 path to the above electrode group. Referenced by
% the general/extracellular_ephys Dynamic Table
egroupPath = ['/general/extracellular_ephys/' deviceName];
eGroupReference = matnwb.types.untyped.ObjectView(egroupPath);
for i = 1:length(meta.extracellular.siteLocations)
    location = meta.extracellular.siteLocations{i};
    % add each row in the dynamic table. The `id` column is populated
    % dynamically.
    dynTable.addRow(...
        'x', location(1), 'y', location(2), 'z', location(3),...
        'imp', 0,...
        'location', recordingLocation,...
        'filtering', '',...
        'group', eGroupReference,...
        'group_name', probetype);
end
%%
% The |group| column in the Dynamic Table contains an *ObjectView* to the previously
% created |ElectrodeGroup|.  An |ObjectView| can be best thought of as a direct
% pointer to another typed object.  It also directly maps to a 
% <https://portal.hdfgroup.org/display/HDF5/H5R_CREATE HDF5 Object Reference>,
% thus the HDF5 path requirement.  |ObjectViews| are slightly different from |SoftLinks|
% in that they can be stored in datasets (data columns, tables, and |data| fields in
% |NWBData| objects).

nwb.general_extracellular_ephys_electrodes = dynTable;
%%
% The |electrodes| property in |extracellular_ephys| is a special keyword in NWB that
% must be paired with a *Dynamic Table*.  These are tables which can have an unbounded
% number of columns and rows, each as their own dataset.  With the exception of the |id|
% column, all other columns must be *VectorData* or *VectorIndex* objects.  The |id|
% column, meanwhile, must be an *ElementIdentifiers* object.  The names of all used
% columns are specified in the in the |colnames| property as a cell array of strings.

% general/optogenetics/photostim
nwb.general_optogenetics.set('photostim', ...
    matnwb.types.core.OptogeneticStimulusSite(...
    'excitation_lambda', meta.photostim.photostimWavelength{1}, ...
    'location', meta.photostim.photostimLocation{1}, ...
    'device', matnwb.types.untyped.SoftLink(['/general/devices/' laserName]), ...
    'description', formatStruct(meta.photostim, {...
    'stimulationMethod';'photostimCoordinates';'identificationMethod'})));
%% Analysis Data Structure
% The ALM-3 data structures .mat file contains analyzed spike data, trial-specific
% parameters, and behavioral analysis data.
%% Hashes
% ALM-3 stores its data structures in the form of *hashes* which are essentially the
% same as python's dictionaries or MATLAB's maps but where the keys and values
% are stored under separate struct fields.  Getting a hashed value from a key
% involves retrieving the array index that the key is in and applying it to the
% parallel array in the values field.
%%
% You can find more information about hashes and how they're used on the
% <https://crcns.org/data-sets/motor-cortex/alm-3/about-alm-3 ALM-3 about page>.
fprintf('Processing Data Structure `%s`\n', datastructure_loc);
loaded = load(datastructure_loc, 'obj');
data = loaded.obj;

% wherein each cell is one trial. We must populate this way because trials
% may not be in trial order.
% Trial timeseries will be a compound type under intervals/trials.
trial_timeseries = cell(size(data.trialIds)); 

%%
% NWB comes with default support for trial-based data.  These must be *TimeIntervals* that
% are placed in the |intervals| property.  Note that |trials| is a special
% keyword that is required for PyNWB compatibility.

ephus = data.timeSeriesArrayHash.value{1};
ephusUnit = data.timeUnitNames{data.timeUnitIds(ephus.timeUnit)};

% lick direction and timestamps trace
tsIdx = strcmp(ephus.idStr, 'lick_trace');
bts = matnwb.types.core.BehavioralTimeSeries();

bts.timeseries.set('lick_trace_ts', ...
    matnwb.types.core.TimeSeries(...
    'data', ephus.valueMatrix(:,tsIdx),...
    'data_unit', ephusUnit,...
    'description', ephus.idStrDetailed{tsIdx}, ...
    'timestamps', ephus.time, ...
    'timestamps_unit', ephusUnit));
nwb.acquisition.set('lick_trace', bts);
bts_ref = matnwb.types.untyped.ObjectView('/acquisition/lick_trace/lick_trace_ts');

% acousto-optic modulator input trace
tsIdx = strcmp(ephus.idStr, 'aom_input_trace');
ts = matnwb.types.core.TimeSeries(...
    'data', ephus.valueMatrix(:,tsIdx), ...
    'data_unit', 'Volts', ...
    'description', ephus.idStrDetailed{tsIdx}, ...
    'timestamps', ephus.time, ...
    'timestamps_unit', ephusUnit);
nwb.stimulus_presentation.set('aom_input_trace', ts);
ts_ref = matnwb.types.untyped.ObjectView('/stimulus/presentation/aom_input_trace');

% laser power
tsIdx = strcmp(ephus.idStr, 'laser_power');
ots = matnwb.types.core.OptogeneticSeries(...
    'data', ephus.valueMatrix(:,tsIdx), ...
    'data_unit', 'mW', ...
    'description', ephus.idStrDetailed{tsIdx}, ...
    'timestamps', ephus.time, ...
    'timestamps_unit', ephusUnit, ...
    'site', matnwb.types.untyped.SoftLink('/general/optogenetics/photostim'));
nwb.stimulus_presentation.set('laser_power', ots);
ots_ref = matnwb.types.untyped.ObjectView('/stimulus/presentation/laser_power');

% append trials timeseries references in order
[ephus_trials, ~, trials_to_data] = unique(ephus.trial);
for i=1:length(ephus_trials)
    i_loc = i == trials_to_data;
    t_start = find(i_loc, 1);
    t_count = sum(i_loc);
    trial = ephus_trials(i);
    
    trial_timeseries{trial}(end+(1:3), :) = {...
        bts_ref int64(t_start) int64(t_count);...
        ts_ref  int64(t_start) int64(t_count);...
        ots_ref int64(t_start) int64(t_count)};
end

%%
% The |timeseries| property of the |TimeIntervals| object is an example of a
% *compound data type*.  These types are essentially tables of data in HDF5 and can
% be represented by a MATLAB table, an array of structs, or a struct of arrays.
% Beware: validation of column lengths here is not guaranteed by the type checker
% until export.
%%
% *VectorIndex* objects index into a larger *VectorData* column.  The object that is
% being referenced is indicated by the |target| property, which uses an ObjectView.
% Each element in the VectorIndex marks the *last* element in the corresponding
% vector data object for the VectorIndex row.  Thus, the starting index for this
% row would be the previous index + 1.  Note that these indices must be 0-indexed
% for compatibility with pynwb.  You can see this in effect with the |timeseries|
% property which is indexed by the |timeseries_index| property.
%%
% Though TimeIntervals is a subclass of the DynamicTable type, we opt for
% populating the Dynamic Table data by column instead of using `addRow`
% here because of how the data is formatted. DynamicTable is flexible
% enough to accomodate both styles of data conversion.
trials_epoch = matnwb.types.core.TimeIntervals(...
    'colnames', {'start_time'}, ...
    'description', 'trial data and properties', ...
    'start_time', matnwb.types.hdmf_common.VectorData( ...
        'data', data.trialStartTimes, ...
        'description', 'Start time of epoch, in seconds.'), ...
    'id', matnwb.types.hdmf_common.ElementIdentifiers( ...
        'data', data.trialIds));

% Add columns for the trial types
for i=1:length(data.trialTypeStr)
    columnName = data.trialTypeStr{i};
    columnData = matnwb.types.hdmf_common.VectorData(...
        'data', data.trialTypeMat(i,:)', ... % transpose for column vector 
        'description', data.trialTypeStr{i});
    trials_epoch.addColumn( columnName, columnData )
end

% Add columns for the trial properties
for i=1:length(data.trialPropertiesHash.keyNames)
    columnName = data.trialPropertiesHash.keyNames{i};
    descr = data.trialPropertiesHash.descr{i};
    if iscellstr(descr)
        descr = strjoin(descr, newline);
    end
    columnData = matnwb.types.hdmf_common.VectorData(...
        'data', data.trialPropertiesHash.value{i},...
        'description', data.trialTypeStr{i});
    trials_epoch.addColumn( columnName, columnData )
end

nwb.intervals_trials = trials_epoch;

%%
% Ephus spike data is separated into units which directly maps to the NWB property
% of the same name.  Each such unit contains a group of analysed waveforms and spike
% times, all linked to a different subset of trials IDs.

%%
% The waveforms are placed in the |analysis| Set and are paired with their unit name
% ('unitx' where 'x' is some unit ID).

%%
% Trial IDs, wherever they are used, are placed in a relevent |control| property in the
% data object and will indicate what data is associated with what trial as
% defined in |trials|'s |id| column.

nwb.units = matnwb.types.core.Units('colnames',...
    {'spike_times', 'trials', 'waveforms'},...
    'description', 'Analysed Spike Events');
esHash = data.eventSeriesHash;
ids = regexp(esHash.keyNames, '^unit(\d+)$', 'once', 'tokens');
ids = str2double([ids{:}]);
nwb.units.spike_times = matnwb.types.hdmf_common.VectorData(...
    'description', 'timestamps of spikes');

for i=1:length(ids)
    esData = esHash.value{i};
    % add trials ID reference
    
    good_trials_mask = ismember(esData.eventTrials, nwb.intervals_trials.id.data);
    eventTrials = esData.eventTrials(good_trials_mask);
    eventTimes = esData.eventTimes(good_trials_mask);
    waveforms = esData.waveforms(good_trials_mask,:);
    channel = esData.channel(good_trials_mask);
    
    % add waveform data to "unitx" and associate with "waveform" column as ObjectView.
    ses = matnwb.types.core.SpikeEventSeries(...
        'control', ids(i),...
        'control_description', 'Units Table ID',...
        'data', waveforms .', ...
        'description', esHash.descr{i}, ...
        'timestamps', eventTimes, ...
        'timestamps_unit', data.timeUnitNames{data.timeUnitIds(esData.timeUnit)},...
        'electrodes', matnwb.types.hdmf_common.DynamicTableRegion(...
            'description', 'Electrodes involved with these spike events',...
            'table', matnwb.types.untyped.ObjectView('/general/extracellular_ephys/electrodes'),...
            'data', channel - 1));
    ses_name = esHash.keyNames{i};
    ses_ref = matnwb.types.untyped.ObjectView(['/analysis/', ses_name]);
    if ~isempty(esData.cellType)
        ses.comments = ['cellType: ' esData.cellType{1}];
    end
    nwb.analysis.set(ses_name, ses);
    nwb.units.addRow(...
        'id', ids(i), 'trials', eventTrials,'spike_times', eventTimes, 'waveforms', ses_ref);
    
    %add this timeseries into the trials table as well.
    [s_trials, ~, trials_to_data] = unique(eventTrials);
    for j=1:length(s_trials)
        trial = s_trials(j);
        j_loc = j == trials_to_data;
        t_start = find(j_loc, 1);
        t_count = sum(j_loc);
        
        trial_timeseries{trial}(end+1, :) = {ses_ref int64(t_start) int64(t_count)};
    end
end
%%
% To better understand how |spike_times_index| and |spike_times| map to each other, refer to
% <https://neurodatawithoutborders.github.io/matnwb/tutorials/html/ecephys.html#13 this
% diagram> from the Extracellular Electrophysiology Tutorial.

%% Raw Acquisition Data
% Each ALM-3 session is associated with a large number of raw voltage data grouped by
% trial ID. To map this data to NWB, each trial is created as its own *ElectricalSeries*
% object under the name 'trial n' where 'n' is the trial ID.  The trials are then linked
% to the |trials| dynamic table for easy referencing.
fprintf('Processing Raw Acquisition Data from `%s` (will take a while)\n', rawdata_loc);
untarLoc = fullfile(pwd, identifier);
if 7 ~= exist(untarLoc, 'dir')
    untar(rawdata_loc, pwd);
end

rawfiles = dir(untarLoc);
rawfiles = fullfile(untarLoc, {rawfiles(~[rawfiles.isdir]).name});

nrows = length(nwb.general_extracellular_ephys_electrodes.id.data);
tablereg = matnwb.types.hdmf_common.DynamicTableRegion(...
    'description','Relevent Electrodes for this Electrical Series',...
    'table',matnwb.types.untyped.ObjectView('/general/extracellular_ephys/electrodes'),...
    'data',(1:nrows) - 1);
objrefs = cell(size(rawfiles));

endTimestamps = trials_epoch.start_time.data;
for i=1:length(rawfiles)
    tnumstr = regexp(rawfiles{i}, '_trial_(\d+)\.mat$', 'tokens', 'once');
    tnumstr = tnumstr{1};
    rawdata = load(rawfiles{i}, 'ch_MUA', 'TimeStamps');
    tnum = str2double(tnumstr);
    
    if tnum > length(endTimestamps)
        continue; % sometimes there are extra trials without an associated start time.
    end
    
    es = matnwb.types.core.ElectricalSeries(...
        'data', rawdata.ch_MUA,...
        'description', ['Raw Voltage Acquisition for trial ' tnumstr],...
        'electrodes', tablereg,...
        'timestamps', rawdata.TimeStamps);
    tname = ['trial ' tnumstr];
    nwb.acquisition.set(tname, es);
    
    endTimestamps(tnum) = endTimestamps(tnum) + rawdata.TimeStamps(end);
    objrefs{tnum} = matnwb.types.untyped.ObjectView(['/acquisition/' tname]);
end

%Link to the raw data by adding the acquisition column with ObjectViews
%to the data
emptyrefs = cellfun('isempty', objrefs);
objrefs(emptyrefs) = {matnwb.types.untyped.ObjectView('')};

trials_epoch.addColumn('acquisition', matnwb.types.hdmf_common.VectorData(...
    'description', 'soft link to acquisition data for this trial',...
    'data', [objrefs{:}]'));

trials_epoch.stop_time = matnwb.types.hdmf_common.VectorData(...
    'data', endTimestamps',...
    'description', 'the end time of each trial');
trials_epoch.colnames{end+1} = 'stop_time';

%% Add timeseries to trials_epoch
%first, we'll format and store |trial_timeseries| into |intervals_trials|.
% note that |timeseries_index| data is 0-indexed.
ts_len = cellfun('size', trial_timeseries, 1);
nwb.intervals_trials.timeseries_index = types.hdmf_common.VectorIndex(...
        'description', 'Index into Timeseries VectorData', ...
        'data', cumsum(ts_len)', ...
        'target', types.untyped.ObjectView('/intervals/trials/timeseries') );

% intervals/trials/timeseries is a compound type so we use cell2table to
% convert this 2-d cell array into a compatible table.
is_len_nonzero = ts_len > 0;
trial_timeseries_table = cell2table(vertcat(trial_timeseries{is_len_nonzero}),...
    'VariableNames', {'timeseries', 'idx_start', 'count'});
trial_timeseries_table = movevars(trial_timeseries_table, 'timeseries', 'After', 'count');

interval_trials_timeseries = types.core.TimeSeriesReferenceVectorData(...
    'description', 'Index into TimeSeries data', ...
    'data', trial_timeseries_table);
nwb.intervals_trials.timeseries = interval_trials_timeseries;
nwb.intervals_trials.colnames{end+1} = 'timeseries';

%% Export
outDest = fullfile(outloc, [identifier '.nwb']);
if 2 == exist(outDest, 'file')
    delete(outDest);
end
nwbExport(nwb, outDest);