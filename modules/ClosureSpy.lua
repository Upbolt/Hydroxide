local ClosureSpy = {}
local ClosureHook = import("objects/ClosureHook")

local requiredMethods = {
    hookFunction = true,
    newCClosure = true,
    isLClosure = true,
    getProtos = true,
    getUpvalues = true,
    getUpvalue = true,
    setUpvalue = true,
    getConstants = true,
    getConstant = true,
    setConstant = true
}

local currentClosures = {}
local currentHooks = {}

local eventSet = false
local uiCallback 

local function connectEvent(callback)
    if not eventSet then
        uiCallback = callback
        eventSet = true
    end
end

-- Set as environment variable to reduce upvalue count
function sendCallEvent(data, ...)
    local closure, originalClosure = unpack(data)

    local results
    local vargs = {...}
    local hook = currentHooks[originalClosure]

    if not hook then
        hook = ClosureHook.new(closure, originalClosure)
        currentHooks[originalClosure] = hook
        oh.Hooks[originalClosure] = hook
    end

    local hookIgnored = hook.Ignored
    local hookBlocked = hook.Blocked
    local argsIgnored = hook:AreArgsIgnored(vargs)
    local argsBlocked = hook:AreArgsBlocked(vargs)

    if not hookIgnored and not argsIgnored and not hookBlocked and not argsBlocked then
        results = { secureCall(originalClosure, ...) }
    end

    if eventSet and (not hookIgnored and not argsIgnored) then
        hook:IncrementCalls(vargs)
        uiCallback(hook, vargs, results, getCallingScript((is_protosmasher_closure and 2) or nil))
    end

    if hookBlocked or argsBlocked then
        return
    end

    if results then
        return unpack(results)
    end

    return secureCall(originalClosure, ...)
end

local function spyClosure(closure)
    local closureData = closure.Data
    local upvalueCount = 0

    for i,v in pairs(getUpvalues(closureData)) do
        upvalueCount = upvalueCount + 1
    end
    
    if upvalueCount == 0 then
        return
    elseif currentClosures[closureData] then
        return false
    elseif not currentClosures[closureData] then
        local upvalues 

        local function hook(...)
            return sendCallEvent(upvalues, ...)
        end

        if not isLClosure(closureData) then
            hook = newCClosure(hook)
        end

        upvalues = { closure, hookFunction(closureData, hook) }
        currentClosures[closureData] = true
    end

    return true
end

ClosureSpy.ConnectEvent = connectEvent
ClosureSpy.SpyClosure = spyClosure
ClosureSpy.RequiredMethods = requiredMethods
return ClosureSpy