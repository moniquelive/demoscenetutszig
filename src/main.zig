const std = @import("std");
const rl = @import("raylib");
const Effect = @import("effect.zig").Effect;

const screenWidth = 800;
const screenHeight = 500;
pub const windowBounds = rl.Rectangle.init(1, 1, screenWidth - 1, screenHeight - 1);

pub fn main() !void {
    rl.initWindow(screenWidth, screenHeight, "DemosceneZig");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    //------------------------------------------------- create the effect ---
    var fx = try Effect.new("star2d");

    //------------------------------------- create our off screen texture ---
    var target = try rl.loadRenderTexture(@intCast(fx.width()), @intCast(fx.height()));
    defer rl.unloadRenderTexture(target);

    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        rl.beginDrawing();
        defer rl.endDrawing();

        //----------------------------------------- draw over our texture ---
        target.begin();
        rl.clearBackground(rl.Color.black);
        fx.draw();
        target.end();

        //--------------------------- stretch our texture over the window ---
        const src = rl.Rectangle.init(0, 0, @floatFromInt(target.texture.width), @floatFromInt(-target.texture.height));
        const dst = rl.Rectangle.init(0, 0, @floatFromInt(screenWidth), @floatFromInt(screenHeight));
        rl.drawTexturePro(target.texture, src, dst, rl.Vector2.zero(), 0, rl.Color.white);
    }
}
