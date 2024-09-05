# TSID

Zig port for the famous [TSID generator](https://github.com/f4b6a3/tsid-creator/) created by Fabio Lima.

Build for Zig `0.13.0`.

## Status

- [x] Thread safety with `Atomic.value`
- [x] `TSID.toString` / `TSID.fromString` Crockford's Base32 representation
- [x] Benchmarks vs UUIDs libs
- [ ] Benchmarks vs other TSIDs implementations

## Installation

Include it as library:
```sh
zig fetch --save git+https://github.com/rlopzc/tsid-zig
```

In your `build.zig`:
```
const tsid = b.dependency("tsid-zig", .{});
exe.root_module.addImport("tsid", tsid.module("tsid"));
```

## Usage

```
const TSID = @import("tsid").TSID;
const TsidFactory = @import("tsid").Factory;

// Build a TSID Factory supporting 1024 nodes, with a Node ID = 500
var tsid_factory = TsidFactory.init_1024_nodes(500);

// Generate a TSID
const tsid = tsid_factory.create();

// Get the Crockford's Base32 string
tsid.toString();

// Get the u64 number
tsid.number;

// Build a TSID from a String
const tsid_from_str = try TSID.fromString("0H0596Q9R05TZ");
```

## Benchmarks

I compared this TSID generation vs other UUIDs implementations from the community. If you want to run this benchmarks,
run `zig build run-bench`.

Here are the results.
```
benchmark              runs     total time     time/run (avg ± σ)     (min ... max)                p75        p99        p995
-----------------------------------------------------------------------------------------------------------------------------
r4gus/uuid v4          65535    1.873ms        28ns ± 19ns            (20ns ... 200ns)             30ns       131ns      131ns
r4gus/uuid v7          65535    3.112ms        47ns ± 22ns            (40ns ... 3.967us)           50ns       150ns      151ns
karlseguin/zul UUID v4 65535    1.894ms        28ns ± 47ns            (20ns ... 11.131us)          30ns       131ns      131ns
karlseguin/zul UUID v7 65535    3.846ms        58ns ± 19ns            (50ns ... 3.607us)           60ns       160ns      160ns
rlopzc/tsid-zig 256    65535    3.453ms        52ns ± 16ns            (50ns ... 4.188us)           60ns       61ns       61ns
rlopzc/tsid-zig 1024   65535    3.446ms        52ns ± 16ns            (50ns ... 4.028us)           51ns       61ns       61ns
rlopzc/tsid-zig 4096   65535    3.445ms        52ns ± 19ns            (50ns ... 3.927us)           51ns       61ns       61ns
```

## Useful links

- https://ziggit.dev/t/how-to-package-a-zig-source-module-and-how-to-use-it/3457
- https://github.com/bitwalker/uniq/blob/main/lib/uuid.ex#L307
- https://github.com/E-xyza/zigler
- https://github.com/r4gus/uuid-zig
- https://ziglang.org/documentation/master/std/#std.atomic.Value
