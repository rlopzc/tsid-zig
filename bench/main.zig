const std = @import("std");
const TsidFactory = @import("tsid").Factory;
const uuid = @import("uuid");
const zul = @import("zul");

const iterations = 10_000_000;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var i: usize = 0;
    var duration: u64 = 0;

    try stdout.print("r4gus/uuid\n", .{});
    var timer = try std.time.Timer.start();
    while (i < iterations) : (i += 1) {
        const id = uuid.v4.new();
        std.mem.doNotOptimizeAway(id);
    }
    duration = timer.read();
    try stdout.print("UUIDv4: {d} UUIDs in {}\n", .{ iterations, std.fmt.fmtDuration(duration) });

    i = 0;
    timer.reset();
    while (i < iterations) : (i += 1) {
        const id = uuid.v7.new();
        std.mem.doNotOptimizeAway(id);
    }
    duration = timer.read();
    try stdout.print("UUIDv7: {d} UUIDs in {}\n", .{ iterations, std.fmt.fmtDuration(duration) });

    try stdout.print("\n", .{});
    try stdout.print("karlseguin/zul\n", .{});
    i = 0;
    timer.reset();
    while (i < iterations) : (i += 1) {
        const id = zul.UUID.v4();
        std.mem.doNotOptimizeAway(id);
    }
    duration = timer.read();
    try stdout.print("UUIDv4: {d} UUIDs in {}\n", .{ iterations, std.fmt.fmtDuration(duration) });

    i = 0;
    timer.reset();
    while (i < iterations) : (i += 1) {
        const id = zul.UUID.v7();
        std.mem.doNotOptimizeAway(id);
    }
    duration = timer.read();
    try stdout.print("UUIDv7: {d} UUIDs in {}\n", .{ iterations, std.fmt.fmtDuration(duration) });

    try stdout.print("\n", .{});
    var tsid_factory = TsidFactory.init_256_nodes(1);
    i = 0;
    timer.reset();
    while (i < iterations) : (i += 1) {
        const id = tsid_factory.create();
        std.mem.doNotOptimizeAway(id);
    }
    duration = timer.read();
    try stdout.print("TSID 256:  {d} TSIDs in {}\n", .{ iterations, std.fmt.fmtDuration(duration) });

    tsid_factory = TsidFactory.init_1024_nodes(1);
    i = 0;
    timer.reset();
    while (i < iterations) : (i += 1) {
        const id = tsid_factory.create();
        std.mem.doNotOptimizeAway(id);
    }
    duration = timer.read();
    try stdout.print("TSID 1024: {d} TSIDs in {}\n", .{ iterations, std.fmt.fmtDuration(duration) });

    tsid_factory = TsidFactory.init_4096_nodes(1);
    i = 0;
    timer.reset();
    while (i < iterations) : (i += 1) {
        const id = tsid_factory.create();
        std.mem.doNotOptimizeAway(id);
    }
    duration = timer.read();
    try stdout.print("TSID 4096: {d} TSIDs in {}\n", .{ iterations, std.fmt.fmtDuration(duration) });
}
