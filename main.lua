assert(getgenv, "<oh> - Your exploit is not supported")

if Hydroxide then
    Hydroxide.exit()
end

-- Global Methods
local Methods = {
    checkCaller = checkcaller or false,
    newCClosure = newcclosure or false,
    hookFunction = hookfunction or false,
    getGc = getgc or false,
    getContext = getthreadcontext or syn_context_get or false,
    getScriptClosure = get_script_function or getscriptclosure or false,
    getNamecallMethod = getnamecallmethod or false,
    getConstants = debug.getconstants or getconstants or getconsts or false,
    getUpvalues = debug.getupvalues or getupvalues or getupvals or false,
    getStack = debug.getstack or getstack or false,
    getConstant = debug.getconstant or getconstant or getconst or false,
    getUpvalue = debug.getupvalue or getupvalue or getupval or false,
    getMetatable = getrawmetatable or debug.getmetatable or false,
    setConstant = debug.setconstant or setconstant or setconst or false,
    setUpvalue = debug.setupvalue or setupvalue or setupval or false,
    setStack = debug.setstack or setstack or false,
    setContext = setthreadcontext or syn_context_set or false,
    setReadOnly = setreadonly or false,
    isLClosure = islclosure or (iscclosure and function(closure) return not iscclosure(closure) end) or false,
    isReadOnly = isreadonly or false,
    isXClosure = is_synapse_function or issentinelclosure or is_protosmasher_closure or is_sirhurt_closure or checkclosure or false
}

for name, method in pairs(Methods) do
    if method then
        getgenv()[name] = method
    end
end

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInput = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")

local Client = Players.LocalPlayer
local Mouse = Client:GetMouse()

-- Modules
getgenv().Hydroxide = {}
local Explorer = {}
local RemoteSpy = {}
local ClosureSpy = {}
local UpvalueScanner = {}
local ScriptScanner = {}
local ModuleScanner = {}

Hydroxide.Events = {}

-- UI
local Assets = game:GetObjects("rbxassetid://5042114982")[1]
local Interface = game:GetObjects("rbxassetid://5042109928")[1]

local Base = Interface.Base

local Tabs = Base.Tabs.Container
local Drag = Base.Drag
local Body = Base.Body
local Status = Base.Status

local Pages = Body.Pages

local ContextMenu = {}
local ContextMenuButton = {}

local Constants = {
    tabEnterColor = Color3.fromRGB(45, 45, 45),
    tabLeaveColor = Color3.fromRGB(20, 20, 20),
    iconEnterColor = Color3.new(1, 1, 1),
    iconLeaveColor = Color3.fromRGB(127, 127, 127)
}

-- Core UI
local dragging
local dragStart
local startPos

Drag.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Base.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

Hydroxide.Events.Drag = UserInput.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
		local delta = input.Position - dragStart
	    Base.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

local SelectedPage = Pages.Home
local SelectedTab 
local tabAnimationCache = {}

for i, tab in pairs(Tabs:GetChildren()) do
    if tab:IsA("ImageButton") then
        local enter = TweenService:Create(tab, TweenInfo.new(0.15), { ImageColor3 = Constants.tabEnterColor })
        local leave = TweenService:Create(tab, TweenInfo.new(0.15), { ImageColor3 = Constants.tabLeaveColor })
        local iconEnter = TweenService:Create(tab.Icon, TweenInfo.new(0.15), { ImageColor3 = Constants.iconEnterColor })
        local iconLeave = TweenService:Create(tab.Icon, TweenInfo.new(0.15), { ImageColor3 = Constants.iconLeaveColor })

        tabAnimationCache[tab] = {
            enter = enter,
            leave = leave,
            iconEnter = iconEnter,
            iconLeave = iconLeave
        }

        tab.MouseButton1Click:Connect(function()
            local page = Pages:FindFirstChild(tab.Name)

            if page then
                if SelectedTab then
                    local selectedTabAnimation = tabAnimationCache[SelectedTab]
                    selectedTabAnimation.leave:Play()
                    selectedTabAnimation.iconLeave:Play()
                end
                
                SelectedPage.Visible = false
                page.Visible = true
                tab.ImageColor3 = Constants.tabEnterColor

                SelectedTab = tab
                SelectedPage = page
            end
        end)

        tab.MouseEnter:Connect(function()
            if SelectedPage ~= Pages:FindFirstChild(tab.Name) then
                enter:Play()
                iconEnter:Play()
            end
        end)

        tab.MouseLeave:Connect(function()
            if SelectedPage ~= Pages:FindFirstChild(tab.Name) then
                leave:Play()
                iconLeave:Play()
            end
        end)
    end
