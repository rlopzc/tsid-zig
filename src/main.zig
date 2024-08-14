const std = @import("std");

const testing = std.testing;
const time = std.time;
const log = std.log;
const random = std.crypto.random;
const atomic = std.atomic;

// TSID Epoch 2020-01-01T00:00:00.000Z
const TSID_EPOCH_MILLIS = 1577836800000;
const TIME_BITS = 42;
const RANDOM_BITS = 22;
const RANDOM_MASK = 0x003fffff;

// Node bits
const NODE_BITS_256 = 8;
const NODE_BITS_1024 = 10;
const NODE_BITS_4096 = 12;

// Provide fns that accept as node_id:
// - IPv4
// - IPv6

// Counter bits can be at most 22 bits, according to TSID spec.
const COUNTER_TYPE = u32;

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
    var factory = TsidFactory.init_256_nodes(1);
    const tsid = factory.create();

    try testing.expect(tsid.number == std.mem.bytesToValue(u64, tsid.toBytes()[0..]));
}

pub const TsidFactory = struct {
    node_id: u32,
    node_bits: u8,
    node_mask: u64,
    shifted_node: u64,

    counter_bits: u8,
    counter_mask: u64,
    counter: atomic.Value(COUNTER_TYPE),

    last_time: u64,

    pub fn init(node_id: u32, comptime node_bits: u8) TsidFactory {
        const counter_bits: u8 = RANDOM_BITS - node_bits;
        const counter_mask = RANDOM_MASK >> node_bits;

        const node_mask = RANDOM_MASK >> counter_bits;
        const node = (node_id & node_mask);
        const shifted_node = node << counter_bits;

        return TsidFactory{
            .node_id = node,
            .node_bits = node_bits,
            .node_mask = node_mask,
            .shifted_node = shifted_node,

            .counter_bits = counter_bits,
            .counter_mask = counter_mask,
            .counter = atomic.Value(COUNTER_TYPE).init(random.int(COUNTER_TYPE)),

            .last_time = getTimeMillisSinceTsidEpoch(),
        };
    }

    pub fn init_256_nodes(node_id: u32) TsidFactory {
        return init(node_id, NODE_BITS_256);
    }

    pub fn init_1024_nodes(node_id: u32) TsidFactory {
        return init(node_id, NODE_BITS_1024);
    }

    pub fn init_4096_nodes(node_id: u32) TsidFactory {
        return init(node_id, NODE_BITS_4096);
    }

    pub fn create(self: *TsidFactory) TSID {
        var current_time = getTimeMillisSinceTsidEpoch();

        var counter: COUNTER_TYPE = 0;
        if (current_time <= self.last_time) {
            counter = self.counter.fetchAdd(1, .monotonic);
            // If counter overflows, increase time.
            const carry: u1 = if ((counter >> @intCast(self.counter_bits)) > 0) 1 else 0;
            current_time = self.last_time + carry;
        } else {
            counter = self.counter.swap(random.int(COUNTER_TYPE), .monotonic);
        }

        self.last_time = current_time;
        counter &= @intCast(self.counter_mask);
        const shifted_time = (current_time << RANDOM_BITS);

        //           |--- time ---|------- node ------| counter |
        const tsid = shifted_time | self.shifted_node | counter;
        return TSID.new(tsid);
    }

    pub fn getTimeMillisSinceTsidEpoch() u64 {
        const now: u64 = @intCast(time.milliTimestamp());
        return now - TSID_EPOCH_MILLIS;
    }
};

//
// Enable debug logs inside a test with:
// std.testing.log_level = .debug;
//

test "Tsid for 256 nodes, bits and masks are correctly set" {
    // |------------------------------------------|----------|------------|
    //        time (msecs since 2020-01-01)           node       counter
    //                 42 bits                       8 bits      14 bits
    const factory = TsidFactory.init_256_nodes(1);

    // Node ID = 1
    try testing.expect(factory.node_id == 1);
    // 256 nodes = 8 bits
    try testing.expect(factory.node_bits == 8);
    // 0x003fffff >> 14. Shifted right cause there's no need for a bigger mask for all possible nodes (8 bits).
    try testing.expect(factory.node_mask == 0x000000ff);
    // node << 14. Shifted left so counter can accomodate all of it's bits (14 bits).
    try testing.expect(factory.shifted_node == 0x0000000000004000);
    // counter_bits = 14 (random_bits - 8)
    try testing.expect(factory.counter_bits == 14);
    // 0x003fffff >> 8. Shifted right cause there's no need for a bigger mask for all possible counts (14 bits).
    try testing.expect(factory.counter_mask == 0x00003fff);
    // 64 bits in use
    try testing.expect(64 == TIME_BITS + factory.node_bits + factory.counter_bits);
}

