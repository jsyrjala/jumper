const std = @import("std");
const Allocator = std.mem.Allocator;
const util = @import("util.zig");

const ECS = @import("ecs.zig").ECS;

const collision_resolve = @import("collision_resolve.zig");
const CollisionRect = collision_resolve.CollisionRect;
const Collision = collision_resolve.Collision;
const Vec2 = @import("vector.zig").Vec2;

var collisions: std.ArrayList(CollidingObstacle) = undefined;

const CollidingObstacle = struct {
    obstacle_id: usize,
    t_hit_near: f32,
};

pub fn setup(ecs: *ECS, allocator: Allocator) !void {
    _ = ecs;
    try util.log("obstacle.setup()", .{});
    collisions = try std.ArrayList(CollidingObstacle).initCapacity(allocator, 8);
}

pub const Obstacle = struct {};

pub fn collisionSystem(ecs: *ECS) !void {
    // clear sort array not needed actually
    var player_id: usize = 0;
    while (player_id < ecs.max_entities) : (player_id += 1) {
        if (!isPlayer(ecs, player_id)) {
            continue;
        }
        collisions.clearRetainingCapacity();
        ecs.player[player_id].?.on_ground = false;
        // TODO gather all obstacles to collision_array
        // we need to resolve collisions nearest collision point first
        var obstacle_id: usize = 0;
        while (obstacle_id < ecs.max_entities) : (obstacle_id += 1) {
            if (!isObstacle(ecs, obstacle_id)) {
                continue;
            }
            const collision = computeCollision(ecs, player_id, obstacle_id);
            if (collision != null) {
                try collisions.append(CollidingObstacle{
                    .obstacle_id = obstacle_id,
                    .t_hit_near = collision.?.t_hit_near,
                });
            }
        }
        std.sort.sort(CollidingObstacle, collisions.items, {}, closestFirst);
        for (collisions.items) |collision| {
            resolveCollision(ecs, player_id, collision.obstacle_id);
        }
        ecs.position[player_id] = ecs.position[player_id].?.add(ecs.velocity[player_id].?);
    }
}

fn closestFirst(player_pos: void, lhs: CollidingObstacle, rhs: CollidingObstacle) bool {
    _ = player_pos;
    if (lhs.t_hit_near != rhs.t_hit_near) {
        return lhs.t_hit_near < rhs.t_hit_near;
    }
    return false;
}

fn isPlayer(ecs: *ECS, entity_id: usize) bool {
    return ecs.alive[entity_id] and ecs.player[entity_id] != null;
}

fn isObstacle(ecs: *ECS, entity_id: usize) bool {
    return ecs.alive[entity_id] and ecs.obstacle[entity_id] != null;
}

fn computeCollision(ecs: *ECS, player_id: usize, obstacle_id: usize) ?Collision {
    var playerPos = ecs.position[player_id].?;
    var playerSprite = ecs.sprite[player_id].?;
    var playerVelocity = ecs.velocity[player_id].?;

    var obstaclePos = ecs.position[obstacle_id].?;
    var obstacleSprite = ecs.sprite[obstacle_id].?;

    const playerRect = CollisionRect.init(playerPos, playerSprite.size(), playerVelocity);
    const obstacleRect = CollisionRect.init(obstaclePos, obstacleSprite.size(), Vec2.zero());
    return playerRect.resolveDynamicRectCollision(obstacleRect);
}

fn resolveCollision(ecs: *ECS, player_id: usize, obstacle_id: usize) void {
    var playerPos = ecs.position[player_id].?;
    var playerSprite = ecs.sprite[player_id].?;
    var playerVelocity = ecs.velocity[player_id].?;

    var obstaclePos = ecs.position[obstacle_id].?;
    var obstacleSprite = ecs.sprite[obstacle_id].?;

    const playerRect = CollisionRect.init(playerPos, playerSprite.size(), playerVelocity);
    const obstacleRect = CollisionRect.init(obstaclePos, obstacleSprite.size(), Vec2.zero());
    const collision = playerRect.resolveDynamicRectCollision(obstacleRect);
    if (collision != null) {
        const resolve = collision.?.resolve;
        if (resolve != null) {
            const orig_velocity = ecs.velocity[player_id].?;
            ecs.velocity[player_id] = orig_velocity.add(resolve.?);
        }
        if (collision.?.contact_normal.y < -0) {
            ecs.player[player_id].?.on_ground = true;
        }
    }
}
