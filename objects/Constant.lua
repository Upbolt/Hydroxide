local Constant = {}

function Constant.new(closure, index, value)
    local object = {}

    object.Closure = closure
    object.Index = index
    object.Value = value
    object.Update = Constant.update

    return object
end

function Constant.update(constant)
    constant.Value = getConstant(constant.Closure, constant.Index)
end

return Constant