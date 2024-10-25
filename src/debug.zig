const std = @import("std");
const raylib = @import("raylib.zig");
// var debug_stack: ?std.ArrayList([*c]const u8) = null;
//
// pub fn debugInit(allocator: std.mem.Allocator) !void {
//     debug_stack = std.ArrayList([*c]const u8).init(allocator);
// }
const FONT_SIZE = 16;
const SPACING = 2;
const BASE_OFFSET = raylib.Vector2{
    .x = 20,
    .y = 50,
};
const PADDING = 5;
var current_y_offset: f32 = 0;

fn sprintf(allocator: std.mem.Allocator, comptime fmt: []const u8, args: anytype) ![*c]const u8 {
    const formatted = try std.fmt.allocPrint(allocator, fmt, args);
    // Allocate memory for the null-terminated string (length + 1 for '\0')
    const null_terminated = try allocator.alloc(u8, formatted.len + 1);
    // Copy the formatted string into the null-terminated buffer
    std.mem.copyBackwards(u8, null_terminated, formatted);

    // Append the null terminator
    null_terminated[formatted.len] = 0; // '\0'

    // Now `null_terminated` is of type [*c] const u8
    return @ptrCast(null_terminated);
}

pub fn format(allocator: std.mem.Allocator, comptime fmt: []const u8, args: anytype) [*c]const u8 {
    return sprintf(allocator, fmt, args) catch "";
}
pub fn debug(allocator: std.mem.Allocator, comptime fmt: []const u8, args: anytype) !void {
    // debug_stack.?.append(c_string);
    const c_string = try sprintf(allocator, fmt, args);
    const size = raylib.MeasureTextEx(raylib.GetFontDefault(), c_string, FONT_SIZE, SPACING);
    raylib.DrawTextEx(raylib.GetFontDefault(), c_string, .{ .x = BASE_OFFSET.x, .y = BASE_OFFSET.y + current_y_offset }, FONT_SIZE, SPACING, raylib.WHITE);
    current_y_offset += size.y + PADDING;
}

pub fn reset() void {
    current_y_offset = 0;
}
