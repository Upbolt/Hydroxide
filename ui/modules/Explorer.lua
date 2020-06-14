local Explorer = {}
local Methods = import("modules/Explorer")

if not hasMethods(Methods.RequiredMethods) then
    return Explorer
end

return Explorer