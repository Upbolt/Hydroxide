local methods = {
    get_metatable = getrawmetatable or debug.getmetatable or false,
    get_constants = debug.getconstants or getconstants or getconsts or false,
    get_upvalues = debug.getupvalues or getupvalues or getupvals or false,
    get_constant = debug.getconstant or getconstant or getconsts or false,
    get_upvalue = debug.getupvalue or getupvalue or getupval or false,
    get_info = debug.getinfo or getinfo or false,
    get_gc = getgc or false,

    set_clipboard = setclipboard or (syn and syn.write_clipboard) or false,
    set_constant = debug.setconstant or setconstant or setconst or false,
    set_upvalue = debug.setupvalue or setupvalue or setupval or false,
    set_readonly = setreadonly or false,

    is_readonly = isreadonly or false,
    is_l_closure = islclosure or (iscclosure and function(closure) return not iscclosure(closure) end) or false,
    is_x_closure = is_synapse_function or issentinelclosure or is_protosmasher_closure or is_sirhurt_closure or checkclosure or false
}

methods.to_string = function(data)
    local type = typeof(data)

    if type == "table" or type == "userdata" then
        local metatable = methods.get_metatable(data)
        local readonly 
        local __tostring

        if not metatable or (metatable and not metatable.__tostring) then
            return tostring(data)
        elseif metatable and metatable.__tostring then
            readonly = methods.is_readonly(metatable)

            if readonly then
                methods.set_readonly(metatable, false)
            end

            __tostring = metatable.__tostring
            metatable.__tostring = nil
            data = tostring(data)
        end

        metatable.__tostring = __tostring

        if readonly then
            methods.set_readonly(metatable, true)
        end

        return data
    else
        return tostring(data)
    end
end

return methods