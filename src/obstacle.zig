const std = @import("std");
const Allocator = std.mem.Allocator;
const util = @import("util.zig");

const ECS = @import("ecs.zig").ECS;

const collision_resolve = @import("collision_resolve.zig");
const CollisionRect = collision_resolve.CollisionRect;
const Collision = collision_resolve.Collision;
const Vec2 = @import("vector.zig").Vec2;

var resolve_array: []Collision = undefined;

pub fn setup(ecs: *ECS, allocator: *Allocator) !void {
    _ = ecs;
    _ = allocator;
    try util.log("obstacle.setup()", .{});
}

pub const Obstacle = struct {};

pub fn collisionSystem(ecs: *ECS) void {
    // clear sort array not needed actually
    var playerId: usize = 0;
    while (playerId < ecs.max_entities) : (playerId += 1) {
        if (!isPlayer(ecs, playerId)) {
            continue;
        }
        ecs.player[playerId].?.on_ground = false;
        // TODO gather all obstacles to resolve_array
        // we need to resolve collisions nearest collision point first
        var obstacleId: usize = 0;
        while (obstacleId < ecs.max_entities) : (obstacleId += 1) {
            if (!isObstacle(ecs, obstacleId)) {
                continue;
            }
            resolveCollision(ecs, playerId, obstacleId);
        }
        ecs.position[playerId] = ecs.position[playerId].?.add(ecs.velocity[playerId].?);
    }
}

fn isPlayer(ecs: *ECS, entityId: usize) bool {
    return ecs.alive[entityId] and ecs.player[entityId] != null;
}

fn isObstacle(ecs: *ECS, entityId: usize) bool {
    return ecs.alive[entityId] and ecs.obstacle[entityId] != null;
}

fn resolveCollision(ecs: *ECS, playerId: usize, obstacleId: usize) void {
    var playerPos = ecs.position[playerId].?;
    var playerSprite = ecs.sprite[playerId].?;
    var playerVelocity = ecs.velocity[playerId].?;

    var obstaclePos = ecs.position[obstacleId].?;
    var obstacleSprite = ecs.sprite[obstacleId].?;

    //const diff = playerPos.subtract(obstaclePos);
    //const distance = diff.manhattan();
    // quick and dirty optimization
    //if (distance > 50) {
    //    return;
    //}

    const playerRect = CollisionRect.init(playerPos, playerSprite.size(), playerVelocity);
    const obstacleRect = CollisionRect.init(obstaclePos, obstacleSprite.size(), Vec2.zero());
    const collision = playerRect.resolveDynamicRectCollision(obstacleRect);
    if (collision != null) {
        const resolve = collision.?.resolve;
        if (resolve != null) {
            const orig_velocity = ecs.velocity[playerId].?;
            ecs.velocity[playerId] = orig_velocity.add(resolve.?);
        }
        if (collision.?.contact_normal.y < -0) {
            ecs.player[playerId].?.on_ground = true;
        }
    }
}
