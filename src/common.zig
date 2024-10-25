const raylib = @import("raylib.zig");
const std = @import("std");

const PLAYER_POSITION_HISTORY_COUNT = 300;

pub const PLAYER_SIZE = 50 / 2;
pub const PLAYER_SPEED_MOD = 5;
pub const SPEED_DAMPING = 0.95;
pub const BREAKING_SPEED_DAMPING = 0.5;
pub const MAX_VECTOR_SIZE = 50;
pub const TILE_SIZE = 30;
pub const PLAYER_ACCEL = raylib.Vector2{
    .x = 0,
    .y = 500,
};

pub const TEXTURES = enum {
    PLACEHOLDER,
    SPRITE,
    TEST,

    pub fn path(self: TEXTURES) [:0]const u8 {
        switch (self) {
            .PLACEHOLDER => return "./assets/placeholder.png",
            .SPRITE => return "./assets/sprite.png",
            else => return TEXTURES.path(TEXTURES.PLACEHOLDER),
        }
    }
};

pub const PLUG_STATE = struct {
    frame_count: usize = 0,
    debug_mode: bool = false,
    braking: bool = false,
    player_position: raylib.Vector2 = .{ .y = 10, .x = 10 },
    player_velocity: raylib.Vector2 = .{ .y = 0, .x = 0 },
    position_history: std.BoundedArray(raylib.Vector2, PLAYER_POSITION_HISTORY_COUNT) = undefined,
    // Assets
    assets: std.AutoArrayHashMap(TEXTURES, raylib.Texture2D),

    pub fn get_texture(self: PLUG_STATE, tex: TEXTURES) raylib.Texture2D {
        return self.assets.get(tex) orelse self.assets.get(TEXTURES.PLACEHOLDER).?;
    }
};
