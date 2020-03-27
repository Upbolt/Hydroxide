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

local upvalue_scanner = {}



upvalue_scanner.methods = methods
return upvalue_scanner 