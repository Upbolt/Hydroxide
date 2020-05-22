assert(getgenv, "<oh> - Your exploit is not supported")

if Hydroxide and Hydroxide.exit then
    Hydroxide.exit()
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

function Methods.userdataValue(data)
    local dataType = typeof(data)

    if dataType == "userdata" then
        return toString(data)
    elseif dataType == "Instance" then
        return getPath(data)
    elseif 
        dataType == "Vector3" or
        dataType == "Vector2" or
        dataType == "CFrame" or
        dataType == "Color3" or
        dataType == "UDim2" 
    then
        return dataType .. ".new(" .. tostring(data) .. ")"
    elseif dataType == "Ray" then
        local split = tostring(data):split('}, ')
        local origin = split[1]:gsub('{', "Vector3.new("):gsub('}', ')')
        local direction = split[2]:gsub('{', "Vector3.new("):gsub('}', ')')
        return "Ray.new(" .. origin .. "), " .. direction .. ')'
    elseif dataType == "ColorSequence" then
        return "ColorSequence.new(" .. dataToString(v.Keypoints) .. ')'
    elseif dataType == "ColorSequenceKeypoint" then
        return "ColorSequenceKeypoint.new(" .. data.Time .. ", Color3.new(" .. tostring(data.Value) .. "))"
    end

    return tostring(data)
end

