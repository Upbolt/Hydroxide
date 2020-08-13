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

local RemoteList = Page.List
local ListFlags = RemoteList.Flags
local ListQuery = RemoteList.Query
local ListSearch = ListQuery.Search
local ListRefresh = ListQuery.Refresh
local ListResults = RemoteList.Results.Clip.Content

local RemoteLogs = Page.Logs
local LogsButtons = RemoteLogs.Buttons
local LogsRemote = RemoteLogs.RemoteObject
local LogsBack = RemoteLogs.Back
local LogsResults = RemoteLogs.Results.Clip.Content

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
    textWidth = Vector2.new(1337420, 20),
    normalColor = Color3.new(1, 1, 1),
    blockedColor = Color3.fromRGB(170, 0, 0),
    ignoredColor = Color3.fromRGB(100, 100, 100)
}

local remoteList = List.new(ListResults, true)
local remoteLogs = List.new(LogsResults, true)
local currentLogs = {}
local removed = {}

local selected = {
    logs = {}
}

local pathContext = ContextMenuButton.new("rbxassetid://4891705738", "Get Remote Path")
local conditionContext = ContextMenuButton.new("rbxassetid://4891633802", "Call Conditions")
local clearContext = ContextMenuButton.new("rbxassetid://4892169181", "Clear Calls")
local ignoreContext = ContextMenuButton.new("rbxassetid://4842578510", "Ignore Calls")
local blockContext = ContextMenuButton.new("rbxassetid://4891641806", "Block Calls")
local removeContext = ContextMenuButton.new("rbxassetid://4702831188", "Remove Log")

local scriptContext = ContextMenuButton.new("rbxassetid://4800244808", "Generate Script")
local callingScriptContext = ContextMenuButton.new("rbxassetid://4800244808", "Get Calling Script")
local spyClosureContext = ContextMenuButton.new("rbxassetid://4666593447", "Spy Calling Function")
local repeatCallContext = ContextMenuButton.new("rbxassetid://4907151581", "Repeat Call")

local pathContextSelected = ContextMenuButton.new("rbxassetid://4891705738", "Get Paths")
local clearContextSelected = ContextMenuButton.new("rbxassetid://4892169181", "Clear Calls")
local ignoreContextSelected = ContextMenuButton.new("rbxassetid://4842578510", "Ignore Calls")
local blockContextSelected = ContextMenuButton.new("rbxassetid://4891641806", "Block Calls")
local unignoreContextSelected = ContextMenuButton.new("rbxassetid://4842578818", "Unignore Calls")
local unblockContextSelected = ContextMenuButton.new("rbxassetid://4891642508", "Unblock Calls")
local removeContextSelected = ContextMenuButton.new("rbxassetid://4702831188", "Remove Logs")

local remoteListMenu = ContextMenu.new({ pathContext, conditionContext, clearContext, ignoreContext, blockContext, removeContext })
local remoteListMenuSelected = ContextMenu.new({ pathContextSelected, clearContextSelected, ignoreContextSelected, unignoreContextSelected, blockContextSelected, unblockContextSelected, removeContextSelected })
local remoteLogsMenu = ContextMenu.new({ scriptContext, callingScriptContext, spyClosureContext, repeatCallContext })

local function checkCurrentIgnored()
    local selectedRemote = (selected.remoteLog or selected.logContext).Remote

    LogsButtons.Ignore.Label.Text = (selectedRemote.Ignored and "Unignore") or "Ignore"
    LogsButtons.Ignore.Icon.Image = (selectedRemote.Ignored and icons.unignore) or icons.ignore

    local newWidth = TextService:GetTextSize((selectedRemote.Ignored and "Unignore") or "Ignore", 18, "SourceSans", constants.textWidth).X + 30

    LogsButtons.Ignore.Size = UDim2.new(0, newWidth, 0, 20)
end

local function checkCurrentBlocked()
    local selectedRemote = selected.remoteLog.Remote

    LogsButtons.Block.Label.Text = (selectedRemote.Blocked and "Unblock") or "Block"
    LogsButtons.Block.Icon.Image = (selectedRemote.Blocked and icons.unblock) or icons.block

    local newWidth = TextService:GetTextSize((selectedRemote.Blocked and "Unblock") or "Block", 18, "SourceSans", constants.textWidth).X + 30

    LogsButtons.Block.Size = UDim2.new(0, newWidth, 0, 20)
end

remoteList:BindContextMenu(remoteListMenu)
remoteList:BindContextMenuSelected(remoteListMenuSelected)
remoteLogs:BindContextMenu(remoteLogsMenu)

