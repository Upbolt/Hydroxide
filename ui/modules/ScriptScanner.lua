local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")

local ScriptScanner = {}
local Methods = import("modules/ScriptScanner")

if not hasMethods(Methods.RequiredMethods) then
    return ScriptScanner
end

local List, ListButton = import("ui/controls/List")
local MessageBox, MessageType = import("ui/controls/MessageBox")
local ContextMenu, ContextMenuButton = import("ui/controls/ContextMenu")

local Page = import("rbxassetid://11389137937").Base.Body.Pages.ScriptScanner
local Assets = import("rbxassetid://5042114982").ScriptScanner

local ScriptList = Page.List
local ScriptInfo = Page.Info

local ListQuery = ScriptList.Query
local ListSearch = ListQuery.Search
local ListRefresh = ListQuery.Refresh
local ListResults = ScriptList.Results.Clip.Content

local InfoScript = ScriptInfo.ScriptObject
local InfoBack = ScriptInfo.Back
local InfoOptions = ScriptInfo.Options.Clip.Content
local InfoSections = ScriptInfo.Sections

local InfoSource = InfoSections.Source
local InfoEnvironment = InfoSections.Environment
local InfoProtos = InfoSections.Protos
local InfoConstants = InfoSections.Constants

local EnvironmentQuery = InfoEnvironment.Query
local EnvironmentResultsClip = InfoEnvironment.Results.Clip
local EnvironmentResultsStatus = EnvironmentResultsClip.ResultStatus
local EnvironmentResults = EnvironmentResultsClip.Content

local ConstantsQuery = InfoConstants.Query
local ConstantsResultsClip = InfoConstants.Results.Clip
local ConstantsResultsStatus = ConstantsResultsClip.ResultStatus
local ConstantsResults = ConstantsResultsClip.Content

local ProtosQuery = InfoProtos.Query
local ProtosResultsClip = InfoProtos.Results.Clip
local ProtosResultsStatus = ProtosResultsClip.ResultStatus
local ProtosResults = ProtosResultsClip.Content

local scriptList = List.new(ListResults)
local protosList = List.new(ProtosResults)
local constantsList = List.new(ConstantsResults)

local scriptLogs = {}
local selected = {}
local icons = {
    LocalScript = "rbxassetid://4800244808"
}

local constants = {
    fadeLength = TweenInfo.new(0.15),
    textWidth = Vector2.new(133742069, 20)
}

local pathContext = ContextMenuButton.new("rbxassetid://4891705738", "Get Script Path")
scriptList:BindContextMenu(ContextMenu.new({ pathContext }))

pathContext:SetCallback(function()
    local selectedInstance = selected.logContext.LocalScript.Instance

    setClipboard(getInstancePath(selectedInstance))
    MessageBox.Show("Success", ("%s's path was copied to your clipboard."):format(selectedInstance.Name), MessageType.OK)
end)

local function createProto(index, value)
    local instance = Assets.ProtoPod:Clone()
    local information = instance.Information
    local functionName = getInfo(value).name or ''
    local indexWidth = TextService:GetTextSize(index, 18, "SourceSans", constants.textWidth).X + 8

    if functionName == '' then
        functionName = "Unnamed function"
        information.Label.TextColor3 = oh.Constants.Syntax["unnamed_function"]
    end
    
    information.Index.Text = index
    information.Label.Text = functionName

    information.Index.Size = UDim2.new(0, indexWidth, 0, 20)
    information.Label.Size = UDim2.new(1, -(indexWidth + 20), 1, 0)
    information.Icon.Position = UDim2.new(0, indexWidth, 0, 2)
    information.Label.Position = UDim2.new(0, indexWidth + 20, 0, 0)

    ListButton.new(instance, protosList)
end

