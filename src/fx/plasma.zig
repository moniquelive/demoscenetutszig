/// Plasma Effect
/// Tutorial #3 - Efeitos Demoscene
/// https://www.flipcode.com/archives/The_Art_of_Demomaking-Issue_04_Per_Pixel_Control.shtml
const std = @import("std");
const rl = @import("raylib");
const windowBounds = @import("../main.zig").windowBounds;

const bgBytes = @embedFile("plasma.raw");

pub const Main = struct {
    const Self = @This();

    width: u32 = 320,
    height: u32 = 200,

    bg: *const [64_000:0]u8,
    plasma1: [256_000]u8,
    plasma2: [256_000]u8,

    inline fn f1(i: f32, j: f32) u8 {
        return @intFromFloat(64.0 + 63.0 * std.math.sin(std.math.hypot(200 - j, 320 - i) / 16.0));
    }
    inline fn f2(i: f32, j: f32) u8 {
        return @intFromFloat(64.0 + 63.0 * std.math.sin(i / (37.0 + 15.0 * std.math.cos(j / 74.0))) * std.math.cos(j / (31.0 + 11.0 * std.math.sin(i / 57.0))));
    }
    pub fn init() Self {
        var plasma1: [256000]u8 = undefined;
        for (0..400) |j| {
            for (0..640) |i| plasma1[640 * j + i] = f1(@floatFromInt(i), @floatFromInt(j));
        }

        var plasma2: [256000]u8 = undefined;
        for (0..400) |j| {
            for (0..640) |i| plasma2[640 * j + i] = f2(@floatFromInt(i), @floatFromInt(j));
        }

        return Self{
            .bg = bgBytes,
            .plasma1 = plasma1,
            .plasma2 = plasma2,
        };
    }
    pub fn draw(self: *Self) void {
        const time = rl.getTime() * 100;

        // update the palette
        var colors: [256]rl.Color = undefined;
        for (0..colors.len) |i| {
            const fi: f32 = @floatFromInt(i);
            const pi_over_128 = std.math.pi / 128.0;
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
                const src1 = self.plasma1[640 * @as(usize, @intCast(j + y1)) + @as(usize, @intCast(i + x1))];
                const src2 = self.plasma2[640 * @as(usize, @intCast(j + y2)) + @as(usize, @intCast(i + x2))];
                const src3 = self.plasma2[640 * @as(usize, @intCast(j + y3)) + @as(usize, @intCast(i + x3))];
                const c: u8 = self.bg[320 * j + i] +% src1 +% src2 +% src3;
                rl.drawPixel(@intCast(i), @intCast(j), colors[c]);
            }
        }
    }
};
