local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")

local ClosureSpy = {}
local Methods = import("modules/ClosureSpy")

if not hasMethods(Methods.RequiredMethods) then
    return ClosureSpy
end

local Prompt = import("ui/controls/Prompt")
local CheckBox = import("ui/controls/CheckBox")
local Dropdown = import("ui/controls/Dropdown")
local List, ListButton = import("ui/controls/List")
local MessageBox, MessageType = import("ui/controls/MessageBox")
local ContextMenu, ContextMenuButton = import("ui/controls/ContextMenu")

local Base = import("rbxassetid://11389137937").Base
local Assets = import("rbxassetid://5042114982").ClosureSpy

local Prompts = Base.Prompts
local Page = Base.Body.Pages.ClosureSpy

local ClosureList = Page.List
local ListQuery = ClosureList.Query
local ListSearch = ListQuery.Search
local ListRefresh = ListQuery.Refresh
local ListResults = ClosureList.Results.Clip.Content

local ClosureLogs = Page.Logs
local LogsButtons = ClosureLogs.Buttons
local LogsClosure = ClosureLogs.ClosureObject
local LogsBack = ClosureLogs.Back
local LogsResults = ClosureLogs.Results.Clip.Content

local ClosureConditions = Page.Conditions
local ConditionsClosure = ClosureConditions.ClosureObject
local ConditionsButtons = ClosureConditions.Buttons
local ConditionsResults = ClosureConditions.Results.Clip.Content
local ConditionsBack = ClosureConditions.Back

local NewClosureCondition = Prompts.NewClosureCondition
local NewConditionInner = NewClosureCondition.Inner
local NewConditionButtons = NewConditionInner.Buttons
local NewConditionContent = NewConditionInner.Content
local NewConditionIndex = NewConditionContent.Index

local currentClosures = Methods.CurrentClosures

local icons = {
    type = "rbxassetid://4702850565",
    status = "rbxassetid://4909102841",
    valueType = "rbxassetid://4702850565",
    block = "rbxassetid://4891641806",
    unblock = "rbxassetid://4891642508",
    ignore = "rbxassetid://4842578510",
    unignore = "rbxassetid://4842578818"
}

local constants = {
    fadeLength = TweenInfo.new(0.15),
    textWidth = Vector2.new(1337420, 20),
    normalColor = Color3.new(1, 1, 1),
    blockedColor = Color3.fromRGB(170, 0, 0),
    ignoredColor = Color3.fromRGB(100, 100, 100)
}

local newClosureCondition = Prompt.new(NewClosureCondition)
local conditionStatus = Dropdown.new(NewConditionContent.Status)
local conditionType = Dropdown.new(NewConditionContent.Type)
local conditionValueType = Dropdown.new(NewConditionContent.ValueType)

local closureList = List.new(ListResults, true)
local hookLogs = List.new(LogsResults)
local closureConditions = List.new(ConditionsResults, true)

local currentLogs = {}
local removed = {}

local selected = {
    logs = {},
    conditions = {}
}

local conditionContext = ContextMenuButton.new("rbxassetid://4891633802", "Call Conditions")
local clearContext = ContextMenuButton.new("rbxassetid://4892169181", "Clear Calls")
local ignoreContext = ContextMenuButton.new("rbxassetid://4842578510", "Ignore Calls")
local blockContext = ContextMenuButton.new("rbxassetid://4891641806", "Block Calls")
local removeContext = ContextMenuButton.new("rbxassetid://4702831188", "Remove Log")

local callingScriptContext = ContextMenuButton.new("rbxassetid://4800244808", "Get Calling Script")
local spyClosureContext = ContextMenuButton.new("rbxassetid://4666593447", "Spy Calling Function")

local removeConditionContext = ContextMenuButton.new("rbxassetid://4702831188", "Remove Condition")

