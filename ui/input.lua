local base = oh.gui.Base
local input_box = base.InputBox
local shadow = base.UsageBlock

local input_body = input_box.Body
local buttons = input_body.Buttons

local title_obj = input_box.Title
local input_obj = input_body.Input.Input

local confirm_event
local deny_event

local tween_service = game:GetService("TweenService")
local text_service = game:GetService("TextService")

local time = TweenInfo.new(0.15)
local max_size = Vector2.new(250, 1337420)
local enter_color = Color3.fromRGB(170, 0, 0)
local leave_color = Color3.fromRGB(40, 40, 40)

for i,v in pairs(buttons:GetDescendants()) do
    if v:IsA("ImageButton") then
        local enter = tween_service:Create(v, time, {ImageColor3 = enter_color})
        local leave = tween_service:Create(v, time, {ImageColor3 = leave_color})

        v.MouseEnter:Connect(function()
            enter:Play()
        end)

        v.MouseLeave:Connect(function()
            leave:Play()
        end)
    end
end

local input = function(type, title, placeholder, confirm, deny)
    local button_set

    if oh.message_box_visible then
        return
    end

    input_obj.Text = ""

    if type == "ok" then
        button_set = buttons.OK
        confirm_event = button_set.OK.MouseButton1Click:Connect(function()
            if confirm then
                confirm(input_obj.Text)
            end

            input_box.Visible = false
            shadow.Visible = false

            confirm_event:Disconnect()
            oh.input_visible = false
        end)
    elseif type == "okcancel" then
        button_set = buttons.OKCANCEL

        confirm_event = button_set.OK.MouseButton1Click:Connect(function()
            if confirm then
                confirm(input_obj.Text)
            end

            input_box.Visible = false
            shadow.Visible = false
            
            confirm_event:Disconnect()
            deny_event:Disconnect()
            oh.input_visible = false
        end)

        deny_event = button_set.Cancel.MouseButton1Click:Connect(function()
            if deny then
                deny(input_obj.Text)
            end

            input_box.Visible = false
            shadow.Visible = false
            
            confirm_event:Disconnect()
            deny_event:Disconnect()
            oh.input_visible = false
        end)
    end

    title_obj.Text = title
    input_obj.PlaceholderText = placeholder

    button_set.Visible = true
    input_box.Visible = true
    shadow.Visible = true

    oh.input_visible = true
end

return input