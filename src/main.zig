/// test
const w4 = @import("wasm4.zig");
const game = @import("game.zig");
const util = @import("util.zig");
const shapes = @import("shapes.zig");

export fn start() void {
    game.setup() catch |e| {
        util.log("start() error {}", .{e}) catch {};
    };
}

var frame_counter: u32 = 0;
export fn update() void {
    if (frame_counter == 0) {
        util.log("First update", .{}) catch {};
    }
    game.update(frame_counter) catch |e| {
        util.log("update() error {}", .{e}) catch {};
    };
    frame_counter += 1;
}
