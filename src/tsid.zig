const std = @import("std");
const Factory = @import("factory.zig").Factory;

const testing = std.testing;

pub const TSID = struct {
    number: u64,

    pub fn new(number: u64) TSID {
        return TSID{ .number = number };
    }

    pub fn toBytes(self: TSID) [8]u8 {
        return std.mem.toBytes(self.number);
    }
};

test "TSID toBytes" {
    var factory = Factory.init_256_nodes(1);
    const tsid = factory.create();

    try testing.expect(tsid.number == std.mem.bytesToValue(u64, tsid.toBytes()[0..]));
}
