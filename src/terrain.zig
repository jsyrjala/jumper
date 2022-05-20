const std = @import("std");
const math = std.math;
const Allocator = std.mem.Allocator;
const util = @import("util.zig");

const vector = @import("vector.zig");
const Vec2 = vector.Vec2;
const Sprite = @import("sprite.zig").Sprite;
const shapes = @import("shapes.zig");

const World = @import("ecs/systems.zig").World;
const EntityID = @import("ecs/entities.zig").EntityID;
const Adapter = @import("ecs/systems.zig").Adapter;

pub fn setup(allocator: *Allocator, world: *World) !void {
    try createTerrain(allocator, world, Vec2{.x = 0, .y = 147}, 2);
    _ = world;
    //try world.register("terrain", terrainSystem);
}

fn createTerrain(allocator: *Allocator, world: *World, position: Vec2, blocks: u16) !void{
    var i: u16 = 0;
    while (i < blocks) : (i += 1) {
        var sprite = try Sprite.init(allocator, &shapes.ground_block, 2, 3, 2, 0);
        var pos = try allocator.create(Vec2);
        pos.* = position.add(Vec2{ .x = @intToFloat(f32, i * sprite.width), .y = 0});
        const entityId = try world.entities.new();
        try world.entities.setComponent(entityId, "position", pos);
        try world.entities.setComponent(entityId, "sprite", sprite);
    }
    
}