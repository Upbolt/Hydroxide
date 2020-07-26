local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local UpvalueScanner = {}
local ClosureSpy = import("modules/ClosureSpy")
local Methods = import("modules/UpvalueScanner")

if not hasMethods(Methods.RequiredMethods) then
    return UpvalueScanner
end

local Closure = import("objects/Closure")

local Prompt = import("ui/controls/Prompt")
local CheckBox = import("ui/controls/CheckBox")
local Dropdown = import("ui/controls/Dropdown")
local List, ListButton = import("ui/controls/List")
local MessageBox, MessageType = import("ui/controls/MessageBox")
local ContextMenu, ContextMenuButton = import("ui/controls/ContextMenu")
local TabSelector = import("ui/controls/TabSelector")

local Base = import("rbxassetid://5042109928").Base
local Prompts = Base.Prompts
local Page = Base.Body.Pages.UpvalueScanner
local Assets = import("rbxassetid://5042114982").UpvalueScanner

local SpyHook = ClosureSpy.Hook

local Query = Page.Query
local Search = Query.Search
local SearchBox = Query.Query
local Filters = Page.Filters
local ResultsClip = Page.Results.Clip
local ResultStatus = ResultsClip.ResultStatus

local modifyUpvalue = Prompt.new(Prompts.ModifyUpvalue)
local deepSearch = CheckBox.new(Filters.SearchInTables)
local upvalueList = List.new(ResultsClip.Content)
local upvalueLogs = {}

local selectedLog
local selectedUpvalue

local spyClosureContext = ContextMenuButton.new("rbxassetid://4666593447", "Spy Closure")
local viewUpvaluesContext = ContextMenuButton.new("rbxassetid://5179169654", "View All Upvalues")

local changeUpvalueContext = ContextMenuButton.new("rbxassetid://5432062776", "Change Upvalue")

local closureContextMenu = ContextMenu.new({ spyClosureContext, viewUpvaluesContext })
local upvalueContextMenu = ContextMenu.new({ changeUpvalueContext })

local modifyUpvalueInner = modifyUpvalue.Instance.Inner
local modifyUpvalueContent = modifyUpvalueInner.Content
local modifyUpvalueButtons = modifyUpvalueInner.Buttons.SetCancel
local modifyUpvalueType = modifyUpvalueContent.Type
local modifyUpvalueValue = modifyUpvalueContent.Value.Input

local upvalueTypeDropdown = Dropdown.new(modifyUpvalueType)

local function typeMismatchMessage()
    MessageBox.Show("Error", 
        "Value does not match selected type",
        MessageType.OK)
end

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

        upvalueLog.MouseButton2Click:Connect(function()
            selectedUpvalue = upvalue
            upvalueTypeDropdown:SetSelected(type(upvalue.Value))
            upvalueContextMenu:Show()
        end)

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

upvalueList:BindContextMenu(ContextMenu.new({ spyClosureContext, viewUpvaluesContext }))

spyClosureContext:SetCallback(function()
    local selectedClosure = selectedLog.Closure

    if TabSelector.SelectTab("ClosureSpy") then
        local result = SpyHook.new(selectedClosure)

        if result == false then
            MessageBox.Show("Already hooked", "You are already spying " .. selectedClosure.Name)
        elseif result == nil then
            MessageBox.Show("Cannot hook", ('Cannot hook "%s" because there are no upvalues'):format(selectedClosure.Name))
        end
    end
end)

changeUpvalueContext:SetCallback(function()
    if selectedUpvalue then
        local index = selectedUpvalue.Index
        local indexFrame = modifyUpvalueContent.Index
        local indexNumber = indexFrame.Number
        local indexWidth = TextService:GetTextSize(tostring(index), 18, "SourceSans", indexFrame.AbsoluteSize).X
        
        indexNumber.Text = index
        indexNumber.Size = UDim2.new(0, indexWidth, 0, 25)
        
        modifyUpvalue:Show()
    end
end)

upvalueTypeDropdown:SetCallback(function(dropdown, button)
    local instance = dropdown.Instance
    local icon = oh.Constants.Types[button.Name] or oh.Constants.Types["userdata"]

    instance.Icon.Image = icon
    modifyUpvalueValue.Text = ""
end)

deepSearch:SetCallback(function(enabled)
    Methods.UpvalueDeepSearch = enabled
    
    if enabled then
        MessageBox.Show("Notice", "Deep searching may result in longer scan times!", MessageType.OK)
    end
end)

modifyUpvalueButtons.Cancel.MouseButton1Click:Connect(function()
    modifyUpvalue:Hide()
end)

modifyUpvalueButtons.Set.MouseButton1Click:Connect(function()
    local newType = modifyUpvalueType.Label.Text
    local newValue = modifyUpvalueValue.Text

    if upvalueType ~= "Select Type" then
        local value 

        if newType == "string" then
            value = newValue    
        elseif newType == "number" then
            local numberVal = tonumber(newValue)

            if not numberVal then
                typeMismatchMessage()
            else
                value = numberVal
            end
        elseif newType == "boolean" then
            if newValue == "true" then 
                value = true
            elseif newValue == "false" then
                value = false
            else
                typeMismatchMessage()
            end
        else
            local success, result = pcall(loadstring("return " .. newValue))

            if success then
                if typeof(result) ~= newType then
                    typeMismatchMessage()
                else
                    value = result
                end
            else
                MessageBox.Show("Error",
                    "There was an error with your value input",
                    MessageType.OK)
            end
        end

        if value then
            selectedUpvalue:Set(value)
            modifyUpvalue:Hide()
        end
    end
end)

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