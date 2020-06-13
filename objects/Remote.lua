local Remote = {}

function Remote.new(instance)
    local remote = {}

    remote.Instance = instance
    remote.Logs = {}
    remote.Calls = 0
    remote.Blocked = false
    remote.Ignored = false
    remote.Clear = Remote.clear
    remote.Block = Remote.block
    remote.Ignore = Remote.ignore
    remote.BlockedArgs = {}
    remote.IgnoredArgs = {}
    remote.AreArgsBlocked = Remote.areArgsBlocked
    remote.AreArgsIgnored = Remote.areArgsIgnored
    remote.IncrementCalls = Remote.incrementCalls
    remote.DecrementCalls = Remote.decrementCalls

    return remote
end

function Remote.clear(remote)
    remote.Calls = 0
    remote.Logs = {}
end

function Remote.block(remote)
    remote.Blocked = not remote.Blocked
end

function Remote.ignore(remote)  
    remote.Ignored = not remote.Ignored
end

function Remote.areArgsBlocked(remote, args)
    local blockedArgs = remote.BlockedArgs

    for index, value in pairs(args) do
        local indexBlock = blockedArgs[index]
        
        if indexBlock and ( indexBlock.types[type(v)] or indexBlock.values[v] ~= nil ) then
            return true
        end
    end
end

function Remote.areArgsIgnored(remote, args)
    local ignoredArgs = remote.IgnoredArgs

    for index, value in pairs(args) do
        local indexIgnore = ignoredArgs[index]
        
        if indexIgnore and ( indexIgnore.types[type(v)] or indexIgnore.values[v] ~= nil ) then
            return true
        end
    end
end

function Remote.incrementCalls(remote, vargs)
    remote.Calls = remote.Calls + 1
    table.insert(remote.Logs, vargs)
end

function Remote.decrementCalls(remote, vargs)
    local logs = remote.Logs

    remote.Calls = remote.Calls - 1
    table.remove(logs, table.find(logs, vargs))
end

return Remote