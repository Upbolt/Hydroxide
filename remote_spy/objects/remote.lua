local run_service = game:GetService("RunService")
local remote = {}

local weak_table = {
    __mode = 'v',
    __index = function(t, i)
        if i == 'is_destroyed' then
            return t[1] and true
        elseif i == "data" then
            return t[1]
        end
    end
}

remote.cache = setmetatable({}, {
    __index = function(cache, remote)
        for object, instance in pairs(cache) do
            if instance.data == remote then
                return object
            end
        end
    end
})

remote.new = function(instance)
    local object = {}

    object.remove = remote.remove
    object.calls = 0
    object.ignore = false
    object.block = false
    object.alive_check = instance.ChildAdded:Connect(function()end)

    remote.cache[object] = setmetatable({instance}, weak_table)

    return object
end

remote.remove = function(object)
    remote.cache[object] = nil
end

run_service.RenderStepped:Connect(function()
    for object, instance in pairs(remote.cache) do
        if instance.is_destroyed then
            object:remove()
        end
    end
end)

return remote