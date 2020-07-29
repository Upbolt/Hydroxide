local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local UpvalueScanner = {}
local ClosureSpy = import("modules/ClosureSpy")
local Methods = import("modules/UpvalueScanner")

if not hasMethods(Methods.RequiredMethods) then
    return UpvalueScanner
end

local Closure = import("objects/Closure")
local Upvalue = import("objects/Upvalue")

local Prompt = import("ui/controls/Prompt")
local CheckBox = import("ui/controls/CheckBox")
local Dropdown = import("ui/controls/Dropdown")
local List, ListButton = import("ui/controls/List")
local TabSelector = import("ui/controls/TabSelector")
local MessageBox, MessageType = import("ui/controls/MessageBox")
local ContextMenu, ContextMenuButton = import("ui/controls/ContextMenu")

local Base = import("rbxassetid://5042109928").Base
local Assets = import("rbxassetid://5042114982").UpvalueScanner

local Prompts = Base.Prompts
local Page = Base.Body.Pages.UpvalueScanner

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

local deepSearchFlag = false
local currentUpvalues = {}

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

local constants = {
    tempUpvalueColor = Color3.fromRGB(40, 20, 20),
    tempBorderColor = Color3.fromRGB(20, 0, 0)
}

local function typeMismatchMessage()
    MessageBox.Show("Error", 
        "Value does not match selected type",
        MessageType.OK)
end

local function addUpvalue(upvalue, temporary)
    local upvalueLog 
    local index = upvalue.Index
    local value = upvalue.Value
    local valueType = type(value)
    
    if valueType == "table" then
        upvalueLog = Assets.Table:Clone()
        local height = 25

        if temporary then
            upvalueLog.ImageColor3 = constants.tempUpvalueColor
            upvalueLog.Border.ImageColor3 = constants.tempBorderColor
        end

        for i, v in pairs(upvalue.Scanned) do
            local elementLog = Assets.Element:Clone()
            local indexType = type(i)
            local valueType = type(v)
            local indexText = toString(i)

            height = height + elementLog.AbsoluteSize.Y + 5

            elementLog.Name = indexText

            elementLog.Index.Label.Text = indexText
            elementLog.Value.Label.Text = toString(v)
            elementLog.Index.Label.TextColor3 = oh.Constants.Syntax[indexType]
            elementLog.Value.Label.TextColor3 = oh.Constants.Syntax[valueType]
            elementLog.Index.Icon.Image = oh.Constants.Types[indexType]
            elementLog.Value.Icon.Image = oh.Constants.Types[valueType]
            elementLog.Parent = upvalueLog.Elements
        end

        upvalueLog.Size = UDim2.new(1, 0, 0, height)
    else
        upvalueLog = Assets.Upvalue:Clone()

        if temporary then
            upvalueLog.ImageColor3 = constants.tempUpvalueColor
            upvalueLog.Border.ImageColor3 = constants.tempBorderColor
        end

        if valueType == "function" then
            local closureName = getInfo(value).name
            upvalueLog.Value.Text = (closureName == '' and "Unnamed function") or closureName
        else
            upvalueLog.Value.Text = toString(value)
        end
    end
    
    upvalueLog.Name = index
    upvalueLog.Index.Text = index
    upvalueLog.Value.Text = toString(value)
    upvalueLog.Value.TextColor3 = oh.Constants.Syntax[valueType]
    upvalueLog.Icon.Image = oh.Constants.Types[valueType]

    upvalueLog.MouseButton2Click:Connect(function()
        selectedUpvalue = upvalue
        upvalueTypeDropdown:SetSelected(typeof(upvalue.Value))
        upvalueContextMenu:Show()
    end)

    return upvalueLog
end

