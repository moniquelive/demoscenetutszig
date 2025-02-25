const std = @import("std");
const rl = @import("raylib");
const Effect = @import("../effect.zig").Effect;
const windowBounds = @import("../main.zig").windowBounds;

pub const Main = struct {
    const Self = @This();

    stars: [500]Star,

    pub fn init(self: *Self) Effect {
        for (0..self.stars.len) |i|
            self.stars[i] = Star.init();
        return .{
            .ptr = self,
            .drawFn = draw,
            .widthFn = width,
            .heightFn = height,
        };
    }

    pub fn draw(ptr: *anyopaque) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        for (&self.stars) |*s| {
            s.update();
            s.draw();
        }
    }

    pub fn width(_: *anyopaque) u32 {
        return 320;
    }

    pub fn height(_: *anyopaque) u32 {
        return 200;
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
            .x = rand.float(f32) * 320 + 1,
            .y = rand.float(f32) * 200 + 1,
            .p = rand.float(f32) * maxPlanes + 1,
        };
    }
    pub fn update(self: *Star) void {
        const pos = rl.getMousePosition();
        if (rl.checkCollisionPointRec(pos, windowBounds)) {
            self.xVel = rl.math.remap(pos.x, 0, windowBounds.width, self.minxVel, self.maxxVel);
        }

        self.x += self.p * self.xVel;
        if (self.x >= 320) {
            self.x = 0;
            self.y = rand.float(f32) * 200 + 1;
        }
    }

    pub fn draw(self: Star) void {
        const gray: u8 = @intFromFloat((256 / maxPlanes) * self.p);
        rl.drawPixel(@intFromFloat(self.x), @intFromFloat(self.y), rl.Color.init(255, 255, 255, gray));
    }
};
