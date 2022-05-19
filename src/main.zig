/// test
const w4 = @import("wasm4.zig");
const game = @import("game.zig");
const util = @import("util.zig");
const shapes = @import("shapes.zig");


export fn start() void {
    game.setup() catch {};
}

var frame_counter: u32 = 0;
export fn update() void {
    game.update(frame_counter) catch {};
    frame_counter += 1;
}
