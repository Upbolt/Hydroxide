local Assets = import("rbxassetid://5042114982").Controls
local Storage = import("rbxassetid://11389137937").ContextMenus

local Players = game:GetService("Players")
local UserInput = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")

local client = Players.LocalPlayer
local mouse = client:GetMouse()

local ContextMenuButton = {}
local ContextMenu = {}

local currentContextMenu
local constants = {
    fadeLength = TweenInfo.new(0.15),
    textWidth = Vector2.new(1337420, 20)
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
        if contextMenuButton.Callback then
            contextMenuButton.Callback()
        end
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
    contextMenuButton.SetCallback = ContextMenuButton.setCallback
    return contextMenuButton
end

function ContextMenuButton.setIcon(contextMenuButton, newIcon)
    contextMenuButton.Instance.Icon.Image = newIcon
end

function ContextMenuButton.setText(contextMenuButton, newText)
    contextMenuButton.Instance.Label.Text = newText
end

function ContextMenuButton.setCallback(contextMenuButton, callback)
    if not contextMenuButton.Callback then
        contextMenuButton.Callback = callback
    end
end

function ContextMenu.new(contextMenuButtons)
    local contextMenu = {}
    local instance = Assets.ContextMenu:Clone()
    local instanceWidth = 0
    local instanceHeight = 0

    instance.Parent = Storage
    
    for _i, contextMenuButton in pairs(contextMenuButtons) do
        local buttonInstance = contextMenuButton.Instance
        local textWidth = TextService:GetTextSize(buttonInstance.Label.Text, 18, "SourceSans", constants.textWidth).X

        buttonInstance.Parent = instance.List
        buttonInstance.TextWrapped = false

        local buttonWidth = buttonInstance.Icon.AbsoluteSize.X + textWidth + 16
        
        if buttonWidth > instanceWidth then
            instanceWidth = buttonWidth
        end

        instanceHeight = instanceHeight + buttonInstance.AbsoluteSize.Y
    end
    
    instance.Size = UDim2.new(0, instanceWidth, 0, instanceHeight)
    instance.Visible = false
    
    contextMenu.Instance = instance
    contextMenu.Visible = false
    contextMenu.Buttons = {}
    contextMenu.Show = ContextMenu.show
    contextMenu.Hide = ContextMenu.hide
    return contextMenu
end

function ContextMenu.add(contextMenu, contextMenuButton)
    table.insert(contextMenu.Buttons, contextMenuButton)
end

function ContextMenu.show(contextMenu)
    if currentContextMenu then
        currentContextMenu:Hide()
    end

    local instance = contextMenu.Instance

    instance.Visible = true
    instance.Position = UDim2.new(0, mouse.X, 0, mouse.Y)
    
    contextMenu.Visible = true
    currentContextMenu = contextMenu
end

function ContextMenu.hide(contextMenu)
    contextMenu.Visible = false
    contextMenu.Instance.Visible = false
end

UserInput.InputEnded:Connect(function(input)
    if currentContextMenu and input.UserInputType == Enum.UserInputType.MouseButton1 then
        currentContextMenu:Hide()
        currentContextMenu = nil
    end
end)

return ContextMenu, ContextMenuButton