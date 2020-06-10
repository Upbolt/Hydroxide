local ScriptScanner = {}
local requiredMethods = {
    getGc = true,
    isXClosure = true,
    getProtos = true,
    getConstants = true,
    getScriptClosure = true
}

local function scan()
    local scripts = {}

    for i,v in pairs(getgc()) do
        if type(v) == "function" and not isXClosure(v) then
            local environment = getfenv(v)
            local script = rawget(environment, "script")
            local isExploit = rawget(environment, "getgenv")

            if script and 
               script:IsA("LocalScript") and 
               not scripts[script] and 
               not isExploit and 
               (script.Parent or getScriptClosure(script))
            then
                scripts[script] = true 
            end
        end
    end

    return scripts
end

ScriptScanner.RequiredMethods = requiredMethods
ScriptScanner.Scan = scan
return ScriptScanner