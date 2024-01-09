const std = @import("std");
const simd = std.simd;
const testing = std.testing;

/// Linear search for the index of a scalar value inside a slice.
pub fn indexOfScalar(comptime T: type, slice: []const T, value: T) ?usize {
    return indexOfScalarPos(T, slice, 0, value);
}

pub fn indexOfScalarPos(comptime T: type, slice: []const T, start_index: usize, value: T) ?usize {
    const vector_len: comptime_int = comptime simd.suggestVectorSize(T).?;
    const V = @Vector(vector_len, T);
    const IndexInt = simd.VectorIndex(V);

    const needle: V = @splat(value);
    const all_max: @Vector(vector_len, IndexInt) = @splat(~@as(IndexInt, 0));
    const indices = simd.iota(IndexInt, vector_len);

    var i = start_index;
    while (i < slice.len) {
        if (slice.len - i < vector_len)
            return std.mem.indexOfScalarPos(T, slice, i, value);

        const haystack: V = slice[i..][0..vector_len].*;
        const pred = haystack == needle;

        if (@reduce(.Or, pred)) {
            const result = @select(IndexInt, pred, indices, all_max);
            return i + @reduce(.Min, result);
        }

        i += vector_len;
    }

    return null;
}

/// Linear search for the last index of a scalar value inside a slice.
pub fn lastIndexOfScalar(comptime T: type, slice: []const T, value: T) ?usize {
    const vector_len: comptime_int = comptime simd.suggestVectorSize(T).?;
    const V = @Vector(vector_len, T);
    const IndexInt = simd.VectorIndex(V);

    const needle: V = @splat(value);
    const all_zeroes: @Vector(vector_len, IndexInt) = @splat(0);
    const indices = simd.iota(IndexInt, vector_len);

    var i = slice.len;
    while (i > 0) : (i -= vector_len) {
        if (i < vector_len) {
            while (i != 0) {
                i -= 1;
                if (slice[i] == value) return i;
            }
            return null;
        }

        const haystack: V = slice[i - vector_len .. i][0..vector_len].*;
        const pred = haystack == needle;

        if (@reduce(.Or, pred)) {
            const result = @select(IndexInt, pred, indices, all_zeroes);
            return i - vector_len + @reduce(.Max, result);
        }
    }

    return null;
}

/// Compares two slices and returns whether they are equal.
pub fn eql(comptime T: type, a: []const T, b: []const T) bool {
    if (a.len != b.len) return false;
    if (a.ptr == b.ptr) return true;

    const vector_len: comptime_int = comptime simd.suggestVectorSize(T).?;
    const V = @Vector(vector_len, T);

    var i: usize = 0;
    while (i < a.len) : (i += vector_len) {
        if (a.len - i < vector_len)
            return std.mem.eql(T, a[i..], b[i..]);

        const a_vec: V = a[i..][0..vector_len].*;
        const b_vec: V = b[i..][0..vector_len].*;
        if (!@reduce(.And, a_vec == b_vec)) {
            return false;
        }
    }

    return true;
}

test "indexOfScalar" {
    var rnd = std.rand.DefaultPrng.init(0);
    var buf: [1024]u8 = undefined;
    for (0..10000) |_| {
        const len = rnd.random().intRangeLessThan(usize, 1, 1024);
        const haystack = buf[0..len];
        rnd.random().bytes(haystack);
        const needle = rnd.random().int(u8);
        try testing.expectEqual(std.mem.indexOfScalar(u8, haystack, needle), indexOfScalar(u8, haystack, needle));
    }
}

test "lastIndexOfScalar" {
    try testing.expectEqual(@as(?usize, 0), lastIndexOfScalar(u8, "foobar", 'f'));
    try testing.expectEqual(@as(?usize, 99), lastIndexOfScalar(u8, "A" ** 100, 'A'));

    try testing.expectEqual(@as(?usize, 1000), lastIndexOfScalar(u8, "A" ** 1000 ++ "B" ++ "A" ** 1000, 'B'));
    try testing.expectEqual(@as(?usize, 1001), lastIndexOfScalar(u8, "A" ** 1001 ++ "B" ++ "A" ** 1000, 'B'));
    try testing.expectEqual(@as(?usize, 1002), lastIndexOfScalar(u8, "A" ** 1002 ++ "B" ++ "A" ** 1000, 'B'));
    try testing.expectEqual(@as(?usize, 1003), lastIndexOfScalar(u8, "A" ** 1003 ++ "B" ++ "A" ** 1000, 'B'));
    try testing.expectEqual(@as(?usize, 1004), lastIndexOfScalar(u8, "A" ** 1004 ++ "B" ++ "A" ** 1000, 'B'));
    try testing.expectEqual(@as(?usize, 1005), lastIndexOfScalar(u8, "A" ** 1005 ++ "B" ++ "A" ** 1000, 'B'));
    try testing.expectEqual(@as(?usize, 1006), lastIndexOfScalar(u8, "A" ** 1006 ++ "B" ++ "A" ** 1000, 'B'));
    try testing.expectEqual(@as(?usize, 1007), lastIndexOfScalar(u8, "A" ** 1007 ++ "B" ++ "A" ** 1000, 'B'));
    try testing.expectEqual(@as(?usize, 1008), lastIndexOfScalar(u8, "A" ** 1008 ++ "B" ++ "A" ** 1000, 'B'));

    try testing.expectEqual(@as(?usize, 1009), lastIndexOfScalar(u8, "A" ** 1008 ++ "BB" ++ "A" ** 1000, 'B'));
    try testing.expectEqual(@as(?usize, null), lastIndexOfScalar(u8, "A" ** 62 ++ "BB" ++ "A" ** 64, 'C'));
    try testing.expectEqual(@as(?usize, 0), lastIndexOfScalar(u8, "C" ++ "A" ** 1008 ++ "BB" ++ "A" ** 1000, 'C'));

    var rnd = std.rand.DefaultPrng.init(0);
    var buf: [1024]u8 = undefined;
    for (0..10000) |_| {
        const len = rnd.random().intRangeLessThan(usize, 1, 1024);
        const haystack = buf[0..len];
        rnd.random().bytes(haystack);
        const needle = rnd.random().int(u8);
        try testing.expectEqual(std.mem.lastIndexOfScalar(u8, haystack, needle), lastIndexOfScalar(u8, haystack, needle));
    }
}

test "eql" {
    var rnd = std.rand.DefaultPrng.init(0);
    var buf: [1024]u8 = undefined;
    var buf2: [1024]u8 = undefined;
    for (0..10000) |_| {
        const len = rnd.random().intRangeLessThan(usize, 1, 1024);
        const a = buf[0..len];
        const b = buf2[0..len];
        rnd.random().bytes(a);
        @memcpy(b, a);
        try testing.expectEqual(std.mem.eql(u8, a, b), eql(u8, a, b));
    }
    for (0..10000) |_| {
        const len = rnd.random().intRangeLessThan(usize, 1, 1024);
        const a = buf[0..len];
        const b = buf2[0..len];
        rnd.random().bytes(a);
        rnd.random().bytes(b);
        try testing.expectEqual(std.mem.eql(u8, a, b), eql(u8, a, b));
    }
}
