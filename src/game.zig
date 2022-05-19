const std = @import("std");

const colors = @import("colors.zig");
const util = @import("util.zig");


const Adapter = @import("ecs/systems.zig").Adapter;
const System = @import("ecs/systems.zig").System;
const World = @import("ecs/systems.zig").World;
const EntityID = @import("ecs/entities.zig").EntityID;
const Entities = @import("ecs/entities.zig").Entities;

const Player = @import("player.zig").Player;

var world: World = undefined;

var buffer: [1000]u8 = undefined;
var worldAllocator = std.heap.FixedBufferAllocator.init(&buffer);
var player1: Player = undefined;

pub fn setup() !void {
    try util.log("game.setup()", .{});
    colors.setup();

    world = try World.init(worldAllocator.allocator());
    const player1Id = try world.entities.new();
    player1 = Player.init(0, player1Id);

    try util.log("player1 {}", .{player1});

}


pub fn update(frame_counter: u32) !void {
    if (@rem(frame_counter, 600) == 0) {
        try util.log("Frame: {} time: {}s", .{frame_counter, frame_counter / 60});
    }
    const input = player1.input();
    if (input.changed) {
        try util.log("Input {}", .{input});
    }

}

