const std = @import("std");

const colors = @import("colors.zig");
const util = @import("util.zig");
const sprite = @import("sprite.zig");
const vector = @import("vector.zig");
const Vec2 = vector.Vec2;

const ECS = @import("ecs.zig").ECS;

const player = @import("player.zig");
const terrain = @import("terrain.zig");
const obstacle = @import("obstacle.zig");

var ecs: ECS = undefined;

var buffer: [15000]u8 = undefined;
var worldAllocator = std.heap.FixedBufferAllocator.init(&buffer);

pub fn setup() !void {
    try util.log("game.setup()", .{});
    colors.setup();
    var allocator = worldAllocator.allocator();

    ecs = try ECS.init(&allocator);

    try sprite.setup(&ecs);
    try terrain.setup(&ecs);
    try player.setup(&ecs);
    try obstacle.setup(&ecs);

    try util.log("setup done", .{});
}

pub fn update(frame_counter: u32) !void {
    if (@rem(frame_counter, 600) == 0) {
        try util.log("Frame: {} time: {}s", .{ frame_counter, frame_counter / 60 });
    }
    ecs.tick();
    player.playerSystem(&ecs);
    obstacle.collisionSystem(&ecs);
    sprite.spriteSystem(&ecs);

    //var i: f32 = -80000000.000;
    //util.log("test={} {}", .{i, std.math.isNormal(i)}) catch{};
}
