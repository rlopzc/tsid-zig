const std = @import("std");

const testing = std.testing;
const time = std.time;
const log = std.log;
const random = std.crypto.random;
const atomic = std.atomic;

// TSID Epoch 2020-01-01T00:00:00.000Z
const TSID_EPOCH_MILLIS = 1577836800000;
const RANDOM_BITS = 22;
const RANDOM_MASK = 0x003fffff;

// Node bits
const NODE_BITS_256 = 8;
const NODE_BITS_1024 = 10;
const NODE_BITS_4096 = 12;

// Provide fns that accept
// - IPv4
// - IPv6
// Convert identifiers into node_id

const Tsid = struct {
    node: u32,
    node_bits: u8,
    node_mask: u64,
    node_val: u64,
    counter_bits: u8,
    counter_mask: u64,
    counter: atomic.Value(u64),

    fn init(node_id: u32, comptime node_bits: u8) Tsid {
        const counter_bits: u8 = RANDOM_BITS - node_bits;
        const counter_mask: u64 = RANDOM_MASK >> node_bits;

        const node_mask = RANDOM_MASK >> counter_bits;
        const node = node_id & node_mask;

        return Tsid{
            .node = node,
            .node_bits = node_bits,
            .node_mask = node_mask,
            .node_val = node << counter_bits,

            .counter_bits = counter_bits,
            .counter_mask = counter_mask,
            .counter = atomic.Value(u64).init(0),
        };
    }

    fn init_256_nodes(node_id: u32) Tsid {
        return init(node_id, NODE_BITS_256);
    }

    fn init_1024_nodes(node_id: u32) Tsid {
        return init(node_id, NODE_BITS_1024);
    }

    fn init_4096_nodes(node_id: u32) Tsid {
        return init(node_id, NODE_BITS_4096);
    }

    fn create(self: *Tsid) u64 {
        const current_time: u64 = getTimeMillisSinceTsidEpoch() << RANDOM_BITS;
        const counter: u64 = self.increaseCounter() & self.counter_mask;
        const tsid = current_time | self.node_val | counter;

        return tsid;
    }

    fn increaseCounter(self: *Tsid) u64 {
        // No ordering necessary; just updating a counter.
        return self.counter.fetchAdd(1, .monotonic);
    }

    fn getTimeMillisSinceTsidEpoch() u64 {
        const now: u64 = @intCast(time.milliTimestamp());
        return now - TSID_EPOCH_MILLIS;
    }
};

test "Tsid for 256 nodes, bits and masks are correctly set" {
    // |------------------------------------------|----------|------------|
    //        time (msecs since 2020-01-01)           node       counter
    //                 42 bits                       8 bits      14 bits
    const tsid = Tsid.init_256_nodes(1);

    // Node ID = 1
    try testing.expect(tsid.node == 1);
    // 256 nodes = 8 bits
    try testing.expect(tsid.node_bits == 8);
    // 0x003fffff >> 14. Shifted right cause there's no need for a bigger mask for all possible nodes (8 bits).
    try testing.expect(tsid.node_mask == 0x000000ff);
    // node << 14. Shifted left so counter can accomodate all of it's bits.
    try testing.expect(tsid.node_val == 0x0000000000004000);
    // counter_bits = 14 (random_bits - 8)
    try testing.expect(tsid.counter_bits == 14);
    // 0x003fffff >> 8. Shifted right cause there's no need for a bigger mask for all possible counts (14 bits).
    try testing.expect(tsid.counter_mask == 0x00003fff);
    // counter starts at 0.
    try testing.expect(tsid.counter.load(.monotonic) == 0);
}

test "Tsid creates different values each time" {
    var tsid = Tsid.init_256_nodes(1);

    var i: usize = 0;
    while (i < 100) : (i += 1) {
        const tsid1 = tsid.create();
        const tsid2 = tsid.create();

        try testing.expect(tsid1 != tsid2);
    }
}

test "UNIX Epoch is after getTimeMillisSinceTsidEpoch" {
    const unix_epoch = time.milliTimestamp();
    const time_tsid = Tsid.getTimeMillisSinceTsidEpoch();

    try testing.expect(unix_epoch > time_tsid);
}
