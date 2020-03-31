local remote = {}

remote.cache = {}

remote.new = function(instance)
    local object = {}

    object.remove = remote.remove
    object.data = instance
    object.ignore = false
    object.block = false
    object.calls = 0
    object.logs = {}

    remote.cache[instance] = object

    return object
end

remote.remove = function(object)
    remote.cache[object.data] = nil
end

return remote