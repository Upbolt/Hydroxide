local ClosureHook = {}

function ClosureHook.new(closure, originalFunction)
    local closureHook = {}

    closureHook.Closure = closure
    closureHook.OriginalFunction = originalFunction
    closureHook.Logs = {}
    closureHook.Calls = 0
    closureHook.Blocked = false
    closureHook.Ignored = false
    closureHook.Clear = ClosureHook.clear
    closureHook.Block = ClosureHook.block
    closureHook.Ignore = ClosureHook.ignore
    closureHook.BlockedArgs = {}
    closureHook.IgnoredArgs = {}
    closureHook.AreArgsBlocked = ClosureHook.areArgsBlocked
    closureHook.AreArgsIgnored = ClosureHook.areArgsIgnored
    closureHook.IncrementCalls = ClosureHook.incrementCalls
    closureHook.DecrementCalls = ClosureHook.decrementCalls

    closure:AssignHook(closureHook)

    return closureHook
end

function ClosureHook.clear(closureHook)
    closureHook.Calls = 0
    closureHook.Logs = {}
end

function ClosureHook.block(closureHook)
    closureHook.Blocked = not closureHook.Blocked
end

function ClosureHook.ignore(closureHook)  
    closureHook.Ignored = not closureHook.Ignored
end

function ClosureHook.areArgsBlocked(closureHook, args)
    local blockedArgs = closureHook.BlockedArgs

    for index, value in pairs(args) do
        local indexBlock = blockedArgs[index]
        
        if indexBlock and ( indexBlock.types[type(v)] or indexBlock.values[v] ~= nil ) then
            return true
        end
    end
end

function ClosureHook.areArgsIgnored(closureHook, args)
    local ignoredArgs = closureHook.IgnoredArgs

    for index, value in pairs(args) do
        local indexIgnore = ignoredArgs[index]
        
        if indexIgnore and ( indexIgnore.types[type(v)] or indexIgnore.values[v] ~= nil ) then
            return true
        end
    end
end

function ClosureHook.incrementCalls(closureHook, vargs)
    closureHook.Calls = closureHook.Calls + 1
    table.insert(closureHook.Logs, vargs)
end

function ClosureHook.decrementCalls(closureHook, vargs)
    local logs = closureHook.Logs

    closureHook.Calls = closureHook.Calls - 1
    table.remove(logs, table.find(logs, vargs))
end

return ClosureHook