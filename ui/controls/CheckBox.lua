local CheckBox = {}

function CheckBox.new(instance)
    local object = {}
    local toggle = instance.Toggle
    local label = toggle.Label

    toggle.MouseButton1Click:Connect(function()
        object.Enabled = not object.Enabled

        if object.Callback then
            object.Callback(object.Enabled)
        end

        label.Text = (object.Enabled and '✓') or ''
    end)

    object.Enabled = label.Text == '✓'
    object.Instance = instance
    object.SetCallback = CheckBox.setCallback

    return object
end

function CheckBox.setCallback(checkBox, callback)
    checkBox.Callback = callback
end

return CheckBox