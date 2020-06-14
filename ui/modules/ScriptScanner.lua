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

local Query = Page.Query
local Search = Query.Search
local Refresh = Query.Refresh
local Results = Page.Results.Clip.Content

local scriptList = List.new(Results)
local scriptLogs = {}
local selectedLog

local pathContext = ContextMenuButton.new("rbxassetid://4891705738", "Get Script Path")
scriptList:BindContextMenu(ContextMenu.new({ pathContext }))

pathContext:SetCallback(function()
    local selectedInstance = selectedLog.LocalScript.Instance

    setClipboard(getInstancePath(selectedInstance))
    MessageBox.Show("Success", ("%s's path was copied to your clipboard."):format(selectedInstance.Name), MessageType.OK)
end)

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

    listButton:SetRightCallback(function()
        selectedLog = log
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

    for instance, localScript in pairs(Methods.Scan(query)) do
        Log.new(localScript)
    end

    scriptList:Recalculate()
end

Search.FocusLost:Connect(function(returned)
    if returned then
        addScripts(Search.Text)
        Search.Text = ""
    end
end)

Refresh.MouseButton1Click:Connect(function()
    addScripts()
end)

addScripts()

return ScriptScanner