local clearContextSelected = ContextMenuButton.new("rbxassetid://4892169181", "Clear Calls")
local ignoreContextSelected = ContextMenuButton.new("rbxassetid://4842578510", "Ignore Calls")
local blockContextSelected = ContextMenuButton.new("rbxassetid://4891641806", "Block Calls")
local unignoreContextSelected = ContextMenuButton.new("rbxassetid://4842578818", "Unignore Calls")
local unblockContextSelected = ContextMenuButton.new("rbxassetid://4891642508", "Unblock Calls")
local removeContextSelected = ContextMenuButton.new("rbxassetid://4702831188", "Remove Logs")

local removeConditionContextSelected = ContextMenuButton.new("rbxassetid://4702831188", "Remove Conditions")

local closureListMenu = ContextMenu.new({ conditionContext, clearContext, ignoreContext, blockContext, removeContext })
local closureListMenuSelected = ContextMenu.new({ clearContextSelected, ignoreContextSelected, unignoreContextSelected, blockContextSelected, unblockContextSelected, removeContextSelected })
local hookLogsMenu = ContextMenu.new({ callingScriptContext, spyClosureContext, repeatCallContext })
local closureConditionMenu = ContextMenu.new({ removeConditionContext })
local closureConditionMenuSelected = ContextMenu.new({ removeConditionContextSelected })

local function checkCurrentIgnored()
    local selectedHook = (selected.hookLog or selected.logContext).Hook

    LogsButtons.Ignore.Label.Text = (selectedHook.Ignored and "Unignore") or "Ignore"
    LogsButtons.Ignore.Icon.Image = (selectedHook.Ignored and icons.unignore) or icons.ignore

    local newWidth = TextService:GetTextSize((selectedHook.Ignored and "Unignore") or "Ignore", 18, "SourceSans", constants.textWidth).X + 30

    LogsButtons.Ignore.Size = UDim2.new(0, newWidth, 0, 20)
end

local function checkCurrentBlocked()
    local selectedHook = (selected.hookLog or selected.logContext).Hook

    LogsButtons.Block.Label.Text = (selectedHook.Blocked and "Unblock") or "Block"
    LogsButtons.Block.Icon.Image = (selectedHook.Blocked and icons.unblock) or icons.block

    local newWidth = TextService:GetTextSize((selectedHook.Blocked and "Unblock") or "Block", 18, "SourceSans", constants.textWidth).X + 30

    LogsButtons.Block.Size = UDim2.new(0, newWidth, 0, 20)
end

local Condition = {}
function Condition.new(closure, status, index, value, type)
    local condition = {}
    local instance = Assets.ConditionPod:Clone() 
    local content = instance.Content
    local identifiers = instance.Identifiers
    local button = ListButton.new(instance, closureConditions)
    local check = CheckBox.new(content.Toggle)
    local valueType = type or typeof(value)
    local typeIcons = oh.Constants.Types
    local branch = (status == "Ignore" and closure.IgnoredArgs[index]) or closure.BlockedArgs[index]

    condition.Branch = branch
    condition.Status = status
    condition.Index = index
    condition.Value = value
    condition.Type = type
    condition.Closure = closure
    condition.Enabled = true
    condition.Instance = instance
    condition.Button = button
    condition.Toggle = Condition.toggle
    condition.Remove = Condition.remove

    check:SetCallback(function()
        condition:Toggle()
    end)

    button:SetRightCallback(function()
        selected.condition = condition
    end)

    button:SetSelectedCallback(function()
        if not table.find(selected.conditions, condition) then
            table.insert(selected.conditions, condition)
        end
    end)
    
    if byType then
        instance.Identifiers.ByType.Visible = false
    end 
    
    identifiers.ByType.Visible = type ~= nil
    identifiers.Status.Image = (status == "Ignore" and icons.ignore) or icons.block
    identifiers.Status.Border.Image = identifiers.Status.Image

    content.Index.Text = index
    content.Label.Text = (type and valueType) or toString(value)
    content.Label.TextColor3 = oh.Constants.Syntax[valueType] or oh.Constants.Syntax["userdata"]
    content.Type.Image = typeIcons[valueType] or typeIcons["userdata"]

    return condition
end

