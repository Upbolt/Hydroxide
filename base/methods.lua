local methods = {
    get_context = (syn and syn.get_thread_identity) or getthreadcontext or false,
    get_metatable = getrawmetatable or debug.getmetatable or false,
    get_constants = debug.getconstants or getconstants or getconsts or false,
    get_upvalues = debug.getupvalues or getupvalues or getupvals or false,
    get_constant = debug.getconstant or getconstant or getconsts or false,
    get_upvalue = debug.getupvalue or getupvalue or getupval or false,
    get_info = debug.getinfo or getinfo or false,
    get_gc = getgc or false,

    set_context = (syn and syn.set_thread_identity) or setthreadcontext or false,
    set_clipboard = setclipboard or (syn and syn.write_clipboard) or false,
    set_constant = debug.setconstant or setconstant or setconst or false,
    set_upvalue = debug.setupvalue or setupvalue or setupval or false,
    set_readonly = setreadonly or false,

    new_cclosure = newcclosure or false,
    check_caller = checkcaller or false,
    hook_function = hookfunction or replaceclosure or false,

    is_readonly = isreadonly or false,
    is_l_closure = islclosure or (iscclosure and function(closure) return not iscclosure(closure) end) or false,
    is_x_closure = is_synapse_function or issentinelclosure or is_protosmasher_closure or is_sirhurt_closure or checkclosure or false
}

methods.to_string = function(value) 
    local type = typeof(value)
    if type == "userdata" or type == "table" then
        local mt = oh.methods.get_metatable(value)
        local __tostring = mt and rawget(mt, "__tostring")

        if not mt or (mt and not __tostring) then 
            return tostring(value) 
        end

        rawset(mt, "__tostring", nil)
        
        value = tostring(value)
        
        rawset(mt, "__tostring", __tostring)

        return value  
    else 
        return tostring(value) 
    end
end

methods.get_path = function(instance)
	if not instance then
		return "--[[THIS OBJECT IS PARENTED TO NIL, OR IS DESTROYED]] nil"
	elseif instance == game then
		return 'game'
	elseif instance == workspace then
		return 'workspace'
    end
    
    local path

    if instance:gsub('_', ''):find('%p') then
        path = '["' .. instance.Name .. '"]'
    else
        path = '.' .. instance.Name
    end
	
	return methods.get_path(instance.Parent) .. path
end

methods.charray = function(str)
	local chars = {}

	for i,v in utf8.codes(str) do
		chars[i] = v
	end

	return chars
end

methods.combine = function(charray)
	local str = '"'

	for i,v in pairs(charray) do
		if v < 32 then 
			str = str .. '" .. string.char(' .. v .. ') .. "'
		elseif v > 126 then
			str = str .. '" .. utf8.char(' .. v .. ') .. "'
		else
			local char = string.char(v)

			if char == '\\' then
				str = str .. '\\\\'
			elseif char == '"' then
				str = str .. '\\"'
			else 
				str = str .. char
			end
		end
	end

	return str .. '"'
end

return methods
