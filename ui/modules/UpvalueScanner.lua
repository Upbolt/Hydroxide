local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local UpvalueScanner = {}
local ClosureSpy = import("modules/ClosureSpy")
local Methods = import("modules/UpvalueScanner")

if not hasMethods(Methods.RequiredMethods) then
    return UpvalueScanner
end

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

local Query = Page.Query
local Search = Query.Search
local SearchBox = Query.Query
local Filters = Page.Filters
local ResultsClip = Page.Results.Clip
local ResultStatus = ResultsClip.ResultStatus

local modifyUpvalue = Prompt.new(Prompts.ModifyUpvalue)
local modifyElement = Prompt.new(Prompts.ModifyElement)
local deepSearch = CheckBox.new(Filters.SearchInTables)
local upvalueList = List.new(ResultsClip.Content)

local deepSearchFlag = false
local currentUpvalues = {}

local selectedLog
local selectedUpvalue
local selectedUpvalueLog
local selectedElement

local spyClosureContext = ContextMenuButton.new("rbxassetid://4666593447", "Spy Closure")
local viewUpvaluesContext = ContextMenuButton.new("rbxassetid://5179169654", "View All Upvalues")
local changeUpvalueContext = ContextMenuButton.new("rbxassetid://5458573463", "Change Upvalue")
local changeTableContext = ContextMenuButton.new("rbxassetid://5458573463", "Change Upvalue")
local viewElementsContext = ContextMenuButton.new("rbxassetid://5179169654", "View All Elements")
local changeElementContext = ContextMenuButton.new("rbxassetid://5458573463", "Change Element")
local upvalueScriptContext = ContextMenuButton.new("rbxassetid://4800244808", "Generate Script")
local tableScriptContext = ContextMenuButton.new("rbxassetid://4800244808", "Generate Script")
local elementScriptContext = ContextMenuButton.new("rbxassetid://4800244808", "Generate Script")
local getScriptContext = ContextMenuButton.new("rbxassetid://4891705738", "Get Script Path")

local closureContextMenu = ContextMenu.new({ spyClosureContext, viewUpvaluesContext, getScriptContext })
local tableContextMenu = ContextMenu.new({ changeTableContext, viewElementsContext, tableScriptContext })
local upvalueContextMenu = ContextMenu.new({ changeUpvalueContext, upvalueScriptContext })
local elementContextMenu = ContextMenu.new({ changeElementContext, elementScriptContext })

local modifyUpvalueInner = modifyUpvalue.Instance.Inner
local modifyUpvalueContent = modifyUpvalueInner.Content
local modifyUpvalueButtons = modifyUpvalueInner.Buttons.SetCancel
local modifyUpvalueType = modifyUpvalueContent.Type
local modifyUpvalueValue = modifyUpvalueContent.Value.Input

local modifyElementInner = modifyElement.Instance.Inner
local modifyElementContent = modifyElementInner.Content
local modifyElementButtons = modifyElementInner.Buttons.SetCancel
local modifyElementType = modifyElementContent.Type
local modifyElementValue = modifyElementContent.Value.Input

local upvalueTypeDropdown = Dropdown.new(modifyUpvalueType)
local elementTypeDropdown = Dropdown.new(modifyElementType)

local constants = {
    tempElementColor = Color3.fromRGB(30, 10, 10),
    tempUpvalueColor = Color3.fromRGB(40, 20, 20),
    tempBorderColor = Color3.fromRGB(20, 0, 0)
}

local function typeMismatchMessage()
    MessageBox.Show("Error", 
        "Value does not match selected type",
        MessageType.OK)
end

local function addElement(upvalueLog, upvalue, index, value, temporary)
    local elementLog = Assets.Element:Clone()
    local elementIndexType = type(index)
    local elementValueType = type(value)
    local indexText = toString(index)

    if temporary then
        elementLog.ImageColor3 = constants.tempElementColor
        elementLog.Border.ImageColor3 = constants.tempBorderColor
    end

    elementLog.Name = indexText
    elementLog.Index.Label.Text = indexText
    elementLog.Value.Label.Text = toString(value)
    elementLog.Index.Label.TextColor3 = oh.Constants.Syntax[elementIndexType]
    elementLog.Index.Icon.Image = oh.Constants.Types[elementIndexType]
    elementLog.Value.Label.TextColor3 = oh.Constants.Syntax[elementValueType]
    elementLog.Value.Icon.Image = oh.Constants.Types[elementValueType]

    elementLog.MouseButton2Click:Connect(function()
        selectedUpvalue = upvalue
        selectedUpvalueLog = upvalueLog
        selectedElement = index
        elementTypeDropdown:SetSelected(typeof(value))
        elementContextMenu:Show()
    end)

    return elementLog
