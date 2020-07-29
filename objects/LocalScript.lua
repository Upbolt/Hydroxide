local LocalScript = {}

function LocalScript.new(instance)
    local localScript = {}
    local closure = getScriptClosure(instance)

    localScript.Instance = instance
    localScript.Environment = getSenv(instance)
    localScript.Constants = getConstants(closure)

    if is_protosmasher_caller() then
        localScript.Protos = {nil}
    else
        localScript.Protos = getProtos(closure)
    end

    return localScript
end

return LocalScript
