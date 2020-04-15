local methods = {
    get_metatable = true,
    get_context = true,
    set_context = true,
    hook_function = true,
    check_caller = true,
    new_cclosure = true
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

local remote_hook = function(method)
    oh.hooks[method] = oh.methods.hook_function(method, newcclosure(function(obj, ...)
        if oh.methods.check_caller() and (obj.Name == "increment_call") then
            return oh.hooks[method](obj, ...)
        end

        if remote_check[obj.ClassName] then
            local old = oh.methods.get_context()
            local object = remote.cache[obj] 
            
            oh.methods.set_context(6)

            if not object then
                object = remote.new(obj)
                object.log = ui.new_log(object)
            end
            
            if (not issentinelclosure and oh.methods.check_caller()) or object.ignore then
                return oh.hooks[method](obj, ...)
            end
            
            if object.block then
                return 
            end

            pcall(ui.update, object, ...)
            oh.methods.set_context(old)
        end

        return oh.hooks[method](obj, ...)
    end))
end

for class_name, method in pairs(remote_check) do
    remote_hook(method)
end

--[[
    do not blame me for this ugly code
    this is all slappy's fault
    for not letting me be able to hook __namecall with hookfunction
]]
if not PROTOSMASHER_LOADED then
    remote_hook(gmt.__namecall)
else
    local nmc = gmt.__namecall

    oh.methods.set_readonly(gmt, false)

    gmt.__namecall = function(obj, ...)
        if oh.methods.check_caller() and (obj.Name == "increment_call") then
            return nmc(obj, ...)
        end

        if remote_check[obj.ClassName] then
            local old = oh.methods.get_context()
            local object = remote.cache[obj]
            
            oh.methods.set_context(6)

            if not object then
                object = remote.new(obj)
                object.log = ui.new_log(object)
            end
            
            if oh.methods.check_caller() or object.ignore then
                return nmc(obj, ...)
            end
            
            if object.block then
                return 
            end

            pcall(ui.update, object, ...)
            oh.methods.set_context(old)
        end

        return nmc(obj, ...)
    end
end
-- end of ugly slappy code

remote_spy.ui = ui
remote_spy.remote = remote
remote_spy.methods = methods
return remote_spy