end

local function updateElement(upvalueLog, index, value)
    local indexText = toString(index)
    local elementIndexType = type(index)
    local elementValueType = type(value)
    local elementLog = upvalueLog.Elements:FindFirstChild(indexText)

    elementLog.Index.Label.Text = indexText
    elementLog.Value.Label.Text = toString(value)
    elementLog.Index.Label.TextColor3 = oh.Constants.Syntax[elementIndexType]
    elementLog.Value.Label.TextColor3 = oh.Constants.Syntax[elementValueType]
    elementLog.Value.Icon.Image = oh.Constants.Types[elementIndexType]
    elementLog.Value.Icon.Image = oh.Constants.Types[elementValueType]
    elementLog.Parent = upvalueLog.Elements
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

        if not temporary then
            for i, v in pairs(upvalue.Scanned) do
                local elementLog = addElement(upvalueLog, upvalue, i, v)
                elementLog.Parent = upvalueLog.Elements
                
                height = height + elementLog.AbsoluteSize.Y + 5
            end
        end

        upvalueLog.Size = UDim2.new(1, 0, 0, height)
    else
        upvalueLog = Assets.Upvalue:Clone()

        if temporary then
            upvalueLog.ImageColor3 = constants.tempUpvalueColor
            upvalueLog.Border.ImageColor3 = constants.tempBorderColor
        end

        if valueType == "function" then
            local closureName = getInfo(value).name or ''
            upvalueLog.Value.Text = (closureName == '' and "Unnamed function") or closureName
        else
            upvalueLog.Value.Text = toString(value)
        end
    end
    
    upvalueLog.Name = index
    upvalueLog.Index.Text = index
    upvalueLog.Value.TextColor3 = oh.Constants.Syntax[valueType]
    upvalueLog.Icon.Image = oh.Constants.Types[valueType]

    upvalueLog.MouseButton2Click:Connect(function()
        selectedUpvalue = upvalue
        selectedUpvalueLog = upvalueLog
        upvalueTypeDropdown:SetSelected(typeof(upvalue.Value))

        if upvalue.Scanned then
            tableContextMenu:Show()
        else
            upvalueContextMenu:Show()
        end
    end)

    return upvalueLog
end

local function updateUpvalue(closureLog, upvalue)
    local upvalueLog = closureLog.Instance.Upvalues[tostring(upvalue.Index)]
    local closure = upvalue.Closure
    local index = upvalue.Index
    local newValue = getUpvalue(closure, index)
    local valueType = type(newValue)

    if valueType == "function" then
        local closureName = getInfo(newValue).name or ''
        upvalueLog.Value.Text = (closureName == '' and "Unnamed function") or closureName
    elseif valueType == "table" and upvalue.Scanned then
        for i, v in pairs(upvalue.Scanned) do
            updateElement(upvalueLog, i, v)
        end

        if upvalue.TemporaryElements then
            local table = upvalue.Value

            for idx, _v in pairs(upvalue.TemporaryElements) do
                updateElement(upvalueLog, idx, table[idx])
            end
        end
    else
        upvalueLog.Value.Text = toString(newValue)
    end

    upvalueLog.Value.TextColor3 = oh.Constants.Syntax[valueType]
    upvalueLog.Icon.Image = oh.Constants.Types[valueType]

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
    for _i, upvalue in pairs(log.Closure.Upvalues) do
        updateUpvalue(log, upvalue)
    end
    
    for _i, upvalue in pairs(log.Closure.TemporaryUpvalues) do
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
        local showResultLabel = false

        upvalueList:Clear()
        currentUpvalues = {}

        for _i, closure in pairs(Methods.Scan(query, deepSearchFlag)) do
            if closure.Name == '' then
                unnamedFunctions[closure.Data] = closure
            else
                Log.new(closure)
            end

            showResultLabel = true
        end

        for _i, closure in pairs(unnamedFunctions) do
            Log.new(closure)
        end

        ResultStatus.Visible = showResultLabel

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

