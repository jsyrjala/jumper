const w4 = @import("wasm4.zig");
const EntityID = @import("ecs/entities.zig").EntityID;
const util = @import("util.zig");

pub const Player = struct {
    index: u16,
    entity: EntityID,
    prev_gamepad: u8,
        counter: u32,


    pub fn init(index: u16, entity: EntityID) Player {
        return Player{
            .index = index, 
            .entity = entity, 
            .prev_gamepad = 0,
            .counter = 1,
        };
    }

    pub fn input(self: *Player) Input {
        const gamepad = w4.GAMEPADS[self.index];
        //const just_pressed = gamepad & (gamepad ^ self.prev_gamepad);
        const changed = gamepad != self.prev_gamepad;
        self.prev_gamepad = gamepad;
        return Input{
            .up = w4.BUTTON_UP & gamepad != 0,
            .down = w4.BUTTON_DOWN & gamepad != 0,
            .left = w4.BUTTON_LEFT & gamepad != 0,
            .right = w4.BUTTON_RIGHT & gamepad != 0,
            .button_1 = w4.BUTTON_1 & gamepad != 0,
            .button_2 = w4.BUTTON_2 & gamepad != 0,
            .any_button = gamepad != 0,
            .changed = changed,
        };
    }
};

const Input = struct {
    up: bool,
    down: bool,
    left: bool,
    right: bool,
    button_1: bool,
    button_2: bool,
    any_button: bool,
    changed: bool,
};

pub fn playerInput(player: *Player) void {
    const gamepad = w4.GAMEPADS[player.index];
    //const just_pressed = gamepad & (gamepad ^ self.prev_gamepad);
    const changed = gamepad != player.prev_gamepad;
    util.log("Changed:  {}, {} prev {}", .{player, gamepad, player.prev_gamepad}) catch {};
    const input = Input{
        .up = w4.BUTTON_UP & gamepad != 0,
        .down = w4.BUTTON_DOWN & gamepad != 0,
        .left = w4.BUTTON_LEFT & gamepad != 0,
        .right = w4.BUTTON_RIGHT & gamepad != 0,
        .button_1 = w4.BUTTON_1 & gamepad != 0,
        .button_2 = w4.BUTTON_2 & gamepad != 0,
        .any_button = gamepad != 0,
        .changed = changed,
    };
    util.log("Input: {} gamepad: {} prev {}", .{input, gamepad, player.prev_gamepad}) catch {};
    player.prev_gamepad = gamepad;


}