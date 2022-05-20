pub const Shape = struct {
    pixel_data: *const [] const u8,
    width: u16,
    height: u16,
    frames: u16,

    pub fn init(pixel_data: *const [] const u8, width: u16, height: u16, frames: u16) Shape {
        return Shape{.pixel_data = pixel_data, .width = width, .height = height, .frames = frames};
    }
};

pub const smiley = Shape.init(&smiley_pixels, 8, 8, 3);
pub const ground_block = Shape.init(&block_pixels, 8, 8, 1);
pub const big_block = Shape.init(&big_block_pixels, 16, 16, 1);

const smiley_pixels: [] const u8 = &[_]u8{
    0b11000011,
    0b10000001,
    0b00100100,
    0b00100100,
    0b00000000,
    0b00100100,
    0b10011001,
    0b11000011,

    0b11000011,
    0b10000001,
    0b01100110,
    0b00100100,
    0b00000000,
    0b00111100,
    0b10000001,
    0b11000011,

    0b11000011,
    0b10000001,
    0b01000010,
    0b00100100,
    0b00000000,
    0b00011000,
    0b10100101,
    0b11000011,
};

const block_pixels: [] const u8 = &.{
    0b11111111,
    0b10000000,
    0b10000000,
    0b10000000,
    0b10000000,
    0b10000000,
    0b10000000,
    0b11111111,
};

const big_block_pixels: [] const u8 = &.{
    0b11111111, 0b11111111,
    0b11111111, 0b11111111,
    0b10111111, 0b11101111,
    0b11111111, 0b11111111,

    0b11111111, 0b11111111,
    0b11111111, 0b11111111,
    0b11111111, 0b11111111,
    0b11111111, 0b11111111,

    0b11111111, 0b11111111,
    0b11111111, 0b11111111,
    0b11111111, 0b11111111,
    0b11111111, 0b11111111,

    0b11111111, 0b11111111,
    0b11111111, 0b11111111,
    0b11111111, 0b11111111,
    0b11111111, 0b11111111,
};