local function setValue(valueText, value, dropdown)
    local raw = valueText
    local valueType = typeof(value)
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
            if typeof(result) == dropdown.Selected.Name then
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

    return newValue
end

local function typeDropdownAdjust(dropdown, button)
    local instance = dropdown.Instance
    local icon = oh.Constants.Types[button.Name] or oh.Constants.Types["userdata"]

    instance.Icon.Image = icon
end

modifyUpvalueButtons.Set.MouseButton1Click:Connect(function()
    local newValue = setValue(
        modifyUpvalueValue.Text, 
        selectedUpvalue.Value, 
        upvalueTypeDropdown)

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

modifyElementButtons.Set.MouseButton1Click:Connect(function()
    local upvalueValue = selectedUpvalue.Value
    
    local newValue = setValue(
        modifyElementValue.Text, 
        upvalueValue[selectedElement], 
        elementTypeDropdown)

    if newValue ~= nil then
        upvalueValue[selectedElement] = newValue

        modifyElementValue.Text = ""
        modifyElement:Hide()
    end
end)

modifyElementButtons.Cancel.MouseButton1Click:Connect(function()
    modifyElementValue.Text = ""
    modifyElement:Hide()
end)

upvalueTypeDropdown:SetCallback(typeDropdownAdjust)
elementTypeDropdown:SetCallback(typeDropdownAdjust)

local function generateScriptFormat(elementIndex)
    local generatedScript = [[-- Generated by Hydroxide's Upvalue Scanner: https://github.com/Upbolt/Hydroxide

local aux = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Upbolt/Hydroxide/revision/ohaux.lua"))()

local scriptPath = %s
local closureName = "%s"
local upvalueIndex = %d
local closureConstants = %s

local closure = aux.searchClosure(scriptPath, closureName, upvalueIndex, closureConstants)
local value = YOUR_NEW_VALUE_HERE
]]

    if elementIndex and elementIndex ~= "nil" then
        generatedScript = generatedScript .. ("local elementIndex = %s\n"):format(elementIndex)
        generatedScript = generatedScript .. "\n\n-- DO NOT RELY ON THIS FEATURE TO PRODUCE %s FUNCTIONAL SCRIPTS\n"
        return generatedScript .. "debug.getupvalue(closure, upvalueIndex)[elementIndex] = value"
    end
    
    return generatedScript .. "\n\n-- DO NOT RELY ON THIS FEATURE TO PRODUCE %s FUNCTIONAL SCRIPTS\ndebug.setupvalue(closure, upvalueIndex, value)"
end

local function generateScript(elementIndex) 
    local index = selectedUpvalue.Index
    local closure = selectedUpvalue.Closure
    local closureData = closure.Data
    local closureScript = rawget(getfenv(closureData), "script")

    local generatedScript = generateScriptFormat(dataToString(elementIndex))

    local currentConstants = {}
    local currentIndex = 0

    if closureScript and not closureScript.Parent then
        closureScript = nil
    end

    for idx, constant in pairs(getConstants(closureData)) do
        if currentIndex > 5 then 
            break 
        elseif type(constant) ~= "function" then
            currentConstants[idx] = constant
            currentIndex = currentIndex + 1
        end
    end

    setClipboard(
        generatedScript:format(
            (closureScript and getInstancePath(closureScript)) or "nil", 
            closure.Name, 
            index,
            tableToString(currentConstants),
            "100%"
        )
    )
end

upvalueScriptContext:SetCallback(function()
    generateScript()
end)

tableScriptContext:SetCallback(function()
    generateScript()
end)

elementScriptContext:SetCallback(function()
    generateScript(selectedElement)
end)

local SpyHook = ClosureSpy.Hook
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
    if selectedLog then
        local temporaryUpvalues = selectedLog.TemporaryUpvalues 
        local instance = selectedLog.Instance
        local newHeight = 0

        if temporaryUpvalues then
            for _i, upvalueLog in pairs(temporaryUpvalues) do
                newHeight = newHeight - (upvalueLog.AbsoluteSize.Y + 5)
                upvalueLog:Destroy()
            end

            selectedLog.TemporaryUpvalues = nil
            selectedLog.Closure.TemporaryUpvalues = {}
        else
            local closure = selectedLog.Closure
            
            temporaryUpvalues = {}

            for i,v in pairs(getUpvalues(closure)) do
                if not closure.Upvalues[i] then
                    local upvalue = Upvalue.new(closure, i, v)
                    
                    if type(v) == "table" then
                        upvalue.Scanned = {}
                    end
                    
                    local upvalueLog = addUpvalue(upvalue, true)
                    upvalueLog.Parent = instance.Upvalues
                    
                    newHeight = newHeight + upvalueLog.AbsoluteSize.Y + 5
                    temporaryUpvalues[i] = upvalueLog
                    closure.TemporaryUpvalues[i] = upvalue
                end
            end

            selectedLog.TemporaryUpvalues = temporaryUpvalues
        end

        newHeight = UDim2.new(0, 0, 0, newHeight)

        instance.Upvalues.Size = instance.Upvalues.Size + newHeight
        instance.Size = instance.Size + newHeight

        upvalueList:Recalculate()
    end
end)

