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
local hookMap = {}
local hookCache = {}

function Hook.new(closure)
    local hook = {}

    local closureData = closure.Data
    local original
    
    if getInfo(closureData).nups < 2 then
        return
    elseif hookCache[closureData] or table.find(oh.Hooks, closureData) then
        return false
    end

    original = hookFunction(closureData, function(...)
        local vargs = {...}

        if not hook.Ignored and not hook:AreArgsIgnored(vargs) then
            log(hook, getCallingScript(), ...)
        end
        
        if not hook.Blocked and not hook:AreArgsBlocked(vargs) then
            return original(...)
        end
    end)

    closure.Data = original
    
    hook.Original = original
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

    oh.Hooks[original] = closureData
    hookCache[closureData] = hook

    return hook
end

function Hook.remove(hook)
    local closure = hook.Closure
    local original = hook.Original

    hookMap[original] = nil

    hookfunction(closure.Data, original)
    closure.Data = original
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