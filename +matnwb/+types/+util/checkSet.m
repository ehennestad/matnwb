function checkSet(pname, namedprops, constraints, val)
    if isempty(val)
        return;
    end
    
    assert(isa(val, 'matnwb.types.untyped.Set'),...
        'NWB:CheckSet:InvalidType',...
        'Property `%s` must be a `matnwb.types.untyped.Set`', pname);
    
    val.setValidationFcn(...
        @(nm, val)matnwb.types.util.checkConstraint(pname, nm, namedprops, constraints, val));
    val.validateAll();
end