function checkUnset(obj, argin)
    publicProperties = properties(obj);
    objMetaClass = metaclass(obj);
    isHiddenProperty = logical([objMetaClass.PropertyList.Hidden]);
    hiddenProperties = {objMetaClass.PropertyList(isHiddenProperty).Name};
    allProperties = union(publicProperties, hiddenProperties);
    anonNames = {};
    for i = 1:length(allProperties)
        p = obj.(allProperties{i});
        if isa(p, 'matnwb.types.untyped.Anon')
            anonNames = [anonNames;{p.name}];
        elseif isa(p, 'matnwb.types.untyped.Set')
            anonNames = [anonNames;keys(p) .'];
        end
    end
    dropped = setdiff(argin, union(allProperties, anonNames));
    if ~isempty(dropped)
        warning('NWB:CheckUnset:InvalidProperties' ...
        , ['Unexpected properties {%s}.  '...
        '\n\nYour schema version may be incompatible with the file.  '...
        'Consider checking the schema version of the file with '...
        '`matnwb.util.getSchemaVersion(filename)` '...
        'and comparing with the YAML namespace version present in '...
        'nwb-schema/core/nwb.namespace.yaml'], matnwb.misc.cellPrettyPrint(dropped));
    end
end