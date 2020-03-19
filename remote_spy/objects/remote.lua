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
    __index = function(cache, instance)
        for index, object in pairs(cache) do
            if object.data == instance then
                return object
            end
        end
    end
})

remote.new = function(instance)
    local object = {}

    object.instance = setmetatable({instance}, weak_table)
    object.remove = remote.remove
    object.calls = 0
    object.ignore = false
    object.block = false
    object.alive_check = instance.ChildAdded:Connect(function()end)

    return object
end

remote.remove = function(remote)
    cache[remote] = nil
end

run_service.RenderStepped:Connect(function()
    for instance, object in pairs(remote.cache) do
        if not object.alive_check.Connected then
            object:remove()
        end
    end
end)

return remote