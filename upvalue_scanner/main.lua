local methods = {
    get_upvalues = true,
    get_upvalue = true,
    get_info = true,
    get_gc = true,
    set_clipboard = true,
    set_readonly = true,
    set_upvalue = true,
    is_readonly = true,
    is_x_closure = true
}

local closure = oh.import('upvalue_scanner/objects/closure')
local upvalue = oh.import('upvalue_scanner/objects/upvalue')
local table_upvalue = oh.import('upvalue_scanner/objects/table_upvalue')

local ui = oh.import('upvalue_scanner/ui')

local upvalue_scanner = {}
local current_upvalues = {}

local match_query = function(query, data)
    return data:find(query) ~= nil
end

local scan = function(query)
    local results = {}

    for i, func in pairs(oh.methods.get_gc()) do
        if type(func) == "function" and not oh.methods.is_x_closure(func) then
            for k, upvalue in pairs(oh.methods.get_upvalues(func)) do
                if type(upvalue) == "table" then
                    for key, value in pairs(upvalue) do

                        if match_query(query, key) then
                            
                        end
                    end
                else
                    
                end
            end
        end
    end
end

upvalue_scanner.scan = scan

upvalue_scanner.methods = methods
return upvalue_scanner 