classdef Subject < matnwb.types.core.NWBContainer & matnwb.types.untyped.GroupClass
% SUBJECT Information about the animal or person from which the data was measured.


% OPTIONAL PROPERTIES
properties
    age; %  (char) Age of subject. Can be supplied instead of 'date_of_birth'.
    age_reference; %  (char) Age is with reference to this event. Can be 'birth' or 'gestational'. If reference is omitted, 'birth' is implied.
    date_of_birth; %  (datetime) Date of birth of subject. Can be supplied instead of 'age'.
    description; %  (char) Description of subject and where subject came from (e.g., breeder, if animal).
    genotype; %  (char) Genetic strain. If absent, assume Wild Type (WT).
    sex; %  (char) Gender of subject.
    species; %  (char) Species of subject.
    strain; %  (char) Strain of subject.
    subject_id; %  (char) ID of animal/person used/participating in experiment (lab convention).
    weight; %  (char) Weight at time of experiment, at time of surgery and at other important times.
end

methods
    function obj = Subject(varargin)
        % SUBJECT Constructor for Subject
        varargin = [{'age_reference' 'birth'} varargin];
        obj = obj@matnwb.types.core.NWBContainer(varargin{:});
        
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        addParameter(p, 'age',[]);
        addParameter(p, 'age_reference',[]);
        addParameter(p, 'date_of_birth',[]);
        addParameter(p, 'description',[]);
        addParameter(p, 'genotype',[]);
        addParameter(p, 'sex',[]);
        addParameter(p, 'species',[]);
        addParameter(p, 'strain',[]);
        addParameter(p, 'subject_id',[]);
        addParameter(p, 'weight',[]);
        matnwb.misc.parseSkipInvalidName(p, varargin);
        obj.age = p.Results.age;
        obj.age_reference = p.Results.age_reference;
        obj.date_of_birth = p.Results.date_of_birth;
        obj.description = p.Results.description;
        obj.genotype = p.Results.genotype;
        obj.sex = p.Results.sex;
        obj.species = p.Results.species;
        obj.strain = p.Results.strain;
        obj.subject_id = p.Results.subject_id;
        obj.weight = p.Results.weight;
        if strcmp(class(obj), 'matnwb.types.core.Subject')
            cellStringArguments = convertContainedStringsToChars(varargin(1:2:end));
            matnwb.types.util.checkUnset(obj, unique(cellStringArguments));
        end
    end
    %% SETTERS
    function set.age(obj, val)
        obj.age = obj.validate_age(val);
    end
    function set.age_reference(obj, val)
        obj.age_reference = obj.validate_age_reference(val);
    end
    function set.date_of_birth(obj, val)
        obj.date_of_birth = obj.validate_date_of_birth(val);
    end
    function set.description(obj, val)
        obj.description = obj.validate_description(val);
    end
    function set.genotype(obj, val)
        obj.genotype = obj.validate_genotype(val);
    end
    function set.sex(obj, val)
        obj.sex = obj.validate_sex(val);
    end
    function set.species(obj, val)
        obj.species = obj.validate_species(val);
    end
    function set.strain(obj, val)
        obj.strain = obj.validate_strain(val);
    end
    function set.subject_id(obj, val)
        obj.subject_id = obj.validate_subject_id(val);
    end
    function set.weight(obj, val)
        obj.weight = obj.validate_weight(val);
    end
    %% VALIDATORS
    
    function val = validate_age(obj, val)
        val = matnwb.types.util.checkDtype('age', 'char', val);
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
    function val = validate_age_reference(obj, val)
        val = matnwb.types.util.checkDtype('age_reference', 'char', val);
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
    function val = validate_date_of_birth(obj, val)
        val = matnwb.types.util.checkDtype('date_of_birth', 'datetime', val);
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
    function val = validate_genotype(obj, val)
        val = matnwb.types.util.checkDtype('genotype', 'char', val);
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
    function val = validate_sex(obj, val)
        val = matnwb.types.util.checkDtype('sex', 'char', val);
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
    function val = validate_species(obj, val)
        val = matnwb.types.util.checkDtype('species', 'char', val);
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
    function val = validate_strain(obj, val)
        val = matnwb.types.util.checkDtype('strain', 'char', val);
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
    function val = validate_subject_id(obj, val)
        val = matnwb.types.util.checkDtype('subject_id', 'char', val);
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
    function val = validate_weight(obj, val)
        val = matnwb.types.util.checkDtype('weight', 'char', val);
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
        refs = export@matnwb.types.core.NWBContainer(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
        if ~isempty(obj.age)
            if startsWith(class(obj.age), 'matnwb.types.untyped.')
                refs = obj.age.export(fid, [fullpath '/age'], refs);
            elseif ~isempty(obj.age)
                matnwb.io.writeDataset(fid, [fullpath '/age'], obj.age);
            end
        end
        if ~isempty(obj.age) && ~isa(obj.age, 'matnwb.types.untyped.SoftLink') && ~isa(obj.age, 'matnwb.types.untyped.ExternalLink') && ~isempty(obj.age_reference)
            matnwb.io.writeAttribute(fid, [fullpath '/age/reference'], obj.age_reference);
        end
        if ~isempty(obj.date_of_birth)
            if startsWith(class(obj.date_of_birth), 'matnwb.types.untyped.')
                refs = obj.date_of_birth.export(fid, [fullpath '/date_of_birth'], refs);
            elseif ~isempty(obj.date_of_birth)
                matnwb.io.writeDataset(fid, [fullpath '/date_of_birth'], obj.date_of_birth);
            end
        end
        if ~isempty(obj.description)
            if startsWith(class(obj.description), 'matnwb.types.untyped.')
                refs = obj.description.export(fid, [fullpath '/description'], refs);
            elseif ~isempty(obj.description)
                matnwb.io.writeDataset(fid, [fullpath '/description'], obj.description);
            end
        end
        if ~isempty(obj.genotype)
            if startsWith(class(obj.genotype), 'matnwb.types.untyped.')
                refs = obj.genotype.export(fid, [fullpath '/genotype'], refs);
            elseif ~isempty(obj.genotype)
                matnwb.io.writeDataset(fid, [fullpath '/genotype'], obj.genotype);
            end
        end
        if ~isempty(obj.sex)
            if startsWith(class(obj.sex), 'matnwb.types.untyped.')
                refs = obj.sex.export(fid, [fullpath '/sex'], refs);
            elseif ~isempty(obj.sex)
                matnwb.io.writeDataset(fid, [fullpath '/sex'], obj.sex);
            end
        end
        if ~isempty(obj.species)
            if startsWith(class(obj.species), 'matnwb.types.untyped.')
                refs = obj.species.export(fid, [fullpath '/species'], refs);
            elseif ~isempty(obj.species)
                matnwb.io.writeDataset(fid, [fullpath '/species'], obj.species);
            end
        end
        if ~isempty(obj.strain)
            if startsWith(class(obj.strain), 'matnwb.types.untyped.')
                refs = obj.strain.export(fid, [fullpath '/strain'], refs);
            elseif ~isempty(obj.strain)
                matnwb.io.writeDataset(fid, [fullpath '/strain'], obj.strain);
            end
        end
        if ~isempty(obj.subject_id)
            if startsWith(class(obj.subject_id), 'matnwb.types.untyped.')
                refs = obj.subject_id.export(fid, [fullpath '/subject_id'], refs);
            elseif ~isempty(obj.subject_id)
                matnwb.io.writeDataset(fid, [fullpath '/subject_id'], obj.subject_id);
            end
        end
        if ~isempty(obj.weight)
            if startsWith(class(obj.weight), 'matnwb.types.untyped.')
                refs = obj.weight.export(fid, [fullpath '/weight'], refs);
            elseif ~isempty(obj.weight)
                matnwb.io.writeDataset(fid, [fullpath '/weight'], obj.weight);
            end
        end
    end
end

end