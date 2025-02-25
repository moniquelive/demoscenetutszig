/// Plasma Effect
/// Tutorial #3 - Efeitos Demoscene
/// https://www.flipcode.com/archives/The_Art_of_Demomaking-Issue_04_Per_Pixel_Control.shtml
const std = @import("std");
const rl = @import("raylib");
const Effect = @import("../effect.zig").Effect;

const pi_over_128 = std.math.pi / 128.0;

pub const Main = struct {
    const Self = @This();

    bg: *const [64_000:0]u8,
    plasma1: [256_000]u8 = undefined,
    plasma2: [256_000]u8 = undefined,

    inline fn f1(x: f32, y: f32) u7 {
        const hypo = std.math.hypot(200.0 - y, 320.0 - x);
        const sin = std.math.sin(hypo / 16.0);
        return @intFromFloat(64.0 + 63.0 * sin);
    }
    inline fn f2(x: f32, y: f32) u7 {
        const sin = std.math.sin(x / (37.0 + 15.0 * std.math.cos(y / 74.0)));
        const cos = std.math.cos(y / (31.0 + 11.0 * std.math.sin(x / 57.0)));
        return @intFromFloat(64.0 + 63.0 * sin * cos);
    }
    pub fn init(self: *Self) Effect {
        for (0..400) |j| {
            for (0..640) |i| self.plasma1[640 * j + i] = f1(@floatFromInt(i), @floatFromInt(j));
        }
        for (0..400) |j| {
            for (0..640) |i| self.plasma2[640 * j + i] = f2(@floatFromInt(i), @floatFromInt(j));
        }
        self.bg = @embedFile("plasma.raw");
        return .{
            .ptr = self,
            .drawFn = draw,
            .widthFn = width,
            .heightFn = height,
        };
    }
    pub fn draw(ptr: *anyopaque) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        // animation speed
        const time = rl.getTime() * 150;

        // update the palette
        var colors: [256]rl.Color = undefined;
        for (0..colors.len) |i| {
            const fi: f32 = @floatFromInt(i);
            const r: u8 = @intFromFloat(128 + 127 * std.math.cos(fi * pi_over_128 + time / 74.0));
            const g: u8 = @intFromFloat(128 + 127 * std.math.sin(fi * pi_over_128 + time / 63.0));
            const b: u8 = @intFromFloat(128 - 127 * std.math.cos(fi * pi_over_128 + time / 81.0));
            colors[i] = rl.Color.init(r, g, b, 255);
        }

        // do the plasma
        const x1: usize = @intFromFloat(160 + 159 * std.math.cos(time / 97.0));
        const x2: usize = @intFromFloat(160 + 159 * std.math.sin(-time / 114.0));
        const x3: usize = @intFromFloat(160 + 159 * std.math.sin(-time / 137.0));

        const y1: usize = @intFromFloat(100 + 99 * std.math.sin(time / 123.0));
        const y2: usize = @intFromFloat(100 + 99 * std.math.cos(-time / 75.0));
        const y3: usize = @intFromFloat(100 + 99 * std.math.cos(-time / 108.0));

        for (0..200) |j| {
            for (0..320) |i| {
                const src1 = self.plasma1[640 * (j + y1) + i + x1];
                const src2 = self.plasma2[640 * (j + y2) + i + x2];
                const src3 = self.plasma2[640 * (j + y3) + i + x3];
                const c: u8 = self.bg[320 * j + i] +% src1 +% src2 +% src3;
                rl.drawPixel(@intCast(i), @intCast(j), colors[c]);
            }
        }
    }

    pub fn width(_: *anyopaque) u32 {
        return 320;
    }

    pub fn height(_: *anyopaque) u32 {
        return 200;
    }
};
