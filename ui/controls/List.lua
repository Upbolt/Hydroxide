local List = {}
local ListButton = {}

function List.new(instance)
    local list = {}

    instance.CanvasSize = UDim2.new(0, 0, 0, 15)

    list.Buttons = {}
    list.Instance = instance
    list.Recalculate = List.recalculate
    list.BindContextMenu = List.bindContextMenu

    return list
end

function ListButton.new(instance, list)
    local listButton = {}
    local listInstance = list.Instance

    list.Buttons[instance] = object
    listInstance.CanvasSize = listInstance.CanvasSize + UDim2.new(0, 0, 0, instance.AbsoluteSize.Y + 5)

    instance.Parent = listInstance
    instance.MouseButton1Click:Connect(function()
        if listButton.Callback then
            listButton.Callback()
        end
    end)

    instance.MouseButton2Click:Connect(function()
        if listButton.RightCallback then
            listButton.RightCallback()
        end
    end)

    listButton.List = list
    listButton.Instance = instance
    listButton.SetCallback = ListButton.setCallback
    listButton.SetRightCallback = ListButton.setRightCallback
    listButton.Remove = ListButton.remove
    return listButton
end

function List.bindContextMenu(list, contextMenu)
    if not list.BoundContextMenu then
        for instance, object in pairs(list.Buttons) do
            instance.MouseButton2Click:Connect(function()
                contextMenu:Show()
            end)
        end

        list.Instance.ChildAdded:Connect(function(instance)
            instance.MouseButton2Click:Connect(function()
                contextMenu:Show()
            end)
        end)

        list.BoundContextMenu = contextMenu
    end
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

function ListButton.setCallback(listButton, callback)
    listButton.Callback = callback
end

function ListButton.setRightCallback(listButton, callback)
    listButton.RightCallback = callback
end

function ListButton.remove(listButton)
    local list = listButton.List
    local instance = listButton.Instance
    local listInstance = list.Instance

    listInstance.CanvasSize = listInstance.CanvasSize - UDim2.new(0, 0, 0, instance.AbsoluteSize.Y)
    list.Buttons[instance] = nil 

    instance:Destroy()
end

return List, ListButton