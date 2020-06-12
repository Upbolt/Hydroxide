local Closure = {}
local Upvalue = import("objects/Upvalue")
local Constant = import("objects/Constant")

function Closure.new(data, isProto)
    local closure = {}
    
    closure.Data = data
    closure.Protos = {}
    closure.Constants = {}
    closure.Environment = getfenv(data)

    if not isProto then
        closure.Upvalues = {}
        closure.AssignUpvalues = Closure.assignUpvalues
    end
    
    closure.AssignProtos = Closure.assignProtos
    closure.AssignConstants = Closure.assignConstants

    return closure
end

function Closure.assignProtos(closure)
    local data = closure.Data
    local protos = closure.Protos

    for index, value in pairs(getProtos(closure)) do
        protos[index] = Closure.new(value, true)
    end
end

function Closure.assignUpvalues(closure)
    local data = closure.Data
    local upvalues = closure.Upvalues

    for index, value in pairs(getUpvalues(closure)) do
        upvalues[index] = Upvalue.new(data, index, value)
    end
end

function Closure.assignConstants(closure)
    local data = closure.Data
    local constants = closure.Constants

    for index, value in pairs(getConstants(closure)) do
        constants[index] = Constant.new(data, index, value)
    end
end

return Closure