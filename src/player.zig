const std = @import("std");
const math = std.math;

const Allocator = std.mem.Allocator;
const vector = @import("vector.zig");
const Vec2 = vector.Vec2;
const Sprite = @import("sprite.zig").Sprite;
const shapes = @import("shapes.zig");

const w4 = @import("wasm4.zig");

const World = @import("ecs/systems.zig").World;
const EntityID = @import("ecs/entities.zig").EntityID;
const Adapter = @import("ecs/systems.zig").Adapter;
const util = @import("util.zig");

const max_walk_speed: f32 = 1;
const max_run_speed: f32 = 2;
const walk_acceleration: f32 = 0.07;
const run_acceleration: f32 = 0.15;
const deceleration: f32 = 0.07;
const gravity: f32 = 2;
const ground_y: f32 = 130 + 8;

pub fn setup(allocator: *Allocator, world: *World) !void {
    try createPlayer(allocator, world, 0, Vec2{.x = 10, .y = 130}, Vec2.zero());
    try world.register("player", playerSystem);
}

fn createPlayer(allocator: *Allocator, world: *World, index: u16, position: Vec2, velocity: Vec2) !void{
    const playerId = try world.entities.new();

    var player = try allocator.create(Player);
    player.* = Player.init(index, playerId);
    try world.entities.setComponent(playerId, "player", player);

    var pos = try allocator.create(Vec2);
    pos.* = position;
    try world.entities.setComponent(playerId, "position", pos);

    var vel = try allocator.create(Vec2);
    vel.* = velocity;
    try world.entities.setComponent(playerId, "velocity", vel);

    var sprite = try Sprite.init(allocator, &shapes.smiley);
    try world.entities.setComponent(playerId, "sprite", sprite);
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
            var sprite = adapter.world.entities.getComponent(row.entity, "sprite", *Sprite) orelse unreachable;
            updatePlayer(player, position, velocity, sprite) catch |e| {
                util.log("PlayerSystem: Failure {}", .{e}) catch {};
            };
        }
    }
}).playerFunc;

fn updatePlayer(player: *Player, position: *Vec2, velocity: *Vec2, sprite: *Sprite) !void {
    const input = player.input();
    var acceleration = Vec2.zero();
    var max_speed: f32 = max_run_speed;
    if (input.left) {
        sprite.animation_frame = 2;
        if (input.button_1) {
            // running
            acceleration = Vec2{.x = -run_acceleration, .y = 0};
            max_speed = max_run_speed;
        } else {
            acceleration = Vec2{.x = -walk_acceleration, .y = 0};
            max_speed = max_walk_speed;
        }
    } else if (input.right) {
        sprite.animation_frame = 1;
        if (input.button_1) {
            // running
            acceleration = Vec2{.x = run_acceleration, .y = 0};
            max_speed = max_run_speed;
        } else {
            acceleration = Vec2{.x = walk_acceleration, .y = 0};
            max_speed = max_walk_speed;
        }
    }
    velocity.* = velocity.*.add(acceleration);

    if (!input.left and !input.right) {
        // not pressing any buttons => slow down
        if (velocity.*.x > 0) {
            velocity.*.x -= deceleration;
            velocity.*.x = math.clamp(velocity.*.x, 0, max_speed);
        } else {
            velocity.*.x += deceleration;
            velocity.*.x = math.clamp(velocity.*.x, -max_speed, 0);
        }
    }
    position.* = position.*.add(velocity.*);
    if (position.*.x < 0) {
        position.*.x = 0;
        if (velocity.*.x < 0) {
            velocity.*.x = 0;
        }
    }
    const right_limit = @intToFloat(f32, w4.SCREEN_SIZE) - @intToFloat(f32, sprite.*.width);
    if (position.*.x > right_limit) {
        position.*.x = right_limit;
        if (velocity.*.x > 0) {
            velocity.*.x = 0;
        }
    }
}
