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

function Upvalue.set(upvalue, value)
    setUpvalue(upvalue.Closure.Data, upvalue.Index, value)
    upvalue.Value = value
end

function Upvalue.update(upvalue, newValue)
    local value = newValue or getUpvalue(upvalue.Closure.Data, upvalue.Index)
    local scanned = upvalue.Scanned

    upvalue.Value = value

    if type(value) ~= "table" and scanned then
        upvalue.Scanned = nil
    elseif scanned then
        for i,v in pairs(value) do
            if scanned[i] then
                scanned[i] = v
            end
        end
    end
end

return Upvalue, TableUpvalue