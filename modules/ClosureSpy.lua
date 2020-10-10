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
    local vargs = {...}
    
    if eventCallback and not hook:AreArgsIgnored(vargs) then
        local call = {
            script = callingScript,
            args = vargs
        }
        eventCallback(hook, call)
    end
end

local function setEvent(callback)
    if not eventCallback then
        eventCallback = callback
    end
end

local Hook = {}
local hookMap = {}
hookCache = {}

function Hook.new(closure)
    local hook = {}
    local data = closure.Data

    if getInfo(data).nups < 1 then
        return
    elseif hookCache[data] then
        return false
    end

    local wrap = { hook, data }
    hookCache[data] = hookFunction(data, function(...)
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

    closure.Data = hookCache[data]

    hook.Closure = closure
    hook.Calls = 0
    hook.Logs = {}
    hook.Ignored = false
    hook.Blocked = false
    hook.Ignore = Hook.ignore
    hook.Block = Hook.block
    hook.IgnoreArg = Hook.ignoreArg
    hook.BlockArg = Hook.blockArg
    hook.Remove = Hook.remove
    hook.Clear = Hook.clear
    hook.BlockedArgs = {}
    hook.IgnoredArgs = {}
    hook.AreArgsBlocked = Hook.areArgsBlocked
    hook.AreArgsIgnored = Hook.areArgsIgnored
    hook.IncrementCalls = Hook.incrementCalls
    hook.DecrementCalls = Hook.decrementCalls

    hookMap[data] = hook

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

function Hook.blockArg(hook, index, value, byType)
    local blockedArgs = hook.BlockedArgs
    local blockedIndex = blockedArgs[index]

    if not blockedIndex then
        blockedIndex = {
            types = {},
            values = {}
        }
        blockedArgs[index] = blockedIndex
    end

    if byType then
        blockedIndex.types[value] = true
    else
        blockedIndex.values[value] = true
    end
end

function Hook.ignoreArg(hook, index, value, byType)
    local ignoredArgs = hook.IgnoredArgs
    local indexIgnore = ignoredArgs[index]

    if not indexIgnore then
        indexIgnore = {
            types = {},
            values = {}
        }

        ignoredArgs[index] = indexIgnore
    end

    if byType then
        indexIgnore.types[value] = true
    else
        indexIgnore.values[value] = true
    end
end

function Hook.areArgsBlocked(hook, args)
    local blockedArgs = hook.BlockedArgs

    for index, value in pairs(args) do
        local indexBlock = blockedArgs[index]
        
        if indexBlock and ( indexBlock.types[typeof(value)] or indexBlock.values[value] ~= nil ) then
            return true
        end
    end

    return false
end

function Hook.areArgsIgnored(hook, args)
    local ignoredArgs = hook.IgnoredArgs

    for index, value in pairs(args) do
        local indexIgnore = ignoredArgs[index]

        if indexIgnore and ( indexIgnore.types[typeof(value)] or indexIgnore.values[value] ~= nil ) then
            return true
        end
    end

    return false
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