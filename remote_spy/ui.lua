local text_service = game:GetService("TextService")
local call_count_width = Vector2.new(1337420, 20)

local ui = {}
local base = oh.gui.Base
local assets = oh.assets.RemoteSpy

local tab = base.Body.Contents.Tabs.RemoteSpy
local list = tab.List
local logs = tab.Logs

local list_main = list.Main
local list_results = list_main.Results.Clip.Contents

local viewing = {
    RemoteEvent = true,
    RemoteFunction = false,
    BindableEvent = false,
    BindableFunction = false
}

local add_call = function(log, params)
    local remote = log.remote
    local object = log.object
    local call_count = object.Calls
    local remote_name = object.Label
    local remote_icon = object.Icon

    local selected_remote = oh.remote_spy.selected_remote
    local call_width = text_service:GetTextSize(tostring(remote.calls + 1), 16, "SourceSans", call_count_width).X

    remote.calls = remote.calls + 1
    call_count.Text = remote.calls

    if not call_count.Text.Fits then
        if remote.calls < 10000 then
            remote_icon.Position = UDim2.new(0, call_width - 2, 0, 0)

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

local new_log = function(remote)
    local log = {}
    local object = assets.RemoteLog:Clone()

    log.remote = remote
    log.object = object
    
    remote.log = log
    object.Parent = list_results

    return log
end

ui.update = function(remote, ...)
    print("updated " .. remote.Name)
end

return ui