getgenv().oh = {}

local from_disk = true

oh.import = function(asset)
    local asset_type = type(asset)

    if asset_type == "string" then
        local content = (from_disk and readfile(asset)) or game:HttpGetAsync("https://raw.githubusercontent.com/nrv-ous/Hydroxide/master/")
        return loadstring(content)()
    elseif asset_type == "number" then
        return game:GetObjects(asset)[1]
    end
end

oh.methods = oh.import("base/methods")
oh.import("upvalue_scanner/main")

oh.remote_spy = oh.import("remote_spy/main")
oh.upvalue_scanner = oh.import("upvalue_scanner/main")

oh.execute()