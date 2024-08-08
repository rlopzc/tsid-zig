const std = @import("std");
const TsidFactory = @import("tsid").TsidFactory;

pub fn main() !void {
    var tsid_factory = TsidFactory.init_1024_nodes(1);

    const id = tsid_factory.create();
    try std.io.getStdOut().writer().print("TSID\nDecimal: {d}\nHex:     {x}\nBinary:  {b}\n", .{ id, id, id });
}
