const std = @import("std");
const rl = @import("raylib");
const Effect = @import("../effect.zig").Effect;

pub const Main = struct {
    const Self = @This();

    img: rl.Image,
    dispX: [256_000]i8 = undefined,
    dispY: [256_000]i8 = undefined,

    pub fn init(self: *Self) Effect {
        var dst: usize = 0;
        for (0..400) |j| {
            for (0..640) |i| {
                const x: f32 = @floatFromInt(i);
                const y: f32 = @floatFromInt(j);
                // notice the values contained in the buffers are signed
                // i.e. can be both positive and negative
                self.dispX[dst] = @intFromFloat((8 * (2 * (std.math.sin(x / 20) + std.math.sin(x * y / 2000) + std.math.sin((x + y) / 100) + std.math.sin((y - x) / 70) + std.math.sin((x + 4 * y) / 70) + 2 * std.math.sin(std.math.hypot(256 - x, (150 - y / 8)) / 40)))));

                // also notice we multiply by 8 to get 5.3 fixed point distortion
                // coefficients for our bilinear filtering
                self.dispY[dst] = @intFromFloat((8 * ((std.math.cos(x / 31) + std.math.cos(x * y / 1783) + 2 * std.math.cos((x + y) / 137) + std.math.cos((y - x) / 55) + 2 * std.math.cos((x + 8 * y) / 57) + std.math.cos(std.math.hypot(384 - x, (274 - y / 9)) / 51)))));
                dst += 1;
            }
        }

        self.img = rl.loadImageFromMemory(".png", @embedFile("bifilter.png")) catch unreachable;
        return .{
            .ptr = self,
            .drawFn = draw,
            .widthFn = width,
            .heightFn = height,
        };
    }

    fn distort(self: *Self, x1: usize, y1: usize, x2: usize, y2: usize) void {
        var src1: usize = y1 * 640 + x1;
        var src2: usize = y2 * 640 + x2;
        for (0..200) |j| {
            for (0..320) |i| {
                // get distorted coordinates, use the integer part of the distortion
                // buffers and truncate to closest texel
                const dY: i32 = @as(i32, @intCast(j)) + @as(i32, @intCast(self.dispY[src1] >> 3));
                const dX: i32 = @as(i32, @intCast(i)) + @as(i32, @intCast(self.dispX[src2] >> 3));
                // check the texel is valid
                if ((dY >= 0) and (dY < 199) and (dX >= 0) and (dX < 319)) {
                    rl.drawPixel(@intCast(i), @intCast(j), self.img.getColor(dX, dY));
                } else {
                    rl.drawPixel(@intCast(i), @intCast(j), rl.Color.black);
                }
                // next pixel
                src1 += 1;
                src2 += 1;
            }
            // next line
            src1 += 320;
            src2 += 320;
        }
    }

    fn distortBili(self: *Self, x1: usize, y1: usize, x2: usize, y2: usize) void {
        var src1: usize = y1 * 640 + x1;
        var src2: usize = y2 * 640 + x2;
        for (0..200) |j| {
            for (0..320) |i| {
                // get distorted coordinates, by using the truncated integer part
                // of the distortion coefficients
                const dY: i32 = @as(i32, @intCast(j)) + @as(i32, @intCast(self.dispY[src1] >> 3));
                const dX: i32 = @as(i32, @intCast(i)) + @as(i32, @intCast(self.dispX[src2] >> 3));
                // get the linear interpolation coefficiants by using the fractionnal
                // part of the distortion coefficients
                const cY: i32 = self.dispY[src1] & 0x7;
                const cX: i32 = self.dispX[src2] & 0x7;
                // check if the texel is valid
                if ((dY >= 0) and (dY < 199) and (dX >= 0) and (dX < 319)) {
                    // load the 4 surrounding texels and multiply them by the
                    // right bilinear coefficients, then get rid of the fractionnal
                    // part by shifting right by 6
                    const a: i32 = self.img.getColor(dX, dY).r;
                    const b: i32 = self.img.getColor(dX + 1, dY).r;
                    const c: i32 = self.img.getColor(dX, dY + 1).r;
                    const d: i32 = self.img.getColor(dX + 1, dY + 1).r;
                    const cc = (a * (8 - cX) * (8 - cY) +
                        b * cX * (8 - cY) +
                        c * (8 - cX) * cY +
                        d * cX * cY) >> 6;
                    const clr = rl.Color.init(@intCast(cc), @intCast(cc), @intCast(cc), 255);
                    rl.drawPixel(@intCast(i), @intCast(j), clr);
                } else {
                    rl.drawPixel(@intCast(i), @intCast(j), rl.Color.black);
                }
                src1 += 1;
                src2 += 1;
            }
            // next line
            src1 += 320;
            src2 += 320;
        }
    }

    pub fn draw(ptr: *anyopaque) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        const time = rl.getTime() * 100;
        const x1: usize = @intFromFloat(160 + (159 * std.math.cos(time / 205)));
        const x2: usize = @intFromFloat(160 + (159 * std.math.sin(-time / 197)));
        const y1: usize = @intFromFloat(100 + (99 * std.math.sin(time / 231)));
        const y2: usize = @intFromFloat(100 + (99 * std.math.cos(-time / 224)));

        const iTime: u64 = @intFromFloat(time);
        if ((iTime & 511) < 256) {
            self.distort(x1, y1, x2, y2);
        } else {
            self.distortBili(x1, y1, x2, y2);
        }
    }

    pub fn width(_: *anyopaque) u32 {
        return 320;
    }
    pub fn height(_: *anyopaque) u32 {
        return 200;
    }
};