function Methods.getPath(instance)
    local name = instance.Name
    local head = '.' .. name
    
    if not instance.Parent and instance ~= game then
        return head .. " --[[ PARENTED TO NIL OR DESTROYED ]]"
    end
    
    if instance == game then
        return "game"
    elseif instance == workspace then
        return "workspace"
    else
        local success, result = pcall(game.GetService, game, instance.ClassName)
        
        if result then
            head = ':GetService("' .. instance.ClassName .. '")'
        elseif instance == Players.LocalPlayer then
            head = '.LocalPlayer' 
        else
            local nonAlphaNum = name:gsub('[%w_]', '')
            local noPunct = nonAlphaNum:gsub('[%s%p]', '')
            
            if tonumber(name:sub(1, 1)) or (#nonAlphaNum ~= 0 and #noPunct == 0) then
                head = '["' .. name:gsub('"', '\\"'):gsub('\\', '\\\\') .. '"]'
            elseif #nonAlphaNum ~= 0 and #noPunct > 0 then
                head = '[' .. toUnicode(name) .. ']'
            end
        end
    end
    
    return getPath(instance.Parent) .. head
end

function Methods.toString(value)
    local dataType = typeof(value)

    if dataType == "userdata" or dataType == "table" then
        local mt = getMetatable(value)
        local __tostring = mt and rawget(mt, "__tostring")

        if not mt or (mt and not __tostring) then 
            return tostring(value) 
        end

        rawset(mt, "__tostring", nil)
        
        value = tostring(value)
        
        rawset(mt, "__tostring", __tostring)

        return value 
    elseif type(value) == "userdata" then
        return userdataValue(value)
    else
        return tostring(value) 
    end
end

function Methods.dataToString(data, root, indents)
    local dataType = type(data)

    if dataType == "userdata" then
        return userdataValue(data)
    elseif dataType == "string" then
        if #(data:gsub('%w', ''):gsub('%s', ''):gsub('%p', '')) > 0 then
            local success, result = pcall(toUnicode, data)
            return (success and result) or toString(data)
        else
            return ('"%s"'):format(data:gsub('"', '\\"'))
        end
    elseif dataType == "table" then
        indents = indents or 1
        root = root or data

        local head = '{\n'
        local elements = 0
        local indent = ('\t'):rep(indents)
        
        for i,v in pairs(data) do
            if i ~= root and v ~= root then
                head = head .. ("%s[%s] = %s,\n"):format(indent, dataToString(i, root, indents + 1), dataToString(v, root, indents + 1))
            else
                head = head .. ("%sOH_CYCLIC_PROTECTION,\n"):format(indent)
            end

            elements = elements + 1
        end
        
        if elements > 0 then
            return ("%s\n%s"):format(head:sub(1, -3), ('\t'):rep(indents - 1) .. '}')
        else
            return "{}"
        end
    end

    return tostring(data)
end

for name, method in pairs(Methods) do
    if method then
        getgenv()[name] = method
    end
end

-- Modules
local Explorer = {}
local RemoteSpy = {}
local ClosureSpy = {}
local UpvalueScanner = {}
local ScriptScanner = {}
local ModuleScanner = {}

getgenv().Hydroxide = {
    Events = {},

    Explorer = Explorer,
    RemoteSpy = RemoteSpy,
    ClosureSpy = ClosureSpy,
    UpvalueScanner = UpvalueScanner,
    ScriptScanner = ScriptScanner,
    ModuleScanner = ModuleScanner
}

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
    remote.Ignored = not remote.Ignored

end

function Remote.block(remote)
    remote.Blocked = not remote.Blocked

end

-- Upvalue
local Upvalue = {}

function Upvalue.new(closure, index)
    local object = {}

    object.Closure = closure
    object.Index = index
    object.Value = getUpvalue(closure, index)
    object.Update = Upvalue.update

    return object
end

function Upvalue.update(upvalue)
    local value = getUpvalue(upvalue.Closure, upvalue.Index)

    if value ~= upvalue.Value then
        upvalue.Value = value
    end
end

-- Constant
local Constant = {}

function Constant.new(closure, index)
    local object = {}

    object.Closure = closure
    object.Index = index
    object.Value = getConstant(closure, index)

    return Object
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
local TableCache = {}
local InstanceCache = {}

-- RemoteSpy
local RemoteCache = {}
local RemoteIgnore = {}
local RemoteAddLog = Instance.new("BindableFunction")

local gameMethods = getMetatable(game)
local namecall = gameMethods.__namecall
local remoteMethods = {
    RemoteEvent = Instance.new("RemoteEvent").FireServer,
    RemoteFunction = Instance.new("RemoteFunction").InvokeServer,
    BindableEvent = Instance.new("BindableEvent").Fire,
    BindableFunction = Instance.new("BindableFunction").Invoke,
}

RemoteIgnore[RemoteAddLog] = true

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
    return "yes"
end

local function remoteHook(oldMethod, instance, ...)
    local results = { oldMethod(instance, ...) }

    local remote = RemoteCache[instance]

    if not remote then
        remote = Remote.new(instance)
        remote.log = RemoteAddLog.Invoke(RemoteAddLog)
    end

    return unpack(results)
end

function gameMethods.__namecall(instance, ...)
    if remoteMethods[getNamecallMethod()] and not RemoteIgnore[instance] then
        return remoteHook(namecall, instance, ...)
    end 

    return namecall(instance, ...)
end

for name, method in pairs(remoteMethods) do
    local oldMethod
    oldMethod = hookFunction(method, function(instance, ...)
        if not RemoteIgnore[instance] then
            return remoteHook(oldMethod, instance, ...)
        end
        
        return oldMethod(instance, ...)
    end)
end

-- ClosureSpy
local ClosureCache = {}

local function spyFunction(closure)
    if ClosureCache[closure] then
        -- already spying closure
        return 
    end

    if isXClosure(closure) then
        -- cannot spy exploit function
        return
    end

    ClosureCache[closure] = Closure.new(closure)
end

local function unspyFunction(closure)
    if not ClosureCache[closure] then
        -- not spying closure
        return
    end


end

-- UpvalueScanner
local UpvalueCache = {}

local function compareUpvalue(query, upvalue)
    local upvalueType = type(upvalue)

    local stringCheck = upvalueType == "string" and (query == upvalue or upvalue:find(query))
    local numberCheck = upvalueType == "number" and (tonumber(query) == upvalue or ("%.2f"):format(upvalue) == query)
    local userDataCheck = upvalueType == "userdata" and toString(upvalue) == query

    if upvalueDeepSearch and upvalueType == "table" then
        for i,v in pairs(upvalue) do
            if (i ~= upvalue and v ~= upvalue) and (compareUpvalue(query, v) or compareUpvalue(query, i)) then
                return true
            end
        end

        return false
    end

    return stringCheck or numberCheck or userDataCheck
end

local function scanUpvalues(query)
    local upvalues = {}

    for i,v in pairs(getGc()) do
        if type(v) == "function" and not isXClosure(v) then
            for k, upvalue in pairs(getUpvalues(v)) do
                if compareUpvalue(query, upvalue) then
                    local closure = upvalues[v]

                    if not closure then
                        upvalues[v] = { [k] = upvalue }
                    else
                        closure[k] = upvalue
                    end
                end
            end
        end
    end

    return upvalues
end

Hydroxide.Events.UpdateUpvalues = RunService.Heartbeat:Connect(function()
    for func, upvalues in pairs(UpvalueCache) do
        for index, upvalue in pairs(upvalues) do
            upvalue:update()
        end
    end
end)

UpvalueScanner.scan = scanUpvalues

-- ScriptScanner
local function scanScripts()
    local scripts = {}

    for i,v in pairs(getgc()) do
        if type(v) == "function" and not isXClosure(v) then
            local environment = getfenv(v)
            local script = rawget(environment, "script")
            local isExploit = rawget(environment, "getgenv")

            if script and script:IsA("LocalScript") and not isExploit then
                table.insert(scripts, script)
            end
        end
    end

    return scripts
end

ScriptScanner.scan = scanScripts

-- ModuleScanner
local function scanModules()
    local modules = {}

    for i,v in pairs(getgc()) do
        if type(v) == "function" and not isXClosure(v) then
            local script = rawget(getfenv(v), "script")

            if script and script:IsA("ModuleScript") then
                table.insert(modules, script)
            end
        end
    end

    return modules
end

ModuleScanner.scan = scanModules

-- Initialization
function Hydroxide.exit()
    for i, event in pairs(Hydroxide.Events) do
        event:Disconnect()
    end

    gameMethods.__namecall = namecall

    Interface:Destroy()
    Assets:Destroy()
end

Interface.Parent = CoreGui
