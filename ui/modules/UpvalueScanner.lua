local UpvalueScanner = {}
local Methods = import("modules/UpvalueScanner")
local MessageBox = import("ui/controls/MessageBox")
local ContextMenu, ContextMenuButton = import("ui/controls/ContextMenu")

local Page = import("rbxassetid://5042109928").Base.Body.Pages.UpvalueScanner
local Assets = import("rbxassetid://5042114982")

local RunService = game:GetService("RunService")

local currentUpvalues = {}



oh.Events.UpdateUpvalues = RunService.Heartbeat:Connect(function()
    for closure, upvalues in pairs(currentUpvalues) do
        for index, upvalue in pairs(upvalues) do
            upvalue:update()
        end
    end
end)

return UpvalueScanner 