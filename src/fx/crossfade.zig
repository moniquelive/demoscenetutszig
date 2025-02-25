/// Tutorial #2 - Efeitos Demoscene
/// https://www.flipcode.com/archives/The_Art_of_Demomaking-Issue_03_Timer_Related_Issues.shtml
///
/// Outras interpolações: https://easings.net/
const std = @import("std");
const rl = @import("raylib");
const Effect = @import("../effect.zig").Effect;
const windowBounds = @import("../main.zig").windowBounds;

pub const Main = struct {
    const Self = @This();

    step: f32,
    k: f32,

    at: rl.Texture2D,
    ww: rl.Texture2D,

    src: rl.Rectangle,
    dst: rl.Rectangle,
    zero: rl.Vector2,

    pub fn init(self: *Self) Effect {
        const img_at = rl.loadImageFromMemory(".png", @embedFile("at.png")) catch unreachable;
        defer img_at.unload();

        const img_ww = rl.loadImageFromMemory(".png", @embedFile("ww.png")) catch unreachable;
        defer img_ww.unload();

        const atw: f32 = @floatFromInt(img_at.width);
        const ath: f32 = @floatFromInt(img_at.height);
        const ratio = ath / atw;
        const x = 800.0 / 2 - (600.0 / ratio) / 2;
        const y = 0;
        const w = 600.0 / ratio;
        const h = 600.0;

        self.at = img_at.toTexture() catch unreachable;
        self.ww = img_ww.toTexture() catch unreachable;
        self.src = rl.Rectangle{ .x = 0, .y = 0, .width = atw, .height = ath };
        self.dst = rl.Rectangle{ .x = x, .y = y, .width = w, .height = h };
        self.zero = rl.Vector2.zero();
        self.step = 0.015;
        self.k = 0.0;
        return .{
            .ptr = self,
            .drawFn = draw,
            .widthFn = width,
            .heightFn = height,
        };
    }

    pub fn draw(ptr: *anyopaque) void {
        const self: *Self = @ptrCast(@alignCast(ptr));
        if (self.k < 0.0 or self.k > 1.0) {
            self.step *= -1;
        }
        const ffps: f32 = @floatFromInt(rl.getFPS());
        self.k += self.step * ffps / 100.0;
        const alpha = easeInOutBack(self.k);

        rl.drawTexturePro(self.at, self.src, self.dst, self.zero, 0, rl.Color.alpha(rl.Color.white, alpha));
        rl.drawTexturePro(self.ww, self.src, self.dst, self.zero, 0, rl.Color.alpha(rl.Color.white, (1 - alpha)));
    }

    pub fn width(_: *anyopaque) u32 {
        return 800;
    }

    pub fn height(_: *anyopaque) u32 {
        return 600;
    }

    inline fn easeInOutBack(t: f32) f32 {
        const c1 = 1.70158;
        const c2 = c1 * 1.525;
        if (t < 0.5) {
            return ((2 * t * 2 * t) * ((c2 + 1) * 2 * t - c2)) / 2;
        }
        return (((2 * t - 2) * (2 * t - 2)) * ((c2 + 1) * (t * 2 - 2) + c2) + 2) / 2;
    }
};
