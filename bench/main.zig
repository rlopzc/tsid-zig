const std = @import("std");

const TsidFactory = @import("tsid").Factory;

const zbench = @import("zbench");
const uuid = @import("uuid");
const zul = @import("zul");

const iterations = 10_000_000;

// r4gus/uuid

fn benchmarkRagusUuidV4(_: std.mem.Allocator) void {
    _ = uuid.v4.new();
}

fn benchmarkRagusUuidV7(_: std.mem.Allocator) void {
    _ = uuid.v7.new();
}

// karlseguin/zul

fn benchmarkZulV4(_: std.mem.Allocator) void {
    _ = zul.UUID.v4();
}

fn benchmarkZulV7(_: std.mem.Allocator) void {
    _ = zul.UUID.v7();
}

// TSID

var benchmark_tsid: BenchmarkTsid = undefined;

fn beforeAll() void {
    benchmark_tsid.init();
}

fn benchmarkTsid256(_: std.mem.Allocator) void {
    _ = benchmark_tsid.tsid256.create();
}

fn benchmarkTsid1024(_: std.mem.Allocator) void {
    _ = benchmark_tsid.tsid1024.create();
}

fn benchmarkTsid4096(_: std.mem.Allocator) void {
    _ = benchmark_tsid.tsid4096.create();
}

const BenchmarkTsid = struct {
    tsid256: TsidFactory,
    tsid1024: TsidFactory,
    tsid4096: TsidFactory,

    pub fn init(self: *BenchmarkTsid) void {
        self.tsid256 = TsidFactory.init_256_nodes(1);
        self.tsid1024 = TsidFactory.init_1024_nodes(1);
        self.tsid4096 = TsidFactory.init_4096_nodes(1);
    }
};

test "bench" {
    const benchConfig: zbench.Config = .{
        .hooks = .{
            .before_all = beforeAll,
        },
    };
    var bench = zbench.Benchmark.init(std.testing.allocator, benchConfig);
    defer bench.deinit();

    try bench.add("r4gus/uuid v4", benchmarkRagusUuidV4, .{});
    try bench.add("r4gus/uuid v7", benchmarkRagusUuidV7, .{});

    try bench.add("karlseguin/zul UUID v4", benchmarkZulV4, .{});
    try bench.add("karlseguin/zul UUID v7", benchmarkZulV7, .{});

    try bench.add("rlopzc/tsid-zig 256", benchmarkTsid256, .{});
    try bench.add("rlopzc/tsid-zig 1024", benchmarkTsid1024, .{});
    try bench.add("rlopzc/tsid-zig 4096", benchmarkTsid4096, .{});

    try bench.run(std.io.getStdErr().writer());
}
