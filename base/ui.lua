local tween_service = game:GetService("TweenService")

local ui = {}

local base = oh.gui.Base

local body = base.Body

local tabs = body.Contents.Tabs
local tab_selector = body.Tabs.Body.Contents

local tween_info = TweenInfo.new(0.15)
local enter_color = Color3.fromRGB(170, 0, 0)
local leave_color = Color3.fromRGB(40, 40, 40)

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

oh.execute = function()
    oh.gui.Parent = game:GetService("CoreGui")
end

oh.exit = function()
    for i,v in pairs(oh.events) do
        v:Disconnect()
    end

    oh.is_dead = true
    oh.gui:Destroy()
    oh.assets:Destroy()
end

return ui