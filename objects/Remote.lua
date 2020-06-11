local Remote = {}

function Remote.new(instance)
    local object = {}

    object.Instance = instance
    object.Logs = {}
    object.Calls = 0
    object.Blocked = false
    object.Ignored = false
    object.Block = Remote.block
    object.Ignore = Remote.ignore

    return object
end

function Remote.block(remote)
    remote.Blocked = not remote.Blocked
end

function Remote.ignore(remote)  
    remote.Ignored = not remote.Ignored
end

return Remote