--- Sets the data table to use to get the list data.
--- @param listBoxName string The name of the ListBox.
--- @param dataTable string The name of a valid lua table.
function ListBoxSetDataTable(listBoxName, dataTable) end

--- Returns the  data-table index that is currently display on a particular row index.
--- @param listBoxName string The name of the ListBox.
--- @param rowIndex number The row index on the list box ( 1 -> max vis rows )
--- @return dataIndex number The index in the ListData lua table.
function ListBoxGetDataIndex(listBoxName, rowIndex) end

--- Sets the order in which the data list is displayed.  This function allows you to both sort and filter in lua.
--- @param listBoxName string The name of the ListBox.
--- @param displayOrder number-table The data-indicies in the order that they should be displayed.
function ListBoxSetDisplayOrder(listBoxName, displayOrder) end

--- Sets the maximum number of rows that can be displayed on the screen at once.
--- @param listBoxName string The name of the ListBox.
--- @param visibleRows number Sets the max number of rows to display at once.
function ListBoxSetVisibleRowCount(listBoxName, visibleRows) end

ListBox = ListBox or {}