local function createConstant(index, value)
    local instance = Assets.ConstantPod:Clone()
    local information = instance.Information
    local valueType = type(value)
    local indexWidth = TextService:GetTextSize(index, 18, "SourceSans", constants.textWidth).X + 8    

    information.Index.Text = index

    information.Index.Size = UDim2.new(0, indexWidth, 0, 20)
    information.Label.Size = UDim2.new(1, -(indexWidth + 20), 1, 0)
    information.Icon.Position = UDim2.new(0, indexWidth, 0, 2)
    information.Label.Position = UDim2.new(0, indexWidth + 20, 0, 0)

    if valueType == "function" then
        local functionName = getInfo(value).name or ''

        if functionName == '' then
            functionName = "Unnamed function"
            information.Label.TextColor3 = oh.Constants.Syntax["unnamed_function"]
        end
        
        information.Label.Text = functionName
    else
        information.Label.Text = toString(value)
    end
    
    ListButton.new(instance, constantsList)
end

-- Log Object
local Log = {}

function Log.new(localScript)
    local log = {}
    local scriptInstance = localScript.Instance
    local button = Assets.ScriptLog:Clone()
    local listButton = ListButton.new(button, scriptList)
    local scriptName = scriptInstance.Name

    button.Name = scriptName
    button:FindFirstChild("Name").Text = scriptName
    button.Protos.Text = #localScript.Protos
    button.Constants.Text = #localScript.Constants

    listButton:SetCallback(function()
        if selected.scriptLog ~= log then
            protosList:Clear()
            constantsList:Clear()
            
            ScriptList.Visible = false
            ScriptInfo.Visible = true

            local nameLength = TextService:GetTextSize(scriptName, 18, "SourceSans", constants.textWidth).X + 20
            
            InfoScript.Icon.Image = icons.LocalScript
            InfoScript.Label.Text = scriptName
            InfoScript.Label.Size = UDim2.new(0, nameLength, 0, 20)
            InfoScript.Position = UDim2.new(1, -nameLength, 0, 0)

            for i,v in pairs(localScript.Protos) do
                createProto(i, v)
            end 

            for i,v in pairs(localScript.Constants) do
                createConstant(i, v)
            end

            -- for i,v in pairs(localScript.Environment) do
            --     createEnvironment(i, v)
            -- end

            -- script decompilation here

            selected.scriptLog = log
        end
    end)

    listButton:SetRightCallback(function()
        selected.logContext = log
    end)

    scriptLogs[scriptInstance] = log

    log.LocalScript = localScript
    log.Button = listButton
    return log
end

-- UI Functionality

local function addScripts(query)
    scriptList:Clear()
    scriptLogs = {}

    for _instance, localScript in pairs(Methods.Scan(query)) do
        Log.new(localScript)
    end

    scriptList:Recalculate()
end

ListSearch.FocusLost:Connect(function(returned)
    if returned then
        addScripts(ListSearch.Text)
        ListSearch.Text = ""
    end
end)

ListRefresh.MouseButton1Click:Connect(function()
    addScripts()
end)

addScripts()

InfoBack.MouseButton1Click:Connect(function()
    ScriptInfo.Visible = false
    ScriptList.Visible = true
end)

local selectedSection = InfoProtos
local selectedSectionButton = InfoOptions.Protos
local animationCache = {}

for _i, sectionButton in pairs(InfoOptions:GetChildren()) do
    if sectionButton:IsA("TextButton") then
        local label = sectionButton.Label
        local enterAnimation = TweenService:Create(label, constants.fadeLength, { TextTransparency = 0 })
        local leaveAnimation = TweenService:Create(label, constants.fadeLength, { TextTransparency = 0.2 })

        sectionButton.MouseButton1Click:Connect(function()
            local section = InfoSections:FindFirstChild(sectionButton.Name)
            animationCache[selectedSectionButton].leave:Play()
            
            selectedSection.Visible = false
            section.Visible = true
            
            selectedSection = section
            selectedSectionButton = sectionButton

        end)

        sectionButton.MouseEnter:Connect(function()
            if selectedSectionButton ~= sectionButton then
                enterAnimation:Play()
            end
        end)

        sectionButton.MouseLeave:Connect(function()
            if selectedSectionButton ~= sectionButton then
                leaveAnimation:Play()
            end
        end)

        animationCache[sectionButton] = {
            enter = enterAnimation,
            leave = leaveAnimation
        }
    end
end

return ScriptScanner