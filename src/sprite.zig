const std = @import("std");
const Allocator = std.mem.Allocator;
const Vec2 = @import("vector.zig").Vec2;
const util = @import("util.zig");

const w4 = @import("wasm4.zig");
const Shape = @import("shapes.zig").Shape;
const ECS = @import("ecs.zig").ECS;

pub fn setup(allocator: *Allocator, ecs: *ECS) !void {
    _ = allocator;
    _ = ecs;
    try util.log("sprite.setup()", .{});
}

pub const Sprite = struct {
    shape: *const Shape,
    animation_frame: u16,
    animation_count: u16,
    width: u16,
    height: u16,
    color1: u4,
    color2: u4,
    color3: u4,
    color4: u4,

    pub fn init_new(shape: *const Shape, color1: u4, color2: u4, color3: u4, color4: u4) !Sprite {
        return Sprite{
            .shape = shape, .animation_count = shape.frames, .animation_frame = 0,
            .width = shape.width, .height = shape.height,
            .color1 = color1, .color2 = color2, .color3 = color3, .color4 = color4,
        };
    }


    pub fn init(
        allocator: *Allocator, shape: *const Shape,
        color1: u4, color2: u4, color3: u4, color4: u4) !*Sprite {
        var sprite = try allocator.create(Sprite);
        sprite.* = Sprite{
            .shape = shape, .animation_count = shape.frames, .animation_frame = 0,
            .width = shape.width, .height = shape.height,
            .color1 = color1, .color2 = color2, .color3 = color3, .color4 = color4,
        };
        return sprite;
    }
};


pub fn spriteSystem(ecs: *ECS) void {
    var entityId: usize = 0;
    while (entityId < ecs.max_entities) : (entityId += 1) {
        if (!ecs.alive[entityId]) {
            return;
        }
        if (ecs.sprite[entityId] != null and 
            ecs.position[entityId] != null) {
            drawSprite(
                ecs.sprite[entityId] orelse unreachable, 
                ecs.position[entityId] orelse unreachable
            ) catch |e| {
                util.log("SpriteSystem: Failure {}", .{e}) catch {};
            };
        }
    }
}

fn drawSprite(sprite: Sprite, position: Vec2) !void {
    w4.DRAW_COLORS.* = (@as(u16, sprite.color4) << 12) + (@as(u16, sprite.color3) << 8) + (@as(u16, sprite.color2) << 4) + sprite.color1;
    w4.blit(
        sprite.shape.pixel_data.ptr + sprite.animation_frame * sprite.height, 
        @floatToInt(i32, position.x), @floatToInt(i32, position.y),
        sprite.width, sprite.height, 
        w4.BLIT_1BPP
    );
}