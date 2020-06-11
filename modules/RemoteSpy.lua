local RemoteSpy = {}
local Remote = import("objects/Remote")

local requiredMethods = {
    checkCaller = true,
    hookFunction = true,
    isReadOnly = true,
    setReadOnly = true,
    setContext = true,
    getContext = true,
    getMetatable = true,
    setClipboard = true,
    getNamecallMethod = true,
    getCallingScript = true
}

local remoteMethods = {
    FireServer = true,
    InvokeServer = true,
    Fire = true,
    Invoke = true
}

local remotesViewing = {
    RemoteEvent = true,
    RemoteFunction = false,
    BindableEvent = false,
    BindableFunction = false
}

local methodHooks = {
    RemoteEvent = Instance.new("RemoteEvent").FireServer,
    RemoteFunction = Instance.new("RemoteFunction").InvokeServer,
    BindableEvent = Instance.new("BindableEvent").Fire,
    BindableFunction = Instance.new("BindableFunction").Invoke
}

local currentRemotes = {}

local gmt = getMetatable(game)
local nmc = gmt.__namecall

local remoteDataEvent = Instance.new("BindableEvent")
local eventSet = false

local function connectEvent(callback)
    remoteDataEvent.Event:Connect(callback)

    if not eventSet then
        eventSet = true
    end
end

setReadOnly(gmt, false)

gmt.__namecall = function(instance, ...)
    local results
    local className = instance.ClassName

    if remotesViewing[className] and instance ~= remoteDataEvent and (method ~= nmc or remoteMethods[getNamecallMethod()]) then
        local remote = currentRemotes[instance]
        local vargs = {...}

        if not remote then
            remote = Remote.new(instance)
            currentRemotes[instance] = remote
        end

        if remote.Blocked then
            return
        end

        if string.find(className, "Function") and not remote.Ignored then
            results = { nmc(instance, ...) }
        end

        if eventSet and not remote.Ignored then
            remote.Calls = remote.Calls + 1
            table.insert(remote.Logs, vargs)

            remoteDataEvent.Fire(remoteDataEvent, remote, vargs, results, getCallingScript((is_protosmasher_closure and 2) or nil))
        end
    end

    if results then
        return unpack(results)
    end

    return nmc(instance, ...)
end

for name, hook in pairs(methodHooks) do
    local originalMethod
    originalMethod = hookFunction(hook, function(instance, ...)
        local results
        local className = instance.ClassName

        if remotesViewing[className] and instance ~= remoteDataEvent and (method ~= nmc or remoteMethods[getNamecallMethod()]) then
            local remote = currentRemotes[instance]
            local vargs = {...}

            if not remote then
                remote = Remote.new(instance)
            end

            if remote.Blocked or remote:AreArgsBlocked(vargs) then
                return
            end

            if string.find(className, "Function") and not remote.Ignored then
                results = { originalMethod(instance, ...) }
            end

            if eventSet and not remote.Ignored then
                remote.Calls = remote.Calls + 1
                table.insert(remote.Logs, vargs)

                remoteDataEvent:Fire(remote, vargs, results, getCallingScript())
            end
        end

        if results then
            return unpack(results)
        end

        return originalMethod(instance, ...)
    end)

    oh.Hooks[originalMethod] = hook
end

RemoteSpy.RemotesViewing = remotesViewing
RemoteSpy.CurrentRemotes = currentRemotes
RemoteSpy.ConnectEvent = connectEvent
RemoteSpy.RequiredMethods = requiredMethods
return RemoteSpy