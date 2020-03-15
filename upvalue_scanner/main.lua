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

local current_directory = "upvalue_scanner/"
local closure = oh.get_file(current_directory, 'objects/closure')
local upvalue = oh.get_file(current_directory, 'objects/upvalue')
local table_upvalue = oh.get_file(current_directory, 'objects/table_upvalue')



return methods