function Condition.toggle(condition)
    condition.Enabled = not condition.Enabled

    local index = condition.Index
    local value = condition.Value
    local closure = condition.Closure
    local ignoredArgs = closure.IgnoredArgs[index]
    local blockedArgs = closure.BlockedArgs[index]
    local argStatus = (condition.Status == "Ignore" and ignoredArgs) or blockedArgs

    if value then
        argStatus.values[value] = condition.Enabled or nil
    else
        argStatus.types[condition.Type] = condition.Enabled or nil
    end
end

function Condition.remove(condition)
    local branch = condition.Branch
    condition.Button:Remove()

    if condition.Value then
        branch.values[condition.Value] = nil
    else
        branch.types[condition.Type] = nil
    end
end

local function createConditions(hook)
    closureConditions:Clear()

    ClosureList.Visible = false
    ClosureLogs.Visible = false
    ClosureConditions.Visible = true

    local nameLength = TextService:GetTextSize(hook.Closure.Name, 18, "SourceSans", constants.textWidth).X + 20

    ConditionsClosure.Icon.Image = oh.Constants.Types["function"]
    ConditionsClosure.Label.Text = hook.Closure.Name
    ConditionsClosure.Label.Size = UDim2.new(0, nameLength, 0, 20)
    ConditionsClosure.Position = UDim2.new(1, -nameLength, 0, 0)

    for index, arg in pairs(hook.IgnoredArgs) do
        for type in pairs(arg.types) do
            Condition.new(hook, "Ignore", index, nil, type)
        end

        for value in pairs(arg.values) do
            Condition.new(hook, "Ignore", index, value)
        end
    end

    for index, arg in pairs(hook.BlockedArgs) do
        for type in pairs(arg.types) do
            Condition.new(hook, "Block", index, nil, type)
        end

        for value in pairs(arg.values) do
            Condition.new(hook, "Block", index, value)
        end
    end
end

closureList:BindContextMenu(closureListMenu)
closureList:BindContextMenuSelected(closureListMenuSelected)
hookLogs:BindContextMenu(hookLogsMenu)
closureConditions:BindContextMenu(closureConditionMenu)
closureConditions:BindContextMenuSelected(closureConditionMenuSelected)

-- Log Object
local Log = {}
local ArgsLog = {}

function Log.new(hook)
    local log = {}
    local button = Assets.ClosureLog:Clone()
    local buttonName = button:FindFirstChild("Name")
    local buttonInfo = button.Information
    local listButton = ListButton.new(button, closureList)
    local closure = hook.Closure
    local original = closure.Data

    local normalAnimation = TweenService:Create(buttonName, constants.fadeLength, { TextColor3 = constants.normalColor })
    local blockAnimation = TweenService:Create(buttonName, constants.fadeLength, { TextColor3 = constants.blockedColor })
    local ignoreAnimation = TweenService:Create(buttonName, constants.fadeLength, { TextColor3 = constants.ignoredColor })

    buttonInfo.Protos.Text = #getProtos(original)
    buttonInfo.Upvalues.Text = #getUpvalues(original)
    buttonInfo.Constants.Text = #getConstants(original)

    button.Name = closure.Name
    buttonName.Text = closure.Name

    local function viewLogs()
        if selected.hookLog then
            hookLogs:Clear()
        end
        
        local nameLength = TextService:GetTextSize(closure.Name, 18, "SourceSans", constants.textWidth).X + 20
        
        selected.hookLog = log

        for _i, call in pairs(hook.Logs) do
            ArgsLog.new(log, call)
        end

        checkCurrentBlocked()
        checkCurrentIgnored()

        LogsClosure.Icon.Image = oh.Constants.Types["function"]
        LogsClosure.Label.Text = closure.Name
        LogsClosure.Label.Size = UDim2.new(0, nameLength, 0, 20)
        LogsClosure.Position = UDim2.new(1, -nameLength, 0, 0)

        hookLogs:Recalculate()
    end

    listButton:SetCallback(function()
        local oldContext = getContext()
        setContext(7)

        if selected.hookLog ~= log then
            if #hook.Logs > 400 then
                MessageBox.Show("Warning",
                    "This closure seems to have a lot of calls, opening this may cause your game to freeze for a few seconds.\n\nContinue?",
                    MessageType.YesNo,
                    viewLogs)
            else
                viewLogs()
            end
        end

        ClosureList.Visible = false
        ClosureLogs.Visible = true

        selected.hookLog = log

        setContext(oldContext)
    end)

    listButton:SetRightCallback(function()
        local oldContext = getContext()
        setContext(7)

        ignoreContext:SetIcon((hook.Ignored and icons.unignore) or icons.ignore)
        ignoreContext:SetText((hook.Ignored and "Unignore Calls") or "Ignore Calls")
        blockContext:SetIcon((hook.Blocked and icons.unblock) or icons.block)
        blockContext:SetText((hook.Blocked and "Unblock Calls") or "Block Calls")

        selected.logContext = log

        setContext(oldContext)
    end)

    listButton:SetSelectedCallback(function()
        if not table.find(selected.logs, log) then
            table.insert(selected.logs, log)
        end
    end)

    currentLogs[hook] = log

    log.Hook = hook
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

