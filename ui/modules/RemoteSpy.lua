local RemoteSpy = {}
local Methods = import("modules/RemoteSpy")
local CheckBox = import("ui/controls/CheckBox")

local Page = import("rbxassetid://5042109928").Base.Body.Pages.RemoteSpy
local Assets = import("rbxassetid://5042114982")

local Flags = Page.Flags

local remotesViewing = Methods.RemotesViewing
local currentRemotes = Methods.CurrentRemotes

local remoteLogs = {}

for i,flag in pairs(Flags:GetChildren()) do
    if flag:IsA("Frame") then
        local check = CheckBox.new(flag)

        check:SetCallback(function(enabled)
            remotesViewing[flag.Name] = enabled
        end)
    end
end

Methods.ConnectEvent(function(remote, vargs, results, callingScript)
    local instance = remote.instance
    local log = remoteLogs[instance]

    if not log then
        
    else

    end
end)

return RemoteSpy