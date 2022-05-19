const math = @import("std").math;
const util = @import("util.zig");

pub const Vec2 = struct {
    x: f32,
    y: f32,

    pub fn zero() Vec2 {
        return Vec2{.x = 0, .y =0};
    }

    pub fn length(self: Vec2) f32 {
        return math.hypot(f32, self.x, self.y);
    }

    pub fn normalize(self: Vec2) Vec2 {
        const l = self.length();
        if (l == 0) {
            return Vec2{
                .x = 0,
                .y = 0,
            };
        }
        return Vec2{
            .x = self.x / l,
            .y = self.y / l,
        };
    }

    pub fn negate(self: Vec2) Vec2 {
        return Vec2{.x = self.x * -1, .y = self.y * -1};
    }

    pub fn scale(self: Vec2, scalar: f32) Vec2 {
        return Vec2{
            .x = self.x * scalar,
            .y = self.y * scalar,
        };
    }

    pub fn add(self: Vec2, other: Vec2) Vec2 {
        return Vec2{
            .x = self.x + other.x,
            .y = self.y + other.y,
        };
    }

    pub fn subtract(self: Vec2, other: Vec2) Vec2 {
        return Vec2{
            .x = self.x - other.x,
            .y = self.y - other.y,
        };
    }

    pub fn multiply(self: Vec2, other: Vec2) Vec2 {
        return Vec2 {
            .x = self.x * other.x,
            .y = self.y * other.y
        };
    }

    pub fn dot(self: Vec2, other: Vec2) f32 {
        return self.x * other.x + self.y * other.y;
    }

    pub fn reflect(self: Vec2, normal: Vec2) Vec2 {
       return self.add(normal.scale(-1).scale(2 * self.dot(normal)));
    }

    pub fn clampX(self: Vec2, min: f32, max: f32) Vec2 {
        return Vec2{.x = math.clamp(self.x, min, max), .y = self.y};
    }

    pub fn clampY(self: Vec2, min: f32, max: f32) Vec2 {
        return Vec2{.x = self.x, .y = math.clamp(self.y, min, max)};
    }

};


pub const Rect = struct {
    position: Vec2,
    size: Vec2,

    pub fn move(rect: *Rect, delta: Vec2) Rect {
        return Rect {
            .position = rect.position.add(delta),
            .size = rect.size
        };
    }

    pub fn rectOverlap(rectA: *Rect, rectB: Rect) ?Rect {
        const intersectionX1 = math.max(rectA.position.x, rectB.position.x);
        const intersectionX2 = math.min(rectA.position.x + rectA.size.x, rectB.position.x + rectB.size.x);
        if (intersectionX2 < intersectionX1) {
            return null;
        }
        const intersectionY1 = math.max(rectA.position.y, rectB.position.y);
        const intersectionY2 = math.min(rectA.position.y + rectA.size.y, rectB.position.y + rectB.size.y);
        if (intersectionY2 < intersectionY1) {
            return null;
        }
        return Rect {
            .position = Vec2 {.x = intersectionX1, .y = intersectionY1 },
            .size = Vec2 {.x = intersectionX2 - intersectionX1, .y = intersectionY2 - intersectionY1 },
        };
    }

    pub fn collisionNormal(ball: *Rect, player: *Rect) !Vec2 {
        const ballCenter = Vec2{
            .x = ball.position.x + ball.size.x / 2.0,
            .y = ball.position.y + ball.size.y / 2.0,
        };
        const playerCenter = Vec2{
            .x = player.position.x + player.size.x / 2.0,
            .y = player.position.y + player.size.y / 2.0,
        };
        var normal = Vec2{ .x = 0, .y = -1 };
        if (ballCenter.x >= player.position.x and ballCenter.x <= player.position.x + player.size.x) {
            // top or bottom hit
            if (ballCenter.y <= playerCenter.y) {
                // top hit
                // top has "curved surface"
                const x = mapValue(ballCenter.x, player.position.x, player.position.x + player.size.x, -1, 1);
                normal = Vec2{ .x = x, .y = -2 };
            } else {
                // bottom hit
                normal = Vec2{ .x = 0, .y = 1 };
            }
        } else if (ballCenter.y >= player.position.y and ballCenter.y <= player.position.y + player.size.y) {
            // left or right hit
            if (ballCenter.x <= playerCenter.x) {
                normal = Vec2{ .x = -1, .y = 0 };
            } else {
                normal = Vec2{ .x = 1, .y = 0 };
            }
        } 
        // corner hits, ball center out side of player x or y range, point normal to diagonals
        else if (ballCenter.y <= player.position.y) {
            if (ballCenter.x < player.position.x) {
                normal = Vec2{ .x = -1, .y = -1 };
            } else if (ballCenter.x >= player.position.x + player.size.x) {
                normal = Vec2{ .x = 1, .y = -1 };
            }
            const x = mapValue(ballCenter.x, player.position.x, player.position.x + player.size.x, -1, 1);
            normal = Vec2{ .x = x, .y = -2 };
        } else if (ballCenter.y >= player.position.y + player.size.y) {
            if (ballCenter.x < player.position.x) {
                normal = Vec2{ .x = -1, .y = 1 };
            }
            if (ballCenter.x > player.position.x + player.size.x) {
                normal = Vec2{ .x = 1, .y = 1 };
            }
            normal = Vec2{ .x = 0, .y = 1 };
        } else {
            try util.log("this should never happen", .{});
        }
        return normal.normalize();
    }

};


/// Linear interpolation between a b.
/// t is parametric value. 
pub fn lerp(t: f32, a: f32, b: f32) f32 {
    return (b - a) * t + a;
}

pub fn lerpClamp(t: f32, a: f32, b: f32) f32 {
    return math.clamp(lerp(t, a, b), a, b);
}

pub fn mapValue(t: f32, tmin: f32, tmax: f32, rmin: f32, rmax: f32) f32 {
    const paramt = (t - tmin) / (tmax - tmin);
    return lerp(paramt, rmin, rmax);
}

const testing = @import("std").testing;
const expectEqual = testing.expectEqual;

test "lerp" {
    try expectEqual(@as(f32, 2.5), lerp(0.25, 2, 4));
    try expectEqual(@as(f32, 4), lerp(1.0, 2, 4));
    try expectEqual(@as(f32, 2), lerp(0.0, 2, 4));
    try expectEqual(@as(f32, 0), lerp(-1.0, 2, 4));
    try expectEqual(@as(f32, 6), lerp(2, 2, 4));
}

test "lerpClamp" {
    try expectEqual(@as(f32, 2.5), lerpClamp(0.25, 2, 4));
    try expectEqual(@as(f32, 4), lerpClamp(1.0, 2, 4));
    try expectEqual(@as(f32, 2), lerpClamp(0.0, 2, 4));
    try expectEqual(@as(f32, 2), lerpClamp(-1.0, 2, 4));
    try expectEqual(@as(f32, 4), lerpClamp(2, 2, 4));
}

test "mapValue" {
    try expectEqual(@as(f32, 2.5), mapValue(0.25, 0, 1, 2, 4));
    try expectEqual(@as(f32, 4), mapValue(1.0, 0, 1, 2, 4));
    try expectEqual(@as(f32, 2), mapValue(0.0, 0, 1, 2, 4));
    try expectEqual(@as(f32, 0), mapValue(-1.0, 0, 1, 2, 4));
    try expectEqual(@as(f32, 6), mapValue(2, 0, 1, 2, 4));
}
