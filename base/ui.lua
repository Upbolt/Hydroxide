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

local message_box = oh.import("ui/message_box")
local input = oh.import("ui/input")

ui.message_box = message_box
ui.input = input

ui.icons = {
    ["nil"] = "rbxassetid://4800232219",
    table = "rbxassetid://4666594276",
    string = "rbxassetid://4666593882",
    number = "rbxassetid://4666593882",
    boolean = "rbxassetid://4666593882",
    userdata = "rbxassetid://4666594723",
    ["function"] = "rbxassetid://4666593447"
}

ui.colors = {
    ["nil"] = Color3.fromRGB(244, 135, 113),
    table = Color3.fromRGB(200, 200, 200),
    string = Color3.fromRGB(225, 150, 85),
    number = Color3.fromRGB(170, 225, 127),
    boolean = Color3.fromRGB(127, 200, 255),
    userdata = Color3.fromRGB(200, 200, 200),
    ["function"] = Color3.fromRGB(200, 200, 200)
}

ui.apply_highlight = function(obj, color_data)
    local property = (color_data and color_data.property) or "BackgroundColor3"
    local condition = (color_data and color_data.condition and color_data.condition()) or true
    local old_color = (color_data and color_data.property and obj[color_data.property]) or obj.BackgroundColor3
    local new_color = (color_data and color_data.new) or Color3.fromRGB((old_color.r * 255) + 30, (old_color.g * 255) + 30, (old_color.b * 255) + 30)
    local down_color = (color_data and color_data.down) or Color3.fromRGB((new_color.r * 255) + 30, (new_color.g * 255) + 30, (new_color.b * 255) + 30)

    local new_tween = function()
        --if condition then
            local old_context = oh.methods.get_context()
            oh.methods.set_context(6)

        print'hi'

            local anim = tween_service.Create(tween_service, obj, TweenInfo.new(0.10), {[property] = new_color})
            anim.Play(anim)

            oh.methods.set_context(old_context)
        --end
    end

    local down_tween = function()
        --if condition then
            local old_context = oh.methods.get_context()
            oh.methods.set_context(6)

            local anim = tween_service.Create(tween_service, obj, TweenInfo.new(0.10), {[property] = down_color})
            
        print'bye'

            anim.Play(anim)

            oh.methods.set_context(old_context)
        --end
    end

    obj.MouseEnter.Connect(obj.MouseEnter, new_tween)
    obj.MouseLeave.Connect(obj.MouseLeave, down_tween)

    if not (color_data and color_data.mouse2) then
        obj.MouseButton1Down.Connect(obj.MouseButton1Down, down_tween)
        obj.MouseButton1Up.Connect(obj.MouseButton1Up, new_tween)
    else
        obj.MouseButton2Down.Connect(obj.MouseButton2Down, down_tween)
        obj.MouseButton2Up:Connect(obj.MouseButton2Up, new_tween)
    end
end

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
    local method_checks = {
        RemoteSpy = oh.remote_spy.methods,
        UpvalueScanner = oh.upvalue_scanner.methods
    }
    
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
                local method_check = method_checks[tab.Name]
                local missing_methods = "" 

                if current_tab == tab or not method_check then
                    return
                end

                for method_name,v in pairs(method_check) do
                    if not oh.methods[method_name] then
                        missing_methods = missing_methods .. method_name .. ", "
                        print(method_name)
                    end
                end

                if #missing_methods > 0 then
                    message_box(
                        "ok",
                        "You cannot use this section!", 
                        "Functions are missing from your exploit! Here is a list of what it needs: " .. missing_methods:sub(1, -3)
                    )
                    return
                end

                if tab then
                    current_tab.Visible = false
                    tab.Visible = true
                    current_tab = tab
                end
            end)
        end
    end

    oh.gui.Parent = game:GetService("CoreGui")
end

oh.exit = function()
    for i,v in pairs(oh.events) do
        v:Disconnect()
    end

    for i,v in pairs(oh.hooks) do
        if i == "namecall" then
            local gmt = oh.methods.get_metatable(game)
            gmt.__namecall = v
        else
            hookfunction(i, v)
        end
    end

    oh.is_dead = true
    oh.gui:Destroy()
    oh.assets:Destroy()
end

return ui