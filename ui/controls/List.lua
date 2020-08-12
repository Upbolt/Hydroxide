local UserInput = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local List = {}
local ListButton = {}

local lists = {}
local ctrlHeld = false
local constants = {
    tweenTime = TweenInfo.new(0.15),
    selected = Color3.fromRGB(55, 35, 35),
    deselected = Color3.fromRGB(35, 35, 35)
}

function List.new(instance, multiClick)
    local list = {}

    instance.CanvasSize = UDim2.new(0, 0, 0, 15)

    list.Buttons = {}
    list.Instance = instance
    list.Clear = List.clear
    list.Recalculate = List.recalculate
    list.BindContextMenu = List.bindContextMenu
    list.BindContextMenuSelected = List.bindContextMenuSelected
    list.MultiClickEnabled = multiClick

    table.insert(lists, list)

    return list
end

function ListButton.new(instance, list)
    local listButton = {}
    local listInstance = list.Instance

    list.Buttons[instance] = listButton

    if instance.Visible then
        listInstance.CanvasSize = listInstance.CanvasSize + UDim2.new(0, 0, 0, instance.AbsoluteSize.Y + 5)
    end

    instance.Parent = listInstance
    instance.MouseButton1Click:Connect(function()
        if not ctrlHeld and listButton.Callback then
            listButton.Callback()
        elseif list.MultiClickEnabled and ctrlHeld then
            if not list.Selected then
                list.Selected = {}
            end

            if listButton.SelectedCallback then
                listButton.SelectedCallback()
            end

            local foundButton = table.find(list.Selected, listButton)

            if not foundButton then
                table.insert(list.Selected, listButton)
                listButton.SelectAnimation:Play()
            else
                table.remove(list.Selected, foundButton)
                listButton.DeselectAnimation:Play()
            end
        end
    end)

    instance.MouseButton2Click:Connect(function()
        if not ctrlHeld and listButton.RightCallback then
            listButton.RightCallback()
        end
    end)

    listButton.List = list
    listButton.Instance = instance
    listButton.SetCallback = ListButton.setCallback
    listButton.SetRightCallback = ListButton.setRightCallback
    listButton.SetSelectedCallback = ListButton.setSelectedCallback
    listButton.Remove = ListButton.remove
    listButton.SelectAnimation = TweenService:Create(instance, constants.tweenTime, { ImageColor3 = constants.selected })
    listButton.DeselectAnimation = TweenService:Create(instance, constants.tweenTime, { ImageColor3 = constants.deselected })
    return listButton
end

function List.clear(list)
    local instance = list.Instance

    for _i, listButton in pairs(instance:GetChildren()) do
        if listButton:IsA("ImageButton") then
            listButton:Destroy()
        end
    end

    instance.CanvasSize = UDim2.new(0, 0, 0, 15)
    list.Buttons = {}
end

function List.recalculate(list)
    local newHeight = 15

    for instance in pairs(list.Buttons) do
        if instance.Visible then
            newHeight = newHeight + instance.AbsoluteSize.Y + 5
        end
    end

    list.Instance.CanvasSize = UDim2.new(0, 0, 0, newHeight)
end

function List.bindContextMenu(list, contextMenu)
    if not list.BoundContextMenu then
        local function showContextMenu()
            if not list.Selected then
                contextMenu:Show()
            end
        end

        list.Instance.ChildAdded:Connect(function(instance)
            instance.MouseButton2Click:Connect(showContextMenu)
        end)

        list.BoundContextMenu = contextMenu
    end
end

function List.bindContextMenuSelected(list, contextMenu)
    if not list.BoundContextMenuSelected then
        local function showContextMenu()
            if list.Selected then
                contextMenu:Show()
            end
        end

        list.Instance.ChildAdded:Connect(function(instance)
            instance.MouseButton2Click:Connect(showContextMenu)
        end)

        list.BoundContextMenuSelected = contextMenu
    end
end

function ListButton.setCallback(listButton, callback)
    listButton.Callback = callback
end

function ListButton.setRightCallback(listButton, callback)
    listButton.RightCallback = callback
end

function ListButton.setSelectedCallback(listButton, callback)
    listButton.SelectedCallback = callback
end

function ListButton.remove(listButton)
    local list = listButton.List
    local instance = listButton.Instance
    local listInstance = list.Instance

    listInstance.CanvasSize = listInstance.CanvasSize - UDim2.new(0, 0, 0, instance.AbsoluteSize.Y + 5)
    list.Buttons[instance] = nil 

    instance:Destroy()
end

oh.Events.ListInputBegan = UserInput.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftControl then
        ctrlHeld = true
    elseif not ctrlHeld and input.UserInputType == Enum.UserInputType.MouseButton1 then
        for _i, list in pairs(lists) do
            if list.Selected then
                for _k, listButton in pairs(list.Selected) do
                    listButton.DeselectAnimation:Play()
                end

                list.Selected = nil
            end
        end
    end
end)

oh.Events.ListInputEnded = UserInput.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftControl then
        ctrlHeld = false 
    end
end)

return List, ListButton