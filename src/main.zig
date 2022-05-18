/// test
const w4 = @import("wasm4.zig");
const game = @import("game.zig");
const colors = @import("colors.zig");
const util = @import("util.zig");

const smiley = [8]u8{
    0b11000011,
    0b10000001,
    0b00100100,
    0b00100100,
    0b00000000,
    0b00100100,
    0b10011001,
    0b11000011,
};

export fn start() void {
    util.log("setup", .{}) catch {};
    colors.setup();
}

export fn update() void {
    try game.update();

    w4.DRAW_COLORS.* = 3;
    w4.text("Hello World!", 16, 20);

    w4.DRAW_COLORS.* = 2;
    const gamepad = w4.GAMEPAD1.*;
    if (gamepad & w4.BUTTON_1 != 0) {
        w4.DRAW_COLORS.* = 4;
    }

    w4.blit(&smiley, 76, 76, 8, 8, w4.BLIT_1BPP);
    w4.text("Press X to blink", 16, 90);

}
