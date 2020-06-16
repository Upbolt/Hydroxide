local ClosureSpy = {}
local requiredMethods = {
    hookFunction = true,
    newCClosure = true,
    isLClosure = true,
    getProtos = true,
    getUpvalues = true,
    getUpvalue = true,
    setUpvalue = true,
    getConstants = true,
    getConstant = true,
    setConstant = true
}

local currentClosures = {}
local currentHooks = {}

local function spyClosure(closure)
    local closureData = closure.Data

    if not currentClosures[closureData] then
        local originalClosure
        local function hook(...)
            
            return originalClosure(...)
        end

        if not isLClosure(closureData) then
            hook = newCClosure(hook)
        end

        originalClosure = hookFunction(closureData, hook)
        currentClosures[closureData] = closure
    end
end

ClosureSpy.RequiredMethods = requiredMethods
return ClosureSpy