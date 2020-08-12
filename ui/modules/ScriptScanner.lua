local ScriptScanner = {}
local Methods = import("modules/ScriptScanner")

if not hasMethods(Methods.RequiredMethods) then
    return ScriptScanner
end

local List, ListButton = import("ui/controls/List")
local MessageBox, MessageType = import("ui/controls/MessageBox")
local ContextMenu, ContextMenuButton = import("ui/controls/ContextMenu")

local Page = import("rbxassetid://5042109928").Base.Body.Pages.ScriptScanner
local Assets = import("rbxassetid://5042114982").ScriptScanner

local List = Page.List
local Info = Page.Info

local ListQuery = List.Query
local ListSearch = ListQuery.Search
local ListRefresh = ListQuery.Refresh
local ListResults = List.Results.Clip.Content

local InfoScript = Info.ScriptObject
local InfoBack = Info.Back
local InfoOptions = Info.Options
local InfoSections = Info.Sections

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

local scriptList = List.new(Results)
local protosList = List.new(ProtosResults)

local scriptLogs = {}
local selected = {}

local pathContext = ContextMenuButton.new("rbxassetid://4891705738", "Get Script Path")
scriptList:BindContextMenu(ContextMenu.new({ pathContext }))

pathContext:SetCallback(function()
    local selectedInstance = selected.log.LocalScript.Instance

    setClipboard(getInstancePath(selectedInstance))
    MessageBox.Show("Success", ("%s's path was copied to your clipboard."):format(selectedInstance.Name), MessageType.OK)
end)

local function createProto(index, value)
    local instance = Assets.ProtoPod:CLone()
    local information = instance.Information
    local functionName = getInfo(value).name

    if functionName == '' then
        functionName = "Unnamed function"
        information.Label.TextColor3 = oh.Constants.Syntax["unnamed_function"]
    end
    
    information.Index.Text = index
    information.Label.Text = functionName

    ListButton.new(instance, protosList)
end

local function createConstant(index, value)
    local instance = Assets.ConstantPod:Clone()
    local information = instance.Information
    local valueType = type(value)
    
    information.Index.Text = index
    
    if valueType == "function" then
        local functionName = getInfo(value).name

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
    
    button.Name = scriptInstance.Name
    button:FindFirstChild("Name").Text = scriptInstance.Name
    button.Protos.Text = #localScript.Protos
    button.Constants.Text = #localScript.Constants

    listButton:SetCallback(function()
        if selected.scriptLog ~= log then
            protosList:Clear()
            constantsList:Clear()
            
            for i,v in pairs(localScript.Protos) do
                createProto(i, v)
            end 

            for i,v in pairs(localScript.Constants) do
                createConstant(i, v)
            end

            for i,v in pairs(localScript.Environment) do
                createEnvironment(i, v)
            end

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

return ScriptScanner