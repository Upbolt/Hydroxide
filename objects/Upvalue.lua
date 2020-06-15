local Upvalue = {}
local TableUpvalue = {}

function Upvalue.new(closure, index, value)
    local upvalue = {}

    upvalue.Closure = closure
    upvalue.Index = index
    upvalue.Value = value
    upvalue.Update = Upvalue.update

    return upvalue
end

function TableUpvalue.new(closure, index, value)
    local tableUpvalue = {}

    tableUpvalue.Scanned = {} 
    tableUpvalue.Closure = closure
    tableUpvalue.Index = index
    tableUpvalue.Value = value
    tableUpvalue.Update = TableUpvalue.update

    return tableUpvalue
end

function Upvalue.update(upvalue)
    upvalue.Value = getUpvalue(upvalue.Closure, upvalue.Index)
end

function TableUpvalue.update(tableUpvalue)
    for index, value in pairs(tableUpvalue.Value) do
        tableUpvalue.Scanned[index] = value
    end
end

return Upvalue, TableUpvalue