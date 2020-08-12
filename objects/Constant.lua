local Constant = {}

function Constant.new(closure, index, value)
    local constant = {}

    constant.Closure = closure
    constant.Index = index
    constant.Value = value
    constant.Set = Constant.set
    constant.Update = Constant.update

    return constant
end

function Constant.set(constant, value)
    setConstant(constant.Closure, constant.Index, value)
    constant.Value = value
end

function Constant.update(constant)
    constant.Value = getConstant(constant.Closure, constant.Index)
end

return Constant