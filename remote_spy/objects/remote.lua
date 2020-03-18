local remote = {}

local run_service = game:GetService("RunService")

remote.cache = {}

remote.new = function(instance)
    local object = {}

    object.data = instance
    object.remove = remote.remove
    object.calls = 0
    object.ignore = false
    object.block = false
    object.alive_check = instance.ChildAdded:Connect(function()end)

    remote.cache[instance] = object

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