local TextService = game:GetService("TextService")

local ConstantScanner = {}
local Methods = import("modules/ConstantScanner")

local List = import("ui/controls/List")
local CheckBox = import("ui/controls/CheckBox")
local ContextMenu, ContextMenuButton = import("ui/controls/ContextMenu")

--local Page = import("rbxassetid://5042109928").Base.Body.Pages.ConstantScanner
--local Assets = import("rbxassetid://5042114982").ConstantScanner

local results = List.new(Page.Results.Clip.Content)

return ConstantScanner
