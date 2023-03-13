const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const cflags_common = [_][]const u8{
        "-Wall",
        "-Wextra",
        "-Wmissing-prototypes",
        "-Wstrict-prototypes",
        "-Wmissing-declarations",
        "-Wpointer-arith",
        "-Wdeclaration-after-statement",
        "-Wformat-security",
        "-Wwrite-strings",
        "-Wshadow",
        "-Winline",
        "-Wnested-externs",
        "-Wfloat-equal",
        "-Wundef",
        "-Wendif-labels",
        "-Wempty-body",
        "-Wcast-align",
        "-Wclobbered",
        "-Wvla",
        "-Wpragmas",
        "-Wunreachable-code",
        "-Waddress",
        "-Wattributes",
        "-Wdiv-by-zero",
        "-Wshorten-64-to-32",
        "-Wconversion",
        "-Wextended-offsetof",
        "-Wformat-nonliteral",
        "-Wlanguage-extension-token",
        "-Wmissing-field-initializers",
        "-Wmissing-noreturn",
        "-Wmissing-variable-declarations",
        "-Wsign-conversion",
        "-Wunreachable-code-break",
        "-Wunused-macros",
        "-Wunused-parameter",
        "-Wredundant-decls",
        "-Wheader-guard",
        "-Wno-format-nonliteral",
    };

    const lib = b.addStaticLibrary(.{
        .name = "nghttp2",
        .target = target,
        .optimize = optimize,
    });
    const nghttp2ver_h = b.addConfigHeader(.{
        .style = .blank,
        .include_path = "nghttp2/nghttp2ver.h",
    }, .{
        .NGHTTP2_VERSION = "1.52.0",
        .NGHTTP2_VERSION_NUM = 0x013400,
    });
    lib.addConfigHeader(nghttp2ver_h);
    lib.addConfigHeader(b.addConfigHeader(.{
        .style = .blank,
        .include_path = "config.h",
    }, .{
        .HAVE_ARPA_INET_H = if (!target.isWindows()) blk: {
            break :blk @as(c_int, 1);
        } else blk: {
            break :blk null;
        },
        .HAVE_NETINET_IN_H = if (!target.isWindows()) blk: {
            break :blk @as(c_int, 1);
        } else blk: {
            break :blk null;
        },
        .DEBUGBUILD = if (optimize == .Debug) blk: {
            break :blk @as(c_int, 1);
        } else blk: {
            break :blk null;
        },
    }));
    lib.addCSourceFiles(&.{
        "lib/nghttp2_pq.c",
        "lib/nghttp2_map.c",
        "lib/nghttp2_queue.c",
        "lib/nghttp2_frame.c",
        "lib/nghttp2_buf.c",
        "lib/nghttp2_stream.c",
        "lib/nghttp2_outbound_item.c",
        "lib/nghttp2_session.c",
        "lib/nghttp2_submit.c",
        "lib/nghttp2_helper.c",
        "lib/nghttp2_npn.c",
        "lib/nghttp2_hd.c",
        "lib/nghttp2_hd_huffman.c",
        "lib/nghttp2_hd_huffman_data.c",
        "lib/nghttp2_version.c",
        "lib/nghttp2_priority_spec.c",
        "lib/nghttp2_option.c",
        "lib/nghttp2_callbacks.c",
        "lib/nghttp2_mem.c",
        "lib/nghttp2_http.c",
        "lib/nghttp2_rcbuf.c",
        "lib/nghttp2_extpri.c",
        "lib/nghttp2_debug.c",
    }, &(cflags_common ++ .{
        "-DBUILDING_NGHTTP2",
        "-DNGHTTP2_STATICLIB",
        "-DHAVE_CONFIG_H=1",
    }));
    lib.linkLibC();
    lib.addIncludePath("lib/includes");
    lib.installConfigHeader(nghttp2ver_h, .{});
    lib.installHeader(
        "lib/includes/nghttp2/nghttp2.h",
        "nghttp2/nghttp2.h",
    );
    lib.install();
}
