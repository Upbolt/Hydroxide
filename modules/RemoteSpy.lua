local RemoteSpy = {}
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

local gmt = getMetatable(game)
local nmc = gmt.__namecall

RemoteSpy.RequiredMethods = requiredMethods
return RemoteSpy