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
    pos: rl.Vector3,

    const rand = std.crypto.random;
    pub fn init() Star {
        return Star{ .pos = rl.Vector3.init(
            rand.float(f32) * 320 - 320 / 2.0,
            rand.float(f32) * 200 - 200 / 2.0,
            rand.float(f32) * 320 + 1,
        ) };
    }

    pub fn update(self: *Star) void {
        self.pos.z -= 1;
        if (self.pos.z < 1) {
            self.pos.x = rand.float(f32) * 320 - 320 / 2;
            self.pos.y = rand.float(f32) * 200 - 200 / 2;
            self.pos.z = 320;
        }
    }
    pub fn draw(self: Star) void {
        const factor = 20;
        const x: i32 = @intFromFloat((self.pos.x * factor) / self.pos.z + (320 / 2));
        const y: i32 = @intFromFloat((self.pos.y * factor) / self.pos.z + (200 / 2));
        if (!rl.checkCollisionPointRec(rl.Vector2.init(@floatFromInt(x), @floatFromInt(y)), windowBounds)) {
            return;
        }
        const gray: u8 = @intFromFloat(64 * (1 - (self.pos.z / 320)));
        rl.drawPixel(x, y, rl.Color.init(255, 255, 255, gray));
    }
};
