local Assets = import("rbxassetid://5042114982").Controls
local Storage = import("rbxassetid://5042109928").ContextMenus

local Players = game:GetService("Players")
local UserInput = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local client = Players.LocalPlayer
local mouse = client:GetMouse()

local ContextMenuButton = {}
local ContextMenu = {}

local currentContextMenu
local constants = {
    fadeLength = TweenInfo.new(0.15)
}

function ContextMenuButton.new(icon, text)
    local contextMenuButton = {}
    local instance = Assets.ContextMenuButton:Clone()
    local label = instance.Label

    local enterAnimation = TweenService:Create(label, constants.fadeLength, { TextTransparency = 0 })
    local leaveAnimation = TweenService:Create(label, constants.fadeLength, { TextTransparency = 0.2 })

    label.Text = text
    instance.Icon.Image = icon

    instance.MouseButton1Click:Connect(function()
        
    end)

    instance.MouseEnter:Connect(function()
        enterAnimation:Play()
    end)

    instance.MouseLeave:Connect(function()
        leaveAnimation:Play()
    end)

    contextMenuButton.Instance = instance
    contextMenuButton.SetIcon = ContextMenuButton.setIcon
    contextMenuButton.SetText = ContextMenuButton.setText
    return contextMenuButton
end

function ContextMenuButton.setIcon(contextMenuButton, newIcon)
    contextMenuButton.Icon.Image = newIcon
end

function ContextMenuButton.setText(contextMenuButton, newText)
    contextMenuButton.Label.Text = newText
end

function ContextMenuButton.setCallback(contextMenuButton, callback)
    if not contextMenuButton.Callback then
        contextMenuButton.Callback = callback
        return contextMenuButton.MouseButton1Click:Connect(function()
            
        end)
    end
end

function ContextMenu.new(contextMenuButtons)
    local contextMenu = {}
    local instance = Assets.ContextMenu:Clone()
    local instanceWidth 

    instance.Parent = Storage
    
    for i, contextMenuButton in pairs(contextMenuButtons) do
        local buttonInstance = contextMenuButton.Instance
        buttonInstance.Parent = instance.List
        
        local buttonWidth = buttonInstance.Icon.AbsoluteSize.X + buttonInstance.Label.TextBounds.X + 18
        
        if not instanceWidth or buttonWidth > instanceWidth then
            instanceWidth = buttonWidth
        end
    end

    instance.Size = UDim2.new(0, instanceWidth, 0, instance.AbsoluteSize.Y)
    
    contextMenu.Instance = instance
    contextMenu.Buttons = {}
    contextMenu.Show = ContextMenu.show
    contextMenu.Hide = ContextMenu.hide
    return contextMenu
end

function ContextMenu.add(contextMenu, contextMenuButton)
    table.insert(contextMenu.Buttons, contextMenuButton)
end

function ContextMenu.show(contextMenu)
    local instance = contextMenu.Instance

    instance.Visible = true
    instance.Position = UDim2.new(0, mouse.X, 0, mouse.Y)
    
    currentContextMenu = contextMenu
end

function ContextMenu.hide(contextMenu)
    contextMenu.Instance.Visible = false
end

UserInput.InputEnded:Connect(function(input)
    if currentContextMenu and input.UserInputType == Enum.UserInputType.MouseButton1 then
        currentContextMenu:Hide()
        currentContextMenu = nil
    end
end)

return ContextMenu, ContextMenuButton