local RemoteSpy = {}
local Remote = import("objects/Remote")

local requiredMethods = {
    ["checkCaller"] = true,
    ["newCClosure"] = true,
    ["hookFunction"] = true,
    ["isReadOnly"] = true,
    ["setReadOnly"] = true,
    ["getInfo"] = true,
    ["getMetatable"] = true,
    ["setClipboard"] = true,
    ["getNamecallMethod"] = true,
    ["getCallingScript"] = true,
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

oh.Namecall = nmc

local remoteDataEvent = Instance.new("BindableEvent")
local eventSet = false

local function connectEvent(callback)
    remoteDataEvent.Event:Connect(callback)

    if not eventSet then
        eventSet = true
    end
end

setReadOnly(gmt, false)

gmt.__namecall = newCClosure(function(instance, ...)
    if not checkCaller() and remotesViewing[instance.ClassName] and instance ~= remoteDataEvent and remoteMethods[getNamecallMethod()] then
        local remote = currentRemotes[instance]
        local vargs = {...}

        if not remote then
            remote = Remote.new(instance)
            currentRemotes[instance] = remote
        end

        local remoteIgnored = remote.Ignored
        local remoteBlocked = remote.Blocked
        local argsIgnored = remote.AreArgsIgnored(remote, vargs)
        local argsBlocked = remote.AreArgsBlocked(remote, vargs)

        if eventSet and (not remoteIgnored and not argsIgnored) then
            local call = {
                script = getCallingScript((PROTOSMASHER_LOADED ~= nil and 2) or nil),
                args = vargs
            }

            remote.IncrementCalls(remote, call)
            remoteDataEvent.Fire(remoteDataEvent, instance, call, getInfo(2).func)
        end

        if remoteBlocked or argsBlocked then
            return
        end
    end

    return nmc(instance, ...)
end)

for _name, hook in pairs(methodHooks) do
    local originalMethod
    originalMethod = hookFunction(hook, newCClosure(function(instance, ...)
        if not checkCaller() and remotesViewing[instance.ClassName] and instance ~= remoteDataEvent then
            local remote = currentRemotes[instance]
            local vargs = {...}

            if not remote then
                remote = Remote.new(instance)
                currentRemotes[instance] = remote
            end

            local remoteIgnored = remote.Ignored 
            local argsIgnored = remote:AreArgsIgnored(vargs)
            
            if eventSet and (not remoteIgnored and not argsIgnored) then
                local call = {
                    script = getCallingScript((PROTOSMASHER_LOADED ~= nil and 2) or nil),
                    args = vargs
                }
    
                remote:IncrementCalls(call)
                remoteDataEvent:Fire(instance, call, getInfo(2).func)
            end

            if remote.Blocked or remote:AreArgsBlocked(vargs) then
                return
            end
        end
        
        return originalMethod(instance, ...)
    end))

    oh.Hooks[originalMethod] = hook
end

RemoteSpy.RemotesViewing = remotesViewing
RemoteSpy.CurrentRemotes = currentRemotes
RemoteSpy.ConnectEvent = connectEvent
RemoteSpy.RequiredMethods = requiredMethods
return RemoteSpy