test "Tsid for 1024 nodes, bits and masks are correctly set" {
    // |------------------------------------------|----------|------------|
    //        time (msecs since 2020-01-01)           node       counter
    //                 42 bits                       10 bits     12 bits
    const factory = TsidFactory.init_1024_nodes(1);

    // Node ID = 1
    try testing.expect(factory.node_id == 1);
    // 1024 nodes = 10 bits
    try testing.expect(factory.node_bits == 10);
    // 0x003fffff >> 12. Shifted right cause there's no need for a bigger mask for all possible nodes (10 bits).
    try testing.expect(factory.node_mask == 0x000003ff);
    // node << 12. Shifted left so counter can accomodate all of it's bits (12 bits).
    try testing.expect(factory.shifted_node == 0x0000000000001000);
    // counter_bits = 12 (random_bits - 10)
    try testing.expect(factory.counter_bits == 12);
    // 0x003fffff >> 10. Shifted right cause there's no need for a bigger mask for all possible counts (12 bits).
    try testing.expect(factory.counter_mask == 0x00000fff);
    // 64 bits in use
    try testing.expect(64 == TIME_BITS + factory.node_bits + factory.counter_bits);
}

test "Tsid for 4096 nodes, bits and masks are correctly set" {
    // |------------------------------------------|----------|------------|
    //        time (msecs since 2020-01-01)           node       counter
    //                 42 bits                       12 bits     10 bits
    const factory = TsidFactory.init_4096_nodes(1);

    // Node ID = 1
    try testing.expect(factory.node_id == 1);
    // 4096 nodes = 12 bits
    try testing.expect(factory.node_bits == 12);
    // 0x003fffff >> 10. Shifted right cause there's no need for a bigger mask for all possible nodes (12 bits).
    try testing.expect(factory.node_mask == 0x00000fff);
    // node << 10. Shifted left so counter can accomodate all of it's bits (10 bits).
    try testing.expect(factory.shifted_node == 0x0000000000000400);
    // counter_bits = 10 (random_bits - 12)
    try testing.expect(factory.counter_bits == 10);
    // 0x003fffff >> 12. Shifted right cause there's no need for a bigger mask for all possible counts (10 bits).
    try testing.expect(factory.counter_mask == 0x000003ff);
    // 64 bits in use
    try testing.expect(64 == TIME_BITS + factory.node_bits + factory.counter_bits);
}

test "Tsid encodes time, node, and counter in the 64 bits" {
    var factory = TsidFactory.init_1024_nodes(567);

    // 42 bits for time
    // Adjust time millis in case of overflow
    const tsid_time: u64 = @intCast(factory.create().number >> RANDOM_BITS);
    const time_diff = tsid_time - TsidFactory.getTimeMillisSinceTsidEpoch();
    try testing.expect(time_diff == 0 or time_diff == 1);

    // 10 bits for node (1024 nodes)
    try testing.expect(567 == ((factory.create().number >> 12) & factory.node_mask));

    // 12 bits for counter
    try testing.expect((factory.create().number & factory.counter_mask) != factory.create().number & factory.counter_mask);
}

test "Tsid creates incremental values each time" {
    var factory = TsidFactory.init_4096_nodes(1);

    var last_id: TSID = factory.create();
    var i: usize = 0;
    while (i < 100_000) : (i += 1) {
        const id: TSID = factory.create();
        try testing.expect(last_id.number < id.number);
        last_id = id;
    }
}

test "UNIX Epoch is after getTimeMillisSinceTsidEpoch" {
    const unix_epoch = time.milliTimestamp();
    const time_tsid = TsidFactory.getTimeMillisSinceTsidEpoch();

    try testing.expect(unix_epoch > time_tsid);
}
