const std = @import("std");
const Star2d = @import("fx/star2d.zig").Main;
const Star3d = @import("fx/star3d.zig").Main;
const Crossfade = @import("fx/crossfade.zig").Main;
const Plasma = @import("fx/plasma.zig").Main;
const Filters = @import("fx/filters.zig").Main;
const Cyber1 = @import("fx/cyber1.zig").Main;

const Effects = union(enum) {
    star2d: Star2d,
    star3d: Star3d,
    crossfade: Crossfade,
    plasma: Plasma,
    filters: Filters,
    cyber1: Cyber1,
};

pub const Effect = struct {
    const Self = @This();

    ptr: *anyopaque,
    drawFn: *const fn (ptr: *anyopaque) void,
    widthFn: *const fn (ptr: *anyopaque) u32,
    heightFn: *const fn (ptr: *anyopaque) u32,

    pub fn new(alloc: std.mem.Allocator, name: []const u8) !Self {
        inline for (std.meta.fields(Effects)) |field| {
            if (std.mem.eql(u8, field.name, name)) {
                var fx = try alloc.create(field.type);
                return fx.init();
            }
        }
        return error.NotFound;
    }

    pub fn free(self: *Self, alloc: std.mem.Allocator, name: []const u8) void {
        inline for (std.meta.fields(Effects)) |field| {
            if (std.mem.eql(u8, field.name, name)) {
                const ptr: *field.type = @ptrCast(@alignCast(self.ptr));
                alloc.destroy(ptr);
                return;
            }
        }
    }

    pub fn draw(self: *Self) void {
        return self.drawFn(self.ptr);
    }

    pub fn width(self: Self) u32 {
        return self.widthFn(self.ptr);
    }

    pub fn height(self: Self) u32 {
        return self.heightFn(self.ptr);
    }
};
