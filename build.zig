const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "zig_cli_lib",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Keymap example
    const keymap_mod = b.createModule(.{
        .root_source_file = b.path("src/lib/keymap.zig"),
        .target = target,
        .optimize = optimize,
    });
    
    const keymap_exe = b.addExecutable(.{
        .name = "keymap_example",
        .root_source_file = b.path("src/keymap_example.zig"),
        .target = target,
        .optimize = optimize,
    });
    keymap_exe.root_module.addImport("keymap", keymap_mod);
    
    const run_keymap_cmd = b.addRunArtifact(keymap_exe);
    const keymap_step = b.step("keymap", "Run keymap example");
    keymap_step.dependOn(&run_keymap_cmd.step);

    // Keymap tests
    const keymap_test_mod = b.createModule(.{
        .root_source_file = b.path("src/lib/keymap_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    keymap_test_mod.addImport("keymap", keymap_mod);
    
    const keymap_unit_tests = b.addTest(.{
        .root_module = keymap_test_mod,
        .target = target,
        .optimize = optimize,
    });
    
    const run_keymap_unit_tests = b.addRunArtifact(keymap_unit_tests);

    const unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
    test_step.dependOn(&run_keymap_unit_tests.step);

    // Performance tests
    const perf_mod = b.createModule(.{
        .root_source_file = b.path("src/performance_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    perf_mod.addImport("cli_color", b.createModule(.{ .root_source_file = b.path("src/lib/cli_color.zig") }));
    perf_mod.addImport("cli_style", b.createModule(.{ .root_source_file = b.path("src/lib/cli_style.zig") }));
    perf_mod.addImport("progress", b.createModule(.{ .root_source_file = b.path("src/lib/progress.zig") }));
    perf_mod.addImport("spinner", b.createModule(.{ .root_source_file = b.path("src/lib/spinner.zig") }));
    perf_mod.addImport("table", b.createModule(.{ .root_source_file = b.path("src/lib/table.zig") }));
    perf_mod.addImport("menu", b.createModule(.{ .root_source_file = b.path("src/lib/menu.zig") }));
    perf_mod.addImport("keymap", keymap_mod);

    const perf_exe = b.addExecutable(.{
        .name = "performance_tests",
        .root_module = perf_mod,
    });

    const run_perf_cmd = b.addRunArtifact(perf_exe);
    const perf_step = b.step("perf", "Run performance tests");
    perf_step.dependOn(&run_perf_cmd.step);
}