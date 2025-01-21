const std = @import("std");
const rl = @import("raylib");

const maxStars = 500;
const maxPlanes = 50;

var xVel: f32 = undefined;

fn map(n: f32, start1: f32, stop1: f32, start2: f32, stop2: f32) f32 {
    return (n - start1) / (stop1 - start1) * (stop2 - start2) + start2;
}

const Star = struct {
    screenWidth: i32,
    screenHeight: i32,
    x: i32,
    y: i32,
    p: u8,

    const rand = std.crypto.random;
    pub fn new(screenWidth: i32, screenHeight: i32) Star {
        return Star{
            .screenWidth = screenWidth,
            .screenHeight = screenHeight,
            .x = rand.intRangeAtMost(i32, 0, screenWidth),
            .y = rand.intRangeAtMost(i32, 0, screenHeight),
            .p = rand.intRangeAtMost(u8, 0, maxPlanes),
        };
    }
    pub fn update(self: *Star) void {
        self.updateXVel();
        self.x += @intFromFloat(@as(f32, @floatFromInt(1 + self.p)) * xVel);
        if (self.x >= self.screenWidth) {
            self.x = 0;
            self.y = rand.intRangeAtMost(i32, 0, self.screenHeight);
        }
    }

    pub fn draw(self: Star) void {
        const gray = ((256 / maxPlanes) * self.p);
        rl.drawPixel(self.x, self.y, rl.Color.init(gray, gray, gray, 255));
    }

    pub fn updateXVel(self: Star) void {
        const pos = rl.getMousePosition();
        if (pos.x > 0 and pos.x < @as(f32, @floatFromInt(self.screenWidth)) and
            pos.y > 0 and pos.y < @as(f32, @floatFromInt(self.screenHeight)))
        {
            xVel = map(pos.x, 0, @floatFromInt(self.screenWidth), 0, 0.25);
        }
    }
};

const Stars = struct {
    stars: [maxStars]Star = undefined,
    screenWidth: i32 = 320,
    screenHeight: i32 = 200,

    pub fn draw(self: *Stars) void {
        for (0..self.stars.len) |i| {
            self.stars[i].update();
            self.stars[i].draw();
        }
    }

    pub fn setup(self: *Stars) void {
        for (0..self.stars.len) |i| {
            self.stars[i] = Star.new(self.screenWidth, self.screenHeight);
        }
    }
};

pub fn main() !void {
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "DemosceneZig");
    defer rl.closeWindow();

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second

    var stars = Stars{};
    stars.setup();

    var target = try rl.loadRenderTexture(stars.screenWidth, stars.screenHeight);
    defer rl.unloadRenderTexture(target);

    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        rl.beginDrawing();
        defer rl.endDrawing();

        target.begin();
        rl.clearBackground(rl.Color.black);
        stars.draw();
        target.end();

        const src = rl.Rectangle.init(0, 0, @floatFromInt(target.texture.width), @floatFromInt(-target.texture.height));
        const dst = rl.Rectangle.init(0, 0, @floatFromInt(screenWidth), @floatFromInt(screenHeight));
        rl.drawTexturePro(target.texture, src, dst, rl.Vector2.zero(), 0, rl.Color.white);
    }
}
