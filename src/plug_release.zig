const std = @import("std");
const builtin = @import("builtin");

var plug: ?*anyopaque = null;

pub extern fn plug_init() void;
pub extern fn plug_destroy() void;

pub extern fn plug_unload_textures() void;

pub extern fn plug_load_textures() void;

pub extern fn plug_unload() *anyopaque;
pub extern fn plug_reload(p: *anyopaque) void;
pub extern fn draw_frame() void;
pub extern fn plug_keypress_handle(p: c_int) void;

pub fn load_lib() void {}

pub fn reload_lib() void {}
