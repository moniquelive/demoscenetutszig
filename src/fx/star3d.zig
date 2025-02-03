const std = @import("std");
const rl = @import("raylib");
const windowBounds = @import("../main.zig").windowBounds;

const width = 320;
const height = 200;

pub const Main = struct {
    stars: [500]Star,
    width: u32,
    height: u32,

    pub fn init() Main {
        var m = Main{
            .stars = undefined,
            .width = width,
            .height = height,
        };
        for (&m.stars) |*s|
            s.* = Star.init();
        return m;
    }
    pub fn draw(self: *Main) void {
        for (&self.stars) |*s| {
            s.update();
            s.draw();
        }
    }
};

const Star = struct {
    pos: rl.Vector3,

    const rand = std.crypto.random;
    pub fn init() Star {
        const pos = rl.Vector3.init(
            rand.float(f32) * width - width / 2.0,
            rand.float(f32) * height - height / 2.0,
            rand.float(f32) * width + 1,
        );
        return Star{ .pos = pos };
    }

    pub fn update(self: *Star) void {
        self.pos.z -= 1;
        if (self.pos.z < 1) {
            self.pos.x = rand.float(f32) * width - width / 2;
            self.pos.y = rand.float(f32) * height - height / 2;
            self.pos.z = width;
        }
    }
    pub fn draw(self: Star) void {
        const factor = 20;
        const x: i32 = @intFromFloat((self.pos.x * factor) / self.pos.z + (width / 2));
        const y: i32 = @intFromFloat((self.pos.y * factor) / self.pos.z + (height / 2));
        if (!rl.checkCollisionPointRec(rl.Vector2.init(@floatFromInt(x), @floatFromInt(y)), windowBounds)) {
            return;
        }
        const gray: u8 = @intFromFloat(64 * (1 - (self.pos.z / width)));
        rl.drawPixel(x, y, rl.Color.init(255, 255, 255, gray));
    }
};
