const std = @import("std");
const raylib = @import("raylib.zig");
const common = @import("common.zig");
const d = @import("debug.zig");

const PLUG_STATE = common.PLUG_STATE;
const TEXTURES = common.TEXTURES;
const PLAYER_SIZE = common.PLAYER_SIZE;
const TILE_SIZE = common.TILE_SIZE;
const PLAYER_SPEED_MOD = common.PLAYER_SPEED_MOD;
const PLAYER_ACCEL = common.PLAYER_ACCEL;
const SPEED_DAMPING = common.SPEED_DAMPING;
const BREAKING_SPEED_DAMPING = common.BREAKING_SPEED_DAMPING;

pub fn update(p: *PLUG_STATE) void {
    p.frame_count += 1;
    const dt = raylib.GetFrameTime();
    if (raylib.IsKeyDown(raylib.KEY_SPACE)) {
        p.braking = true;
    }
    if (raylib.IsKeyUp(raylib.KEY_SPACE)) {
        p.braking = false;
    }
    if (raylib.IsKeyDown(raylib.KEY_A)) {
        p.player_velocity = raylib.Vector2Add(p.player_velocity, .{ .x = -PLAYER_SPEED_MOD, .y = 0 });
    }
    if (raylib.IsKeyDown(raylib.KEY_D)) {
        p.player_velocity = raylib.Vector2Add(p.player_velocity, .{ .x = PLAYER_SPEED_MOD, .y = 0 });
    }
    if (raylib.IsKeyDown(raylib.KEY_W)) {
        p.player_velocity = raylib.Vector2Add(p.player_velocity, .{ .x = 0, .y = -PLAYER_SPEED_MOD });
    }
    if (raylib.IsKeyDown(raylib.KEY_S)) {
        p.player_velocity = raylib.Vector2Add(p.player_velocity, .{ .x = 0, .y = PLAYER_SPEED_MOD });
    }
    p.player_velocity = raylib.Vector2Add(p.player_velocity, raylib.Vector2Scale(PLAYER_ACCEL, dt));
    var new_pos = raylib.Vector2Add(
        p.player_position,
        raylib.Vector2Scale(p.player_velocity, dt),
    );
    var damping: f32 = @floatCast(SPEED_DAMPING);
    if (p.braking) {
        damping = @floatCast(BREAKING_SPEED_DAMPING);
    }
    if ((PLAYER_SIZE >= new_pos.x) or (new_pos.x >= @as(f32, @floatFromInt(raylib.GetScreenWidth() - PLAYER_SIZE)))) {
        new_pos.x = raylib.Clamp(new_pos.x, PLAYER_SIZE, @floatFromInt(raylib.GetScreenWidth() - PLAYER_SIZE));
        p.player_velocity.x = -p.player_velocity.x * damping;
    }
    if ((PLAYER_SIZE >= new_pos.y) or (new_pos.y >= @as(f32, @floatFromInt(raylib.GetScreenHeight() - PLAYER_SIZE)))) {
        new_pos.y = raylib.Clamp(new_pos.y, PLAYER_SIZE, @floatFromInt(raylib.GetScreenHeight() - PLAYER_SIZE));
        p.player_velocity.y = -p.player_velocity.y * damping;
    }
    p.player_position = new_pos;
}
pub fn render(p: *PLUG_STATE) void {
    raylib.ClearBackground(raylib.GetColor(0x181818ff));
    for (p.position_history.buffer) |pos| {
        raylib.DrawCircleV(pos, @floatFromInt(PLAYER_SIZE), raylib.GetColor(0x00ff0022));
    }
    raylib.DrawTextureEx(p.get_texture(TEXTURES.SPRITE), .{ .x = p.player_position.x, .y = p.player_position.y }, 0, 0.2, raylib.WHITE);
    // raylib.DrawCircleV(p.player_position, @floatFromInt(PLAYER_SIZE), raylib.GREEN);
    //    raylib.DrawTexturePro(
    //        p.get_texture(TEXTURES.SPRITE),
    //        .{ .x = 10.62 * TILE_SIZE, .y = 10 * TILE_SIZE, .width = TILE_SIZE, .height = TILE_SIZE },
    //        .{ .x = p.player_position.x, .y = p.player_position.y, .width = PLAYER_SIZE * 2, .height = PLAYER_SIZE * 2 },
    //        .{ .y = PLAYER_SIZE, .x = PLAYER_SIZE },
    //        std.math.atan2(p.player_velocity.y, p.player_velocity.x) * 180 / std.math.pi + 90,
    //        raylib.WHITE,
    //    );
}

var player_speed: f32 = 0;
var player_dir: f32 = 0;

pub fn debug(p: *PLUG_STATE, allocator: std.mem.Allocator) void {
    raylib.DrawFPS(20, 20);
    raylib.DrawLineV(p.player_position, raylib.Vector2Add(p.player_position, raylib.Vector2Multiply(p.player_velocity, .{ .x = 1, .y = 0 })), raylib.RED);
    raylib.DrawLineV(p.player_position, raylib.Vector2Add(p.player_position, raylib.Vector2Multiply(p.player_velocity, .{ .x = 0, .y = 1 })), raylib.GREEN);
    raylib.DrawLineV(p.player_position, raylib.Vector2Add(p.player_position, p.player_velocity), raylib.BLUE);

    if (std.math.mod(usize, p.frame_count, 30) catch {
        return;
    } == 0) {
        player_speed = raylib.Vector2Length(p.player_velocity);
        player_dir = std.math.mod(f32, std.math.atan2(p.player_velocity.y, p.player_velocity.x) / std.math.pi * 180, 360) catch 0;
    }
    d.debug(allocator, "Player:", .{}) catch {
        return;
    };
    d.debug(allocator, "\tSpeed: {d:.2}", .{player_speed}) catch {
        return;
    };
    d.debug(allocator, "\tDirection: {!d:.2}", .{player_dir}) catch {
        return;
    };
    d.reset();
}
