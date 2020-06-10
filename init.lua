local environment = assert(getgenv, "<OH> ~ Your exploit is not supported")()

if oh then
    oh.Exit()
end

local importCache = {}
local globalMethods = {
    checkCaller = checkcaller or false,
    newCClosure = newcclosure or false,
    hookFunction = hookfunction or false,
    getGc = getgc or false,
    getInfo = debug.getinfo or getinfo or false,
    getContext = getthreadcontext or syn_context_get or false,
    getScriptClosure = get_script_function or getscriptclosure or false,
    getNamecallMethod = getnamecallmethod or false,
    getCallingScript = getcallingscript or false,
    getLoadedModules = getloadedmodules or get_loaded_modules or false,
    getConstants = debug.getconstants or getconstants or getconsts or false,
    getUpvalues = debug.getupvalues or getupvalues or getupvals or false,
    getProtos = debug.getprotos or getprotos or false,
    getStack = debug.getstack or getstack or false,
    getConstant = debug.getconstant or getconstant or getconst or false,
    getUpvalue = debug.getupvalue or getupvalue or getupval or false,
    getProto = debug.getproto or getproto or false,
    getMetatable = getrawmetatable or debug.getmetatable or false,
    setClipboard = setclipboard or writeclipboard or false,
    setConstant = debug.setconstant or setconstant or setconst or false,
    setUpvalue = debug.setupvalue or setupvalue or setupval or false,
    setStack = debug.setstack or setstack or false,
    setContext = setthreadcontext or syn_context_set or false,
    setReadOnly = setreadonly or false,
    isLClosure = islclosure or (iscclosure and function(closure) return not iscclosure(closure) end) or false,
    isReadOnly = isreadonly or false,
    isXClosure = is_synapse_function or issentinelclosure or is_protosmasher_closure or is_sirhurt_closure or checkclosure or false
}

local web = true
local function import(asset)
    if importCache[asset] then
        return unpack(importCache[asset])
    end
    
    local assets 

    if asset:find("rbxassetid://") then
        assets = { game:GetObjects(asset)[1] }
    elseif web then
        assets = { loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Upbolt/Hydroxide/revision/" .. asset .. ".lua"))() }
    else
        assets = { loadfile("hydroxide/" .. asset .. ".lua")() }
    end
    
    importCache[asset] = assets
    return unpack(assets)
end

local function useMethods(module)
    for name, method in pairs(module) do
        if method then
            environment[name] = method
        end
    end
end

environment.import = import
environment.oh = {
    Events = {},
    Hooks = {},
    Methods = globalMethods,
    Exit = function()
        for i, event in pairs(oh.Events) do
            event:Disconnect()
        end

        for original, hook in pairs(oh.Hooks) do
            hookFunction(hook, function(...)
                return original(...)
            end)
        end

        unpack(importCache["rbxassetid://5042109928"]):Destroy()
        unpack(importCache["rbxassetid://5042114982"]):Destroy()
    end
}

useMethods(globalMethods)
useMethods(import("methods/string"))
useMethods(import("methods/table"))
useMethods(import("methods/userdata"))
