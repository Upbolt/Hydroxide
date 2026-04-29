local owner = "Yuki-1224-nazz"
local branch = "revision"

-- Cache frequently used functions for performance
local pairs = pairs
local type = type
local unpack = unpack or table.unpack
local pcall = pcall
local loadstring = loadstring
local game = game

-- Optimized web import with caching and error handling
local importCache = {}

local function webImport(file)
    -- Return cached result if available
    if importCache[file] then
        return unpack(importCache[file])
    end
    
    local success, result = pcall(function()
        local url = ("https://raw.githubusercontent.com/%s/Hydroxide/%s/%s.lua"):format(owner, branch, file)
        local content = game:HttpGetAsync(url)
        
        if not content or content == "" then
            return nil
        end
        
        local func = loadstring(content, file .. '.lua')
        if func then
            return func()
        end
        
        return nil
    end)
    
    if success and result ~= nil then
        importCache[file] = {result}
        return result
    end
    
    return nil
end

-- Load main module first (initializes oh environment)
local initResult = webImport("init")

-- Load UI module
if initResult then
    webImport("ui/main")
end
