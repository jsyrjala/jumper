const w4 = @import("wasm4.zig");

// https://colorhunt.co/
pub const background_color = 0x143F6B;
pub const color1 = 0xFEB139;
pub const color2 = 0xF55353;
pub const color3 = 0xF6F54D;

pub fn setup() void {
    w4.DRAW_COLORS.* = 2;
    w4.PALETTE.* = .{
        background_color,
        color1,
        color2,
        color3,
    };
}
