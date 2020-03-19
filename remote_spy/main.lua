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

local hook_method = oh.methods.new_cclosure(function(method)
    return function(obj, ...)
        if remote_check[obj.ClassName] then
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
    end
end)

for class_name, method in pairs(remote_check) do
    oh.methods.hook_function(method, hook_method(method))
end

oh.methods.hook_function(gmt.__namecall, hook_method(method))

remote_spy.ui = ui
remote_spy.remote = remote
return remote_spy