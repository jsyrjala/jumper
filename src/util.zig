const std = @import("std");
const w4 = @import("wasm4.zig");

/// Logs to terminal. Will break if trying to log too long a message.
pub fn log(comptime fmt: []const u8, args: anytype) !void {
    var buffer: [1000]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const stackAlloc = fba.allocator();
    const str = try std.fmt.allocPrint(stackAlloc, fmt, args);
    w4.trace(str);
}
