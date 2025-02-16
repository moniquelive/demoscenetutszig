const std = @import("std");
const rl = @import("raylib");

pub const Main = struct {
    const Self = @This();

    const Pixel = struct {
        xDest: i32,
        yDest: i32,
        xOrig: i32,
        yOrig: i32,
        xCurr: i32 = 0,
        yCurr: i32 = 0,
        color: rl.Color,
    };

    width: u32 = 320,
    height: u32 = 200,

    pixels: [320 * 200]Pixel,
    t: f32 = 0,

    const rnd = std.crypto.random;
    pub fn init() Self {
        const bgBytes = @embedFile("cyber1.png");
        const bgImg = rl.loadImageFromMemory(".png", bgBytes) catch unreachable;
        defer bgImg.unload();

        // var bgColor: [320 * 200]rl.Color = undefined;
        // @memcpy(&bgColor, @as(*[64000]rl.Color, @ptrCast(bgImg.data)));

        var pixels: [320 * 200]Pixel = undefined;
        var offs: usize = 0;
        for (0..200) |j| {
            for (0..320) |i| {
                const color = bgImg.getColor(@intCast(i), @intCast(j));
                pixels[offs] = Pixel{
                    .xDest = @intCast(i),
                    .yDest = @intCast(j),
                    .xOrig = rnd.intRangeAtMost(i32, 0, 320),
                    .yOrig = rnd.intRangeAtMost(i32, 0, 200),
                    .color = color,
                };
                offs += 1;
            }
        }
        return Self{ .pixels = pixels };
    }
    fn update(self: *Self) void {
        self.t = @min(1, self.t + 0.005);
        for (&self.pixels) |*pixel| {
            pixel.xCurr = @intFromFloat(rl.math.lerp(@floatFromInt(pixel.xOrig), @floatFromInt(pixel.xDest), self.t));
            pixel.yCurr = @intFromFloat(rl.math.lerp(@floatFromInt(pixel.yOrig), @floatFromInt(pixel.yDest), self.t));
        }
    }
    pub fn draw(self: *Self) void {
        if (self.t < 1) self.update();

        for (0..200) |j| {
            for (0..320) |i| {
                const curr = self.pixels[j * 320 + i];
                const c = curr.color;
                rl.drawPixel(curr.xCurr, curr.yCurr, c);
            }
        }
    }
};
