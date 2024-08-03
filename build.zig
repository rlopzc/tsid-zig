const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Lib
    const lib = b.addStaticLibrary(.{
        .name = "tsid",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(lib);

    // Lib tests
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);

    // https://ziggit.dev/t/how-to-package-a-zig-source-module-and-how-to-use-it/3457
    const tsid_module = b.addModule("tsid", .{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // install tsid example
    const tsid_example_exe = b.addExecutable(.{
        .name = "tsid-example",
        .root_source_file = b.path("examples/tsid_factory.zig"),
        .target = target,
    });
    tsid_example_exe.root_module.addImport("tsid", tsid_module);
    b.installArtifact(tsid_example_exe);

    // run tsid example
    const run_tsid_example = b.addRunArtifact(tsid_example_exe);
    const tsid_example_step = b.step("run-example", "Run the TsidFactory example");
    tsid_example_step.dependOn(&run_tsid_example.step);
}
