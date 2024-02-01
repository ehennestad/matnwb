function clear(DynamicTable)
%CLEAR Given a valid DynamicTable object, clears all rows and type
%   information in the table.
validateattributes(DynamicTable, {'matnwb.types.hdmf_common.DynamicTable'}, {'scalar'});
DynamicTable.id = matnwb.types.hdmf_common.ElementIdentifiers();

DynamicTable.vectordata = matnwb.types.untyped.Set(@(nm, val)matnwb.types.util.checkConstraint(...
    'vectordata', nm, struct(), {'matnwb.types.hdmf_common.VectorData'}, val));
if isprop(DynamicTable, 'vectorindex') % Schema version <2.3.0
    DynamicTable.vectorindex = matnwb.types.untyped.Set(@(nm, val)matnwb.types.util.checkConstraint(...
        'vectorindex', nm, struct(), {'matnwb.types.hdmf_common.VectorIndex'}, val));
end
end