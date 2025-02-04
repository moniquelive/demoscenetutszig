/// Tutorial #2 - Efeitos Demoscene
/// https://www.flipcode.com/archives/The_Art_of_Demomaking-Issue_03_Timer_Related_Issues.shtml
///
/// Outras interpolações: https://easings.net/
const std = @import("std");
const rl = @import("raylib");
const windowBounds = @import("../main.zig").windowBounds;

const wwBytes = @embedFile("ww.png");
const atBytes = @embedFile("at.png");

pub const Main = struct {
    const Self = @This();

    width: u32 = 800,
    height: u32 = 600,

    step: f32 = 0.015,
    k: f32 = 0.0,

    at: rl.Texture2D,
    ww: rl.Texture2D,

    src: rl.Rectangle,
    dst: rl.Rectangle,
    zero: rl.Vector2,

    pub fn init() Self {
        const img_at = rl.loadImageFromMemory(".png", atBytes) catch unreachable;
        defer img_at.unload();

        const img_ww = rl.loadImageFromMemory(".png", wwBytes) catch unreachable;
        defer img_ww.unload();

        const atw: f32 = @floatFromInt(img_at.width);
        const ath: f32 = @floatFromInt(img_at.height);
        const ratio = ath / atw;
        const x = 800.0 / 2 - (600.0 / ratio) / 2;
        const y = 0;
        const w = 600.0 / ratio;
        const h = 600.0;

        return Self{
            .at = img_at.toTexture() catch unreachable,
            .ww = img_ww.toTexture() catch unreachable,
            .src = rl.Rectangle{ .x = 0, .y = 0, .width = atw, .height = ath },
            .dst = rl.Rectangle{ .x = x, .y = y, .width = w, .height = h },
            .zero = rl.Vector2.zero(),
        };
    }
    pub fn draw(self: *Self) void {
        if (self.k < 0.0 or self.k > 1.0) {
            self.step *= -1;
        }
        const ffps: f32 = @floatFromInt(rl.getFPS());
        self.k += self.step * ffps / 100.0;
        const alpha = easeInOutBack(self.k);

        rl.drawTexturePro(self.at, self.src, self.dst, self.zero, 0, rl.Color.alpha(rl.Color.white, alpha));
        rl.drawTexturePro(self.ww, self.src, self.dst, self.zero, 0, rl.Color.alpha(rl.Color.white, (1 - alpha)));
    }

    fn easeInOutBack(t: f32) f32 {
        const c1 = 1.70158;
        const c2 = c1 * 1.525;
        if (t < 0.5) {
            return ((2 * t * 2 * t) * ((c2 + 1) * 2 * t - c2)) / 2;
        }
        return (((2 * t - 2) * (2 * t - 2)) * ((c2 + 1) * (t * 2 - 2) + c2) + 2) / 2;
    }
};
