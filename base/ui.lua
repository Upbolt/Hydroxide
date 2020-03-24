local tween_service = game:GetService("TweenService")
local user_input = game:GetService("UserInputService")

local ui = {}

local show = oh.gui.Show
local base = oh.gui.Base

local body = base.Body
local drag = base.Drag

local tabs = body.Contents.Tabs
local tab_selector = body.Tabs.Body.Contents

local tween_info = TweenInfo.new(0.15)
local enter_color = Color3.fromRGB(80, 80, 80)
local leave_color = Color3.fromRGB(40, 40, 40)

local show_position = UDim2.new(0.5, -250, 0.5, -200)
local hide_position = UDim2.new(0.5, -250, 0, -500)

local show_toggle = UDim2.new(0.5, -10, 0, 5)
local hide_toggle = UDim2.new(0.5, -10, 0, -100)

local showing = true

--[[
    Tab Selection:
        - Highlight effect when the client hovers their mouse over the tab buttons in the top left
        - Changes tabs upon clicking a button (if applicible)
]]
local current_tab = tabs.Home
for i,button in pairs(tab_selector:GetChildren()) do
    if button:IsA("ImageButton") then
        local enter = tween_service:Create(button, tween_info, { ImageColor3 = enter_color })
        local leave = tween_service:Create(button, tween_info, { ImageColor3 = leave_color })

        button.MouseEnter:Connect(function()
            enter:Play()
        end)

        button.MouseLeave:Connect(function()
            leave:Play()
        end)

        button.MouseButton1Click:Connect(function()
            local tab = tabs:FindFirstChild(button.Name)
            if tab then
                current_tab.Visible = false
                tab.Visible = true
                current_tab = tab
            end
        end)
    end
end

ui.icons = {
    ["nil"] = "rbxassetid://4800232219",
    table = "rbxassetid://4666594276",
    string = "rbxassetid://4666593882",
    number = "rbxassetid://4666593882",
    boolean = "rbxassetid://4666593882",
    userdata = "rbxassetid://4666594723",
    ["function"] = "rbxassetid://4666593447"
}

local dragging, dragInput, dragStart, startPos

drag.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = base.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

drag.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

user_input.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
	    base.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

drag.Collapse.MouseButton1Click:Connect(function()
    if showing then
        base:TweenPosition(hide_position, "Out", "Quad", 0.35)
        show:TweenPosition(show_toggle, "In", "Quad", 0.35)
        showing = false
    end
end)

show.MouseButton1Click:Connect(function()
    if not showing then
        base:TweenPosition(show_position, "In", "Quad", 0.35)
        show:TweenPosition(hide_toggle, "Out", "Quad", 0.35)
        showing = true
    end
end)

oh.execute = function()
    oh.gui.Parent = game:GetService("CoreGui")
end

oh.exit = function()
    for i,v in pairs(oh.events) do
        v:Disconnect()
    end

    for i,v in pairs(oh.hooks) do
        hookfunction(i, v)
    end

    oh.is_dead = true
    oh.gui:Destroy()
    oh.assets:Destroy()
end

return ui