pathContext:SetCallback(function()
    local selectedInstance = selected.logContext.Remote.Instance
    local oldStatus = oh.getStatus()

    oh.setStatus("Copying " .. selectedInstance.Name .. "'s path")
    setClipboard(getInstancePath(selectedInstance))
    wait(0.25)
    oh.setStatus(oldStatus)
end)

clearContext:SetCallback(function()
    selected.logContext:Clear()
end)

ignoreContext:SetCallback(function()
    local selectedRemote = selected.logContext.Remote

    selected.logContext.Remote:Ignore()

    checkCurrentIgnored()

    if selectedRemote.Blocked then
        selected.logContext:PlayBlock()
    elseif selectedRemote.Ignored then
        selected.logContext:PlayIgnore()
    else
        selected.logContext:PlayNormal()
    end
end)

blockContext:SetCallback(function()
    local selectedRemote = selected.logContext.Remote

    selected.logContext.Remote:Block()

    checkCurrentBlocked()
    
    if selectedRemote.Blocked then
        selected.logContext:PlayBlock()
    elseif selectedRemote.Ignored then
        selected.logContext:PlayIgnore()
    else
        selected.logContext:PlayNormal()
    end
end)

removeContext:SetCallback(function()
    selected.logContext:Remove()
end)

pathContextSelected:SetCallback(function()
    local paths = ""

    for _i, log in pairs(selected.logs) do
        paths = paths .. getInstancePath(log.Remote.Instance) .. '\n'
    end

    setClipboard(paths)
    selected.logs = {}
end)

ignoreContextSelected:SetCallback(function()
    for _i, log in pairs(selected.logs) do
        local remote = log.Remote

        remote:Ignore()

        if remote.Blocked then
            log:PlayBlock()
        elseif remote.Ignored then
            log:PlayIgnore()
        end
    end

    selected.logs = {}
end)

unignoreContextSelected:SetCallback(function()
    for _i, log in pairs(selected.logs) do
        local remote = log.Remote

        if remote.Ignored then
            remote:Ignore()
        end

        if remote.Blocked then
            log:PlayBlock()
        else
            log:PlayNormal()
        end
    end

    selected.logs = {}
end)

blockContextSelected:SetCallback(function()
    for _i, log in pairs(selected.logs) do
        local remote = log.Remote

        if remote.Blocked then
            remote:Block()
        end

        if remote.Blocked then
            log:PlayBlock()
        elseif remote.Ignored then
            log:PlayIgnore()
        end
    end

    selected.logs = {}
end)

unblockContextSelected:SetCallback(function()
    for _i, log in pairs(selected.logs) do
        local remote = log.Remote

        remote:Unblock()

        if remote.Ignored then
            log:PlayIgnore()
        else
            log:PlayNormal()
        end
    end

    selected.logs = {}
end)

clearContextSelected:SetCallback(function()
    for _i, log in pairs(selected.logs) do
        log:Clear()
    end

    selected.logs = {}
end)

removeContextSelected:SetCallback(function()
    for _i, log in pairs(selected.logs) do
        log:Remove()
    end

    remoteList:Recalculate()
    selected.logs = {}
end)

scriptContext:SetCallback(function()
    local script = "-- This script was generated by Hydroxide's RemoteSpy: https://github.com/Upbolt/Hydroxide\n\n"
    local selectedRemote = selected.remoteLog.Remote.Instance
    local remoteClassName = selectedRemote.ClassName
    local remotePath = getInstancePath(selectedRemote)
    local method

    if remoteClassName == "RemoteEvent" then
        method = "FireServer"
    elseif remoteClassName == "RemoteFunction" then
        method = "InvokeServer"
    elseif remoteClassName == "BindableEvent" then
        method = "Fire"
    elseif remoteClassName == "BindableFunction" then
        method = "Invoke"
    end

    local oldStatus = oh.getStatus()
    oh.setStatus("Generating RemoteSpy Pseudocode ...")

    if #selected.args == 0 then
        setClipboard(script .. remotePath .. ':' .. method .. "()")
    else
        local selectedArgs = selected.args
        local args = ""

        for i = 1, #selectedArgs do
            local v = selectedArgs[i]
            local valueType = type(v)
            local robloxValueType = typeof(v)
            local variableName = robloxValueType:sub(1, 1):upper() .. robloxValueType:sub(2)

            if valueType == "userdata" then
                v = (typeof(v) == "Instance" and getInstancePath(v)) or userdataValue(v)
            elseif valueType == "table" then
                v = tableToString(v)
            elseif valueType == "string" then
                v = '"' .. toString(v) .. '"'
            else
                v = tostring(v)
            end

            script = script .. ("local oh%s%d = %s\n"):format(variableName, i, v) 
            args = args .. ("oh%s%d, "):format(variableName, i)
        end

        setClipboard(script .. '\n' .. remotePath .. ':' .. method .. '(' .. args:sub(1, -3) .. ')')
    end

    wait(0.25)
    oh.setStatus(oldStatus)
end)

