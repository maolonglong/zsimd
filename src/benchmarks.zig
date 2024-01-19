const std = @import("std");
const testing = std.testing;

const bench = @import("bench");
const benchmark = bench.benchmark;

const zsimd = @import("zsimd");

test "benchmark1" {
    try benchmark(struct {
        pub const args = [_][]const u8{
            &([_]u8{ 1, 10, 100 } ** 128),
            &([_]u8{ 1, 10, 100 } ** 256),
            &([_]u8{ 1, 10, 100 } ** 512),
            &([_]u8{ 1, 10, 100 } ** 1024),
            &([_]u8{ 1, 10, 100 } ** 4096),
        };

        pub const arg_names = [_][]const u8{
            "block=128",
            "block=256",
            "block=512",
            "block=1024",
            "block=4096",
        };

        pub const max_iterations = 10000;

        pub fn std_indexOfScalar(slice: []const u8) ?usize {
            return std.mem.indexOfScalar(u8, slice, 2);
        }

        pub fn simd_indexOfScalar(slice: []const u8) ?usize {
            return zsimd.mem.indexOfScalar(u8, slice, 2);
        }

        pub fn std_lastIndexOfScalar(slice: []const u8) ?usize {
            return std.mem.lastIndexOfScalar(u8, slice, 2);
        }

        pub fn simd_lastIndexOfScalar(slice: []const u8) ?usize {
            return zsimd.mem.lastIndexOfScalar(u8, slice, 2);
        }
    });
}

test "benchmark2" {
    try benchmark(struct {
        const Arg = struct {
            a: []const u8,
            b: []const u8,
        };

        pub const args = [_]Arg{
            .{ .a = &([_]u8{ 1, 10, 100 } ** 128 ++ [_]u8{1}), .b = &([_]u8{ 1, 10, 100 } ** 128 ++ [_]u8{2}) },
            .{ .a = &([_]u8{ 1, 10, 100 } ** 256 ++ [_]u8{1}), .b = &([_]u8{ 1, 10, 100 } ** 256 ++ [_]u8{2}) },
            .{ .a = &([_]u8{ 1, 10, 100 } ** 512 ++ [_]u8{1}), .b = &([_]u8{ 1, 10, 100 } ** 512 ++ [_]u8{2}) },
            .{ .a = &([_]u8{ 1, 10, 100 } ** 1024 ++ [_]u8{1}), .b = &([_]u8{ 1, 10, 100 } ** 1024 ++ [_]u8{2}) },
            .{ .a = &([_]u8{ 1, 10, 100 } ** 4096 ++ [_]u8{1}), .b = &([_]u8{ 1, 10, 100 } ** 4096 ++ [_]u8{2}) },
        };

        pub const arg_names = [_][]const u8{
            "block=128",
            "block=256",
            "block=512",
            "block=1024",
            "block=4096",
        };

        pub const max_iterations = 10000;

        pub fn std_eql(arg: Arg) bool {
            return std.mem.eql(u8, arg.a, arg.b);
        }

        pub fn zsimd_eql(arg: Arg) bool {
            return zsimd.mem.eql(u8, arg.a, arg.b);
        }
    });
}
