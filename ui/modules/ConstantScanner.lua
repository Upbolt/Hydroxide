local TextService = game:GetService("TextService")

local ConstantScanner = {}
local Methods = import("modules/ConstantScanner")
local Closure = import("objects/Closure")

if not hasMethods(Methods.RequiredMethods) then
    return ConstantScanner
end

local List, ListButton = import("ui/controls/List")
local MessageBox, MessageType = import("ui/controls/MessageBox")
local ContextMenu, ContextMenuButton = import("ui/controls/ContextMenu")

local Page = import("rbxassetid://5042109928").Base.Body.Pages.ConstantScanner
local Assets = import("rbxassetid://5042114982").ConstantScanner

local Query = Page.Query
local Search = Query.Search
local SearchBox = Query.Query
 
local constantList = List.new(Page.Results.Clip.Content)
local constantLogs = {}
local selectedLog 

local spyArgs = ContextMenuButton.new("rbxassetid://4666593447", "Spy Function")
local viewConstants = ContextMenuButton.new("rbxassetid://5179169654", "View All Constants")

constantList:BindContextMenu(ContextMenu.new({ spyArgs, viewConstants }))

-- Log Object

local Log = {}

function Log.new(closureData, constants)
    local log = {}
    local button = Assets.ClosureLog:Clone()
    local listButton = ListButton.new(button, constantList) 
    local closure = Closure.new(closureData)
    local logHeight = 30

    for i, constant in pairs(constants) do
        local constantLog = Assets.Constant:Clone()
        local value = constant.Value
        local valueType = type(value)
        local valueColor = oh.Constants.Syntax[valueType]

        if valueType == "function" then
            local name = getInfo(value).name
            value = (name ~= "" and name) or "Unnamed function"
            valueColor = Color3.fromRGB(127, 127, 127)
        end

        constantLog.Name = constant.Index
        constantLog.Icon.Image = oh.Constants.Types[valueType]
        constantLog.Index.Text = constant.Index
        constantLog.Value.Text = toString(value)
        constantLog.Value.TextColor3 = valueColor
        constantLog.Parent = button.Constants

        logHeight = logHeight + constantLog.AbsoluteSize.Y + 5
    end

    if closure.Name == "Unnamed function" then
        button:FindFirstChild("Name").TextColor3 = Color3.fromRGB(127, 127, 127)
    end

    button:FindFirstChild("Name").Text = closure.Name
    button.Size = UDim2.new(1, 0, 0, logHeight)

    listButton:SetRightCallback(function()
        selectedLog = log
    end)

    constantLogs[closureData] = log

    log.Closure = closure
    log.Constants = constants
    log.Button = listButton
    return log
end

-- UI Functinoality

local function addConstants()
    local query = SearchBox.Text

    if query:gsub(' ', '') ~= '' and query:len() > 2 then
        constantList:Clear()
        constantLogs = {}

        for closureData, constants in pairs(Methods.Scan(query)) do
            Log.new(closureData, constants)
        end

        constantList:Recalculate()
    else
        MessageBox.Show("Invalid query", "Your query is too short", MessageType.OK)
    end

    SearchBox.Text = ''
end

Search.MouseButton1Click:Connect(addConstants)
SearchBox.FocusLost:Connect(function(returned)
    if returned then
        addConstants()
    end
end)

return ConstantScanner
