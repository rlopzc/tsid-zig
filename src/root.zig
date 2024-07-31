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

// Provide fns that accept as node_id:
// - IPv4
// - IPv6

const Tsid = struct {
    node_id: u32,
    node_bits: u8,
    node_mask: u64,
    node: u64,
    counter_bits: u8,
    counter_mask: u64,
    counter: atomic.Value(u64),
    last_time: u64,

    fn init(node_id: u32, comptime node_bits: u8) Tsid {
        const counter_bits: u8 = RANDOM_BITS - node_bits;
        const counter_mask: u64 = RANDOM_MASK >> node_bits;

        const node_mask = RANDOM_MASK >> counter_bits;
        const node = node_id & node_mask;
        const counter = random.int(u64);

        return Tsid{
            .node_id = node,
            .node_bits = node_bits,
            .node_mask = node_mask,
            .node = node << counter_bits,

            .counter_bits = counter_bits,
            .counter_mask = counter_mask,
            .counter = atomic.Value(u64).init(counter),

            .last_time = getTimeMillisSinceTsidEpoch(),
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

    fn generate(self: *Tsid) u64 {
        const current_time = getTimeMillisSinceTsidEpoch();

        var counter: u64 = 0;
        if (current_time <= self.last_time) {
            counter = self.counter.fetchAdd(1, .monotonic);
        } else {
            const random_number = random.int(u64);
            _ = self.counter.swap(random_number, .monotonic);
            counter = random_number;
        }
        self.last_time = current_time;

        counter &= self.counter_mask;
        const tsid = (current_time << RANDOM_BITS) | self.node | counter;

        return tsid;
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
    try testing.expect(tsid.node_id == 1);
    // 256 nodes = 8 bits
    try testing.expect(tsid.node_bits == 8);
    // 0x003fffff >> 14. Shifted right cause there's no need for a bigger mask for all possible nodes (8 bits).
    try testing.expect(tsid.node_mask == 0x000000ff);
    // node << 14. Shifted left so counter can accomodate all of it's bits (14 bits).
    try testing.expect(tsid.node == 0x0000000000004000);
    // counter_bits = 14 (random_bits - 8)
    try testing.expect(tsid.counter_bits == 14);
    // 0x003fffff >> 8. Shifted right cause there's no need for a bigger mask for all possible counts (14 bits).
    try testing.expect(tsid.counter_mask == 0x00003fff);
}

test "Tsid for 1024 nodes, bits and masks are correctly set" {
    // |------------------------------------------|----------|------------|
    //        time (msecs since 2020-01-01)           node       counter
    //                 42 bits                      10 bits      12 bits
    const tsid = Tsid.init_1024_nodes(1);

    // Node ID = 1
    try testing.expect(tsid.node_id == 1);
    // 1024 nodes = 10 bits
    try testing.expect(tsid.node_bits == 10);
    // 0x003fffff >> 12. Shifted right cause there's no need for a bigger mask for all possible nodes (10 bits).
    try testing.expect(tsid.node_mask == 0x000003ff);
    // node << 12. Shifted left so counter can accomodate all of it's bits (12 bits).
    try testing.expect(tsid.node == 0x0000000000001000);
    // counter_bits = 12 (random_bits - 10)
    try testing.expect(tsid.counter_bits == 12);
    // 0x003fffff >> 10. Shifted right cause there's no need for a bigger mask for all possible counts (12 bits).
    try testing.expect(tsid.counter_mask == 0x00000fff);
}

test "Tsid for 4096 nodes, bits and masks are correctly set" {
    // |------------------------------------------|----------|------------|
    //        time (msecs since 2020-01-01)           node       counter
    //                 42 bits                      12 bits      10 bits
    const tsid = Tsid.init_4096_nodes(1);

    // Node ID = 1
    try testing.expect(tsid.node_id == 1);
    // 4096 nodes = 12 bits
    try testing.expect(tsid.node_bits == 12);
    // 0x003fffff >> 10. Shifted right cause there's no need for a bigger mask for all possible nodes (12 bits).
    try testing.expect(tsid.node_mask == 0x00000fff);
    // node << 10. Shifted left so counter can accomodate all of it's bits (10 bits).
    try testing.expect(tsid.node == 0x0000000000000400);
    // counter_bits = 10 (random_bits - 12)
    try testing.expect(tsid.counter_bits == 10);
    // 0x003fffff >> 12. Shifted right cause there's no need for a bigger mask for all possible counts (10 bits).
    try testing.expect(tsid.counter_mask == 0x000003ff);
}

test "Tsid encodes time, node, and counter in it's 64 bits" {
    var tsid = Tsid.init_1024_nodes(567);

    // 42 bits for time
    try testing.expect(Tsid.getTimeMillisSinceTsidEpoch() == tsid.generate() >> RANDOM_BITS);

    // 10 bits for node (1024 nodes)
    try testing.expect(567 == ((tsid.generate() >> 12) & tsid.node_mask));

    // 12 bits for counter
    try testing.expect((tsid.generate() & tsid.counter_mask) != tsid.generate() & tsid.counter_mask);
}

test "Tsid creates different values each time" {
    var tsid = Tsid.init_1024_nodes(1);

    var i: usize = 0;
    while (i < 100) : (i += 1) {
        const tsid1 = tsid.generate();
        const tsid2 = tsid.generate();

        try testing.expect(tsid1 != tsid2);
    }
}

test "UNIX Epoch is after getTimeMillisSinceTsidEpoch" {
    const unix_epoch = time.milliTimestamp();
    const time_tsid = Tsid.getTimeMillisSinceTsidEpoch();

    try testing.expect(unix_epoch > time_tsid);
}
