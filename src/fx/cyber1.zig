const std = @import("std");
const rl = @import("raylib");
const Effect = @import("../effect.zig").Effect;
const rnd = std.crypto.random;

pub const Main = struct {
    const Self = @This();

    pixels: [320 * 200]Pixel,
    t: f32,

    pub fn init(self: *Self) Effect {
        const bgImg = rl.loadImageFromMemory(".png", @embedFile("cyber1.png")) catch unreachable;
        defer bgImg.unload();

        for (0..200) |j| {
            for (0..320) |i| {
                const color = bgImg.getColor(@intCast(i), @intCast(j));
                self.pixels[320 * j + i] = Pixel.init(i, j, &color);
            }
        }
        self.t = 0;
        return .{
            .ptr = self,
            .drawFn = draw,
            .widthFn = width,
            .heightFn = height,
        };
    }
    fn update(self: *Self) void {
        self.t = @min(1, self.t + 0.005);
        for (&self.pixels) |*pixel| {
            pixel.update(self.t);
        }
    }
    pub fn draw(ptr: *anyopaque) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        if (self.t < 1) self.update();
        for (&self.pixels) |*pixel| {
            pixel.draw();
        }
    }

    pub fn width(_: *anyopaque) u32 {
        return 320;
    }

    pub fn height(_: *anyopaque) u32 {
        return 200;
    }
};

const Pixel = struct {
    const Self = @This();

    xDest: i32,
    yDest: i32,
    xOrig: i32,
    yOrig: i32,
    xCurr: i32 = undefined,
    yCurr: i32 = undefined,
    color: rl.Color,

    pub fn init(i: usize, j: usize, color: *const rl.Color) Self {
        return Self{
            .xDest = @intCast(i),
            .yDest = @intCast(j),
            .xOrig = rnd.intRangeAtMost(i32, 0, 320),
            .yOrig = rnd.intRangeAtMost(i32, 0, 200),
            .color = color.*,
        };
    }

    pub fn update(self: *Self, t: f32) void {
        self.xCurr = @intFromFloat(rl.math.lerp(@floatFromInt(self.xOrig), @floatFromInt(self.xDest), t));
        self.yCurr = @intFromFloat(rl.math.lerp(@floatFromInt(self.yOrig), @floatFromInt(self.yDest), t));
    }

    pub fn draw(self: *Self) void {
        rl.drawPixel(self.xCurr, self.yCurr, self.color);
    }
};
