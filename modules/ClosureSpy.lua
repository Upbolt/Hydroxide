local ClosureSpy = {}

local requiredMethods = {
    ["hookFunction"] = true,
    ["newCClosure"] = true,
    ["isLClosure"] = true,
    ["getProtos"] = true,
    ["getUpvalues"] = true,
    ["getUpvalue"] = true,
    ["getContext"] = true,
    ["setContext"] = true,
    ["setUpvalue"] = true,
    ["getConstants"] = true,
    ["getConstant"] = true,
    ["setConstant"] = true
}

local eventCallback

-- Define as global function in order to reduce upvalue count in hooks
function log(hook, callingScript, ...)
    if eventCallback then
        eventCallback(hook, callingScript, ...)
    end
end

local function setEvent(callback)
    if not eventCallback then
        eventCallback = callback
    end
end

local Hook = {}
hookCache = {}

function Hook.new(closure)
    local hook = {}
    local data = closure.Data

    if getInfo(closureData).nups < 1 then
        return
    elseif hookCache[closureData] or table.find(oh.Hooks, closureData) then
        return false
    end

    local wrap = { hook, data }
    hookMap[data] = hookFunction(closureData, function(...)
        local vargs = {...}
        local uHook = wrap[1]
        local uData = wrap[2]

        if not uHook.Ignored and not uHook:AreArgsIgnored(vargs) then
            log(uHook, getCallingScript(), ...)
        end
        
        if not uHook.Blocked and not uHook:AreArgsBlocked(vargs) then
            return hookCache[uData](...)
        end
    end)

    closure.Data = hookMap[data]

    hook.Closure = closure
    hook.Calls = 0
    hook.Logs = {}
    hook.Ignored = false
    hook.Blocked = false
    hook.Ignore = Hook.ignore
    hook.Block = Hook.block
    hook.Remove = Hook.remove
    hook.Clear = Hook.clear
    hook.BlockedArgs = {}
    hook.IgnoredArgs = {}
    hook.AreArgsBlocked = Hook.areArgsBlocked
    hook.AreArgsIgnored = Hook.areArgsIgnored
    hook.IncrementCalls = Hook.incrementCalls
    hook.DecrementCalls = Hook.decrementCalls

    hookCache[data] = hook

    return hook
end

function Hook.remove(hook)
    hookMap[hook.Closure.Data] = nil
end

function Hook.clear(hook)
    hook.Calls = 0
end

function Hook.block(hook)
    hook.Blocked = not hook.Blocked
end

function Hook.ignore(hook)  
    hook.Ignored = not hook.Ignored
end

function Hook.areArgsBlocked(hook, args)
    local blockedArgs = hook.BlockedArgs

    for index, value in pairs(args) do
        local indexBlock = blockedArgs[index]
        
        if indexBlock and ( indexBlock.types[type(value)] or indexBlock.values[value] ~= nil ) then
            return true
        end
    end
end

function Hook.areArgsIgnored(hook, args)
    local ignoredArgs = hook.IgnoredArgs

    for index, value in pairs(args) do
        local indexIgnore = ignoredArgs[index]
        
        if indexIgnore and ( indexIgnore.types[type(value)] or indexIgnore.values[value] ~= nil ) then
            return true
        end
    end
end

function Hook.incrementCalls(hook, vargs)
    hook.Calls = hook.Calls + 1
    table.insert(hook.Logs, vargs)
end

function Hook.decrementCalls(hook, vargs)
    local logs = hook.Logs

    hook.Calls = hook.Calls - 1
    table.remove(logs, table.find(logs, vargs))
end

ClosureSpy.Hook = Hook
ClosureSpy.SetEvent = setEvent
ClosureSpy.RequiredMethods = requiredMethods
return ClosureSpy