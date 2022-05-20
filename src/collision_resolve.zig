// Arbitrary axis aligned rectangle collisions
// Taken from https://github.com/OneLoneCoder/olcPixelGameEngine/blob/master/Videos/OneLoneCoder_PGE_Rectangles.cpp

const std = @import("std");
const math = std.math;
const vector = @import("vector.zig");
const Rect = vector.Rect;
const Vec2 = vector.Vec2;
const util = @import("util.zig");

pub const Collision = struct {
    contact_point: Vec2,
    contact_normal: Vec2,
    t_hit_near: f32,
    resolve: ?Vec2 = undefined,
};

pub const CollisionRect = struct {
    position: Vec2,
    size: Vec2,
    velocity: Vec2,

    pub fn init(position: Vec2, size: Vec2, velocity: Vec2) CollisionRect {
        return CollisionRect{
            .position = position,
            .size = size,
            .velocity = velocity,
        };
    }

    pub fn collidesPoint(self: CollisionRect, point: Vec2) bool {
        return (point.x >= self.position.x and
            point.y >= self.position.y and
            point.x < self.position.x + self.size.x and
            point.y < self.position.y + self.size.y);
    }

    pub fn collidesRect(self: CollisionRect, rect: CollisionRect) bool {
        return (self.position.x < rect.position.x + rect.size.x and self.position.x + self.size.x > rect.position.x and self.position.y < rect.position.y + rect.size.y and self.position.y + self.size.y > rect.position.y);
    }

    /// Calculates collision of ray starting from ray_origin going to direction ray_dir
    /// and a rectangle. Calculates the nearest point. Works only if starting point in outside of the rectangle.
    pub fn collidesRay(target: CollisionRect, ray_origin: Vec2, ray_dir: Vec2) ?Collision {
        // Cache division
        // Fix divide by zero if ray_dir.x or ray_dir.y is exactly 0
        const epsilon = 0.0000001;
        const inv_dir = Vec2{
            .x = 1.0 / if (math.fabs(ray_dir.x) > epsilon) ray_dir.x else epsilon,
            .y = 1.0 / if (math.fabs(ray_dir.y) > epsilon) ray_dir.y else epsilon,
        };

        // Calculate intersections with rectangle bounding axes
        var t_near = target.position.subtract(ray_origin).multiply(inv_dir);
        var t_far = target.position.add(target.size).subtract(ray_origin).multiply(inv_dir);

        if (!math.isFinite(t_far.y) or !math.isFinite(t_far.x)) return null;
        if (!math.isFinite(t_near.y) or !math.isFinite(t_near.x)) return null;

        // Sort distances
        if (t_near.x > t_far.x) {
            const tmp = t_far.x;
            t_far.x = t_near.x;
            t_near.x = tmp;
        }
        if (t_near.y > t_far.y) {
            const tmp = t_far.y;
            t_far.y = t_near.y;
            t_near.y = tmp;
        }

        // Early rejection
        if (t_near.x > t_far.y or t_near.y > t_far.x) return null;

        // Closest 'time' will be the first contact
        const t_hit_near: f32 = math.max(t_near.x, t_near.y);

        // Furthest 'time' is contact on opposite side of target
        const t_hit_far: f32 = math.min(t_far.x, t_far.y);

        // Reject if ray direction is pointing away from object
        if (t_hit_far < 0) return null;

        // Contact point of collision from parametric line equation
        var contact_normal = Vec2.zero();
        var contact_point = ray_origin.add(ray_dir.scale(t_hit_near));
        if (t_near.x > t_near.y) {
            if (inv_dir.x < 0) {
                contact_normal = Vec2{ .x = 1, .y = 0 };
            } else {
                contact_normal = Vec2{ .x = -1, .y = 0 };
            }
        } else if (t_near.x < t_near.y) {
            if (inv_dir.y < 0) {
                contact_normal = Vec2{ .x = 0, .y = 1 };
            } else {
                contact_normal = Vec2{ .x = 0, .y = -1 };
            }
        }

        // Note if t_near == t_far, collision is principly in a diagonal
        // so pointless to resolve. By returning a CN={0,0} even though its
        // considered a hit, the resolver wont change anything.
        return Collision{ .contact_point = contact_point, .contact_normal = contact_normal, .t_hit_near = t_hit_near };
    }

    /// Collision between dynamic (moving) rectangle and static rectangle.
    /// Doesn't work if the "static" rectangle is actually moving
    pub fn collidesDynamicRect(dynamic: CollisionRect, static: CollisionRect) ?Collision {
        // Check if dynamic rectangle is actually moving - we assume rectangles are NOT in collision to start
        if (dynamic.velocity.x == 0 and dynamic.velocity.y == 0) {
            return null;
        }
        // Expand target rectangle by source dimensions
        const expanded_target = CollisionRect.init(
            static.position.subtract(dynamic.size.scale(0.5)),
            static.size.add(dynamic.size),
            Vec2.zero(),
        );
        const collision = expanded_target.collidesRay(dynamic.position.add(dynamic.size.scale(0.5)), dynamic.velocity.subtract(static.velocity));

        if (collision != null and collision.?.t_hit_near >= 0.0 and collision.?.t_hit_near < 1.0) {
            return collision;
        } else {
            return null;
        }
    }

    // Resolve collision
    // This does platformer style "sliding" resolve.
    // Also this assumes that the another rectangle is static
    pub fn resolveDynamicRectCollision(dynamic: CollisionRect, static: CollisionRect) ?Collision {
        var collision = dynamic.collidesDynamicRect(static);
        if (collision != null) {
            // calculate
            //const resolve = collision.?.contact_normal.multiply(dynamic.velocity).scale(1.0 - collision.?.t_hit_near);
            const abs_velocity = Vec2{ .x = math.fabs(dynamic.velocity.x), .y = math.fabs(dynamic.velocity.y) };
            const resolve = collision.?.contact_normal.multiply(abs_velocity).scale(1.0 - collision.?.t_hit_near);
            collision.?.resolve = resolve;
            return collision;
        }
        return null;
    }
};

