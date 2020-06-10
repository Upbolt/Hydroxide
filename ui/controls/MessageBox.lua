local TextService = game:GetService("TextService")

local Interface = import("rbxassetid://5042109928")
local Base = Interface.Base
local Object = Base.MessageBox
local Shadow = Base.MessageBoxShadow

local MessageBox = {}
local MessageType = {}

local selectedButtons
local firstClickEvent 
local secondClickEvent

local constants = {
    dynamicWidth = Vector2.new(133742069, 25),
    dynamicHeight = Vector2.new(Object.AbsoluteSize.X, 133742069)
}

MessageType.OK = 1
MessageType.OKCancel = 2
MessageType.YesNo = 3

function MessageBox.Show(title, message, messageType, firstCallback, secondCallback)
    if firstClickEvent then
        firstClickEvent:Disconnect()
        
        if secondClickEvent then
            secondClickEvent:Disconnect()
        end
    end
    
    local first, second
    local inner = Object.Inner
    local buttons = inner.Buttons

    local messageWidth = TextService:GetTextSize(title, 18, "SourceSans", constants.dynamicWidth).X + 10
    if messageWidth <= 300 then
        messageWidth = 300
    end

    local messageHeight = TextService:GetTextSize(message, 18, "SourceSans", Vector2.new(messageWidth - 30, 133742069)).Y + 95

    if messageType == MessageType.OK then
        selectedButtons = buttons.OK
        first =  selectedButtons.OK
    elseif messageType == MessageType.OKCancel then
        selectedButtons = buttons.OKCancel
        first = selectedButtons.OK
        second = selectedButtons.Cancel
    elseif messageType == MessageType.YesNo then
        selectedButtons = buttons.YesNo
        first = selectedButtons.Yes
        second = selectedButtons.No
    else
        return
    end

    Object.Title.Text = title
    inner.Message.Text = message

    Object.Size = UDim2.new(0, messageWidth, 0, messageHeight)
    Object.Position = UDim2.new(0.5, -(messageWidth / 2), 0.5, -(messageHeight / 2))

    firstClickEvent = first.MouseButton1Click:Connect(function()
        if firstCallback then
            firstCallback()
        end

        MessageBox.Hide()
    end)

    if second then
        secondClickEvent = second.MouseButton1Click:Connect(function()
            if secondCallback then
                secondCallback()
            end

            MessageBox.Hide()
        end)
    end

    selectedButtons.Visible = true
    Shadow.Visible = true
    Object.Visible = true
end

function MessageBox.Hide()
    if firstClickEvent then
        firstClickEvent:Disconnect()

        if secondClickEvent then
            secondClickEvent:Disconnect()
        end
    end

    firstClickEvent = nil
    secondClickEvent = nil

    Shadow.Visible = false
    Object.Visible = false

    selectedButtons.Visible = false
end

return MessageBox, MessageType