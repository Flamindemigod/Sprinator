const raylib = @import("raylib.zig");
const std = @import("std");
const game = @import("game.zig");
const common = @import("common.zig");
const d = @import("debug.zig");
const PLUG_STATE = common.PLUG_STATE;
const TEXTURES = common.TEXTURES;

const allocator = std.heap.c_allocator;
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
var stringArena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

var p: ?*PLUG_STATE = null;
export fn plug_unload_textures() void {
    arena.deinit();
}

export fn plug_load_textures() void {
    p.?.assets = std.AutoArrayHashMap(TEXTURES, raylib.Texture2D).init(arena.allocator());
    load_textures();
}

export fn plug_init() void {
    p = allocator.create(PLUG_STATE) catch {
        unreachable("Failed to allocate PLUG");
        return null;
    };
    p.?.debug_mode = false;
    p.?.assets = std.AutoArrayHashMap(TEXTURES, raylib.Texture2D).init(arena.allocator());
}

fn load_textures() void {
    var image: ?raylib.Image = null;
    inline for (@typeInfo(TEXTURES).Enum.fields) |f| {
        const path: []const u8 = TEXTURES.path(@enumFromInt(f.value));
        const field: TEXTURES = @enumFromInt(f.value);
        runt: {
            _ = std.fs.cwd().statFile(path) catch {
                break :runt;
            };
            image = raylib.LoadImage(@ptrCast(path));
            _ = p.?.assets.put(field, raylib.LoadTextureFromImage(image.?)) catch {
                break :runt;
            };
            raylib.UnloadImage(image.?);
            image = null;
        }
    }
}

export fn plug_destroy() void {
    allocator.destroy(p.?);
}
export fn plug_unload() *PLUG_STATE {
    return p.?;
}
export fn plug_reload(plug_ptr: *PLUG_STATE) void {
    p = plug_ptr;
}
export fn plug_keypress_handle(key: c_int) void {
    switch (key) {
        0 => {},
        raylib.KEY_F3 => {
            p.?.debug_mode = !p.?.debug_mode;
        },
        else => {
            raylib.TraceLog(raylib.LOG_DEBUG, d.format(stringArena.allocator(), "Pressed KEY {}", .{key}));
        },
    }
}

export fn draw_frame() void {
    game.update(p.?);
    game.render(p.?);
    if (p.?.debug_mode) game.debug(p.?, stringArena.allocator());
    _ = p.?.position_history.insert(0, p.?.player_position) catch {
        _ = p.?.position_history.pop();
        _ = p.?.position_history.insert(0, p.?.player_position) catch {};
    };
    _ = stringArena.reset(std.heap.ArenaAllocator.ResetMode.retain_capacity);
}