end

-- ContextMenu
function ContextMenu.new(menu)
    local newContextMenu = {}
    local buttons = {}

    newContextMenu.Instance = menu
    newContextMenu.Buttons = buttons
    newContextMenu.Add = ContextMenuButton.new

    return NewContextMenu
end

function ContextMenu.Show(contextMenu)
    local instance = contextMenu.Instance

    instance.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y)
    instance.Visible = true

    ContextMenu.SelectedMenu = contextMenu
end

function ContextMenu.Hide(contextMenu, newSelectedContextMenu)
    local instance = contextMenu.Instance
    
    instance.Visible = false

    ContextMenu.SelectedMenu = newSelectedContextMenu
end

function ContextMenuButton.new(contextMenu, icon, text)
    local newMenuButton = {}
    local instance = Assets.Interface.ContextMenuButton:Clone()

    instance.Icon.Image = icon
    instance.Label.Text = text

    newMenuButton.Instance = instance
    newMenuButton.SetIcon = ContextMenuButton.setIcon
    newMenuButton.SetText = ContextMenuButton.setText

    return newMenuButton
end

function ContextMenuButton.setIcon(contextMenuButton, id)
    contextMenuButton.Instance.Icon.Image = id
end

function ContextMenuButton.setText(contextMenuButton, text)
    contextMenuButton.Instance.Label.Text = text
end

Hydroxide.Events.ContextMenuDisable = UserInput.InputEnded:Connect(function(input)
    local selectedMenu = ContextMenu.SelectedMenu

    if selectedMenu and input.UserInputType == Enum.UserInputType.MouseButton1 then
        selectedMenu:Hide()
    end
end)

-- Remote
local Remote = {}

function Remote.new(instance)
    local object = {
        Calls = 0,
        Logs = {},
        Ignore = Remote.ignore,
        Block = Remote.block,
        Ignored = false,
        Blocked = false,
        Instance = instance,
    }

    return object
end

function Remote.ignore(remote)
    remote.ignored = not remote.ignored

end

function Remote.block(remote)
    remote.blocked = not remote.blocked

end



-- Closure
local Closure = {}

function Closure.new(data)
    local object = {}
    local upvalues = {}
    local constants = {}

    object.Upvalues = upvalues
    object.Constants = constants
    object.Environment = getfenv(data)

    return object
end

-- Explorer



-- RemoteSpy
local RemoteCache = {}
local RemoteAddLog = Instance.new("BindableEvent")

local gameMethods = getMetatable(game)
local namecall = gameMethods.__namecall
local remoteMethods = {
    RemoteEvent = Instance.new("RemoteEvent").FireServer,
    RemoteFunction = Instance.new("RemoteFunction").InvokeServer,
    BindableEvent = Instance.new("BindableEvent").Fire,
    BindableFunction = Instance.new("BindableFunction").Invoke,
}

setReadOnly(gameMethods, false)
setmetatable(remoteMethods, {
    __index = {
        FireServer = rawget(remoteMethods, "RemoteEvent"),
        InvokeServer = rawget(remoteMethods, "RemoteFunction"),
        Fire = rawget(remoteMethods, "BindableEvent"),
        Invoke = rawget(remoteMethods, "BindableFunction")
    }
})

function RemoteAddLog.OnInvoke(instance)

end

local remoteHook = function(oldMethod, instance, ...)
    local results = { oldMethod(instance, ...) }

    return unpack(results)
end

gameMethods.__namecall = function(instance, ...)
    if remoteMethods[getNamecallMethod()] then
        return remoteHook(namecall, instance, ...)
    end 

    return namecall(instance, ...)
end

for name, method in pairs(remoteMethods) do
    local oldMethod
    oldMethod = hookFunction(method, function(instance, ...)
        return remoteHook(oldMethod, instance, ...)
    end)
end

-- ClosureSpy



-- UpvalueScanner

local UpvalueCache = {}



Hydroixde.Events.UpdateUpvalues = RunService.Heartbeat:Connect(function()
    for func, upvalues in pairs(UpvalueCache) do
        for index, upvalue in pairs(upvalues) do
            upvalue:update()
        end
    end
end)

-- ScriptScanner


-- ModuleScanner

-- Initialization
Hydroxide.exit = function()
    for i, event in pairs(Hydroxide.Events) do
        event:Disconnect()
    end

    gameMethods.__namecall = namecall

    Interface:Destroy()
    Assets:Destroy()
end

Interface.Parent = CoreGui
