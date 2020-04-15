if oh and oh.exit then
    oh.exit()
end

local from_disk = true
local easier_debug = true
local github_branch = "Upbolt/Hydroxide/master"

getgenv().oh = {}
oh.events = {}
oh.hooks = {}

oh.import = function(asset)
    local asset_type = type(asset)

    if asset_type == "string" then
        local func = loadstring(
            (from_disk and readfile("oh/" .. asset .. '.lua')) or 
            game:HttpGetAsync(("https://raw.githubusercontent.com/%s/%s.lua"):format(github_branch, asset))
        )
        if easier_debug then
            local suc,ret = pcall(func)
            if suc then
                return ret
            else
                game:GetService('TestService'):Error('[Hydroxide] ('..asset..'.lua)\n'..ret)
            end
        else 
            return ls(func)
        end
    elseif asset_type == "number" then
        return game:GetObjects("rbxassetid://" .. asset)[1]
    end
end

oh.gui = oh.import(4635451696)
oh.assets = oh.import(4636445983)

oh.methods = oh.import("base/methods")
oh.ui = oh.import('base/ui')

oh.remote_spy = oh.import("remote_spy/main")
oh.upvalue_scanner = oh.import("upvalue_scanner/main")

oh.execute()
