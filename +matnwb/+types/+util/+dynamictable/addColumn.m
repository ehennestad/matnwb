function addColumn(DynamicTable, varargin)
% ADDCOLUMN Given a dynamic table and a set of keyword arguments for one or
% more columns, add one or more columns to the dynamic table by providing
% either keywords or a MATLAB table
%
%  ADDCOLUMN(DT,TABLE) append the columns of the MATLAB Table TABLE to the 
%  DynamicTable
%
%  ADDCOLUMN(DT,col_name1,col_vector1,...,col_namen,col_vectorn)
%  append specified column names and VectorData to table
%
% This function asserts the following:
% 1) DynamicTable is a valid dynamic table and has the correct
%    properties.
% 2) The height of the columns to be appended matches the height of the
% existing columns

validateattributes(DynamicTable,...
    {'matnwb.types.core.DynamicTable', 'matnwb.types.hdmf_common.DynamicTable'},...
    {'scalar'});

assert(nargin > 1, 'NWB:DynamicTable:AddColumn:NoData', 'Not enough arguments');

if isempty(DynamicTable.id)
    if 8 == exist('matnwb.types.hdmf_common.ElementIdentifiers', 'class')
        DynamicTable.id = matnwb.types.hdmf_common.ElementIdentifiers();
    else % legacy Element Identifiers
        DynamicTable.id = matnwb.types.core.ElementIdentifiers();
    end
end

assert(~isa(DynamicTable.id.data, 'matnwb.types.untyped.DataStub'),...
    'NWB:DynamicTable:AddColumn:Uneditable',...
    ['Cannot write to on-file Dynamic Tables without enabling data pipes. '...
    'If this was produced with pynwb, please enable chunking for this table.']);

if istable(varargin{1})
    matnwb.types.util.dynamictable.addTableColumn(DynamicTable, varargin{:});
else
    matnwb.types.util.dynamictable.addVarargColumn(DynamicTable, varargin{:});
end
