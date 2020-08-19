local ScriptScanner = {}
local LocalScript = import("objects/LocalScript")

local requiredMethods = {
    ["getGc"] = true,
    ["getSenv"] = true,
    ["getProtos"] = true,
    ["getConstants"] = true,
    ["getScriptClosure"] = true,
    ["isXClosure"] = true
}

local function scan(query)
    local scripts = {}
    query = query or ""

    for _i, v in pairs(getGc()) do
        if type(v) == "function" and not isXClosure(v) then
            local script = rawget(getfenv(v), "script")

            if typeof(script) == "Instance" and 
                not scripts[script] and 
                script:IsA("LocalScript") and 
                script.Name:lower():find(query) and
                getScriptClosure(script) and
                pcall(function() getsenv(script) end)
            then
                scripts[script] = LocalScript.new(script)
            end
        end
    end

    return scripts
end

ScriptScanner.RequiredMethods = requiredMethods
ScriptScanner.Scan = scan
return ScriptScanner