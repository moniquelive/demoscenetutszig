const std = @import("std");
const rl = @import("raylib");
const Effect = @import("../effect.zig").Effect;
const rnd = std.crypto.random;

pub const Main = struct {
    const Self = @This();

    bm: rl.Image,
    cm: rl.Image,

    light: [64 * 1024]u8 = undefined,

    pub fn init(self: *Self) Effect {
        const LIGHTSIZE = 2.4;

        for (0..256) |j| {
            for (0..256) |i| {
                // get the distance from the centre
                const si: i32 = @intCast(i);
                const sj: i32 = @intCast(j);
                var dist: f32 = @floatFromInt((128 - si) * (128 - si) + (128 - sj) * (128 - sj));
                if (@abs(dist) > 1) dist = @sqrt(dist);

                // then fade if according to the distance, and a random coefficient
                var c: f32 = (LIGHTSIZE * dist) + rnd.float(f32) * 7 - 3;

                // clip it
                if (c < 0) c = 0;
                if (c > 255) c = 255;

                // and store it
                self.light[(j << 8) + i] = 255 - @as(u8, @intFromFloat(@round(c)));
            }
        }

        self.bm = rl.loadImageFromMemory(".png", @embedFile("bump.png")) catch unreachable;
        self.cm = rl.loadImageFromMemory(".png", @embedFile("map.png")) catch unreachable;
        return .{
            .ptr = self,
            .drawFn = draw,
            .widthFn = width,
            .heightFn = height,
        };
    }

    fn bump(light: *const [64 * 1024]u8, bm: *rl.Image, cm: *rl.Image, lx1: i32, ly1: i32, lx2: i32, ly2: i32, zoom: i32) void {
        // we skip the first line since there are no pixels above
        // to calculate the slope with
        var offs: usize = 320;
        // loop for all the other lines
        for (1..200) |j| {
            // likewise, skip first pixel since there are no pixels on the left
            rl.drawPixel(@intCast(offs % 320), @intCast(offs / 320), rl.Color.black);
            offs += 1;
            // vga->page_draw[offs] = 0; offs++;
            for (1..320) |i| {
                // calculate coordinates of the pixel we need in light map
                // given the slope at this point, and the zoom coefficient
                const si: i32 = @intCast(i);
                const sj: i32 = @intCast(j);
                const c1 = bm.getColor(@intCast((offs - 1) % 320), @intCast((offs - 1) / 320));
                const c2 = bm.getColor(@intCast(offs % 320), @intCast(offs / 320));
                const c3 = bm.getColor(@intCast((offs - 320) % 320), @intCast((offs - 320) / 320));
                const c4 = bm.getColor(@intCast(offs % 320), @intCast(offs / 320));
                const px: i32 = (si * zoom >> 8) + c1.r - c2.r;
                const py: i32 = (sj * zoom >> 8) + c3.r - c4.r;
                // add the movement of the first light
                var x: i32 = px + lx1;
                var y: i32 = py + ly1;
                // check if the coordinates are inside the light buffer
                var c: usize = 0;
                if ((y >= 0) and (y < 256) and (x >= 0) and (x < 256)) // if so get the pixel
                    c = light[@intCast((y << 8) + x)];
                // otherwise assume intensity 0
                // now do the same for the second light
                x = px + lx2;
                y = py + ly2;

                // this time we add the light's intensity to the first value
                if ((y >= 0) and (y < 256) and (x >= 0) and (x < 256))
                    c += light[@intCast((y << 8) + x)];
                // make sure it's not too big
                if (c > 255) c = 255;

                // look up the colour multiplied by the light coeficient
                const cmx: i32 = @intCast(offs % 320);
                const cmy: i32 = @intCast(offs / 320);
                const cmc = cm.getColor(cmx, cmy);
                // use c as an intensity knob (0..1)
                const cr = @as(f32, @floatFromInt(c)) / 255.0 * @as(f32, @floatFromInt(cmc.r));
                const cg = @as(f32, @floatFromInt(c)) / 255.0 * @as(f32, @floatFromInt(cmc.g));
                const cb = @as(f32, @floatFromInt(c)) / 255.0 * @as(f32, @floatFromInt(cmc.b));
                const lc = rl.Color.init(@intFromFloat(cr), @intFromFloat(cg), @intFromFloat(cb), 255);
                rl.drawPixel(@intCast(offs % 320), @intCast(offs / 320), lc);
                offs += 1;
            }
        }
    }

    pub fn draw(ptr: *anyopaque) void {
        const self: *Self = @ptrCast(@alignCast(ptr));

        const time = rl.getTime() * 100;
        const x1: i32 = @as(i32, @intFromFloat(128 * std.math.cos(time / 64))) - 20;
        const x2: i32 = @as(i32, @intFromFloat(128 * std.math.sin(-time / 45))) + 20;
        const y1: i32 = @as(i32, @intFromFloat(128 * std.math.cos(-time / 51))) - 20;
        const y2: i32 = @as(i32, @intFromFloat(128 * std.math.sin(time / 71))) + 20;
        const z: i32 = 192 + @as(i32, @intFromFloat(127 * std.math.sin(time / 112)));
        bump(&self.light, &self.bm, &self.cm, x1, y1, x2, y2, z);
    }

    pub fn width(_: *anyopaque) u32 {
        return 320;
    }
    pub fn height(_: *anyopaque) u32 {
        return 200;
    }
};
