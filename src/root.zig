const std = @import("std");

const testing = std.testing;
const time = std.time;
const log = std.log;

// TSID Epoch 2020-01-01T00:00:00.000Z
const tsid_epoch_milliseconds: u64 = 1577836800000;

pub fn getTimeMillisSinceTsidEpoch() u64 {
    const now: u64 = @intCast(time.milliTimestamp());
    return now - tsid_epoch_milliseconds;
}

test "UNIX Epoch is after getTimeMilisSinceTsidEpoch" {
    const unix_epoch = time.milliTimestamp();
    const time_tsid = getTimeMillisSinceTsidEpoch();

    try testing.expect(unix_epoch > time_tsid);
}
