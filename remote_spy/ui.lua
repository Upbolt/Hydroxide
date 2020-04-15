local text_service = game.GetService(game, "TextService")
local tween_service = game.GetService(game, "TweenService")

local constants = {
    call_count_width = Vector2.new(1337420, 20),
    tween_speed = TweenInfo.new(0.15),
    
    empty_size = UDim2.new(0, 0, 0, 15),
    log_size = UDim2.new(0, 0, 0, 25),

    remote_object_enter = Color3.fromRGB(45, 45, 45),
    remote_object_leave = Color3.fromRGB(30, 30, 30),

    remote_log_enter = Color3.fromRGB(55, 55, 55),
    remote_log_leave = Color3.fromRGB(40, 40, 40)
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

local logs_back = logs.Back
local logs_object = logs.RemoteObject
local logs_results = logs.Results.Clip.Contents
local logs_indication = logs.RemoteObject

local ui_data = {
    RemoteEvent = { viewing = true, icon = "rbxassetid://4229806545" },
    RemoteFunction = { viewing = false, icon = "rbxassetid://4229810474" },
    BindableEvent = { viewing = false, icon = "rbxassetid://4229809371" },
    BindableFunction = { viewing = false, icon = "rbxassetid://4229807624" }
}

local create_arg = function(call, index, value)
    local arg = assets.RemoteArg.Clone(assets.RemoteArg)
    local value_type = type(value)

    arg.Icon.Image = oh.ui.icons[value_type]
    arg.Index.Text = index
    arg.Label.Text = oh.methods.to_string(value)
    arg.Label.TextColor3 = oh.ui.colors[value_type]

    call.Size = call.Size + constants.log_size
    arg.Parent = call.Contents
end

local create_call = function(vargs)
    local call = assets.CallPod.Clone(assets.CallPod)

    if #vargs == 0 then
        create_arg(call, 1, nil)
    else
        for i,value in pairs(vargs) do
            create_arg(call, i, value)
        end
    end
    
    logs_results.CanvasSize = logs_results.CanvasSize + UDim2.new(0, 0, 0, call.AbsoluteSize.Y + 5)
    call.Parent = logs_results
end

ui.new_log = function(remote)
    local log = {}
    
    local data = remote.data
    
    local object = assets.RemoteLog.Clone(assets.RemoteLog)
    local button = object.Button

    local enter_animation = tween_service.Create(tween_service, button, constants.tween_speed, { ImageColor3 = constants.remote_log_enter })
    local leave_animation = tween_service.Create(tween_service, button, constants.tween_speed, { ImageColor3 = constants.remote_log_leave })

    object.Name = data.Name
    object.Label.Text = data.Name
    object.Icon.Image = ui_data[data.ClassName].icon 

    log.object = object

    object.Parent = list_results

    if not ui_data[data.ClassName].viewing then
        object.Visible = false
    else
        list_results.CanvasSize = list_results.CanvasSize + constants.log_size
    end

    button.MouseButton1Click.Connect(button.MouseButton1Click, function() 
        local old = oh.methods.get_context()
        local selected_remote = oh.remote_spy.selected_remote

        oh.methods.set_context(6)

        if not selected_remote or (selected_remote and selected_remote ~= remote) then
            logs_results.CanvasSize = constants.empty_size
            
            for i,v in pairs(logs_results.GetChildren(logs_results)) do
                if v.ClassName == "ImageLabel" then
                    v.Destroy(v)
                end
            end
            
            local data = remote.data
            local remote_name = data.Name
            local indication_width = text_service.GetTextSize(text_service, remote_name, 16, "SourceSans", constants.call_count_width).X + 18
            
            logs_indication.Position = UDim2.new(1, -(indication_width + 5), 0, 2)
            logs_indication.Size = UDim2.new(0, indication_width, 0, 20)
            logs_indication.Label.Text = remote_name
            logs_indication.Icon.Image = ui_data[data.ClassName].icon

            for i,args in pairs(remote.logs) do
                create_call(args)
            end
        end
        
        list.Visible = false
        logs.Visible = true
        
        oh.remote_spy.selected_remote = remote
        oh.methods.set_context(old)
    end)
    
    button.MouseEnter.Connect(button.MouseEnter, function()
        enter_animation.Play(enter_animation)
    end)

    button.MouseLeave.Connect(button.MouseLeave, function()
        leave_animation.Play(leave_animation)
    end)

    return log
end

ui.update = function(remote, ...)
    remote.calls = (remote.calls or 0) + 1
    
    local vargs = {...}

    local object = remote.log.object
    local remote_name = object.Label
    local remote_icon = object.Icon
    local call_count = object.Calls

    local selected_remote = oh.remote_spy.selected_remote
    local call_width = text_service.GetTextSize(text_service, tostring(remote.calls), 16, "SourceSans", constants.call_count_width).X + 10

    call_count.Text = remote.calls
    call_count.Size = UDim2.new(0, call_width, 0, 20)

    table.insert(remote.logs, vargs)
    
    if selected_remote and selected_remote.data == remote.data then
        create_call(vargs)
    end

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
end

logs_back.MouseButton1Click:Connect(function()
    list.Visible = true
    logs.Visible = false

    oh.remote_spy.selected_remote = nil
end)

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
                enter_animation:Play()
            end
        end)

        button_object.MouseLeave:Connect(function()
            if not ui_data[remote_type].viewing then
                leave_animation:Play()
            end
        end)
    end
end

return ui