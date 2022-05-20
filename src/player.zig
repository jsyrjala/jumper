const std = @import("std");
const math = std.math;

const Allocator = std.mem.Allocator;
const vector = @import("vector.zig");
const Vec2 = vector.Vec2;
const Sprite = @import("sprite.zig").Sprite;
const shapes = @import("shapes.zig");

const w4 = @import("wasm4.zig");

const ECS = @import("ecs.zig").ECS;

const util = @import("util.zig");

const max_walk_speed: f32 = 1;
const max_run_speed: f32 = 2;
const walk_acceleration: f32 = 0.07;
const run_acceleration: f32 = 0.15;
const deceleration: f32 = 0.07;
const walk_jump_velocity: f32 = 5;
const run_jump_velocity: f32 = 15;
const jump_gravity: f32 = 0.6;
const drop_gravity: f32 = 0.8;
const strong_jump_gravity: f32 = 0.2;
const ground_y: f32 = 130 + 8;
const player_start_y: f32 = 40;

pub fn setup(ecs: *ECS) !void {
    try createPlayer(ecs, 0, Vec2{ .x = 10, .y = player_start_y }, Vec2.zero());
    try util.log("player.setup()", .{});
}

fn createPlayer(ecs: *ECS, index: u16, position: Vec2, velocity: Vec2) !void {
    const playerId = try ecs.createEntity();
    ecs.player[playerId] = Player.init(index);
    ecs.sprite[playerId] = try Sprite.init_new(&shapes.smiley, 2, 0, 0, 0);
    ecs.position[playerId] = position;
    ecs.velocity[playerId] = velocity;
}

pub const Player = struct {
    index: u16,
    prev_gamepad: u8,
    jump_held: bool,
    on_ground: bool,

    pub fn init(index: u16) Player {
        return Player{
            .index = index,
            .prev_gamepad = 0,
            .jump_held = false,
            .on_ground = false,
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

pub fn playerSystem(ecs: *ECS) void {
    var entityId: usize = 0;
    while (entityId < ecs.max_entities) : (entityId += 1) {
        if (!ecs.alive[entityId]) {
            return;
        }
        if (ecs.player[entityId] != null and
            ecs.position[entityId] != null and
            ecs.velocity[entityId] != null and
            ecs.sprite[entityId] != null)
        {
            updatePlayer(&(ecs.player[entityId] orelse unreachable), &(ecs.position[entityId] orelse unreachable), &(ecs.velocity[entityId] orelse unreachable), &(ecs.sprite[entityId] orelse unreachable)) catch |e| {
                util.log("PlayerSystem: Failure {}", .{e}) catch {};
            };
        }
    }
}

fn updatePlayer(player: *Player, position: *Vec2, velocity: *Vec2, sprite: *Sprite) !void {
    const input = player.input();
    var acceleration = Vec2.zero();
    var max_speed: f32 = max_run_speed;
    const run_button = input.button_2;
    const jump_button = input.button_1;

    // moving left and right
    if (input.left) {
        sprite.animation_frame = 2;
        if (run_button) {
            // running
            acceleration = Vec2{ .x = -run_acceleration, .y = 0 };
            max_speed = max_run_speed;
        } else {
            acceleration = Vec2{ .x = -walk_acceleration, .y = 0 };
            max_speed = max_walk_speed;
        }
    } else if (input.right) {
        sprite.animation_frame = 1;
        if (run_button) {
            // running
            acceleration = Vec2{ .x = run_acceleration, .y = 0 };
            max_speed = max_run_speed;
        } else {
            acceleration = Vec2{ .x = walk_acceleration, .y = 0 };
            max_speed = max_walk_speed;
        }
    }

    // jumping
    const jumping = !player.on_ground;
    var gravity = jump_gravity;

    if (jump_button and !jumping and !player.*.jump_held) {
        player.*.jump_held = true;
        velocity.*.y -= walk_jump_velocity;
        sprite.animation_frame = 0;
    }

    if (!jump_button) {
        player.*.jump_held = false;
    }
    // gravity
    // jump button hold, and raising => lower gravity
    if (jump_button and player.*.jump_held and velocity.*.y < 0) {
        gravity = strong_jump_gravity;
    }
    // dropping => higher gravity
    if (jumping and velocity.*.y > 0) {
        gravity = drop_gravity;
    }
    acceleration = acceleration.add(Vec2{ .x = 0, .y = gravity });

    velocity.* = velocity.*.add(acceleration);

    if (!player.on_ground and velocity.y > 0) {
        sprite.animation_frame = 3;
    }

    // not pressing any buttons => slow down
    if (!input.left and !input.right) {
        if (velocity.*.x > 0) {
            velocity.*.x -= deceleration;
            velocity.*.x = math.clamp(velocity.*.x, 0, max_speed);
        } else {
            velocity.*.x += deceleration;
            velocity.*.x = math.clamp(velocity.*.x, -max_speed, 0);
        }
    }

    //position.* = position.*.add(velocity.*);

    // stop if hitting screen right or left borders
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
