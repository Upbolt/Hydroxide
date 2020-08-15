local CheckBox = {}

function CheckBox.new(instance)
    local checkBox = {}
    local toggle = instance:FindFirstChild("Toggle") or instance
    local label = toggle.Label

    toggle.MouseButton1Click:Connect(function()
        checkBox.Enabled = not checkBox.Enabled

        if checkBox.Callback then
            checkBox.Callback(checkBox.Enabled)
        end

        label.Text = (checkBox.Enabled and '✓') or ''
    end)

    checkBox.Enabled = label.Text == '✓'
    checkBox.Instance = instance
    checkBox.SetCallback = CheckBox.setCallback

    return checkBox
end

function CheckBox.setCallback(checkBox, callback)
    checkBox.Callback = callback
end

return CheckBox