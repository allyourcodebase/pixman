const std = @import("std");

pub fn build(b: *std.Build) !void {
    const upstream = b.dependency("pixman", .{});

    const pixman_path = upstream.path("pixman");

    const pixman_mod = b.createModule(.{
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
        .link_libc = true,
    });

    const lib = b.addLibrary(.{
        .name = "pixman-1",
        .root_module = pixman_mod,
    });

    pixman_mod.addCMacro("HAVE_CONFIG_H", "");

    const config_h = b.addConfigHeader(.{
        .include_path = "pixman-config.h",
    }, .{
        // Required to make pixman-private.h
        .PACKAGE = "FOO",
        .HAVE_PTHREADS = "1",
    });
    lib.root_module.addConfigHeader(config_h);

    const version_h = b.addConfigHeader(
        .{
            .style = .{ .meson = pixman_path.path(b, "pixman-version.h.in") },
        },
        .{
            .PIXMAN_VERSION_MAJOR = 0,
            .PIXMAN_VERSION_MINOR = 46,
            .PIXMAN_VERSION_MICRO = 4,
        },
    );

    pixman_mod.addConfigHeader(version_h);

    lib.root_module.addIncludePath(upstream.path("pixman"));
    lib.installHeadersDirectory(upstream.path("pixman"), "", .{});
    lib.root_module.addCSourceFiles(.{
        .root = upstream.path("pixman"),
        .files = sources,
    });

    const include = b.addWriteFiles();

    _ = include.addCopyFile(pixman_path.path(b, "pixman.h"), "pixman.h");
    _ = include.addCopyFile(version_h.getOutputFile(), "pixman-version.h");

    b.addNamedLazyPath("include", include.getDirectory());

    b.installArtifact(lib);
}

const sources = &.{
    "pixman.c",
    "pixman-access.c",
    "pixman-access-accessors.c",
    "pixman-arm.c",
    "pixman-bits-image.c",
    "pixman-combine32.c",
    "pixman-combine-float.c",
    "pixman-conical-gradient.c",
    "pixman-edge.c",
    "pixman-edge-accessors.c",
    "pixman-fast-path.c",
    "pixman-filter.c",
    "pixman-glyph.c",
    "pixman-general.c",
    "pixman-gradient-walker.c",
    "pixman-image.c",
    "pixman-implementation.c",
    "pixman-linear-gradient.c",
    "pixman-matrix.c",
    "pixman-mips.c",
    "pixman-noop.c",
    "pixman-ppc.c",
    "pixman-radial-gradient.c",
    "pixman-region16.c",
    "pixman-region32.c",
    "pixman-region64f.c",
    "pixman-riscv.c",
    "pixman-solid-fill.c",
    "pixman-timer.c",
    "pixman-trap.c",
    "pixman-utils.c",
    "pixman-x86.c",
};
