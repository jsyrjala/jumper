const w4 = @import("wasm4.zig");

/// Draw text with, with optional background rectangle
pub fn drawText(str: []const u8, x: i32, y: i32, w: u32, fgColor: ?u16, bgColor: ?u16) void {
    _ = w;
    if (bgColor != null) {
        w4.DRAW_COLORS.* = bgColor.?;
        w4.rect(x - 1, y - 1, str.len * 8 + 1, 9);
    }
    if (fgColor != null) {
        w4.DRAW_COLORS.* = fgColor.?;
    }

    w4.text(str, x, y);
}
