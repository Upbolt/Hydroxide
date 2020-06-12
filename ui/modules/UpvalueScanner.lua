local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local UpvalueScanner = {}
local Methods = import("modules/UpvalueScanner")

local List = import("ui/controls/List")
local CheckBox = import("ui/controls/CheckBox")
local MessageBox, MessageType = import("ui/controls/MessageBox")
local ContextMenu, ContextMenuButton = import("ui/controls/ContextMenu")

local Page = import("rbxassetid://5042109928").Base.Body.Pages.UpvalueScanner
local Assets = import("rbxassetid://5042114982").UpvalueScanner

local QueryInfo = Page.Query
local Filters = Page.Filters
local ResultsClip = Page.Results.Clip
local ResultStatus = ResultsClip.ResultStatus

local deepSearch = CheckBox.new(Filters.SearchInTables)
local results = List.new(ResultsClip.Content)

local spyArgs = ContextMenuButton.new("rbxassetid://112902314", "Spy Function")
local viewUpvalues = ContextMenuButton.new("rbxassetid://112902314", "View All Upvalues")

local closureMenu = ContextMenu.new({ spyArgs, viewUpvalues })

spyArgs:SetCallback(function()

end)

deepSearch:SetCallback(function(enabled)
    if enabled then
        MessageBox.Show("Notice", "Deep searching may result in longer scan times!", MessageType.OK)
    end
end)

local currentUpvalues = {}


oh.Events.UpdateUpvalues = RunService.Heartbeat:Connect(function()
    for closure, upvalues in pairs(currentUpvalues) do
        for index, upvalue in pairs(upvalues) do
            upvalue:update()
        end
    end
end)

return UpvalueScanner 