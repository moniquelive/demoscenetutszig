const std = @import("std");
const rl = @import("raylib");
const windowBounds = @import("../main.zig").windowBounds;

const width = 320;
const height = 200;

pub const Main = struct {
    const Self = @This();

    stars: [500]Star,
    width: u32 = width,
    height: u32 = height,

    pub fn init() Self {
        var s = Self{ .stars = undefined };
        for (0..s.stars.len) |i|
            s.stars[i] = Star.init();
        return s;
    }

    pub fn draw(self: *Self) void {
        for (&self.stars) |*s| {
            s.update();
            s.draw();
        }
    }
};

const Star = struct {
    x: f32,
    y: f32,
    p: f32,
    xVel: f32 = 0,
    minxVel: f32 = 0.01,
    maxxVel: f32 = 0.1,

    const maxPlanes = 50;
    const rand = std.crypto.random;
    pub fn init() Star {
        return Star{
            .x = rand.float(f32) * width + 1,
            .y = rand.float(f32) * height + 1,
            .p = rand.float(f32) * maxPlanes + 1,
        };
    }
    pub fn update(self: *Star) void {
        const pos = rl.getMousePosition();
        if (rl.checkCollisionPointRec(pos, windowBounds)) {
            self.xVel = rl.math.remap(pos.x, 0, windowBounds.width, self.minxVel, self.maxxVel);
        }

        self.x += self.p * self.xVel;
        if (self.x >= width) {
            self.x = 0;
            self.y = rand.float(f32) * height + 1;
        }
    }

    pub fn draw(self: Star) void {
        const gray: u8 = @intFromFloat((256 / maxPlanes) * self.p);
        rl.drawPixel(@intFromFloat(self.x), @intFromFloat(self.y), rl.Color.init(255, 255, 255, gray));
    }
};