local function updateUpvalue(closureLog, upvalue)
    local upvalueLog = closureLog.Instance.Upvalues[tostring(upvalue.Index)]
    local closure = upvalue.Closure
    local index = upvalue.Index
    local oldValue = upvalue.Value
    local newValue = getUpvalue(closure.Data, index)
    local valueType = type(newValue)

    if newValue ~= oldValue then
        if valueType == "function" then
            local closureName = getInfo(newValue).name
            upvalueLog.Value.Text = (closureName == '' and "Unnamed function") or closureName
        else
            upvalueLog.Value.Text = toString(newValue)
        end

        upvalueLog.Value.TextColor3 = oh.Constants.Syntax[valueType]
        upvalueLog.Icon.Image = oh.Constants.Types[valueType]
    elseif valueType == "table" and upvalue.Scanned then
        for i, v in pairs(upvalue.Scanned) do
            local indexType = type(i)
            local indexText = toString(i)
            local valuetype = type(v)
            local elementLog = upvalueLog.Elements[indexText]

            elementLog.Index.Label.Text = indexText
            elementLog.Value.Label.Text = toString(v)
            elementLog.Index.Label.TextColor3 = oh.Constants.Syntax[indexType]
            elementLog.Value.Label.TextColor3 = oh.Constants.Syntax[valueType]
            elementLog.Value.Icon.Image = oh.Constants.Types[indexType]
            elementLog.Value.Icon.Image = oh.Constants.Types[valueType]
            elementLog.Parent = upvalueLog.Elements
        end
    end

    upvalue:Update(newValue)
end

-- Log Object
local Log = {}

function Log.new(closure)
    local log = {}
    local instance = Assets.ClosureLog:Clone()
    local listButton = ListButton.new(instance, upvalueList)
    local logHeight = 30

    log.Instance = instance
    log.Closure = closure
    log.Upvalues = {}
    log.Update = Log.update

    for i, upvalue in pairs(closure.Upvalues) do
        local upvalueLog = addUpvalue(upvalue)
        upvalueLog.Parent = instance.Upvalues

        logHeight = logHeight + upvalueLog.AbsoluteSize.Y + 5
        log.Upvalues[i] = upvalueLog
    end

    instance.Size = UDim2.new(1, 0, 0, logHeight)
    instance:FindFirstChild("Name").Text = closure.Name
    
    listButton:SetRightCallback(function()
        selectedLog = log
    end)
    
    currentUpvalues[closure.Data] = log

    upvalueList:Recalculate()
    return log
end

function Log.update(log)
    for i, upvalue in pairs(log.Closure.Upvalues) do
        updateUpvalue(log, upvalue)
    end

    for i, upvalue in pairs(log.Closure.TemporaryUpvalues) do
        updateUpvalue(log, upvalue)
    end
end

local function addUpvalues()
    local query = SearchBox.Text

    if query:gsub(' ', '') ~= '' then
        if not tonumber(query) and query:len() <= 1 then
            return
        end

        local unnamedFunctions = {}
        local results = 0

        upvalueList:Clear()
        currentUpvalues = {}

        for i, closure in pairs(Methods.Scan(query, deepSearchFlag)) do
            local closureData = closure.Data

            if getInfo(closureData).name == "" then
                unnamedFunctions[closureData] = closure
            else
                Log.new(closure)
            end

            results = results + 1
        end

        for i, closure in pairs(unnamedFunctions) do
            Log.new(closure)
        end

        ResultStatus.Visible = results ~= 0

        upvalueList:Recalculate()
    else
        MessageBox.Show("Invalid query", "Your query is too short", MessageType.OK)
    end

    SearchBox.Text = ""
end

upvalueList:BindContextMenu(closureContextMenu)

deepSearch:SetCallback(function(enabled)
    deepSearchFlag = enabled
    
    if enabled then
        MessageBox.Show("Notice", "Deep searching may result in longer scan times!", MessageType.OK)
    end
end)

Search.MouseButton1Click:Connect(addUpvalues)
SearchBox.FocusLost:Connect(function(returned)
    if returned then
        addUpvalues()
    end
end)

