const std = @import("std");
const Allocator = std.mem.Allocator;
const vector = @import("vector.zig");
const Vec2 = vector.Vec2;

const w4 = @import("wasm4.zig");

const World = @import("ecs/systems.zig").World;
const EntityID = @import("ecs/entities.zig").EntityID;
const Adapter = @import("ecs/systems.zig").Adapter;
const util = @import("util.zig");


pub fn setup(allocator: Allocator, world: *World) !void {
    try createPlayer(allocator, world, 0, Vec2{.x = 10, .y = 130}, Vec2.zero());
    try world.register("player", playerSystem);
}

fn createPlayer(allocator: Allocator, world: *World, index: u16, position: Vec2, velocity: Vec2) !void{
    const player1Id = try world.entities.new();

    var player1Component = try allocator.create(Player);
    player1Component.* = Player.init(index, player1Id);
    try world.entities.setComponent(player1Id, "player", player1Component);

    var pos = try allocator.create(Vec2);
    pos.* = position;
    try world.entities.setComponent(player1Id, "position", pos);

    var vel = try allocator.create(Vec2);
    vel.* = velocity;
    try world.entities.setComponent(player1Id, "velocity", vel);
}

pub const Player = struct {
    index: u16,
    entity: EntityID,
    prev_gamepad: u8,

    pub fn init(index: u16, entity: EntityID) Player {
        return Player{
            .index = index, 
            .entity = entity, 
            .prev_gamepad = 0,
        };
    }

    pub fn input(self: *Player) Input {
        const gamepad = w4.GAMEPADS[self.index];
        //const just_pressed = gamepad & (gamepad ^ self.prev_gamepad);
        const changed = gamepad != self.prev_gamepad;
        self.prev_gamepad = gamepad;
        return Input{
            .up = w4.BUTTON_UP & gamepad != 0,
            .down = w4.BUTTON_DOWN & gamepad != 0,
            .left = w4.BUTTON_LEFT & gamepad != 0,
            .right = w4.BUTTON_RIGHT & gamepad != 0,
            .button_1 = w4.BUTTON_1 & gamepad != 0,
            .button_2 = w4.BUTTON_2 & gamepad != 0,
            .any_button = gamepad != 0,
            .changed = changed,
        };
    }
};

const Input = struct {
    up: bool,
    down: bool,
    left: bool,
    right: bool,
    button_1: bool,
    button_2: bool,
    any_button: bool,
    changed: bool,
};


// struct needed for closure?
const playerSystem = ( struct {
    pub fn playerFunc(adapter: *Adapter) void {
        var iter = adapter.query(&.{"player", "position", "velocity"});
        while (iter.next()) |row| {
            defer row.unlock();
            var player = adapter.world.entities.getComponent(row.entity, "player", *Player) orelse unreachable;
            var position = adapter.world.entities.getComponent(row.entity, "position", *Vec2) orelse unreachable;
            var velocity = adapter.world.entities.getComponent(row.entity, "velocity", *Vec2) orelse unreachable;
            updatePlayer(player, position, velocity) catch |e| {
                util.log("PlayerSystem: Failure {}", .{e}) catch {};
            };
        }
    }
}).playerFunc;

fn updatePlayer(player: *Player, position: *Vec2, velocity: *Vec2) !void {
    const input = player.input();
    if (input.changed) {
        try util.log("input: {} position={} velocity={}", .{input, position, velocity});
    }
}
