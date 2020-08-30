local CoreGui = game:GetService("CoreGui")
local UserInput = game:GetService("UserInputService")

local Interface = import("rbxassetid://5042109928")

import("ui/controls/TabSelector")
local MessageBox, MessageType = import("ui/controls/MessageBox")

local modulesLoaded = true
local RemoteSpy
local ClosureSpy
local ScriptScanner
local ModuleScanner
local UpvalueScanner
local ConstantScanner

xpcall(function()
    RemoteSpy = import("ui/modules/RemoteSpy")
    ClosureSpy = import("ui/modules/ClosureSpy")
    ScriptScanner = import("ui/modules/ScriptScanner")
    ModuleScanner = import("ui/modules/ModuleScanner")
    UpvalueScanner = import("ui/modules/UpvalueScanner")
    ConstantScanner = import("ui/modules/ConstantScanner")
end, function(err)
    MessageBox.Show("An error has occurred", "A module in Hydroxide has errored. This typically happens when a section's UI is modified, so please rejoin and execute again.\n\nIf that doesn't work, press F9 and send the error message marked with <HYDROXIDE-ERROR> to hush in the Hydroxide Discord server.\n\nhttps://nrv-ous.xyz/hydroxide/discord", MessageType.OK)
    warn('<HYDROXIDE-ERROR>: ' .. err)
    modulesLoaded = false
end)

if not modulesLoaded then
    if is_protosmasher_caller() then
        Interface.Parent = get_hidden_gui()
    else
        syn.protect_gui(Interface)
        Interface.Parent = CoreGui
    return
end

local constants = {
    opened = UDim2.new(0.5, -325, 0.5, -175),
    closed = UDim2.new(0.5, -325, 0, -400),
    reveal = UDim2.new(0.5, -15, 0, 20),
    conceal = UDim2.new(0.5, -15, 0, -75)
}

local Open = Interface.Open
local Base = Interface.Base
local Drag = Base.Drag
local Status = Base.Status
local Collapse = Drag.Collapse

function oh.setStatus(text)
    Status.Text = '• Status: ' .. text
end

function oh.getStatus()
    return Status.Text:gsub('• Status: ', '')
end

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

oh.Events.Drag = UserInput.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
		local delta = input.Position - dragStart
	    Base.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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

MessageBox.Show("Welcome to Hydroxide", "This is not a finished product", MessageType.OK)
Interface.Parent = CoreGui
