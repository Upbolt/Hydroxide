local methods = {
    get_namecall_method = true,
    get_metatable = true,
    check_caller = true
}

local ui = oh.import('remote_spy/ui')
local remote = oh.import('remote_spy/objects/remote')

local gmt = oh.methods.get_metatable(game)

local remote_spy = {}
local remote_check = {
    RemoteEvent = Instance.new("RemoteEvent").FireServer,
    RemoteFunction = Instance.new("RemoteFunction").InvokeServer,
    BindableEvent = Instance.new("BindableEvent").Fire,
    BindableFunction = Instance.new("BindableFunction").Invoke
}

local hook = function(method, obj, ...)
    if remote_check[obj.ClassName] and not oh.is_dead then
        local object = remote.cache[obj] or remote.new(obj)

        if oh.methods.check_caller() or object.ignore then
            return method(obj, ...)
        end

        if object.block then
            return 
        end

        ui.update(obj, ...)
    end

    return method(obj, ...)
end)

for class_name, method in pairs(remote_check) do
    local h h = oh.methods.hook_function(method, function(obj, ...) return hook(obj, ...) end)
end

local h h = oh.methods.hook_function(gmt.__namecall, function(obj, ...) return hook(obj, ...) end)

remote_spy.ui = ui
remote_spy.remote = remote
return remote_spy