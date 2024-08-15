const std = @import("std");

pub const TSID = @import("tsid.zig").TSID;
pub const Factory = @import("factory.zig").Factory;

test "main tests" {
    _ = TSID;
    _ = Factory;
}
