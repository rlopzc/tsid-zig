const std = @import("std");

const mem = std.mem;
const Factory = @import("factory.zig").Factory;

const testing = std.testing;

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
};

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
