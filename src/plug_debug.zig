const std = @import("std");
const builtin = @import("builtin");

var plug: ?*anyopaque = null;

pub var plug_init: ?*const fn () void = null;
pub var plug_destroy: ?*const fn () void = null;

pub var plug_unload_textures: ?*const fn () void = null;

pub var plug_load_textures: ?*const fn () void = null;

pub var plug_unload: ?*const fn () *anyopaque = null;
pub var plug_reload: ?*const fn (*anyopaque) void = null;
pub var draw_frame: ?*const fn () void = null;
pub var plug_keypress_handle: ?*const fn (c_int) void = null;

pub fn load_lib() void {
    switch (builtin.target.os.tag) {
        .linux => {
            // std.debug.print("Loading Lib\n");
            plug = std.c.dlopen("./zig-out/lib/libplug.so", std.c.RTLD.NOW);
            draw_frame = @ptrCast(std.c.dlsym(plug, "draw_frame"));
            plug_init = @ptrCast(std.c.dlsym(plug, "plug_init"));
            plug_destroy = @ptrCast(std.c.dlsym(plug, "plug_destroy"));
            plug_keypress_handle = @ptrCast(std.c.dlsym(plug, "plug_keypress_handle"));
            plug_unload = @ptrCast(std.c.dlsym(plug, "plug_unload"));
            plug_reload = @ptrCast(std.c.dlsym(plug, "plug_reload"));
            plug_unload_textures = @ptrCast(std.c.dlsym(plug, "plug_unload_textures"));
            plug_load_textures = @ptrCast(std.c.dlsym(plug, "plug_load_textures"));
        },
        else => {
            @panic("TODO: Not implemented");
        },
    }
}

pub fn reload_lib() void {
    if (plug != null) {
        _ = std.c.dlclose(plug.?);
    }
    load_lib();
}
