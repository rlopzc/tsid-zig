const std = @import("std");
const chm = @import("chm");

const mem = std.mem;
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

    pub fn toString(self: TSID) [13]u8 {
        var str: [13]u8 = undefined;

        str[0] = CROCKFORD_ALPHABET.get(((self.number >> 60) & MASK));
        str[1] = CROCKFORD_ALPHABET.get(((self.number >> 55) & MASK));
        str[2] = CROCKFORD_ALPHABET.get(((self.number >> 50) & MASK));
        str[3] = CROCKFORD_ALPHABET.get(((self.number >> 45) & MASK));
        str[4] = CROCKFORD_ALPHABET.get(((self.number >> 40) & MASK));
        str[5] = CROCKFORD_ALPHABET.get(((self.number >> 35) & MASK));
        str[6] = CROCKFORD_ALPHABET.get(((self.number >> 30) & MASK));
        str[7] = CROCKFORD_ALPHABET.get(((self.number >> 25) & MASK));
        str[8] = CROCKFORD_ALPHABET.get(((self.number >> 20) & MASK));
        str[9] = CROCKFORD_ALPHABET.get(((self.number >> 15) & MASK));
        str[10] = CROCKFORD_ALPHABET.get(((self.number >> 10) & MASK));
        str[11] = CROCKFORD_ALPHABET.get(((self.number >> 5) & MASK));
        str[12] = CROCKFORD_ALPHABET.get(((self.number) & MASK));
    }
};

test "TSID toString" {
    const tsid = TSID.new(612675597969135455);

    std.debug.print("{any}\n", tsid.toString());
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
