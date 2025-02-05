const std = @import("std");
const Star2d = @import("fx/star2d.zig").Main;
const Star3d = @import("fx/star3d.zig").Main;
const Crossfade = @import("fx/crossfade.zig").Main;
const Plasma = @import("fx/plasma.zig").Main;

pub const Effect = union(enum) {
    star2d: Star2d,
    star3d: Star3d,
    crossfade: Crossfade,
    plasma: Plasma,

    pub fn new(name: []const u8) !Effect {
        inline for (std.meta.fields(Effect)) |field| {
            if (std.mem.eql(u8, field.name, name)) {
                return switch (field.type) {
                    Star2d => Effect{ .star2d = Star2d.init() },
                    Star3d => Effect{ .star3d = Star3d.init() },
                    Crossfade => Effect{ .crossfade = Crossfade.init() },
                    Plasma => Effect{ .plasma = Plasma.init() },
                    else => error.NotFound,
                };
            }
        }
        return error.NotFound;
    }

    pub fn draw(effect: *Effect) void {
        switch (effect.*) {
            inline else => |*f| f.draw(),
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