const expectEqual = std.testing.expectEqual;

test "collidesPoint" {
    const rect = CollisionRect.init(Vec2{ .x = 10, .y = 12 }, Vec2{ .x = 3, .y = 4 }, Vec2.zero());
    try expectEqual(false, rect.collidesPoint(Vec2{ .x = 0, .y = 0 }));
    try expectEqual(true, rect.collidesPoint(Vec2{ .x = 10, .y = 12 }));
    try expectEqual(true, rect.collidesPoint(Vec2{ .x = 11, .y = 13 }));
    try expectEqual(false, rect.collidesPoint(Vec2{ .x = 14, .y = 17 }));
}

test "collidesRect" {
    const rect1 = CollisionRect.init(Vec2{ .x = 10, .y = 12 }, Vec2{ .x = 3, .y = 4 }, Vec2.zero());
    const rect2 = CollisionRect.init(Vec2{ .x = 9, .y = 12 }, Vec2{ .x = 2, .y = 4 }, Vec2.zero());
    const rect3 = CollisionRect.init(Vec2{ .x = 1, .y = 1 }, Vec2{ .x = 3, .y = 4 }, Vec2.zero());
    try expectEqual(true, rect1.collidesRect(rect1));
    try expectEqual(true, rect1.collidesRect(rect2));
    try expectEqual(true, rect2.collidesRect(rect1));

    try expectEqual(false, rect1.collidesRect(rect3));
    try expectEqual(false, rect3.collidesRect(rect1));
}

test "collidesRay" {
    std.debug.print("\n\n", .{});

    const rect1 = CollisionRect.init(Vec2{ .x = 10, .y = 12 }, Vec2{ .x = 3, .y = 4 }, Vec2.zero());
    try expectEqual(false, rect1.collidesRay(Vec2.zero(), Vec2{ .x = -1, .y = -1 }));
    try expectEqual(true, rect1.collidesRay(Vec2.zero(), Vec2{ .x = 1, .y = 1 }));
    try expectEqual(false, rect1.collidesRay(Vec2.zero(), Vec2{ .x = 1, .y = -1 }));
    try expectEqual(false, rect1.collidesRay(Vec2.zero(), Vec2{ .x = 0, .y = 0 }));
}
