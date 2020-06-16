local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local UpvalueScanner = {}
local ClosureSpy = import("modules/ClosureSpy")
local Methods = import("modules/UpvalueScanner")

if not hasMethods(Methods.RequiredMethods) then
    return UpvalueScanner
end

local Closure = import("objects/Closure")

local CheckBox = import("ui/controls/CheckBox")
local List, ListButton = import("ui/controls/List")
local MessageBox, MessageType = import("ui/controls/MessageBox")
local ContextMenu, ContextMenuButton = import("ui/controls/ContextMenu")
local TabSelector = import("ui/controls/TabSelector")

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

local spyClosureContext = ContextMenuButton.new("rbxassetid://4666593447", "Spy Closure")
local viewUpvaluesContext = ContextMenuButton.new("rbxassetid://5179169654", "View All Upvalues")

upvalueList:BindContextMenu(ContextMenu.new({ spyClosureContext, viewUpvaluesContext }))

spyClosureContext:SetCallback(function()
    local selectedClosure = selectedLog.Closure

    if TabSelector.SelectTab("ClosureSpy") then
        local result = ClosureSpy.SpyClosure(selectedClosure)

        if result == false then
            MessageBox.Show("Already hooked", "You are already spying " .. selectedClosure.Name)
        elseif result == nil then
            MessageBox.Show("Cannot hook", ('Cannot hook "%s" because there are no upvalues'):format(selectedClosure.Name))
        end
    end
end)

deepSearch:SetCallback(function(enabled)
    if enabled then
        Methods.UpvalueDeepSearch = enabled
        MessageBox.Show("Notice", "Deep searching may result in longer scan times!", MessageType.OK)
    end
end)

-- Log Object

local Log = {}

function Log.new(closureData, closure)
    local log = {}
    local button = Assets.ClosureLog:Clone()
    local listButton = ListButton.new(button, upvalueList)
    local upvalues = closure.Upvalues
    local logHeight = 30

    for i, upvalue in pairs(upvalues) do
        local value = upvalue.Value
        local valueType = type(value)
        local valueColor = oh.Constants.Syntax[valueType]
        local upvalueLog = (valueType == "table" and Assets.Table:Clone()) or Assets.Upvalue:Clone()

        if valueType == "function" then
            local name = getInfo(value).name
            value = (name ~= "" and name) or "Unnamed function"
            valueColor = Color3.fromRGB(127, 127, 127)
        elseif valueType == "table" then
            local tableHeight = 30
            log.Scanned = {}

            for index, value in pairs(upvalue.Scanned) do
                local indexType = type(index)
                local valueType = type(value)
                local element = Assets.Element:Clone()
                local indexFrame = element.Index
                local valueFrame = element.Value

                indexFrame.Label.Text = toString(index)
                indexFrame.Label.TextColor3 = oh.Constants.Syntax[indexType]
                indexFrame.Icon.Image = oh.Constants.Types[indexType]

                valueFrame.Label.Text = toString(value)
                valueFrame.Label.TextColor3 = oh.Constants.Syntax[valueType]
                valueFrame.Icon.Image = oh.Constants.Types[valueType]

                element.Parent = upvalueLog.Elements

                tableHeight = tableHeight + element.AbsoluteSize.Y + 5
                log.Scanned[index] = element
            end

            upvalueLog.Size = UDim2.new(1, 0, 0, tableHeight)
        end

        upvalueLog.Name = upvalue.Index
        upvalueLog.Icon.Image = oh.Constants.Types[valueType]
        upvalueLog.Index.Text = upvalue.Index
        upvalueLog.Value.Text = toString(value)
        upvalueLog.Value.TextColor3 = valueColor
        upvalueLog.Parent = button.Upvalues

        logHeight = logHeight + upvalueLog.AbsoluteSize.Y + 5
    end

    if closure.Name == "Unnamed function" then
        button:FindFirstChild("Name").TextColor3 = Color3.fromRGB(127, 127, 127)
    end

    button:FindFirstChild("Name").Text = closure.Name
    button.Size = UDim2.new(1, 0, 0, logHeight)

    listButton:SetRightCallback(function()
        selectedLog = log
    end)

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
            newValue = (name ~= "" and name) or "Unnamed function"
            valueColor = Color3.fromRGB(170, 170, 170)
        elseif valueType == "table" then
            for i, element in pairs(log.Scanned) do
                local v = upvalue.Scanned[i]

                local indexType = type(i)
                local valueType = type(v)
                local indexFrame = element.Index
                local valueFrame = element.Value

                indexFrame.Label.Text = toString(i)
                indexFrame.Label.TextColor3 = oh.Constants.Syntax[indexType]
                indexFrame.Icon.Image = oh.Constants.Types[indexType]

                valueFrame.Label.Text = toString(v)
                valueFrame.Label.TextColor3 = oh.Constants.Syntax[valueType]
                valueFrame.Icon.Image = oh.Constants.Types[valueType]
            end
        end

        upvalueLog.Icon.Image = oh.Constants.Types[valueType]
        upvalueLog.Value.Text = toString(newValue)
        upvalueLog.Value.TextColor3 = valueColor
    end
end

-- UI Functionality

local function addUpvalues()
    local query = SearchBox.Text

    if query:gsub(' ', '') ~= '' then
        if not tonumber(query) and query:len() <= 1 then
            return
        end

        local unnamedFunctions = {}
        local results = 0

        upvalueList:Clear()
        upvalueLogs = {}

        for closureData, closure in pairs(Methods.Scan(query)) do
            if getInfo(closureData).name == "" then
                unnamedFunctions[closureData] = closure
            else
                Log.new(closureData, closure)
            end

            results = results + 1
        end

        for closureData, closure in pairs(unnamedFunctions) do
            Log.new(closureData, closure)
        end

        ResultStatus.Visible = results ~= 0

        upvalueList:Recalculate()
    else
        MessageBox.Show("Invalid query", "Your query is too short", MessageType.OK)
    end

    SearchBox.Text = ''
end

Search.MouseButton1Click:Connect(addUpvalues)
SearchBox.FocusLost:Connect(function(returned)
    if returned then
        addUpvalues()
    end
end)

oh.Events.UpdateUpvalues = RunService.Heartbeat:Connect(function()
    for closureData, log in pairs(upvalueLogs) do
        log:Update()
    end
end)

return UpvalueScanner 