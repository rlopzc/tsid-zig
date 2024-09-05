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
r4gus/uuid v4          65535    14.815ms       226ns ± 156ns          (166ns ... 18.083us)         250ns      250ns      292ns
r4gus/uuid v7          65535    4.501ms        68ns ± 50ns            (0ns ... 375ns)              83ns       292ns      292ns
karlseguin/zul UUID v4 65535    14.689ms       224ns ± 145ns          (125ns ... 26.166us)         250ns      250ns      250ns
karlseguin/zul UUID v7 65535    6.021ms        91ns ± 175ns           (0ns ... 35.375us)           84ns       333ns      334ns
rlopzc/tsid-zig 256    65535    3.228ms        49ns ± 16ns            (0ns ... 209ns)              42ns       84ns       84ns
rlopzc/tsid-zig 1024   65535    3.373ms        51ns ± 29ns            (0ns ... 6.166us)            42ns       84ns       84ns
rlopzc/tsid-zig 4096   65535    3.237ms        49ns ± 28ns            (0ns ... 6.167us)            42ns       84ns       84ns
```

## Useful links

- https://ziggit.dev/t/how-to-package-a-zig-source-module-and-how-to-use-it/3457
- https://github.com/bitwalker/uniq/blob/main/lib/uuid.ex#L307
- https://github.com/E-xyza/zigler
- https://github.com/r4gus/uuid-zig
- https://ziglang.org/documentation/master/std/#std.atomic.Value