local function createArg(instance, index, value)
    local arg = Assets.Arg:Clone()
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

    if selected.hookLog ~= log then
        instance.Visible = false
    end

    local button = ListButton.new(instance, hookLogs)
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
    local logInstance = log.Button.Instance
    local logIcon = logInstance.Icon
    local logName = logInstance:FindFirstChild("Name")

    local callWidth = TextService:GetTextSize(logInstance.Calls.Text, 18, "SourceSans", constants.textWidth).X + 10
    local labelWidth = callWidth + 21

    logInstance.Calls.Size = UDim2.new(0, callWidth, 0, 20)
    logIcon.Position = UDim2.new(0, callWidth, 0.5, -7)
    logName.Position = UDim2.new(0, labelWidth, 0, 0)
    logName.Size = UDim2.new(1, -labelWidth, 1, 0)
end

function Log.clear(log)
    local logInstance = log.Button.Instance

    log.Hook:Clear()

    if selected.hookLog == log then
        hookLogs:Clear()
    end

    logInstance.Calls.Text = 0
    log:Adjust()
end

function Log.incrementCalls(log, call)
    local logInstance = log.Button.Instance
    local hook = log.Hook

    hook.Calls = hook.Calls + 1
    local calls = hook.Calls
    logInstance.Calls.Text = (calls < 10000 and calls) or "..."

    log:Adjust()
    
    if selected.hookLog == log then
        ArgsLog.new(log, call)
        hookLogs:Recalculate()
    end
end

function Log.decrementCalls(log, args)
    local buttonInstance = log.Button.Instance
    local hook = log.Hook

    hook.Calls = Hook.calls - 1

    local calls = hook.Calls

    -- hook:DecrementCalls(args)
    buttonInstance.Calls.Text = (calls < 10000 and calls) or "..."
    log:Adjust()
end

function Log.remove(log)
    local hook = log.Hook

    log.Button:Remove()
    currentLogs[hook] = nil
    removed[hook] = true
end

-- UI Functionality
ListSearch.FocusLost:Connect(function(returned)
    if returned then
        for hook, log in pairs(currentLogs) do
            local instance = log.Button.Instance
            instance.Visible = not (instance.Visible and not hook.Closure.Name:lower():find(ListSearch.Text))
        end

        closureList:Recalculate()
        ListSearch.Text = ""
    end
end)

ListRefresh.MouseButton1Click:Connect(function()
    closureList:Recalculate()
end)

LogsBack.MouseButton1Click:Connect(function()
    ClosureLogs.Visible = false
    ClosureList.Visible = true
end)

LogsButtons.Ignore.MouseButton1Click:Connect(function()
    local selectedLog = selected.hookLog
    local hook = selectedLog.Hook

    hook:Ignore()

    checkCurrentIgnored()

    if hook.Blocked then
        selectedLog:PlayBlock()
    elseif hook.Ignored then
        selectedLog:PlayIgnore()
    else
        selectedLog:PlayNormal()
    end
end)

