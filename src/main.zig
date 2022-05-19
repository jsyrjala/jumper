/// test
const w4 = @import("wasm4.zig");
const game = @import("game.zig");
const colors = @import("colors.zig");
const util = @import("util.zig");
const shapes = @import("shapes.zig");


export fn start() void {
    util.log("setup", .{}) catch {};
    colors.setup();
}

var frame: u32 = 0;
var clicks: u32 = 0;
export fn update() void {
    frame += 1;
    try game.update();

    w4.DRAW_COLORS.* = 3;
    w4.text("Hello World!", 16, 20);

    w4.DRAW_COLORS.* = 2;
    const gamepad = w4.GAMEPAD1.*;
    if (gamepad & w4.BUTTON_1 != 0) {
        clicks += 1;
        w4.DRAW_COLORS.* = 4;
    }

    const shape = &shapes.smiley[@rem(clicks, shapes.smiley.len)];
    w4.blit(shape, 76, 76, 8, 8, w4.BLIT_1BPP);
    w4.text("Press X to blink", 16, 90);

}
