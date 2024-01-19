const std = @import("std");
const testing = std.testing;

pub const mem = @import("./mem.zig");

test {
    testing.refAllDecls(@This());
}
