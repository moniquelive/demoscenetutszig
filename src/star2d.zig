const std = @import("std");
const rl = @import("raylib");
const u = @import("utils.zig");
const m = @import("main.zig");

stars: [500]Star = undefined,
width: u32 = 320,
height: u32 = 200,

const Self = @This();

pub fn new() Self {
    var me = Self{};
    for (0..me.stars.len) |i|
        me.stars[i] = Star.new(me.width, me.height);
    return me;
}

const Effect = @import("effect.zig");
pub fn interface(self: *Self) Effect {
    return .{
        .impl = @ptrCast(self),
        .drawFn = draw,
        .widthFn = width,
        .heightFn = height,
    };
}

pub fn width(self_opaque: *anyopaque) u32 {
    const self: *Self = @ptrCast(@alignCast(self_opaque));
    return self.width;
}

pub fn height(self_opaque: *anyopaque) u32 {
    const self: *Self = @ptrCast(@alignCast(self_opaque));
    return self.height;
}

pub fn draw(self_opaque: *anyopaque) void {
    var self: *Self = @ptrCast(@alignCast(self_opaque));
    for (0..self.stars.len) |i| {
        self.stars[i].update();
        self.stars[i].draw();
    }
}

const Star = struct {
    screenWidth: u32,
    screenHeight: u32,
    x: u32,
    y: u32,
    p: u8,
    xVel: f32,

    const maxPlanes = 50;
    const rand = std.crypto.random;
    pub fn new(w: u32, h: u32) Star {
        return Star{
            .screenWidth = w,
            .screenHeight = h,
            .x = rand.uintLessThan(u32, w),
            .y = rand.uintLessThan(u32, h),
            .p = rand.uintLessThan(u8, maxPlanes),
            .xVel = 0,
        };
    }
    pub fn update(self: *Star) void {
        const pos = rl.getMousePosition();
        if (rl.checkCollisionPointRec(pos, m.windowBounds)) {
            self.xVel = u.map(pos.x, 0, @floatFromInt(self.screenWidth), 0.01, 0.1);
        }

        self.x += @intFromFloat(@as(f32, @floatFromInt(1 + self.p)) * self.xVel);
        if (self.x >= self.screenWidth) {
            self.x = 0;
            self.y = rand.uintLessThan(u32, self.screenHeight);
        }
    }

    pub fn draw(self: Star) void {
        const gray = ((256 / maxPlanes) * self.p);
        rl.drawPixel(@intCast(self.x), @intCast(self.y), rl.Color.init(gray, gray, gray, 255));
    }
};
