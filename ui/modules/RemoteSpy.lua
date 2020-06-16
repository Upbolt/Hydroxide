local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")

local RemoteSpy = {}
local Methods = import("modules/RemoteSpy")

if not hasMethods(Methods.RequiredMethods) then
    return RemoteSpy
end

local CheckBox = import("ui/controls/CheckBox")
local List, ListButton = import("ui/controls/List")
local MessageBox, MessageType = import("ui/controls/MessageBox")
local ContextMenu, ContextMenuButton = import("ui/controls/ContextMenu")

local Page = import("rbxassetid://5042109928").Base.Body.Pages.RemoteSpy
local Assets = import("rbxassetid://5042114982").RemoteSpy

local Flags = Page.Flags
local Query = Page.Query
local Search = Query.Search
local Refresh = Query.Refresh
local Filters = Page.Filters
local Results = Page.Results.Clip.Content

local remotesViewing = Methods.RemotesViewing
local currentRemotes = Methods.CurrentRemotes

local icons = {
    block = "rbxassetid://4891641806",
    unblock = "rbxassetid://4891642508",
    ignore = "rbxassetid://4842578510",
    unignore = "rbxassetid://4842578818",
    RemoteEvent = "rbxassetid://4229806545",
    RemoteFunction = "rbxassetid://4229810474",
    BindableEvent = "rbxassetid://4229809371",
    BindableFunction = "rbxassetid://4229807624"
}

local constants = {
    fadeLength = TweenInfo.new(0.15),
    callWidth = Vector2.new(1337420, 20),
    normalColor = Color3.new(1, 1, 1),
    blockedColor = Color3.fromRGB(170, 0, 0),
    ignoredColor = Color3.fromRGB(100, 100, 100)
}

local remoteList = List.new(Results)
local remoteLogs = {}
local selectedLog

local pathContext = ContextMenuButton.new("rbxassetid://4891705738", "Get Remote Path")
local conditionContext = ContextMenuButton.new("rbxassetid://4891633802", "Call Conditions")
local clearContext = ContextMenuButton.new("rbxassetid://4892169181", "Clear Calls")
local ignoreContext = ContextMenuButton.new("rbxassetid://4842578510", "Ignore Calls")
local blockContext = ContextMenuButton.new("rbxassetid://4891641806", "Block Calls")

local scriptContext = ContextMenuButton.new("rbxassetid://4800244808", "Generate Script")
local callingScriptContext = ContextMenuButton.new("rbxassetid://4800244808", "Get Calling Script")
local spyClosureContext = ContextMenuButton.new("rbxassetid://4666593447", "Spy Calling Function")
local repeatCallContext = ContextMenuButton.new("rbxassetid://4907151581", "Repeat Call")

local remoteListMenu = ContextMenu.new({ pathContext, conditionContext, clearContext, ignoreContext, blockContext })
local remoteLogsMenu = ContextMenu.new({ scriptContext, callingScriptContext, spyClosureContext, repeatCallContext })

remoteList:BindContextMenu(remoteListMenu)

pathContext:SetCallback(function()
    local selectedInstance = selectedLog.Remote.Instance

    setClipboard(getInstancePath(selectedInstance))
    MessageBox.Show("Success", ("%s's path was copied to your clipboard."):format(selectedInstance.Name), MessageType.OK)
end)

clearContext:SetCallback(function()
    selectedLog:Clear()
end)

ignoreContext:SetCallback(function()
    local selectedRemote = selectedLog.Remote

    selectedLog.Remote:Ignore()

    if selectedRemote.Blocked then
        selectedLog:PlayBlock()
    elseif selectedRemote.Ignored then
        selectedLog:PlayIgnore()
    else
        selectedLog:PlayNormal()
    end
end)

blockContext:SetCallback(function()
    local label = selectedLog.Button.Instance.Label
    local selectedRemote = selectedLog.Remote

    selectedLog.Remote:Block()

    if selectedRemote.Blocked then
        selectedLog:PlayBlock()
    elseif selectedRemote.Ignored then
        selectedLog:PlayIgnore()
    else
        selectedLog:PlayNormal()
    end
end)

-- Log Object
local Log = {}

