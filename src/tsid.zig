const std = @import("std");
const chm = @import("chm");

const mem = std.mem;
const fmt = std.fmt;
const Factory = @import("factory.zig").Factory;

const testing = std.testing;

const MASK = 0b11111;

const CROCKFORD_ALPHABET = chm.AutoComptimeHashMap(u8, u8, .{
    .{ 0b00000, '0' },
    .{ 0b00001, '1' },
    .{ 0b00010, '2' },
    .{ 0b00011, '3' },
    .{ 0b00100, '4' },
    .{ 0b00101, '5' },
    .{ 0b00110, '6' },
    .{ 0b00111, '7' },
    .{ 0b01000, '8' },
    .{ 0b01001, '9' },
    .{ 0b01010, 'A' },
    .{ 0b01011, 'B' },
    .{ 0b01100, 'C' },
    .{ 0b01101, 'D' },
    .{ 0b01110, 'E' },
    .{ 0b01111, 'F' },
    .{ 0b10000, 'G' },
    .{ 0b10001, 'H' },
    .{ 0b10010, 'J' },
    .{ 0b10011, 'K' },
    .{ 0b10100, 'M' },
    .{ 0b10101, 'N' },
    .{ 0b10110, 'P' },
    .{ 0b10111, 'Q' },
    .{ 0b11000, 'R' },
    .{ 0b11001, 'S' },
    .{ 0b11010, 'T' },
    .{ 0b11011, 'V' },
    .{ 0b11100, 'W' },
    .{ 0b11101, 'X' },
    .{ 0b11110, 'Y' },
    .{ 0b11111, 'Z' },
});

pub const TSID = struct {
    number: u64,

    pub fn new(number: u64) TSID {
        return TSID{ .number = number };
    }

    pub fn toBytes(self: TSID) [8]u8 {
        return mem.toBytes(self.number);
    }

    pub fn fromBytes(bytes: [8]u8) TSID {
        return TSID{ .number = mem.bytesToValue(u64, bytes[0..8]) };
    }

    pub fn toString(self: TSID) ![13]u8 {
        var adjusted_tsid: [65]u8 = undefined;
        _ = try fmt.bufPrint(&adjusted_tsid, "{b:0>65}", .{self.number});

        var str: [13]u8 = undefined;
        for (&str, 0..) |*c, i| {
            const idx = i * 5;
            const bits = try fmt.parseInt(u8, adjusted_tsid[idx..(idx + 5)], 2);

            c.* = CROCKFORD_ALPHABET.get(bits).?.*;
        }

        return str;
    }
};

test "TSID toString" {
    const tsid = TSID.new(612675597969135455);
    const tsid_string = try tsid.toString();

    try testing.expectEqualStrings("0H0596Q9R05TZ", &tsid_string);
}

test "TSID new" {
    const number: u64 = 999;

    try testing.expect(number == TSID.new(number).number);
}

test "TSID toBytes" {
    var factory = Factory.init_256_nodes(1);
    const tsid = factory.create();

    try testing.expect(tsid.number == mem.bytesToValue(u64, tsid.toBytes()[0..]));
}

test "TSID fromBytes" {
    var factory = Factory.init_256_nodes(1);
    const tsid = factory.create();

    try testing.expect(tsid.number == TSID.fromBytes(tsid.toBytes()).number);
}
