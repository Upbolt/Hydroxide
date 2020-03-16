getgenv().oh = {}

oh.import = function(asset)
    local asset_type = type(asset)

    if asset_type == "string" then
        local content = (from_disk and readfile(asset)) or game:HttpGetAsync("https://raw.githubusercontent.com/nrv-ous/Hydroxide/master/")
        return loadstring(content)()
    elseif asset_type == "number" then
        return game:GetObjects(asset)[1]
    end
end

oh.methods = import("base/methods")
oh.