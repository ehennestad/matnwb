function vecIndName = addVecInd(DynamicTable, colName)
%ADDVECIND Add VectorIndex object to DynamicTable
validateattributes(colName, {'char'}, {'scalartext'});
vecIndName = [colName '_index']; % arbitrary convention of appending '_index' to data column names

if isprop(DynamicTable, colName)
    VecData = DynamicTable.(colName);
elseif isprop(DynamicTable, 'vectorindex') && isKey(DynamicTable.vectorindex.Map, colName)
    VecData = DynamicTable.vectorindex.get(colName);
else
    VecData = DynamicTable.vectordata.get(colName);
end

if isa(VecData.data, 'matnwb.types.untyped.DataPipe')
    oldDataHeight = VecData.data.offset;
elseif isa(VecData.data, 'matnwb.types.untyped.DataStub')
    oldDataHeight = VecData.data.dims(end);
elseif isvector(VecData.data)
    oldDataHeight = length(VecData.data);
else
    oldDataHeight = size(VecData.data, ndims(VecData.data));
end

% we presume that if data already existed in the vectordata, then
% it was never a ragged array and thus its elements corresponded
% directly to each row index.
vecView = matnwb.types.untyped.ObjectView(VecData);
if 8 == exist('matnwb.types.hdmf_common.VectorIndex', 'class')
    VecIndex = matnwb.types.hdmf_common.VectorIndex('target', vecView, 'data', (1:oldDataHeight) .');
else
    VecIndex = matnwb.types.core.VectorIndex('target', vecView, 'data', (1:oldDataHeight) .');
end

if isprop(VecIndex, 'description')
    VecIndex.description = sprintf('Index into column %s', colName);
end

if isprop(DynamicTable, vecIndName)
    DynamicTable.(vecIndName) = VecIndex;
elseif isprop(DynamicTable, 'vectorindex')
    DynamicTable.vectorindex.set(vecIndName, VecIndex);
else
    DynamicTable.vectordata.set(vecIndName, VecIndex);
end
end