function Log.new(remote)
    local log = {}
    local button = Assets.RemoteLog:Clone()
    local remoteInstance = remote.Instance
    local remoteClass = remoteInstance.ClassName
    local listButton = ListButton.new(button, remoteList)
    
    local normalAnimation = TweenService:Create(button.Label, constants.fadeLength, { TextColor3 = constants.normalColor })
    local blockAnimation = TweenService:Create(button.Label, constants.fadeLength, { TextColor3 = constants.blockedColor })
    local ignoreAnimation = TweenService:Create(button.Label, constants.fadeLength, { TextColor3 = constants.ignoredColor })

    button.Name = remoteInstance.Name
    button.Label.Text = remoteInstance.Name
    button.Icon.Image = icons[remoteClass]

    listButton:SetCallback(function()
        
    end)

    listButton:SetRightCallback(function()
        ignoreContext:SetIcon((remote.Ignored and icons.unignore) or icons.ignore)
        ignoreContext:SetText((remote.Ignored and "Unignore Calls") or "Ignore Calls")
        blockContext:SetIcon((remote.Blocked and icons.unblock) or icons.block)
        blockContext:SetText((remote.Blocked and "Unblock Calls") or "Block Calls")

        selectedLog = log
    end)

    remoteLogs[remoteInstance] = log

    log.Remote = remote
    log.Button = listButton
    log.BlockAnimation = blockAnimation
    log.IgnoreAnimation = ignoreAnimation
    log.NormalAnimation = normalAnimation
    log.NormalAnimation = normalAnimation
    log.Clear = Log.clear
    log.PlayBlock = Log.playBlock
    log.PlayIgnore = Log.playIgnore
    log.PlayNormal = Log.playNormal
    log.Adjust = Log.adjust
    log.IncrementCalls = Log.incrementCalls
    log.Decrementcalls = Log.decrementCalls
    return log
end

function Log.playIgnore(log)
    log.IgnoreAnimation:Play()
end

function Log.playBlock(log)
    log.BlockAnimation:Play()
end

function Log.playNormal(log)
    log.NormalAnimation:Play()
end

function Log.adjust(log)
    local remoteClassName = log.Remote.Instance.ClassName
    local logInstance = log.Button.Instance
    local logIcon = logInstance.Icon

    local callWidth = TextService:GetTextSize(logInstance.Calls.Text, 18, "SourceSans", constants.callWidth).X + 10
    local iconPosition = callWidth - (((remoteClassName == "RemoteEvent" or remoteClassName == "BindableEvent") and 4) or 0)
    local labelWidth = iconPosition + 21

    logInstance.Calls.Size = UDim2.new(0, callWidth, 1, 0)
    logIcon.Position = UDim2.new(0, iconPosition, 0.5, -7)
    logInstance.Label.Position = UDim2.new(0, labelWidth, 0, 0)
    logInstance.Label.Size = UDim2.new(1, -labelWidth, 1, 0)
end

function Log.clear(log)
    local logInstance = log.Button.Instance

    log.Remote:Clear()
    logInstance.Calls.Text = 0
    log:Adjust()
end

function Log.incrementCalls(log, args, results)
    local buttonInstance = log.Button.Instance
    local remote = log.Remote
    local calls = remote.Calls

    buttonInstance.Calls.Text = (calls < 10000 and calls) or "..."

    log:Adjust()
end

function Log.decrementCalls(log, args)
    local buttonInstance = log.Button.Instance
    local remote = log.Remote
    local calls = remote.Calls

    remote:DecrementCalls(args)
    buttonInstance.Calls.Text = (calls < 10000 and calls) or "..."
    log:Adjust()
end

-- UI Functionality

local function refreshLogs()
    for remoteInstance, log in pairs(remoteLogs) do
        log.Button.Instance.Visible = remotesViewing[remoteInstance.ClassName]
    end

    remoteList:Recalculate()
end

for i,flag in pairs(Flags:GetChildren()) do
    if flag:IsA("Frame") then
        local check = CheckBox.new(flag)

        check:SetCallback(function(enabled)
            remotesViewing[flag.Name] = enabled
            refreshLogs()
        end)
    end
end

Search.FocusLost:Connect(function(returned)
    if returned then
        for remoteInstance, log in pairs(remoteLogs) do
            local instance = log.Button.Instance
            instance.Visible = not (instance.Visible and not remoteInstance.Name:lower():find(Search.Text))
        end

        remoteList:Recalculate()
        Search.Text = ""
    end
end)

Refresh.MouseButton1Click:Connect(function()
    refreshLogs()
end)

local nilCheck = CheckBox.new(Filters.ViewNil)

Methods.ConnectEvent(function(remoteInstance, vargs, results, callingFunction, callingScript)
    local remote = currentRemotes[remoteInstance]
    local log = remoteLogs[remoteInstance] or Log.new(remote)

    log:IncrementCalls(vargs, results, callingFunction, callingScript)
end)

return RemoteSpy