modifyUpvalueButtons.Set.MouseButton1Click:Connect(function()
    local raw = modifyUpvalueValue.Text
    local valueType = typeof(selectedUpvalue.Value)
    local newValue

    if valueType == "string" then
        newValue = raw
    elseif valueType == "number" then
        local convert = tonumber(raw)

        if convert then
            newValue = convert
        else
            typeMismatchMessage()
        end
    elseif valueType == "boolean" then
        if raw == "true" then
            newValue = true
        elseif raw == "false" then
            newValue = false
        else
            typeMismatchMessage()
        end
    else
        local success, result = pcall(loadstring("return " .. raw))
        
        if success then
            if typeof(result) == upvalueTypeDropdown.Selected.Name then
                newValue = result
            else
                typeMismatchMessage()
            end
        else
            MessageBox.Show("Error",
                "There is an error in your input",
                MessageType.OK)
        end
    end

    if newValue ~= nil then
        selectedUpvalue:Set(newValue)

        modifyUpvalueValue.Text = ""
        modifyUpvalue:Hide()
    end
end)

modifyUpvalueButtons.Cancel.MouseButton1Click:Connect(function()
    modifyUpvalueValue.Text = ""
    modifyUpvalue:Hide()
end)

upvalueTypeDropdown:SetCallback(function(dropdown, button)
    local instance = dropdown.Instance
    local icon = oh.Constants.Types[button.Name] or oh.Constants.Types["userdata"]

    instance.Icon.Image = icon
end)

spyClosureContext:SetCallback(function()
    local closure = selectedLog.Closure

    if TabSelector.SelectTab("ClosureSpy") then
        local result = SpyHook.new(closure)

        if result == false then
            MessageBox.Show("Already hooked", "You are already spying " .. closure.Name)
        elseif result == nil then
            MessageBox.Show("Cannot hook", ('Cannot hook "%s" because there are no upvalues'):format(closure.Name))
        end
    end
end)

viewUpvaluesContext:SetCallback(function()
    local temporaryUpvalues = selectedLog and selectedLog.TemporaryUpvalues 

    if temporaryUpvalues then
        local instance = selectedLog.Instance
        local newHeight = 0

        for i, upvalueLog in pairs(temporaryUpvalues) do
            newHeight = newHeight + upvalueLog.AbsoluteSize.Y + 5
            upvalueLog:Destroy()
        end

        newHeight = UDim2.new(0, 0, 0, newHeight)

        instance.Upvalues.Size = instance.Upvalues.Size - newHeight
        instance.Size = instance.Size - newHeight

        upvalueList:Recalculate()

        selectedLog.TemporaryUpvalues = nil
        selectedLog.Closure.TemporaryUpvalues = {}
    else
        local closure = selectedLog.Closure
        local instance = selectedLog.Instance
        local newHeight = 0
        
        temporaryUpvalues = {}

        for i,v in pairs(getUpvalues(closure.Data)) do
            if not closure.Upvalues[i] then
                local upvalue = Upvalue.new(closure, i, v)

                if type(v) == "table" then
                    upvalue.Scanned = v
                end

                local upvalueLog = addUpvalue(upvalue, true)
                upvalueLog.Parent = instance.Upvalues
                
                newHeight = newHeight + upvalueLog.AbsoluteSize.Y + 5
                temporaryUpvalues[i] = upvalueLog
                closure.TemporaryUpvalues[i] = upvalue
            end
        end

        newHeight = UDim2.new(0, 0, 0, newHeight)

        instance.Upvalues.Size = instance.Upvalues.Size + newHeight
        instance.Size = instance.Size + newHeight

        upvalueList:Recalculate()

        selectedLog.TemporaryUpvalues = temporaryUpvalues
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

oh.Events.UpdateUpvalues = RunService.Heartbeat:Connect(function()
    for i, closureLog in pairs(currentUpvalues) do
        closureLog:Update()
    end
end)

return UpvalueScanner 