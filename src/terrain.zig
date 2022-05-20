const std = @import("std");
const math = std.math;
const Allocator = std.mem.Allocator;
const util = @import("util.zig");

const vector = @import("vector.zig");
const Vec2 = vector.Vec2;
const Sprite = @import("sprite.zig").Sprite;
const shapes = @import("shapes.zig");

const ECS = @import("ecs.zig").ECS;

pub fn setup(ecs: *ECS) !void {
    try createTerrain(ecs, Vec2{.x = 0, .y = 146}, 30);
    try createTerrain(ecs, Vec2{.x = 10, .y = 100}, 3);
    try createTerrain(ecs, Vec2{.x = 70, .y = 80}, 3);

    try createTerrain(ecs, Vec2{.x = 30, .y = 60}, 3);

    try createTerrain(ecs, Vec2{.x = 140, .y = 60}, 1);
    try createTerrain(ecs, Vec2{.x = 140, .y = 67}, 1);
    try createTerrain(ecs, Vec2{.x = 140, .y = 74}, 1);
    try createTerrain(ecs, Vec2{.x = 140, .y = 81}, 1);
    try createTerrain(ecs, Vec2{.x = 140, .y = 88}, 1);
    try createTerrain(ecs, Vec2{.x = 140, .y = 95}, 1);
    try createTerrain(ecs, Vec2{.x = 140, .y = 102}, 1);
    try createTerrain(ecs, Vec2{.x = 140, .y = 109}, 1);
}

fn createTerrain(ecs: *ECS, position: Vec2, blocks: u16) !void{
    var i: u16 = 0;
    while (i < blocks) : (i += 1) {
        const id = try ecs.createEntity();
        const sprite = try Sprite.init_new(&shapes.ground_block, 4, 3, 2, 0);
        ecs.sprite[id] = sprite;
        ecs.position[id] = position.add(Vec2{ .x = @intToFloat(f32, i * sprite.width), .y = 0});
    }
}