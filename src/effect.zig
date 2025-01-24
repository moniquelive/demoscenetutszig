const std = @import("std");
const Star2d = @import("star2d.zig");

pub const Types = enum {
    star2d,
};

pub fn newEffect(allocator: std.mem.Allocator, typ: Types) !Effect {
    return switch (typ) {
        .star2d => Effect{ .star2d = (try allocator.create(Star2d)).init() },
    };
}

pub const Effect = union(Types) {
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
