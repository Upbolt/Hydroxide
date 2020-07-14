local CoreGui = game:GetService("CoreGui")
local UserInput = game:GetService("UserInputService")

local Interface = import("rbxassetid://5042109928")

local TabSelector = import("ui/controls/TabSelector")
local MessageBox, MessageType = import("ui/controls/MessageBox")

local RemoteSpy = import("ui/modules/RemoteSpy")
--local ClosureSpy = import("ui/modules/RemoteSpy")
local ScriptScanner = import("ui/modules/ScriptScanner")
local ModuleScanner = import("ui/modules/ModuleScanner")
local UpvalueScanner = import("ui/modules/UpvalueScanner")
local ConstantScanner = import("ui/modules/ConstantScanner")

local constants = {
    opened = UDim2.new(0.5, -325, 0.5, -175),
    closed = UDim2.new(0.5, -325, 0, -400),
    reveal = UDim2.new(0.5, -15, 0, 20),
    conceal = UDim2.new(0.5, -15, 0, -75)
}

local Open = Interface.Open
local Base = Interface.Base
local Drag = Base.Drag
local Collapse = Drag.Collapse

local dragging
local dragStart
local startPos

Drag.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local dragEnded 

		dragging = true
		dragStart = input.Position
		startPos = Base.Position
		
		dragEnded = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                dragEnded:Disconnect()
			end
		end)
	end
end)

Open.MouseButton1Click:Connect(function()
    Open:TweenPosition(constants.conceal, "Out", "Quad", 0.15)
    Base:TweenPosition(constants.opened, "Out", "Quad", 0.15)
end)

Collapse.MouseButton1Click:Connect(function()
    Base:TweenPosition(constants.closed, "Out", "Quad", 0.15)
    Open:TweenPosition(constants.reveal, "Out", "Quad", 0.15)
end)

oh.Events.Drag = UserInput.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
		local delta = input.Position - dragStart
	    Base.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

MessageBox.Show("Welcome to Hydroxide", "This is not a finished product.", MessageType.OK)
Interface.Parent = CoreGui