const std = @import("std");
const t = std.testing;

/// Maps a number in a range to another
pub inline fn map(n: f32, from: f32, to: f32, new_from: f32, new_to: f32) f32 {
    return (n - from) / (to - from) * (new_to - new_from) + new_from;
}

test map {
    const tc: [5]struct { n: f32, expected: f32 } = .{
        .{ .n = 0, .expected = 0 },
        .{ .n = 0.25, .expected = 25 },
        .{ .n = 0.5, .expected = 50 },
        .{ .n = 0.75, .expected = 75 },
        .{ .n = 1, .expected = 100 },
    };
    for (tc) |case| {
        try t.expectEqual(map(case.n, 0, 1, 0, 100), case.expected);
    }
    try t.expectEqual(map(0.5, 0, 1, 0, 1), 0.5);
    try t.expectEqual(map(0.5, 0, 1, 0, 0), 0);

    try t.expectEqual(0.01, map(0, 0, 320, 0.01, 0.1));
    try t.expectEqual(0.055, map(160, 0, 320, 0.01, 0.1));
    try t.expectEqual(0.1, map(320, 0, 320, 0.01, 0.1));
}
