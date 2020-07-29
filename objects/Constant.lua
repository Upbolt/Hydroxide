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

function Constant.set(constant, index, value)
    setConstant(constant.Closure, constant.Index, value)
    constant.Value = value
end

function Constant.update(constant)
    if is_protosmasher_caller() then
        local PS_ThreadConstants = debug.getconstants(constant.Closure)
        constant.Value = PS_ThreadConstants[constant.Index]
    else
        constant.Value = getConstant(constant.Closure, constant.Index)
    end
end

return Constant