getScriptContext:SetCallback(function()
    if selectedLog then
        local script = getfenv(selectedLog.Closure.Data).script
            
        if typeof(script) == "Instance" then
            setClipboard(getInstancePath(script))
        end
    end
end)

viewElementsContext:SetCallback(function()
    local temporaryElements = selectedUpvalue and selectedUpvalue.TemporaryElements
    local newHeight = 0

    if temporaryElements then
        for index, _v in pairs(temporaryElements) do
            local elementLog = selectedUpvalueLog.Elements[toString(index)]
            newHeight = newHeight - (elementLog.AbsoluteSize.Y + 5)

            elementLog:Destroy()
        end

        selectedUpvalue.TemporaryElements = nil
    else
        local scanned = selectedUpvalue.Scanned
        temporaryElements = {}

        for i,v in pairs(selectedUpvalue.Value) do
            if not scanned[i] then
                local elementLog = addElement(selectedUpvalueLog, selectedUpvalue, i, v, true)
                elementLog.Parent = selectedUpvalueLog.Elements

                newHeight = newHeight + elementLog.AbsoluteSize.Y + 5
                temporaryElements[i] = elementLog
            end
        end 

        selectedUpvalue.TemporaryElements = temporaryElements
    end

    newHeight = UDim2.new(0, 0, 0, newHeight)

    selectedUpvalueLog.Size = selectedUpvalueLog.Size + newHeight
    selectedUpvalueLog.Parent.Parent.Size = selectedUpvalueLog.Parent.Parent.Size + newHeight
    upvalueList:Recalculate()
end)

local function changeUpvalue()
    if selectedUpvalue then
        local index = selectedUpvalue.Index
        local indexFrame = modifyUpvalueContent.Index
        local indexNumber = indexFrame.Number
        local indexWidth = TextService:GetTextSize(tostring(index), 18, "SourceSans", indexFrame.AbsoluteSize).X
        
        indexNumber.Text = index
        indexNumber.Size = UDim2.new(0, indexWidth, 0, 25)
        
        modifyUpvalue:Show()
    end
end

changeUpvalueContext:SetCallback(changeUpvalue)
changeTableContext:SetCallback(changeUpvalue)

changeElementContext:SetCallback(function()
    if selectedUpvalue and selectedElement then
        local index = selectedElement
        local indexType = type(index)
        local indexFrame = modifyElementContent.Index
        local indexLabel = indexFrame.Data
        local indexWidth = TextService:GetTextSize(index, 18, "SourceSans", indexFrame.AbsoluteSize).X
        
        indexLabel.Text = index
        indexLabel.TextColor3 = oh.Constants.Syntax[indexType]
        indexLabel.Size = UDim2.new(0, indexWidth, 0, 25)
        
        modifyElement:Show()
    end
end)

oh.Events.UpdateUpvalues = RunService.Heartbeat:Connect(function()
    for _i, closureLog in pairs(currentUpvalues) do
        closureLog:Update()
    end
end)

return UpvalueScanner 
