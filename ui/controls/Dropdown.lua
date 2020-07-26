local Dropdown = {}

function Dropdown.new(instance)
    local dropdown = {}
    local selection = instance.Selection

    instance.Collapse.MouseButton1Click:Connect(function()
        local collapsed = not dropdown.Collapsed

        selection.Visible = not collapsed
        dropdown.Collapsed = collapsed
    end)

    for i,v in pairs(instance.Selection.Clip.List:GetChildren()) do
        if v:IsA("TextButton") then
            v.MouseButton1Click:Connect(function()
                selection.Visible = false
                dropdown.Collapsed = true

                instance.Label.Text = v.Name

                dropdown.Selected = v
                dropdown:Callback(v)
            end)
        end
    end

    dropdown.Collapsed = true
    dropdown.Instance = instance
    dropdown.SetSelected = Dropdown.setSelected
    dropdown.SetCallback = Dropdown.setCallback

    return dropdown
end

function Dropdown.setSelected(dropdown, buttonName)
    local instance = dropdown.Instance
    local selection = instance.Selection.Clip.List
    local button = selection:FindFirstChild(buttonName)

    if button then
        instance.Label.Text = buttonName

        dropdown.Collapsed = true
        dropdown.Selected = button
        dropdown:Callback(button)
    end
end

function Dropdown.setCallback(dropdown, callback)
    if not dropdown.Callback then
        dropdown.Callback = callback
    end
end

return Dropdown