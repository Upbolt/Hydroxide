local TextService = game:GetService("TextService")

local ConstantScanner = {}
local ClosureSpy = import("modules/ClosureSpy")
local Methods = import("modules/ConstantScanner")

if not hasMethods(Methods.RequiredMethods) then
    return ConstantScanner
end

local List, ListButton = import("ui/controls/List")
local MessageBox, MessageType = import("ui/controls/MessageBox")
local ContextMenu, ContextMenuButton = import("ui/controls/ContextMenu")
local TabSelector = import("ui/controls/TabSelector")

local Page = import("rbxassetid://5042109928").Base.Body.Pages.ConstantScanner
local Assets = import("rbxassetid://5042114982").ConstantScanner

local Query = Page.Query
local Search = Query.Search
local SearchBox = Query.Query
 
local constantList = List.new(Page.Results.Clip.Content)
local constantLogs = {}
local selectedLog 

local spyClosureContext = ContextMenuButton.new("rbxassetid://4666593447", "Spy Closure")
local viewConstantsContext = ContextMenuButton.new("rbxassetid://5179169654", "View All Constants")

constantList:BindContextMenu(ContextMenu.new({ spyClosureContext, viewConstantsContext }))

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

-- Log Object

local Log = {}

function Log.new(closureData, closure)
    local log = {}
    local button = Assets.ClosureLog:Clone()
    local listButton = ListButton.new(button, constantList) 
    local constants = closure.Constants
    local logHeight = 30

    for _i, constant in pairs(constants) do
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

    if query:gsub(' ', '') ~= '' then
        if not tonumber(query) and query:len() <= 1 then
            return
        end

        constantList:Clear()
        constantLogs = {}

        for closureData, closure in pairs(Methods.Scan(query)) do
            Log.new(closureData, closure)
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