LogsButtons.Block.MouseButton1Click:Connect(function()
    local selectedLog = selected.hookLog
    local hook = selectedLog.Hook

    hook:Block()

    checkCurrentBlocked()

    if hook.Blocked then
        selectedLog:PlayBlock()
    elseif hook.Ignored then
        selectedLog:PlayIgnore()
    else
        selectedLog:PlayNormal()
    end
end)

LogsButtons.Clear.MouseButton1Click:Connect(function()
    selected.hookLog:Clear()
end)

LogsButtons.Conditions.MouseButton1Click:Connect(function()
    selected.conditionLog = selected.logContext or selected.hookLog

    createConditions(selected.conditionLog.Hook)
end)

ConditionsBack.MouseButton1Click:Connect(function()
    ClosureConditions.Visible = false

    if selected.hookLog then
        ClosureLogs.Visible = true
    else
        ClosureList.Visible = true
    end
end)

ConditionsButtons.New.MouseButton1Click:Connect(function()
    newClosureCondition:Show()
end)

NewConditionButtons.Add.MouseButton1Click:Connect(function()
    if not conditionStatus.Selected then
        return MessageBox.Show("Error", "Invalid condition status", MessageType.OK)
    end

    local status = conditionStatus.Selected.Name
    local type = conditionType.Selected.Name
    local valueType = conditionValueType.Selected.Name
    local value = NewConditionContent.Value.Input.Text

    if status ~= "Ignore" and status ~= "Block" then
        MessageBox.Show("Error", "Invalid condition status", MessageType.OK)
    elseif not oh.Constants.Types[type] and not isUserdata(type) then
        MessageBox.Show("Error", "Invalid condition type", MessageType.OK)
    elseif valueType ~= "Value" and valueType ~= "Type" then
        MessageBox.Show("Error", "Invalid condition value association", MessageType.OK)
    elseif valueType == "Value" then
        if type == "string" then
            value = toString(value)
        elseif type == "number" then
            value = tonumber(value)

            if not value then
                return MessageBox.Show("Error", "Your input does not match the type you selected", MessageType.OK)
            end
        elseif type == "boolean" then
            if value == "true" then
                value = true
            elseif value == "false" then
                value = false
            else
                return MessageBox.Show("Error", "Your input does not match the type you selected", MessageType.OK)
            end
        else 
            local success, result = pcall(loadstring("return " .. value))

            if valueType == "Value" then
                if not success then
                    return MessageBox.Show("Error", "There was an error interpreting your input value", MessageType.OK)
                elseif typeof(result) ~= type then
                    return MessageBox.Show("Error", "Your input does not match the type you selected", MessageType.OK)
                else
                    value = result
                end
            end
        end
    else
        value = type
    end

    local selectedHook = selected.conditionLog.Hook
    local argIndex = tonumber(NewConditionIndex.Value.Input.Text)
    local byType = valueType == "Type"

    if status == "Block" then
        selectedHook:BlockArg(argIndex, value, byType)
    else
        selectedHook:IgnoreArg(argIndex, value, byType)
    end

    if byType then
        Condition.new(selectedHook, status, argIndex, nil, value)
    else
        Condition.new(selectedHook, status, argIndex, value)
    end

    newClosureCondition:Hide()
end)

NewConditionButtons.Cancel.MouseButton1Click:Connect(function()
    newClosureCondition:Hide()
end)

NewConditionIndex.Add.MouseButton1Click:Connect(function()
    local newIndex = tonumber(NewConditionIndex.Value.Input.Text) + 1
    NewConditionIndex.Value.Input.Text = newIndex
end)

NewConditionIndex.Sub.MouseButton1Click:Connect(function()
    local newIndex = tonumber(NewConditionIndex.Value.Input.Text) - 1
    NewConditionIndex.Value.Input.Text = (newIndex <= 0 and 1) or newIndex
end)

NewConditionIndex.Value.Input.FocusLost:Connect(function()
    local newIndex = tonumber(NewConditionIndex.Value.Input.Text)

    if not newIndex or newIndex <= 0 then
        NewConditionIndex.Value.Input.Text = 1
    end
end)


