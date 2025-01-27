const std = @import("std");
const Star2d = @import("star2d.zig").Main;

pub const Effect = union(enum) {
    star2d: Star2d,

    pub fn new(name: []const u8) !Effect {
        inline for (std.meta.fields(Effect)) |field| {
            if (std.mem.eql(u8, field.name, name)) {
                return switch (field.type) {
                    Star2d => Effect{ .star2d = Star2d.init() },
                    else => error.NotFound,
                };
            }
        }
        return error.NotFound;
    }

    pub fn draw(effect: *Effect) void {
        switch (effect.*) {
            inline else => |*f| {
                f.draw();
            },
        }
    }

    pub fn width(effect: Effect) u32 {
        return switch (effect) {
            inline else => |f| return f.width,
        };
    }

    pub fn height(effect: Effect) u32 {
        return switch (effect) {
            inline else => |f| return f.height,
        };
    }
};
