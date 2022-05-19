const std = @import("std");

const colors = @import("colors.zig");
const util = @import("util.zig");


const Adapter = @import("ecs/systems.zig").Adapter;
const System = @import("ecs/systems.zig").System;
const World = @import("ecs/systems.zig").World;
const EntityID = @import("ecs/entities.zig").EntityID;
const Entities = @import("ecs/entities.zig").Entities;

const p = @import("player.zig");
const Player = p.Player;

var world: World = undefined;

var buffer: [5000]u8 = undefined;
var worldAllocator = std.heap.FixedBufferAllocator.init(&buffer);
var player1Component: Player = undefined;
var player2Component: Player = undefined;

fn playerInput2(player: *Player) void {
    util.log("Player {}", .{player})  catch {};
    const input = player.input();

    if (input.changed) {
         util.log("Input {}", .{input})  catch {};
    }
}

pub fn setup() !void {
    try util.log("game.setup()", .{});
    colors.setup();

    world = try World.init(worldAllocator.allocator());
    const player1Id = try world.entities.new();
    const player2Id = try world.entities.new();
    player1Component = Player.init(0, player1Id);
    player2Component = Player.init(1, player1Id);


    try util.log("player1 {}", .{player1Component});
    _ = player1Component;
    _ = player2Component;
    _ = player1Id;
    _ = player2Id;

    try world.entities.setComponent(player1Id, "player", &player1Component);
    const playerSystem = ( struct {
        pub fn player(adapter: *Adapter) void {
            var iter = adapter.query(&.{"player"});
            while (iter.next()) |row| {
                defer row.unlock();
                if (adapter.world.entities.getComponent(row.entity, "player", *Player)) |component| {
                    const input = component.input();
                    if (input.changed) {
                        util.log("input: {}", .{input}) catch {};
                    }
                }
            }
        }
    }).player;
    try world.register("player", playerSystem);

    try util.log("setup done", .{});
}

pub fn update(frame_counter: u32) !void {

    if (@rem(frame_counter, 600) == 0) {
        try util.log("Frame: {} time: {}s", .{frame_counter, frame_counter / 60});
    }


    world.tick();
}

