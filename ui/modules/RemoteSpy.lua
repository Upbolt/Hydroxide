local TextService = game:GetService("TextService")

local RemoteSpy = {}
local Methods = import("modules/RemoteSpy")
local CheckBox = import("ui/controls/CheckBox")
local List, ListButton = import("ui/controls/List")
local MessageBox, MessageType = import("ui/controls/MessageBox")
local ContextMenu, ContextMenuButton = import("ui/controls/ContextMenu")

local Page = import("rbxassetid://5042109928").Base.Body.Pages.RemoteSpy
local Assets = import("rbxassetid://5042114982").RemoteSpy

local RemoteLog = Assets:FindFirstChild("RemoteLog")

local Flags = Page.Flags
local Filters = Page.Filters
local Results = Page.Results.Clip.Content

local remotesViewing = Methods.RemotesViewing
local currentRemotes = Methods.CurrentRemotes

local icons = {
    RemoteEvent = "rbxassetid://4229806545",
    RemoteFunction = "rbxassetid://4229810474",
    BindableEvent = "rbxassetid://4229809371",
    BindableFunction = "rbxassetid://4229807624"
}

local remoteList = List.new(Results)
local remoteLogs = {}
local selectedLog

local pathContext = ContextMenuButton.new("rbxassetid://4891705738", "Get Remote Path")
local conditionContext = ContextMenuButton.new("rbxassetid://4891633802", "Call Conditions")
local ignoreContext = ContextMenuButton.new("rbxassetid://4842578510", "Ignore Calls")
local blockContext = ContextMenuButton.new("rbxassetid://4891641806", "Block Calls")
remoteList:BindContextMenu(ContextMenu.new({ pathContext, conditionContext, ignoreContext, blockContext }))

pathContext:SetCallback(function()
    local currentInstance = selectedLog.Remote.Instance

    setClipboard(getInstancePath(currentInstance))
    MessageBox.Show("Success", ("%s's path was copied to your clipboard."):format(currentInstance.Name), MessageType.OK)
end)

-- Log Object
local Log = {}

function Log.new(remote)
    local log = {}
    local button = RemoteLog:Clone()
    local remoteInstance = remote.Instance
    local listButton = ListButton.new(button, remoteList)

    button.Label.Text = remoteInstance.Name
    button.Icon.Image = icons[remoteInstance.ClassName]

    listButton:SetCallback(function()
        
    end)

    listButton:SetRightCallback(function()
        selectedLog = log
    end)

    remoteLogs[remoteInstance] = log

    log.Remote = remote
    log.Button = listButton
    log.IncrementCalls = Log.incrementCalls
    log.Decrementcalls = Log.decrementCalls
    return log
end

function Log.incrementCalls(log, args, results)
    local buttonInstance = log.Button.Instance
    local remote = log.Remote
    
    buttonInstance.Calls.Text = remote.Calls
end

function Log.decrementCalls(log, args)
    local buttonInstance = log.Button.Instance
    local remote = log.Remote

    remote:DecrementCalls(args)
    buttonInstance.Calls.Text = remote.Calls
end

-- UI Functionality

local function refreshLogs(remoteClass)
    for remoteInstance, log in pairs(remoteLogs) do
        log.Button.Instance.Visible = remotesViewing[remoteInstance.ClassName]
    end

    remoteList:Recalculate()
end

for i,flag in pairs(Flags:GetChildren()) do
    if flag:IsA("Frame") then
        local check = CheckBox.new(flag)
        local remoteClass = flag.Name

        check:SetCallback(function(enabled)
            remotesViewing[remoteClass] = enabled
            refreshLogs(remoteClass)
        end)
    end
end

local nilCheck = CheckBox.new(Filters.ViewNil)

Methods.ConnectEvent(function(remoteInstance, vargs, results, callingScript)
    local remote = currentRemotes[remoteInstance]
    local log = remoteLogs[remoteInstance] or Log.new(remote)

    log:IncrementCalls(vargs, results)
end)

spawn(function()
    while true do
        for instance in pairs(remoteLogs) do
            local success, result = pcall(function()
                instance.Parent = instance
            end)

            if result:find(": NULL") then
                remoteLogs[instance] = nil
                -- destroy log page n shit
            end
        end 

        wait(2)
    end
end)

return RemoteSpy