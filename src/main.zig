const raylib = @import("raylib.zig");
const std = @import("std");
const builtin = @import("builtin");
const plug = @import("plug.zig");

pub fn main() !void {
    raylib.SetConfigFlags(raylib.FLAG_WINDOW_RESIZABLE | raylib.FLAG_BORDERLESS_WINDOWED_MODE);
    raylib.InitWindow(800, 800, "Sprinator");
    raylib.SetTargetFPS(300);
    raylib.SetTraceLogLevel(raylib.LOG_ALL);
    defer raylib.CloseWindow();
    plug.load_lib();
    plug.plug_init();
    defer plug.plug_destroy();

    plug.plug_load_textures();
    defer plug.plug_unload_textures();

    while (!raylib.WindowShouldClose()) {
        raylib.BeginDrawing();
        defer raylib.EndDrawing();
        const key = raylib.GetKeyPressed();
        switch (key) {
            raylib.KEY_Q => break,
            raylib.KEY_R => {
                if (raylib.IsKeyDown(raylib.KEY_LEFT_SHIFT)) {
                    plug.plug_reload_hard();
                } else {
                    plug.plug_reload_soft();
                }
            },
            else => {
                plug.plug_keypress_handle(key);
            },
        }
        plug.draw_frame();
    }
}
