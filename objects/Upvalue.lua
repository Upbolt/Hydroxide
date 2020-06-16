local Upvalue = {}
local TableUpvalue = {}

function Upvalue.new(closure, index, value)
    local upvalue = {}

    upvalue.Closure = closure
    upvalue.Index = index
    upvalue.Value = value
    upvalue.Set = Upvalue.set
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

function Upvalue.set(upvalue, index, value)
    setUpvalue(upvalue.Closure.Data, upvalue.Index, value)
    upvalue.Value = value
end

function Upvalue.update(upvalue)
    upvalue.Value = getUpvalue(upvalue.Closure.Data, upvalue.Index)
end

function TableUpvalue.set(tableUpvalue, index, value)
    if tableUpvalue.Scanned[index] then
        tableUpvalue.Value[index] = value
        tableUpvalue.Scanned[index] = value
    end
end

function TableUpvalue.update(tableUpvalue)
    for index, value in pairs(tableUpvalue.Value) do
        tableUpvalue.Scanned[index] = value
    end
end

return Upvalue, TableUpvalue