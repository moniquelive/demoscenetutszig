const std = @import("std");
const rl = @import("raylib");
const u = @import("utils.zig");
const windowBounds = @import("main.zig").windowBounds;

stars: [500]Star,
width: u32,
height: u32,

const Self = @This();

pub fn init(self: *Self) *Self {
    self.width = 320;
    self.height = 200;
    for (0..self.stars.len) |i|
        self.stars[i] = Star.new(self.width, self.height);
    return self;
}

pub fn draw(self: *Self) void {
    for (0..self.stars.len) |i| {
        self.stars[i].update();
        self.stars[i].draw();
    }
}

const Star = struct {
    canvasWidth: u32,
    canvasHeight: u32,
    x: u32,
    y: u32,
    p: u8,
    xVel: f32,
    minxVel: f32,
    maxxVel: f32,

    const maxPlanes = 50;
    const rand = std.crypto.random;
    pub fn new(width: u32, height: u32) Star {
        return Star{
            .canvasWidth = width,
            .canvasHeight = height,
            .x = rand.uintLessThan(u32, width),
            .y = rand.uintLessThan(u32, height),
            .p = rand.uintLessThan(u8, maxPlanes),
            .xVel = 0,
            .minxVel = 0.01,
            .maxxVel = 0.1,
        };
    }
    pub fn update(self: *Star) void {
        const pos = rl.getMousePosition();
        if (rl.checkCollisionPointRec(pos, windowBounds)) {
            self.xVel = u.map(pos.x, 0, @floatFromInt(self.canvasWidth), self.minxVel, self.maxxVel);
        }

        self.x += @intFromFloat(@as(f32, @floatFromInt(1 + self.p)) * self.xVel);
        if (self.x >= self.canvasWidth) {
            self.x = 0;
            self.y = rand.uintLessThan(u32, self.canvasHeight);
        }
    }

    pub fn draw(self: Star) void {
        const gray = ((256 / maxPlanes) * self.p);
        rl.drawPixel(@intCast(self.x), @intCast(self.y), rl.Color.init(gray, gray, gray, 255));
    }
};
