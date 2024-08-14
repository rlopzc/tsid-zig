const std = @import("std");
const TsidFactory = @import("tsid").TsidFactory;
const uuid = @import("uuid");

const iterations = 10_000_000;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var i: usize = 0;
    var duration: u64 = 0;

    var timer = try std.time.Timer.start();
    while (i < iterations) : (i += 1) {
        const id = uuid.v4.new();
        std.mem.doNotOptimizeAway(id);
    }
    duration = timer.read();
    try stdout.print("UUIDv4: {d} UUIDs in {}\n", .{ iterations, std.fmt.fmtDuration(duration) });

    i = 0;
    timer = try std.time.Timer.start();
    while (i < iterations) : (i += 1) {
        const id = uuid.v7.new();
        std.mem.doNotOptimizeAway(id);
    }
    duration = timer.read();
    try stdout.print("UUIDv7: {d} UUIDs in {}\n", .{ iterations, std.fmt.fmtDuration(duration) });

    var tsid_factory = TsidFactory.init_256_nodes(1);
    i = 0;
    timer = try std.time.Timer.start();
    while (i < iterations) : (i += 1) {
        const id = tsid_factory.create();
        std.mem.doNotOptimizeAway(id);
    }
    duration = timer.read();
    try stdout.print("TSID:   {d} TSIDs in {}\n", .{ iterations, std.fmt.fmtDuration(duration) });
}
