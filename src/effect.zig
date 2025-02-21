const std = @import("std");
const Star2d = @import("fx/star2d.zig").Main;
const Star3d = @import("fx/star3d.zig").Main;
const Crossfade = @import("fx/crossfade.zig").Main;
const Plasma = @import("fx/plasma.zig").Main;
const Filters = @import("fx/filters.zig").Main;
const Cyber1 = @import("fx/cyber1.zig").Main;

pub const Effect = union(enum) {
    star2d: Star2d,
    star3d: Star3d,
    crossfade: Crossfade,
    plasma: Plasma,
    filters: Filters,
    cyber1: Cyber1,

    pub fn new(name: []const u8) !Effect {
        inline for (std.meta.fields(Effect)) |field| {
            if (std.mem.eql(u8, field.name, name)) {
                return switch (field.type) {
                    // Star2d => Effect{ .star2d = field.type.init() },
                    // Star3d => Effect{ .star3d = field.type.init() },
                    // Crossfade => Effect{ .crossfade = field.type.init() },
                    // Plasma => Effect{ .plasma = field.type.init() },
                    // Filters => Effect{ .filters = field.type.init() },
                    Cyber1 => Effect{ .cyber1 = field.type.init() },
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