callingScriptContext:SetCallback(function()
    local oldStatus = oh.getStatus()

    oh.setStatus("Copying " .. selected.callingScript.Name .. "'s path")
    setClipboard(getInstancePath(selected.callingScript))
    wait(0.25)
    oh.setStatus(oldStatus)
end)

repeatCallContext:SetCallback(function()
    local remoteInstance = selected.remoteLog.Remote.Instance
    local remoteClassName = remoteInstance.ClassName
    local method 

    if remoteClassName == "RemoteEvent" then
        method = "FireServer"
    elseif remoteClassName == "RemoteFunction" then
        method = "InvokeServer"
    elseif remoteClassName == "BindableEvent" then
        method = "Fire"
    elseif remoteClassName == "BindableFunction" then
        method = "Invoke"
    end

    local oldStatus = oh.getStatus()
    oh.setStatus("Recalling " .. remoteInstance.Name)

    remoteInstance[method](remoteInstance, unpack(selected.args))

    wait(0.25)

    oh.setStatus(oldStatus)
end)

-- Log Objects
local Log = {}
local ArgsLog = {}

function Log.new(remote)
    local log = {}
    local button = Assets.RemoteLog:Clone()
    local remoteInstance = remote.Instance
    local remoteInstanceName = remoteInstance.Name
    local remoteClassName = remoteInstance.ClassName
    local listButton = ListButton.new(button, remoteList)
    
    local normalAnimation = TweenService:Create(button.Label, constants.fadeLength, { TextColor3 = constants.normalColor })
    local blockAnimation = TweenService:Create(button.Label, constants.fadeLength, { TextColor3 = constants.blockedColor })
    local ignoreAnimation = TweenService:Create(button.Label, constants.fadeLength, { TextColor3 = constants.ignoredColor })

    button.Name = remoteInstanceName
    button.Label.Text = remoteInstanceName
    button.Icon.Image = icons[remoteClassName]

    local function viewLogs()
        if selected.remoteLog then
            remoteLogs:Clear()
        end
        
        local nameLength = TextService:GetTextSize(remoteInstanceName, 18, "SourceSans", constants.textWidth).X + 20
        
        selected.remoteLog = log

        for _i, call in pairs(remote.Logs) do
            ArgsLog.new(log, call)
        end

        checkCurrentBlocked()
        checkCurrentIgnored()

        LogsRemote.Icon.Image = icons[remoteClassName]
        LogsRemote.Label.Text = remoteInstanceName
        LogsRemote.Label.Size = UDim2.new(0, nameLength, 0, 20)
        LogsRemote.Position = UDim2.new(1, -nameLength, 0, 0)

        remoteLogs:Recalculate()

        RemoteList.Visible = false
        RemoteLogs.Visible = true
    end

    listButton:SetCallback(function()
        if selected.remoteLog ~= log then
            if #remote.Logs > 400 then
                MessageBox.Show("Warning", 
                    "This remote seems to have a lot of calls, opening this may cause your game to freeze for a few seconds.\n\nContinue?", 
                    MessageType.YesNo, 
                    viewLogs)
            else
                viewLogs()
            end
        end
    end)

    listButton:SetRightCallback(function()
        ignoreContext:SetIcon((remote.Ignored and icons.unignore) or icons.ignore)
        ignoreContext:SetText((remote.Ignored and "Unignore Calls") or "Ignore Calls")
        blockContext:SetIcon((remote.Blocked and icons.unblock) or icons.block)
        blockContext:SetText((remote.Blocked and "Unblock Calls") or "Block Calls") 

        selected.logContext = log
    end)

    listButton:SetSelectedCallback(function()
        if not table.find(selected.logs, log) then
            table.insert(selected.logs, log)
        end
    end)

    currentLogs[remoteInstance] = log

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
    log.Remove = Log.remove
    return log
end

local function createArg(instance, index, value)
    local arg = Assets.RemoteArg:Clone()
    local valueType = type(value)

    arg.Icon.Image = oh.Constants.Types[valueType]
    arg.Index.Text = index
    arg.Label.Text = toString(value)
    arg.Label.TextColor3 = oh.Constants.Syntax[valueType]
    arg.Parent = instance.Contents

    return arg.AbsoluteSize.Y + 5
end

