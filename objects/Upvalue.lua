local Upvalue = {}

function Upvalue.new(closure, index, value)
    local object = {}

    object.Closure = closure
    object.Index = index
    object.Value = value
    object.Update = Upvalue.update

    return object
end

function Upvalue.update(upvalue)
    upvalue.Value = getUpvalue(upvalue.Closure, upvalue.Index)
end

return Upvalue