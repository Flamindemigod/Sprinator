const std = @import("std");
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "Sprinator",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .pic = true,
    });

    if (optimize == std.builtin.OptimizeMode.Debug) {
        const lib = b.addSharedLibrary(.{
            .name = "plug",
            // In this case the main source file is merely a path, however, in more
            // complicated build scripts, this could be a generated file.
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
            .pic = true,
        });
        lib.linkSystemLibrary("raylib");
        lib.linkLibC();
        b.installArtifact(lib);
    } else {
        const lib = b.addStaticLibrary(.{
            .name = "plug",
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
            .pic = true,
        });
        lib.linkSystemLibrary("raylib");
        lib.linkLibC();
        b.installArtifact(lib);
        exe.linkLibrary(lib);
    }

    exe.linkSystemLibrary("raylib");
    exe.linkLibC();
    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}
