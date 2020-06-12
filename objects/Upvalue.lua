local Upvalue = {}

function Upvalue.new(closure, index, value)
    local upvalue = {}

    upvalue.Closure = closure
    upvalue.Index = index
    upvalue.Value = value
    upvalue.Update = Upvalue.update

    return upvalue
end

function Upvalue.update(upvalue)
    upvalue.Value = getUpvalue(upvalue.Closure, upvalue.Index)
end

return Upvalue