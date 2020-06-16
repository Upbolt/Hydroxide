local ClosureSpy = {}
local Methods = import("modules/ClosureSpy")

if not hasMethods(Methods.RequiredMethods) then
    return ClosureSpy
end

local List, ListButton = import("ui/controls/List")
local MessageBox, MessageType = import("ui/controls/MessageBox")
local ContextMenu, ContextMenuButton = import("ui/controls/ContextMenu")

local Page = import("rbxassetid://5042109928").Base.Body.Pages.ClosureSpy
local Assets = import("rbxassetid://5042114982").ClosureSpy

local Query = Page.Query
local Search = Query.Search
local Refresh = Query.Refresh

local ResultsClip = Page.Results.Clip
local ResultStatus = ResultsClip.ResultStatus
local Results = ResultsClip.Content

local currentHooks = Methods.CurrentHooks

local icons = {
    block = "rbxassetid://4891641806",
    unblock = "rbxassetid://4891642508",
    ignore = "rbxassetid://4842578510",
    unignore = "rbxassetid://4842578818"
}

local constants = {
    fadeLength = TweenInfo.new(0.15),
    callWidth = Vector2.new(1337420, 20),
    normalColor = Color3.new(1, 1, 1),
    blockedColor = Color3.fromRGB(170, 0, 0),
    ignoredColor = Color3.fromRGB(100, 100, 100)
}

local closureList = List.new(Results)
local closureLogs = {}
local selectedLog

local conditionContext = ContextMenuButton.new("rbxassetid://4891633802", "Call Conditions")
local clearContext = ContextMenuButton.new("rbxassetid://4892169181", "Clear Calls")
local ignoreContext = ContextMenuButton.new("rbxassetid://4842578510", "Ignore Calls")
local blockContext = ContextMenuButton.new("rbxassetid://4891641806", "Block Calls")

closureList:BindContextMenu({ conditionContext, clearCOntext, ignoreContext, blockContext })

-- Log Object
local Log = {}

function Log.new(hook)
    local log = {}
    local button = Assets.ClosureLog:Clone()
    local buttonName = button:FindFirstChild("Name")
    local listButton = ListButton.new(button, closureList)
    local Closure = hook.Closure

    local normalAnimation = TweenService:Create(buttonName, constants.fadeLength, { TextColor3 = constants.normalColor })
    local blockAnimation = TweenService:Create(buttonName, constants.fadeLength, { TextColor3 = constants.blockedColor })
    local ignoreAnimation = TweenService:Create(buttonName, constants.fadeLength, { TextColor3 = constants.ignoredColor })

    button.Name = Closure.Name
    buttonName.Text = Closure.Name

    listButton:SetCallback(function()
        
    end)

    listButton:SetRightCallback(function()
        ignoreContext:SetIcon((hook.Ignored and icons.unignore) or icons.ignore)
        ignoreContext:SetText((hook.Ignored and "Unignore Calls") or "Ignore Calls")
        blockContext:SetIcon((hook.Blocked and icons.unblock) or icons.block)
        blockContext:SetText((hook.Blocked and "Unblock Calls") or "Block Calls")

        selectedLog = log
    end)

    closureLogs[hook] = log

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

    local callWidth = TextService:GetTextSize(logInstance.Calls.Text, 18, "SourceSans", constants.callWidth).X + 10
    local labelWidth = callWidth + 21

    logInstance.Calls.Size = UDim2.new(0, callWidth, 1, 0)
    logIcon.Position = UDim2.new(0, callWidth, 0.5, -7)
    logInstance.Label.Position = UDim2.new(0, labelWidth, 0, 0)
    logInstance.Label.Size = UDim2.new(1, -labelWidth, 1, 0)
end

function Log.clear(log)
    local logInstance = log.Button.Instance

    log.Hook:Clear()
    logInstance.Calls.Text = 0
    log:Adjust()
end

function Log.incrementCalls(log, args, results)
    local buttonInstance = log.Button.Instance
    local hook = log.Hook
    local calls = hook.Calls

    buttonInstance.Calls.Text = (calls < 10000 and calls) or "..."

    log:Adjust()
end

function Log.decrementCalls(log, args)
    local buttonInstance = log.Button.Instance
    local hook = log.Remote
    local calls = hook.Calls

    hook:DecrementCalls(args)
    buttonInstance.Calls.Text = (calls < 10000 and calls) or "..."
    log:Adjust()
end

-- UI Functionality
Search.FocusLost:Connect(function(returned)
    if returned then
        for hook, log in pairs(closureLogs) do
            local instance = log.Button.Instance
            instance.Visible = not (instance.Visible and not hook.Closure.Name:lower():find(Search.Text))
        end

        closureList:Recalculate()
        Search.Text = ""
    end
end)

Refresh.MouseButton1Click:Connect(function()
    closureList:Recalculate()
end)

Methods.ConnectEvent(function(hook, vargs, results, callingScript)
    local log = closureLogs[hook] or Log.new(hook)

    log:IncrementCalls(vargs, results)
end)

return ClosureSpy