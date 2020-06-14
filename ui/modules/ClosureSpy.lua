local ClosureSpy = {}
local Methods = import("modules/ClosureSpy")

if not hasMethods(Methods.RequiredMethods) then
    return ClosureSpy
end

return ClosureSpy