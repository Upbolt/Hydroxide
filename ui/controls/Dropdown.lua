local UserInput = game:GetService("UserInputService")

local Dropdown = {}
local dropdownCache = {}

function Dropdown.new(instance)
    local dropdown = {}
    local selection = instance.Selection

    instance.Collapse.MouseButton1Click:Connect(function()
        local collapsed = not dropdown.Collapsed

        selection.Visible = not collapsed
        dropdown.Collapsed = collapsed
    end)

    for _i, v in pairs(instance.Selection.Clip.List:GetChildren()) do
        if v:IsA("TextButton") then
            v.MouseButton1Click:Connect(function()

                dropdown:Collapse(v.Name)
            end)
        end
    end

    dropdown.Collapse = Dropdown.collapse
    dropdown.Collapsed = true
    dropdown.Instance = instance
    dropdown.SetSelected = Dropdown.setSelected
    dropdown.SetCallback = Dropdown.setCallback

    table.insert(dropdownCache, dropdown)

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

function Dropdown.collapse(dropdown, name)
    local instance = dropdown.Instance
    local selection = instance.Selection

    if name then
        local button = selection.Clip.List:FindFirstChild(name)

        if button then
            instance.Label.Text = button.Name

            dropdown.Selected = button
            dropdown:Callback(button)
        end
    end

    selection.Visible = false
    dropdown.Collapsed = true
end

function Dropdown.setCallback(dropdown, callback)
    if not dropdown.Callback then
        dropdown.Callback = callback
    end
end

-- oh.Events.DropdownCollapse = UserInput.InputEnded:Connect(function(input)
--     if input.UserInputType == Enum.UserInputType.MouseButton1 then
--         for _i, dropdown in pairs(dropdownCache) do
--             dropdown:Collapse()
--         end
--     end
-- end)

return Dropdown