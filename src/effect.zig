impl: *anyopaque,

drawFn: *const fn (*anyopaque) void,
widthFn: *const fn (*anyopaque) u32,
heightFn: *const fn (*anyopaque) u32,

const Self = @This();

pub fn draw(iface: *const Self) void {
    return iface.drawFn(iface.impl);
}

pub fn width(iface: *const Self) u32 {
    return iface.widthFn(iface.impl);
}

pub fn height(iface: *const Self) u32 {
    return iface.heightFn(iface.impl);
}
