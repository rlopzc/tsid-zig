# TSID

Zig port for the famous [TSID generator](https://github.com/f4b6a3/tsid-creator/) created by Fabio Lima.

Build for Zig `0.13.0`.

## Status

- [x] Thread safety with `Atomic.value`
- [x] `TSID.toString` / `TSID.fromString` Crockford's Base32 representation
- [ ] Benchmarks vs UUIDs libs
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

## Useful links

- https://ziggit.dev/t/how-to-package-a-zig-source-module-and-how-to-use-it/3457
- https://github.com/bitwalker/uniq/blob/main/lib/uuid.ex#L307
- https://github.com/E-xyza/zigler
- https://github.com/r4gus/uuid-zig
- https://ziglang.org/documentation/master/std/#std.atomic.Value
