const std = @import("std");
const Star2d = @import("star2d.zig").Main;

pub fn new(allocator: std.mem.Allocator, name: []const u8) !Effect {
    inline for (std.meta.fields(Effect)) |field| {
        if (std.mem.eql(u8, field.name, name)) {
            return switch (field.type) {
                *Star2d => Effect{ .star2d = (try allocator.create(Star2d)).init() },
                else => error.NotFound,
            };
        }
    }
    return error.NotFound;
}

pub const Effect = union(enum) {
    star2d: *Star2d,

    pub fn draw(effect: Effect) void {
        return switch (effect) {
            .star2d => |s| s.draw(),
        };
    }

    pub fn width(effect: Effect) u32 {
        return switch (effect) {
            .star2d => |s| s.width,
        };
    }

    pub fn height(effect: Effect) u32 {
        return switch (effect) {
            .star2d => |s| s.height,
        };
    }
};
