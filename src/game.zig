const std = @import("std");

const colors = @import("colors.zig");
const util = @import("util.zig");
const sprite = @import("sprite.zig");
const vector = @import("vector.zig");
const Vec2 = vector.Vec2;

const Adapter = @import("ecs/systems.zig").Adapter;
const System = @import("ecs/systems.zig").System;
const World = @import("ecs/systems.zig").World;
const EntityID = @import("ecs/entities.zig").EntityID;
const Entities = @import("ecs/entities.zig").Entities;

const player = @import("player.zig");

var world: World = undefined;

var buffer: [5000]u8 = undefined;
var worldAllocator = std.heap.FixedBufferAllocator.init(&buffer);

pub fn setup() !void {
    try util.log("game.setup()", .{});
    colors.setup();
    var allocator = worldAllocator.allocator();
    world = try World.init(allocator);

    try sprite.setup(&allocator, &world);
    try player.setup(&allocator, &world);

    try util.log("setup done", .{});
}

pub fn update(frame_counter: u32) !void {

    if (@rem(frame_counter, 600) == 0) {
        try util.log("Frame: {} time: {}s", .{frame_counter, frame_counter / 60});
    }
    world.tick();
}

