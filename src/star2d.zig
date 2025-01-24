const std = @import("std");
const rl = @import("raylib");
const u = @import("utils.zig");
const windowBounds = @import("main.zig").windowBounds;

const width = 320;
const height = 200;

pub const Main = struct {
    stars: [500]Star,
    width: u32,
    height: u32,

    pub fn init(m: *Main) *Main {
        m.width = width;
        m.height = height;
        for (0..m.stars.len) |i|
            m.stars[i] = Star.new();
        return m;
    }

    pub fn draw(self: *Main) void {
        for (0..self.stars.len) |i| {
            self.stars[i].update();
            self.stars[i].draw();
        }
    }
};

const Star = struct {
    x: f32,
    y: f32,
    p: f32,
    xVel: f32,
    minxVel: f32,
    maxxVel: f32,

    const maxPlanes = 50;
    const rand = std.crypto.random;
    pub fn new() Star {
        return Star{
            .x = rand.float(f32) * width + 1,
            .y = rand.float(f32) * height + 1,
            .p = rand.float(f32) * maxPlanes + 1,
            .xVel = 0,
            .minxVel = 0.01,
            .maxxVel = 0.1,
        };
    }
    pub fn update(self: *Star) void {
        const pos = rl.getMousePosition();
        if (rl.checkCollisionPointRec(pos, windowBounds)) {
            self.xVel = u.map(pos.x, 0, width, self.minxVel, self.maxxVel);
        }

        self.x += self.p * self.xVel;
        if (self.x >= width) {
            self.x = 0;
            self.y = rand.float(f32) * height + 1;
        }
    }

    pub fn draw(self: Star) void {
        const gray: u8 = @intFromFloat((256 / maxPlanes) * self.p);
        rl.drawPixel(@intFromFloat(self.x), @intFromFloat(self.y), rl.Color.init(gray, gray, gray, 255));
    }
};
