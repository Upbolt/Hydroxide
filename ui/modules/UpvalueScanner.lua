local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local UpvalueScanner = {}
local Closure = import("objects/Closure")
local Methods = import("modules/UpvalueScanner")

local CheckBox = import("ui/controls/CheckBox")
local List, ListButton = import("ui/controls/List")
local MessageBox, MessageType = import("ui/controls/MessageBox")
local ContextMenu, ContextMenuButton = import("ui/controls/ContextMenu")

local Page = import("rbxassetid://5042109928").Base.Body.Pages.UpvalueScanner
local Assets = import("rbxassetid://5042114982").UpvalueScanner

local Query = Page.Query
local Search = Query.Search
local SearchBox = Query.Query
local Filters = Page.Filters
local ResultsClip = Page.Results.Clip
local ResultStatus = ResultsClip.ResultStatus

local deepSearch = CheckBox.new(Filters.SearchInTables)
local upvalueList = List.new(ResultsClip.Content)
local upvalueLogs = {}
local selectedLog

local spyArgs = ContextMenuButton.new("rbxassetid://112902314", "Spy Function")
local viewUpvalues = ContextMenuButton.new("rbxassetid://112902314", "View All Upvalues")

upvalueList:BindContextMenu(ContextMenu.new({ spyArgs, viewUpvalues }))

spyArgs:SetCallback(function()end)

deepSearch:SetCallback(function(enabled)
    if enabled then
        MessageBox.Show("Notice", "Deep searching may result in longer scan times!", MessageType.OK)
    end
end)

-- Log Object

local Log = {}

function Log.new(closureData, upvalues)
    local log = {}
    local button = Assets.ClosureLog:Clone()
    local listButton = ListButton.new(button, upvalueList)
    local closure = Closure.new(closureData)

    local logHeight = 30

    for i, upvalue in pairs(upvalues) do
        local upvalueLog = Assets.Upvalue:Clone()
        local value = upvalue.Value
        local valueType = type(value)
        local valueColor = oh.Constants.Syntax[valueType]

        if valueType == "function" then
            local name = getInfo(value).name
            value = (name ~= "" and name) or "Unnamed function"
            valueColor = Color3.fromRGB(127, 127, 127)
        end

        upvalueLog.Name = upvalue.Index
        upvalueLog.Icon.Image = oh.Constants.Types[valueType]
        upvalueLog.Index.Text = upvalue.Index
        upvalueLog.Value.Text = value
        upvalueLog.Value.TextColor3 = valueColor
        upvalueLog.Parent = button.Upvalues

        logHeight = logHeight + upvalueLog.AbsoluteSize.Y + 5
    end

    if closure.Name == "Unnamed function" then
        button:FindFirstChild("Name").TextColor3 = Color3.fromRGB(127, 127, 127)
    end

    button:FindFirstChild("Name").Text = closure.Name
    button.Size = UDim2.new(1, 0, 0, logHeight)

    upvalueList:Recalculate()
    upvalueLogs[closureData] = log

    log.Closure = closure
    log.Upvalues = upvalues
    log.Button = listButton
    log.Update = Log.update
    return log
end

function Log.update(log)
    local storage = log.Button.Instance.Upvalues
    for index, upvalue in pairs(log.Upvalues) do
        upvalue:Update()

        local newValue = upvalue.Value
        local valueType = type(newValue)
        local valueColor = oh.Constants.Syntax[valueType]
        local upvalueLog = storage:FindFirstChild(index)

        if valueType == "function" then
            local name = getInfo(newValue).name
            value = (name ~= "" and name) or "Unnamed function"
            valueColor = Color3.fromRGB(170, 170, 170)
        end

        upvalueLog.Icon.Image = oh.Constants.Types[valueType]
        upvalueLog.Value.Text = newValue
        upvalueLog.Value.TextColor3 = valueColor
    end
end

-- UI Functionality

local function addUpvalues(query)
    upvalueList:Clear()

    for closureData, upvalues in pairs(Methods.Scan(query)) do
        Log.new(closureData, upvalues)
    end
end

Search.MouseButton1Click:Connect(function()
    addUpvalues(SearchBox.Text)
    SearchBox.Text = ""
end)

SearchBox.FocusLost:Connect(function(returned)
    if returned then
        addUpvalues(SearchBox.Text)
        SearchBox.Text = ""
    end
end)

oh.Events.UpdateUpvalues = RunService.Heartbeat:Connect(function()
    for closureData, log in pairs(upvalueLogs) do
        log:Update()
    end
end)

return UpvalueScanner 