const std = @import("std");
const Allocator = std.mem.Allocator;

const Player = @import("player.zig").Player;
const Sprite = @import("sprite.zig").Sprite;
const Obstacle = @import("obstacle.zig").Obstacle;
const vector = @import("vector.zig");
const Vec2 = vector.Vec2;

pub const max_entities = 150;

const EcsError = error{
    TooManyEntities,
};

pub const ECS = struct {
    max_entities: usize,
    alive: []bool,
    player: []?Player,
    obstacle: []?Obstacle,
    sprite: []?Sprite,
    position: []?Vec2,
    velocity: []?Vec2,
    entity_count: u16,

    pub fn init(allocator: Allocator) !ECS {
        _ = allocator;
        return ECS{
            .max_entities = max_entities,
            .alive = try allocator.alloc(bool, max_entities),
            .player = try allocator.alloc(?Player, max_entities),
            .obstacle = try allocator.alloc(?Obstacle, max_entities),
            .sprite = try allocator.alloc(?Sprite, max_entities),
            .position = try allocator.alloc(?Vec2, max_entities),
            .velocity = try allocator.alloc(?Vec2, max_entities),
            .entity_count = 0,
        };
    }

    pub fn createEntity(self: *ECS) !usize {
        var i: usize = 0;
        while (i < self.alive.len) : (i += 1) {
            if (!self.alive[i]) {
                self.alive[i] = true;
                self.entity_count += 1;
                return i;
            }
        }
        return error.TooManyEntities;
    }
    pub fn deleteEntity(self: *ECS, entityId: usize) void {
        if (self.alive.len <= entityId) {
            return;
        }
        self.alive[entityId] = false;
        self.player[entityId] = null;
        self.obstacle[entityId] = null;
        self.sprite[entityId] = null;
        self.position[entityId] = null;
        self.velocity[entityId] = null;
        self.entity_count -= 1;
    }

    pub fn tick(self: *ECS) void {
        _ = self;
    }
};
