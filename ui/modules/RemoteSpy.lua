local RemoteSpy = {}
local Methods = import("modules/RemoteSpy")
local CheckBox = import("ui/controls/CheckBox")

local Page = import("rbxassetid://5042109928").Base.Body.Pages.RemoteSpy
local Assets = import("rbxassetid://5042114982")

local Flags = Page.Flags

local currentRemotes = {}
local gmt = getMetatable(game)
local nmc = gmt.__namecall

for i,flag in pairs(Flags:GetChildren()) do
    if flag:IsA("Frame") then
        local check = CheckBox.new(flag)

        check:SetCallback(function(enabled)
            remotesViewing[flag.Name] = enabled
        end)
    end
end

gmt.__namecall = function(instance, ...)
    local instanceClass = instance.ClassName
    local results 

    if not checkCaller() and remoteMethods[instanceClass] and remoteMethods[getNamecallMethod()] then
        if string.find(instanceClass, "Function") then
            results = { nmc(instance, ...) }
        end

        local remote = currentRemotes[instance]

        if not remote then
            
        end
    end

    if results then
        return unpack(results)
    end

    return nmc(instance, ...)
end

spawn(function()
    while true do
        for remote in pairs(currentRemotes) do
            local ran, result = pcall(function()
                remote.Parent = remote
            end)

            if result:find(": NULL") then
                currentRemotes[remote] = nil
            end
        end

        wait(2)
    end
end)

return RemoteSpy