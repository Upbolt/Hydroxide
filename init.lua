local environment = assert(getgenv, "<OH> ~ Your exploit is not supported")()

if oh then
    oh.Exit()
end

local importCache = {}
local globalMethods = {
    checkCaller = checkcaller,
    newCClosure = newcclosure,
    hookFunction = hookfunction,
    getGc = getgc,
    getInfo = debug.getinfo or getinfo,
    getSenv = getsenv,
    getMenv = getmenv,
    getContext = getthreadcontext or syn_context_get,
    getScriptClosure = get_script_function or getscriptclosure,
    getNamecallMethod = getnamecallmethod,
    getCallingScript = getcallingscript,
    getLoadedModules = getloadedmodules or get_loaded_modules,
    getConstants = debug.getconstants or getconstants or getconsts,
    getUpvalues = debug.getupvalues or getupvalues or getupvals,
    getProtos = debug.getprotos or getprotos,
    getStack = debug.getstack or getstack,
    getConstant = debug.getconstant or getconstant or getconst,
    getUpvalue = debug.getupvalue or getupvalue or getupval,
    getProto = debug.getproto or getproto,
    getMetatable = getrawmetatable or debug.getmetatable,
    setClipboard = setclipboard or writeclipboard,
    setConstant = debug.setconstant or setconstant or setconst,
    setUpvalue = debug.setupvalue or setupvalue or setupval,
    setStack = debug.setstack or setstack,
    setContext = setthreadcontext or syn_context_set,
    setReadOnly = setreadonly,
    isLClosure = islclosure or (iscclosure and function(closure) return not iscclosure(closure) end),
    isReadOnly = isreadonly,
    isXClosure = is_synapse_function or issentinelclosure or is_protosmasher_closure or is_sirhurt_closure or checkclosure
}

local settings = (...) or {}
settings.web = (settings.web == nil and true) or settings.web
settings.branch = settings.branch or "Upbolt/Hydroxide/revision"

local function import(asset)
    if importCache[asset] then
        return unpack(importCache[asset])
    end
    
    local assets 

    if asset:find("rbxassetid://") then
        assets = { game:GetObjects(asset)[1] }
    elseif settings.web then
        assets = { loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/" .. settings.branch .. "/" .. asset .. ".lua"), "Hydroxide/" .. asset ..".lua")() }
    else
        assets = { loadfile("hydroxide/" .. asset .. ".lua")() }
    end
    
    importCache[asset] = assets
    return unpack(assets)
end

local function hasMethods(methods)
    for name in pairs(methods) do
        if not environment[name] then
            return false
        end
    end

    return true
end

local function useMethods(module)
    for name, method in pairs(module) do
        if method then
            environment[name] = method
        end
    end
end

environment.import = import
environment.hasMethods = hasMethods
environment.oh = {
    Settings = {},
    Events = {},
    Hooks = {},
    Methods = globalMethods,
    Constants = {
        Types = {
            ["nil"] = "rbxassetid://4800232219",
            table = "rbxassetid://4666594276",
            string = "rbxassetid://4666593882",
            number = "rbxassetid://4666593882",
            boolean = "rbxassetid://4666593882",
            userdata = "rbxassetid://4666594723",
            ["function"] = "rbxassetid://4666593447"
        },
        Syntax = {
            ["nil"] = Color3.fromRGB(244, 135, 113),
            table = Color3.fromRGB(200, 200, 200),
            string = Color3.fromRGB(225, 150, 85),
            number = Color3.fromRGB(170, 225, 127),
            boolean = Color3.fromRGB(127, 200, 255),
            userdata = Color3.fromRGB(200, 200, 200),
            ["function"] = Color3.fromRGB(200, 200, 200)
        }
    },
    Exit = function()
        for i, event in pairs(oh.Events) do
            event:Disconnect()
        end

        for original, hook in pairs(oh.Hooks) do
            hookFunction(hook, function(...)
                return original(...)
            end)
        end

        getrawmetatable(game).__namecall = oh.Namecall

        unpack(importCache["rbxassetid://5042109928"]):Destroy()
        unpack(importCache["rbxassetid://5042114982"]):Destroy()
    end
}

useMethods(globalMethods)
useMethods(import("methods/string"))
useMethods(import("methods/table"))
useMethods(import("methods/userdata"))