function ArgsLog.new(log, call)
    local instance = Assets.CallPod:Clone()
    local args = call.args

    if selected.remoteLog ~= log then
        instance.Visible = false
    end

    local button = ListButton.new(instance, remoteLogs)
    local height = 0

    if #args == 0 then
        height = height + createArg(instance, 1, nil)
    else
        for i = 1, #args do
            local v = args[i]
            height = height + createArg(instance, i, v)
        end
    end

    button:SetRightCallback(function()
        selected.args = call.args
        selected.callingScript = call.script
    end)

    button.Instance.Size = button.Instance.Size + UDim2.new(0, 0, 0, height)

    return button 
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

    local callWidth = TextService:GetTextSize(logInstance.Calls.Text, 18, "SourceSans", constants.textWidth).X + 10
    local iconPosition = callWidth - (((remoteClassName == "RemoteEvent" or remoteClassName == "BindableEvent") and 4) or 0)
    local labelWidth = iconPosition + 21

    logInstance.Calls.Size = UDim2.new(0, callWidth, 1, 0)
    logIcon.Position = UDim2.new(0, iconPosition, 0.5, (remoteClassName == "RemoteEvent" and -9) or -7)
    logInstance.Label.Position = UDim2.new(0, labelWidth, 0, 0)
    logInstance.Label.Size = UDim2.new(1, -labelWidth, 1, 0)
end

function Log.clear(log)
    local logInstance = log.Button.Instance

    log.Remote:Clear()

    if selected.remoteLog == log then
        remoteLogs:Clear()
    end

    logInstance.Calls.Text = 0
    log:Adjust()
end

function Log.incrementCalls(log, call)
    local buttonInstance = log.Button.Instance
    local remote = log.Remote
    local calls = remote.Calls

    buttonInstance.Calls.Text = (calls < 10000 and calls) or "..."

    log:Adjust()
    
    if selected.remoteLog == log then
        ArgsLog.new(log, call)
        remoteLogs:Recalculate()
    end
end

function Log.decrementCalls(log, args)
    local buttonInstance = log.Button.Instance
    local remote = log.Remote
    local calls = remote.Calls

    remote:DecrementCalls(args)
    buttonInstance.Calls.Text = (calls < 10000 and calls) or "..."
    log:Adjust()
end

function Log.remove(log)
    local remoteInstance = log.Remote.Instance

    log.Button:Remove()
    currentLogs[remoteInstance] = nil
    removed[remoteInstance] = true
end

-- UI Functionality

local function refreshLogs()
    for remoteInstance, log in pairs(currentLogs) do
        log.Button.Instance.Visible = remotesViewing[remoteInstance.ClassName]
    end

    remoteList:Recalculate()
end

for _i,flag in pairs(ListFlags:GetChildren()) do
    if flag:IsA("Frame") then
        local check = CheckBox.new(flag)

        check:SetCallback(function(enabled)
            remotesViewing[flag.Name] = enabled
            refreshLogs()
        end)
    end
end

ListSearch.FocusLost:Connect(function(returned)
    if returned then
        for remoteInstance, log in pairs(currentLogs) do
            local instance = log.Button.Instance
            instance.Visible = not (instance.Visible and not remoteInstance.Name:lower():find(ListSearch.Text))
        end

        remoteList:Recalculate()
        ListSearch.Text = ""
    end
end)

ListRefresh.MouseButton1Click:Connect(function()
    refreshLogs()
end)

LogsBack.MouseButton1Click:Connect(function()
    RemoteLogs.Visible = false
    RemoteList.Visible = true
end)

LogsButtons.Ignore.MouseButton1Click:Connect(function()
    local selectedRemote = selected.remoteLog.Remote

    selectedRemote:Ignore()

    checkCurrentIgnored()

    if selectedRemote.Blocked then
        selected.remoteLog:PlayBlock()
    elseif selectedRemote.Ignored then
        selected.remoteLog:PlayIgnore()
    else
        selected.remoteLog:PlayNormal()
    end
end)

LogsButtons.Block.MouseButton1Click:Connect(function()
    local selectedRemote = selected.remoteLog.Remote

    selectedRemote:Block()

    checkCurrentBlocked()

    if selectedRemote.Blocked then
        selected.remoteLog:PlayBlock()
    elseif selectedRemote.Ignored then
        selected.remoteLog:PlayIgnore()
    else
        selected.remoteLog:PlayNormal()
    end
end)

LogsButtons.Clear.MouseButton1Click:Connect(function()
    selected.remoteLog:Clear()
end)

Methods.ConnectEvent(function(remoteInstance, vargs, callingFunction, callingScript)
    if not removed[remoteInstance] then
        local remote = currentRemotes[remoteInstance]
        local log = currentLogs[remoteInstance] or Log.new(remote)

        log:IncrementCalls(vargs, callingScript)
    end
end)

return RemoteSpy