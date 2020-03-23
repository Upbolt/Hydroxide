local text_service = game.GetService(game, "TextService")
local tween_service = game.GetService(game, "TweenService")


local constants = {
    call_count_width = Vector2.new(1337420, 20),
    tween_speed = TweenInfo.new(0.15),
    
    empty_size = UDim2.new(0, 0, 0, 0),
    log_size = UDim2.new(0, 0, 0, 30),

    remote_object_enter = Color3.fromRGB(50, 50, 50),
    remote_object_leave = Color3.fromRGB(30, 30, 30)
}

local ui = {}
local base = oh.gui.Base
local assets = oh.assets.RemoteSpy

local tab = base.Body.Contents.Tabs.RemoteSpy
local list = tab.List
local logs = tab.Logs

local list_main = list.Main
local list_buttons = list.Remotes
local list_results = list_main.Results.Clip.Contents

local ui_data = {
    RemoteEvent = { viewing = true, icon = "rbxassetid://4229806545" },
    RemoteFunction = { viewing = false, icon = "rbxassetid://4229810474" },
    BindableEvent = { viewing = false, icon = "rbxassetid://4229809371" },
    BindableFunction = { viewing = false, icon = "rbxassetid://4229807624" }
}

local add_call = function(log, ...)
    local remote = log.remote
    local object = log.object
    local remote_name = object.Label
    local remote_icon = object.Icon
    local call_count = object.Calls

    local selected_remote = oh.remote_spy.selected_remote
    local call_width = text_service.GetTextSize(text_service, tostring(remote.calls + 1), 16, "SourceSans", constants.call_count_width).X + 10

    remote.calls = remote.calls + 1

    call_count.Text = remote.calls
    call_count.Size = UDim2.new(0, call_width, 0, 20)

    if not call_count.Text.Fits then
        if remote.calls < 10000 then
            remote_icon.Position = UDim2.new(0, call_width - 4, 0, 0)

            local icon_width_offset = call_width + remote_icon.AbsoluteSize.X

            remote_name.Position = UDim2.new(0, icon_width_offset, 0, 0)
            remote_name.Size = UDim2.new(1, -icon_width_offset, 0, 20)
        else
            remote_icon.Position = UDim2.new(0, 18, 0, 1)
            remote_name.Position = UDim2.new(0, 40, 0, 0)
            remote_name.Size = UDim2.new(1, -40, 0, 20)

            call_count.Text = "..."
            call_count.Size = UDim2.new(0, 20, 0, 20)
        end
    end

    if selected_remote then

    end
end

ui.new_log = function(remote)
    local log = {}
    local data = remote.data

    local object = assets.RemoteLog.Clone(assets.RemoteLog)

    object.Name = data.Name
    object.Label.Text = data.Name
    object.Icon.Image = ui_data[data.ClassName].icon 

    log.remote = remote
    log.object = object
    
    remote.log = log
    object.Parent = list_results

    if not ui_data[data.ClassName].viewing then
        object.Visible = false
    else
        list_results.CanvasSize = list_results.CanvasSize + constants.log_size
    end

    return log
end

ui.update = function(remote, ...)
    add_call(remote.log, ...)
end

for i, button in pairs(list_buttons:GetChildren()) do
    if button.ClassName == "Frame" then
        local button_object = button.Button
        local remote_type = button.Name
        local enter_animation = tween_service:Create(button_object, constants.tween_speed, { ImageColor3 = constants.remote_object_enter })
        local leave_animation = tween_service:Create(button_object, constants.tween_speed, { ImageColor3 = constants.remote_object_leave })

        button_object.MouseButton1Click.Connect(button_object.MouseButton1Click, function()
            ui_data[remote_type].viewing = not ui_data[remote_type].viewing
            button_object.ImageColor3 = constants.remote_object_enter

            list_results.CanvasSize = constants.empty_size

            for k, remote in pairs(oh.remote_spy.remote.cache) do
                local object = remote.log.object
                object.Visible = ui_data[remote.data.ClassName].viewing

                if object.Visible then
                    list_results.CanvasSize = list_results.CanvasSize + constants.log_size
                end
            end
        end)

        button_object.MouseEnter:Connect(function()
            if not ui_data[remote_type].viewing then
                enter_animation.Play(enter_animation)
            end
        end)

        button_object.MouseLeave:Connect(function()
            if not ui_data[remote_type].viewing then
                leave_animation.Play(leave_animation)
            end
        end)
    end
end

return ui