conditionContext:SetCallback(function()
    selected.conditionLog = selected.logContext or selected.hookLog

    createConditions(selected.conditionLog.Hook)
end)

clearContext:SetCallback(function()
    selected.logContext:Clear()
end)

ignoreContext:SetCallback(function()
    local selectedLog = selected.logContext
    local hook = selectedLog.Hook
    
    hook:Ignore()

    checkCurrentIgnored()

    if hook.Blocked then
        selectedLog:PlayBlock()
    elseif hook.Ignored then
        selectedLog:PlayIgnore()
    else
        selectedLog:PlayNormal()
    end
end)

blockContext:SetCallback(function()
    local selectedLog = selected.logContext
    local hook = selectedLog.Hook

    hook:Block()

    checkCurrentBlocked()
    
    if hook.Blocked then
        selectedLog:PlayBlock()
    elseif hook.Ignored then
        selectedLog:PlayIgnore()
    else
        selectedLog:PlayNormal()
    end
end)

removeContext:SetCallback(function()
    selected.logContext:Remove()
end)


ignoreContextSelected:SetCallback(function()
    for _i, log in pairs(selected.logs) do
        local hook = log.Hook

        if not hook.Ignored then
            hook:Ignore()
        end

        if log.Blocked then
            log:PlayBlock()
        elseif hook.Ignored then
            log:PlayIgnore()
        end
    end

    selected.logs = {}
end)

unignoreContextSelected:SetCallback(function()
    for _i, log in pairs(selected.logs) do
        local hook = log.Hook

        if hook.Ignored then
            hook:Ignore()
        end

        if hook.Blocked then
            log:PlayBlock()
        else
            log:PlayNormal()
        end
    end

    selected.logs = {}
end)

blockContextSelected:SetCallback(function()
    for _i, log in pairs(selected.logs) do
        local hook = log.Hook

        if not hook.Blocked then
            hook:Block()
        end

        if hook.Blocked then
            log:PlayBlock()
        elseif hook.Ignored then
            log:PlayIgnore()
        end
    end

    selected.logs = {}
end)

unblockContextSelected:SetCallback(function()
    for _i, log in pairs(selected.logs) do
        local hook = log.Hook

        if hook.Blocked then
            hook:Block()
        end

        if hook.Ignored then
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

    closureList:Recalculate()
    selected.logs = {}
end)

callingScriptContext:SetCallback(function()
    local oldStatus = oh.getStatus()

    oh.setStatus("Copying " .. selected.callingScript.Name .. "'s path")
    setClipboard(getInstancePath(selected.callingScript))
    wait(0.25)
    oh.setStatus(oldStatus)
end)

removeConditionContext:SetCallback(function()
    selected.condition:Remove()
    selected.condition = nil
end)

removeConditionContextSelected:SetCallback(function()
    for _i, condition in pairs(selected.conditions) do
        condition:Remove()
    end

    selected.conditions = {}
end)

conditionStatus:SetCallback(function(_dropdown, selected)
    local iconCondition = (selected.Name == "Ignore" and icons.ignore) or icons.block
    local icon = NewConditionContent.Status.Icon 

    icon.Image = iconCondition
    icon.Border.Image = iconCondition
end)

conditionType:SetCallback(function(_dropdown, selected)
    local icon = NewConditionContent.Type.Icon 
    local typeIcons = oh.Constants.Types
    local iconCondition = typeIcons[selected.Name] or typeIcons["userdata"]
    
    icon.Image = iconCondition
    icon.Border.Image = iconCondition
end)

conditionValueType:SetCallback(function(_dropdown, selected)
    local iconCondition = (selected.Name == "Type" and icons.type) or oh.Constants.Types["integral"]
    local icon = NewConditionContent.ValueType.Icon 

    icon.Image = iconCondition
    icon.Border.Image = iconCondition
end)

Methods.SetEvent(function(hook, call)
    local oldContext = getContext()
    setContext(7)

    if not removed[hook] then
        local log = currentLogs[hook] or Log.new(hook)
        log:IncrementCalls(call)
    end
    
    setContext(oldContext)
end)

return ClosureSpy
