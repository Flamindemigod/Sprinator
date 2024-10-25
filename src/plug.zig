const std = @import("std");
const builtin = @import("builtin");
const DEBUG = builtin.mode == .Debug;
const plug = if (DEBUG) @import("plug_debug.zig") else @import("plug_release.zig");
pub const load_lib = plug.load_lib;
pub const reload_lib = plug.reload_lib;

pub fn plug_init() void {
    if (DEBUG) {
        plug.plug_init.?();
    } else {
        plug.plug_init();
    }
}
pub fn plug_destroy() void {
    if (DEBUG) {
        plug.plug_destroy.?();
    } else {
        plug.plug_destroy();
    }
}

pub fn plug_unload_textures() void {
    if (DEBUG) {
        plug.plug_unload_textures.?();
    } else {
        plug.plug_unload_textures();
    }
}

pub fn plug_load_textures() void {
    if (DEBUG) {
        plug.plug_load_textures.?();
    } else {
        plug.plug_load_textures();
    }
}

pub fn plug_unload() *anyopaque {
    if (DEBUG) {
        return plug.plug_unload.?();
    } else {
        return plug.plug_unload();
    }
}
pub fn plug_reload(p: *anyopaque) void {
    if (DEBUG) {
        plug.plug_reload.?(p);
    } else {
        plug.plug_reload(p);
    }
}
pub fn draw_frame() void {
    if (DEBUG) {
        plug.draw_frame.?();
    } else {
        plug.draw_frame();
    }
}
pub fn plug_keypress_handle(p: c_int) void {
    if (DEBUG) {
        plug.plug_keypress_handle.?(p);
    } else {
        plug.plug_keypress_handle(p);
    }
}

pub fn plug_reload_soft() void {
    if (DEBUG) {
        std.debug.print("Reloading LibPlug\n", .{});
        plug_unload_textures();
        const p = plug_unload();
        reload_lib();
        plug_reload(p);
        plug_load_textures();
    }
}

pub fn plug_reload_hard() void {
    if (DEBUG) {
        std.debug.print("Resetting LibPlug\n", .{});
        plug_unload_textures();
        plug_destroy();
        reload_lib();
        plug_init();
        plug_load_textures();
    }
}
