local base = oh.gui.Base
local message_box = base.MessageBox
local shadow = base.UsageBlock

local message_body = message_box.Body
local buttons = message_body.Buttons

local title_obj = message_box.Title
local message_obj = message_body.Message

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

local message = function(type, title, message, confirm, deny)
    local button_set
    local message_size = text_service:GetTextSize(message, 18, "SourceSans", max_size)

    if oh.input_visible then
        return
    end

    if type == "ok" then
        button_set = buttons.OK
        confirm_event = button_set.OK.MouseButton1Click:Connect(function()
            if confirm then
                confirm()
            end

            message_box.Visible = false
            shadow.Visible = false

            confirm_event:Disconnect()
            oh.message_box_visible = false
        end)
    elseif type == "okcancel" then
        button_set = buttons.OKCANCEL

        confirm_event = button_set.OK.MouseButton1Click:Connect(function()
            if confirm then
                confirm()
            end

            message_box.Visible = false
            shadow.Visible = false
            
            confirm_event:Disconnect()
            deny_event:Disconnect()
            oh.message_box_visible = false
        end)

        deny_event = button_set.Cancel.MouseButton1Click:Connect(function()
            if deny then
                deny()
            end

            message_box.Visible = false
            shadow.Visible = false
            
            confirm_event:Disconnect()
            deny_event:Disconnect()
            oh.message_box_visible = false
        end)
    else
        button_set = buttons.YESNO

        confirm_event = button_set.Yes.MouseButton1Click:Connect(function()
            if confirm then
                confirm()
            end

            message_box.Visible = false
            shadow.Visible = false
            
            confirm_event:Disconnect()
            deny_event:Disconnect()
            oh.message_box_visible = false
        end)

        deny_event = button_set.No.MouseButton1Click:Connect(function()
            if deny then
                deny()
            end

            message_box.Visible = false
            shadow.Visible = false
            
            confirm_event:Disconnect()
            deny_event:Disconnect()
            oh.message_box_visible = false
        end)
    end

    message_box.Size = UDim2.new(0, 250, 0, 62 + message_size.Y)
    message_box.Position = UDim2.new(0.5, -125, 0.5, -((message_size.Y + 62) / 2))

    title_obj.Text = title
    message_obj.Text = message

    button_set.Visible = true
    message_box.Visible = true
    shadow.Visible = true

    oh.message_box_visible = true
end

return message