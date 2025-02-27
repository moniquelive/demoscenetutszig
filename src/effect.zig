const std = @import("std");

const Effects = union(enum) {
    star2d: @import("fx/star2d.zig").Main,
    star3d: @import("fx/star3d.zig").Main,
    crossfade: @import("fx/crossfade.zig").Main,
    plasma: @import("fx/plasma.zig").Main,
    filters: @import("fx/filters.zig").Main,
    cyber1: @import("fx/cyber1.zig").Main,
    bifilter: @import("fx/bifilter.zig").Main,
};

pub const Effect = struct {
    const Self = @This();

    ptr: *anyopaque,
    drawFn: *const fn (ptr: *anyopaque) void,
    widthFn: *const fn (ptr: *anyopaque) u32,
    heightFn: *const fn (ptr: *anyopaque) u32,

    pub fn create(alloc: std.mem.Allocator, name: []const u8) !Self {
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
