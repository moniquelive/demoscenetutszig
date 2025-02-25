// Package filters
// Tutorial #5 - Efeitos Demoscene
// https://www.flipcode.com/archives/The_Art_of_Demomaking-Issue_05_Filters.shtml
const std = @import("std");
const rl = @import("raylib");
const Effect = @import("../effect.zig").Effect;

pub const Main = struct {
    const Self = @This();

    bg: rl.Image,
    colors: [256]rl.Color,
    flip: bool,

    fire1: [64_000]u8,
    fire2: [64_000]u8,

    inline fn shade_pal(colors: *[256]rl.Color, s: i32, e: i32, r1: i32, g1: i32, b1: i32, r2: i32, g2: i32, b2: i32) void {
        const d = e - s;
        for (0..(d + 1)) |i| {
            const fi: f32 = @floatFromInt(i);
            const fd: f32 = @floatFromInt(d);
            const k = fi / fd;
            const r: u8 = @intFromFloat(@mulAdd(f32, (r2 - r1), k, r1));
            const g: u8 = @intFromFloat(@mulAdd(f32, (g2 - g1), k, g1));
            const b: u8 = @intFromFloat(@mulAdd(f32, (b2 - b1), k, b1));
            colors[s + i] = rl.Color.init(r, g, b, 255);
        }
    }

    pub fn init(self: *Self) Effect {
        shade_pal(&self.colors, 0, 23, 0, 0, 0, 0, 0, 127);
        shade_pal(&self.colors, 24, 47, 0, 0, 127, 255, 0, 0);
        shade_pal(&self.colors, 48, 63, 255, 0, 0, 255, 255, 0);
        shade_pal(&self.colors, 64, 127, 255, 255, 0, 255, 255, 255);
        shade_pal(&self.colors, 128, 255, 255, 255, 255, 255, 255, 255);

        self.bg = rl.loadImageFromMemory(".png", @embedFile("filter.png")) catch unreachable;
        self.flip = true;
        self.fire1 = [_]u8{0} ** 64_000;
        self.fire2 = [_]u8{0} ** 64_000;
        return .{
            .ptr = self,
            .drawFn = draw,
            .widthFn = width,
            .heightFn = height,
        };
    }

    pub fn draw(ptr: *anyopaque) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        defer self.flip = !self.flip;
        self.heat();
        self.blur_up();

        var offs: usize = 0;
        const src = if (!self.flip) &self.fire1 else &self.fire2;
        for (0..197) |j| {
            for (0..320) |i| {
                const c: u8 = src[offs];
                offs += 1;
                rl.drawPixel(@intCast(i), @intCast(j + 3), self.colors[c]);
            }
        }
    }

    pub fn width(_: *anyopaque) u32 {
        return 320;
    }

    pub fn height(_: *anyopaque) u32 {
        return 200;
    }

    const rand = std.crypto.random;
    fn heat(self: *Self) void {
        var dst = if (self.flip) &self.fire1 else &self.fire2;
        for (26880..52480) |i| {
            const bg = self.bg.getColor(@intCast(@rem(i, 320)), @intCast(@divFloor(i, 320))).r;
            if (bg > dst[i]) dst[i] = rand.int(u8) & bg;
        }
        const lines = 3 * 320;
        const r = rand.intRangeAtMost(usize, 0, 512 - 1);
        for (0..r) |_| dst[(64000 - lines) + rand.intRangeAtMost(usize, 0, lines - 1)] = 255;
    }

    fn blur_up(self: *Self) void {
        const src = if (self.flip) &self.fire1 else &self.fire2;
        const dst = if (self.flip) &self.fire2 else &self.fire1;
        var offs: usize = 0;
        for (0..198) |_| {
            // set first pixel of the line to 0
            dst[offs] = 0;
            offs += 1;
            // calculate the filter for all the other pixels
            for (1..319) |_| {
                // calculate the average
                const aa: usize = src[offs - 1];
                const bb: usize = src[offs + 1];
                const cc: usize = src[offs + 319];
                const dd: usize = src[offs + 320];
                const ee: usize = src[offs + 321];
                const ff: usize = src[offs + 639];
                const gg: usize = src[offs + 640];
                const hh: usize = src[offs + 641];
                var b: u8 = @intCast((aa + bb + cc + dd + ee + ff + gg + hh) >> 3);
                // decrement the sum by one so that the fire looses intensity
                if (b > 0) b -= 1;
                // store the pixel
                dst[offs] = b;
                offs += 1;
            }
            // set last pixel of the line to 0
            dst[offs] = 0;
            offs += 1;
        }
        // clear the last 2 lines
        @memset(dst[offs..], 0);
    }
};
