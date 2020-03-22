local table = {}
local element = {}

local text_service = game:GetService("TextService")

table.new = function(closure, data)
    local object = {}

    object.elements = {}

    return object
end

table.update = function(table)
    local data = table.data
    local elements = table.elements

    for i,v in pairs(elements) do
        --if 
    end
end

element.new = function(table, index)
    local object = {}
    local data = table.data

    object.table = table
    object.index = index
    object.value = data[index]

    return object
end

element.update = function(element)
    local table = element.table
    local table_data = table.data

    if table_data[element.id] ~= element.value then
        
    end
end

return table