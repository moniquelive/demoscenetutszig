const std = @import("std");
const rl = @import("raylib");
const Effect = @import("effect.zig").Effect;

const screenWidth = 800;
const screenHeight = 500;
pub const windowBounds = rl.Rectangle.init(1, 1, screenWidth - 1, screenHeight - 1);

pub fn drawFps() void {
    var text: [4:0]u8 = .{0} ** 4;
    const fps = rl.getFPS();
    text[0] = '0' + @as(u8, @intCast(@mod(@divFloor(fps, 100), 10)));
    text[1] = '0' + @as(u8, @intCast(@mod(@divFloor(fps, 10), 10)));
    text[2] = '0' + @as(u8, @intCast(@mod(@divFloor(fps, 1), 10)));
    rl.drawText(&text, 10, 10, 12, rl.Color.white);
}

pub fn main() !void {
    rl.initWindow(screenWidth, screenHeight, "DemosceneZig");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    //------------------------------------------------- create the effect ---
    var fx = try Effect.new("crossfade");

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
        drawFps();
        target.end();

        //--------------------------- stretch our texture over the window ---
        const src = rl.Rectangle.init(0, 0, @floatFromInt(target.texture.width), @floatFromInt(-target.texture.height));
        const dst = rl.Rectangle.init(0, 0, @floatFromInt(screenWidth), @floatFromInt(screenHeight));
        rl.drawTexturePro(target.texture, src, dst, rl.Vector2.zero(), 0, rl.Color.white);
    }
}
