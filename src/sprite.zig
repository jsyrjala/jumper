const std = @import("std");
const Allocator = std.mem.Allocator;
const Vec2 = @import("vector.zig").Vec2;
const util = @import("util.zig");

const Adapter = @import("ecs/systems.zig").Adapter;
const World = @import("ecs/systems.zig").World;
const w4 = @import("wasm4.zig");
const smiley = @import("shapes.zig").smiley;

pub fn setup(allocator: *Allocator, world: *World) !void {
    _ = allocator;
    try util.log("game.setup()", .{});
    try world.register("sprite", spriteSystem);
}

pub const Sprite = struct {
    shapes: []const u8,
    animation_frame: u16,
    animation_count: u16,
    width: u16,
    height: u16,
    color1: u4,
    color2: u4,
    color3: u4,
    color4: u4,

    pub fn init(
        allocator: *Allocator, shapes: []const u8, animation_count: u16, width: u16, height: u16, 
        color1: u4, color2: u4, color3: u4, color4: u4) !*Sprite {
        var sprite = try allocator.create(Sprite);
        sprite.* = Sprite{
            .shapes = shapes, .animation_count = animation_count, .animation_frame = 0, .width = width, .height = height,
            .color1 = color1, .color2 = color2, .color3 = color3, .color4 = color4,
        };
        return sprite;
    }
};


const spriteSystem = ( struct {
    pub fn func(adapter: *Adapter) void {

        var iter = adapter.query(&.{"sprite", "position"});
        while (iter.next()) |row| {
            defer row.unlock();
            var sprite = adapter.world.entities.getComponent(row.entity, "sprite", *Sprite) orelse unreachable;
            var position = adapter.world.entities.getComponent(row.entity, "position", *Vec2) orelse unreachable;
            drawSprite(sprite, position) catch |e| {
                util.log("SpriteSystem: Failure {}", .{e}) catch {};
            };
        }
    }
}).func;

fn drawSprite(sprite: *Sprite, position: *Vec2) !void {
    w4.DRAW_COLORS.* = (@as(u16, sprite.color4) << 12) + (@as(u16, sprite.color3) << 8) + (@as(u16, sprite.color2) << 4) + sprite.color1;
    w4.blit(
        sprite.*.shapes.ptr + sprite.animation_frame * sprite.height, 
        @floatToInt(i32, position.x), @floatToInt(i32, position.y),
        sprite.width, sprite.height, 
        w4.BLIT_1BPP
    );
}