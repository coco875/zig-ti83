const std = @import("std");
const utils = @import("utils.zig");

const function_patch: []const []const []const u8 = &.{
    // sys/power.h
    &.{"void os_DisableAPD("},
    &.{"void os_EnableAPD("},
    &.{"uint8_t boot_GetBatteryStatus("},
    // ti/real.h
    &.{ "struct_real_t", "os_Int24ToReal(" },
    // ti/screen.h
    &.{"void os_NewLine("},
    &.{"void os_MoveUp("},
    &.{"void os_MoveDown("},
    &.{"void os_HomeUp("},
    &.{"void os_ClrLCDFull("},
    &.{"void os_ClrLCD("},
    &.{"void os_ClrTxtShd("},
    // ti/ui.h
    &.{"void os_RunIndicOn("},
    &.{"void os_RunIndicOff("},
    &.{"void os_DrawStatusBar("},
    // ti/vars.h
    &.{"void os_ArcChk("},
    &.{"void os_DelRes("},
};

fn all_match(haystack: []const u8, needles: []const []const u8) bool {
    for (needles) |needle| {
        if (std.mem.count(u8, haystack, needle) == 0) {
            return false;
        }
    }
    return true;
}

fn patch_transcompiled_file(b: *std.Build, file_path: []const u8, output: []const u8) !void {
    const prefix = "__attribute__((__tiflags__))";

    var file = try std.fs.cwd().openFile(file_path, .{ .mode = .read_only });
    defer file.close();

    var output_file = try std.fs.cwd().createFile(output, .{});
    defer output_file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    const reader = buf_reader.reader();

    while (try reader.readUntilDelimiterOrEofAlloc(b.allocator, '\n', 0x1000000)) |line| {
        var have_patch = false;
        for (function_patch) |func| {
            if (all_match(line, func)) {
                var new_line = std.ArrayList(u8).init(b.allocator);
                defer new_line.deinit();
                new_line.appendSlice(prefix) catch {};
                new_line.appendSlice(" ") catch {};
                new_line.appendSlice(line) catch {};
                try output_file.writer().writeAll(new_line.items);
                have_patch = true;
                break;
            }
        }
        if (!have_patch) {
            try output_file.writer().writeAll(line);
        }
        try output_file.writer().writeByte('\n');
    }
}

fn compile_c_file(b: *std.Build, lto: bool, src_file: []const u8, folder: *const std.fs.Dir) struct { file: []const u8, runner: *std.Build.Step.Run } {
    var src_before = std.ArrayList(u8).init(b.allocator);
    src_before.appendSlice("../") catch {};
    src_before.appendSlice(src_file) catch {};
    if (lto) {
        var new_file_name = std.ArrayList(u8).init(b.allocator);
        defer new_file_name.deinit();
        new_file_name.appendSlice(src_file) catch {};
        new_file_name.appendSlice(".bc") catch {};
        const temp_path = std.fs.path.join(b.allocator, &.{ "zig-out", "obj", std.fs.path.dirname(new_file_name.items) orelse "" }) catch "";
        defer b.allocator.free(temp_path);
        folder.makePath(temp_path) catch {};
        const new_path = std.fs.path.join(b.allocator, &.{ "obj", new_file_name.items }) catch "";
        const obj_bc = b.addSystemCommand(&.{
            "../CEdev/bin/ez80-clang",
            "-MD",
            "-c",
            "-emit-llvm",
            "-nostdinc",
            "-isystem",
            "../CEdev/include",
            "-I../src",
            "-fno-threadsafe-statics",
            "-fno-sanitize-thread-atomics",
            "-Xclang",
            "-fforce-mangle-main-argc-argv",
            "-mllvm",
            "-profile-guided-section-prefix=false",
            "-DNDEBUG",
            "-g0",
            "-Wall",
            "-Wextra",
            "-Oz",
            src_before.items,
            "-o",
            new_path,
        });
        obj_bc.cwd = b.path("zig-out");
        return .{ .file = new_path, .runner = obj_bc };
    } else {
        var new_file_name = std.ArrayList(u8).init(b.allocator);
        defer new_file_name.deinit();
        new_file_name.appendSlice(src_file) catch {};
        new_file_name.appendSlice(".src") catch {};
        const temp_path = std.fs.path.join(b.allocator, &.{ "zig-out", "obj", std.fs.path.dirname(new_file_name.items) orelse "" }) catch "";
        defer b.allocator.free(temp_path);
        folder.makePath(temp_path) catch {};
        const new_path = std.fs.path.join(b.allocator, &.{ "obj", new_file_name.items }) catch "";
        const obj_src = b.addSystemCommand(&.{
            "../CEdev/bin/ez80-clang",
            "-S",
            "-MD",
            "-nostdinc",
            "-isystem",
            "../CEdev/include",
            "-I../src",
            "-fno-threadsafe-statics",
            "-Xclang",
            "-fforce-mangle-main-argc-argv",
            "-mllvm",
            "-profile-guided-section-prefix=false",
            "-DNDEBUG",
            "-g0",
            "-Wall",
            "-Wextra",
            "-Oz",
            src_before.items,
            "-o",
            new_path,
        });
        obj_src.cwd = b.path("zig-out");
        return .{ .file = new_path, .runner = obj_src };
    }
}

fn create_obj_src(b: *std.Build, lto: bool, folder: *const std.fs.Dir, ti_lib: std.Build.LazyPath) struct { file: []const u8, runner: *std.Build.Step.Run } {
    const c_files = utils.recursive_search_c_files(b.allocator, b.path("src").getPath3(b, null), "src") catch {
        std.debug.panic("unable to list C files", .{});
    };
    var out_files = std.ArrayList(struct { file: []const u8, runner: *std.Build.Step.Run }).init(b.allocator);
    for (c_files.items) |c_file| {
        const compiled = compile_c_file(b, lto, c_file, folder);
        out_files.append(.{ .file = compiled.file, .runner = compiled.runner }) catch {
            std.debug.panic("unable to append compiled file", .{});
        };
    }

    const path = ti_lib.getPath3(b, null).toString(b.allocator) catch {
        std.debug.panic("unable to get ti_lib path", .{});
    };

    const absolute_path_main = b.path("src/main.zig").getPath3(b, null).toString(b.allocator) catch {
        std.debug.panic("unable to get absolute path for main.zig", .{});
    };

    utils.exec(b.allocator, "zig-out", &.{
        "zig",
        "build-obj",
        "-isystem",
        "CEdev/include",
        "-I",
        path,
        "-I../src",
        "-ofmt=c",
        absolute_path_main,
        "-O",
        "ReleaseSmall",
        "-fsingle-threaded",
        "-fno-strip",
        "-target",
        "arm-freestanding-eabi",
        "-femit-bin=main.c",
    }, .{ .enable_stdout = true, .enable_stderr = true }) catch {
        std.debug.panic("unable to build main.c", .{});
    };
    // c_file.cwd = b.path("zig-out");

    // patch main.c to add __tiflags__ attribute to some functions
    const patched_file = "zig-out/main-patched.c";

    patch_transcompiled_file(b, "zig-out/main.c", patched_file) catch {
        std.debug.panic("unable to patch main.c", .{});
    };

    const compiled = compile_c_file(b, lto, "zig-out/main-patched.c", folder);
    // compiled.runner.step.dependOn(&c_file.step);
    out_files.append(.{ .file = compiled.file, .runner = compiled.runner }) catch {
        std.debug.panic("unable to append compiled file", .{});
    };

    if (lto) {
        var cmd = std.ArrayList([]const u8).init(b.allocator);
        cmd.append("../CEdev/bin/ez80-link") catch {};
        for (out_files.items) |out_file| {
            cmd.append(out_file.file) catch {};
        }
        // cmd.append("--only-needed") catch {};
        // cmd.append("--internalize") catch {};
        cmd.append("-o") catch {};
        cmd.append("obj/lto.bc") catch {};
        const obj_lto_bc = b.addSystemCommand(cmd.items);
        obj_lto_bc.cwd = b.path("zig-out");
        for (out_files.items) |out_file| {
            obj_lto_bc.step.dependOn(&out_file.runner.step);
        }

        const obj_src = b.addSystemCommand(&.{
            "../CEdev/bin/ez80-clang",
            "-S",
            "-mllvm",
            "-profile-guided-section-prefix=false",
            "-Wall",
            "-Wextra",
            "-Oz",
            "obj/lto.bc",
            "-o",
            "obj/lto.src",
        });
        obj_src.cwd = b.path("zig-out");
        obj_src.step.dependOn(&obj_lto_bc.step);
        return .{ .file = "obj/lto.src", .runner = obj_src };
    } else {
        return .{ .file = compiled.file, .runner = compiled.runner };
    }
}

fn comment_atomic(b: *std.Build, file_path: []const u8, file_out_path: []const u8) !void {
    var file = try std.fs.cwd().openFile(file_path, .{ .mode = .read_write });
    defer file.close();

    var output_file = try std.fs.cwd().createFile(file_out_path, .{});
    defer output_file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    const reader = buf_reader.reader();

    var lines = std.ArrayList([]const u8).init(b.allocator);
    defer lines.deinit();
    while (try reader.readUntilDelimiterOrEofAlloc(b.allocator, '\n', 0x1000000)) |line| {
        if (std.mem.startsWith(u8, line, "#define zig_c11_atomics")) {
            var new_line = std.ArrayList(u8).init(b.allocator);
            defer new_line.deinit();
            new_line.appendSlice("// ") catch {};
            new_line.appendSlice(line) catch {};
            try lines.append(new_line.items);
            std.debug.print("Commented atomic line in {s}\n", .{line});
            std.debug.print("Commented atomic line in {s}\n", .{new_line.items});
        } else {
            try lines.append(line);
        }
    }

    for (lines.items) |line| {
        try output_file.writer().writeAll(line);
        try output_file.writer().writeByte('\n');
    }
}

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) !void {
    const root_path = try std.process.getCwdAlloc(b.allocator);
    defer b.allocator.free(root_path);

    try utils.ensure_tar(
        b.allocator,
        root_path,
        "CEdev",
        "https://github.com/CE-Programming/toolchain/releases/latest/download/CEdev-Linux.tar.gz",
    );

    const folder = try std.fs.openDirAbsolute(root_path, .{});
    folder.makeDir("zig-out") catch {};

    const path_zig_out = std.fs.path.join(b.allocator, &.{ root_path, "zig-out" }) catch {
        std.debug.panic("unable to join paths", .{});
    };
    if (!try utils.ensure_file(b.allocator, path_zig_out, "zig.h", "https://raw.githubusercontent.com/ziglang/zig/refs/tags/0.14.1/lib/zig.h")) {
        try utils.exec(b.allocator, path_zig_out, &.{ "sed", "-i", "s/#define zig_c11_atomics/#define zig_c11_atomics_disabled/g", "zig.h" }, .{});
    }

    folder.makeDir("zig-out/obj") catch {};
    folder.makeDir("zig-out/obj/src") catch {};
    folder.makeDir("zig-out/obj/zig-out") catch {};

    const ti_lib = b.dependency("ti83_zig_lib", .{});

    const lto = false;

    const obj_src = create_obj_src(b, lto, &folder, ti_lib.path("include"));

    const icon = b.addSystemCommand(&.{
        "../CEdev/bin/convimg",
        "--icon",
        "../icon.png",
        "--icon-output",
        "obj/icon.src",
        "--icon-format",
        "asm",
        "--icon-description",
        "CE C Toolchain Demo",
    });
    icon.cwd = b.path("zig-out");

    var all_sources = std.ArrayList(u8).init(b.allocator);
    try all_sources.appendSlice("source ");
    try all_sources.appendSlice("\"obj/icon.src\", ");
    try all_sources.appendSlice("\"../CEdev/lib/crt/crt0.src\", ");
    try all_sources.appendSlice("\"");
    try all_sources.appendSlice(obj_src.file);
    try all_sources.appendSlice("\"");

    const bin = b.addSystemCommand(&.{
        "../CEdev/bin/fasmg",
        "-v1",
        "../CEdev/meta/ld.alm",
        "-i",
        "DEBUG := 1",
        "-i",
        "HAS_PRINTF := 1",
        "-i",
        "HAS_LIBC := 1",
        "-i",
        "HAS_LIBCXX := 1",
        "-i",
        "PREFER_OS_CRT := 0",
        "-i",
        "PREFER_OS_LIBC := 1",
        "-i",
        "ALLOCATOR_STANDARD := 1",
        "-i",
        "include \"../CEdev/meta/linker_script\"",
        "-i",
        "range .bss $D052C6 : $D13FD8",
        "-i",
        "provide __stack = $D1A87E",
        "-i",
        "locate .header at $D1A87F",
        "-i",
        "map",
        "-i",
        all_sources.items,
        "-i",
        "library \"../CEdev/lib/libload/fatdrvce.lib\", \"../CEdev/lib/libload/fileioc.lib\", \"../CEdev/lib/libload/fontlibc.lib\", \"../CEdev/lib/libload/graphx.lib\", \"../CEdev/lib/libload/keypadc.lib\", \"../CEdev/lib/libload/msddrvce.lib\", \"../CEdev/lib/libload/srldrvce.lib\", \"../CEdev/lib/libload/usbdrvce.lib\"",
        "DEMO.bin",
    });
    bin.cwd = b.path("zig-out");
    bin.step.dependOn(&icon.step);
    bin.step.dependOn(&obj_src.runner.step);

    const rom = b.addSystemCommand(&.{
        "../CEdev/bin/convbin",
        "-r",
        "-k",
        "8xp",
        "-u",
        "-n",
        "DEMO",
        "-i",
        "DEMO.bin",
        "-o",
        "DEMO.8xp",
    });
    rom.cwd = b.path("zig-out");
    rom.step.dependOn(&bin.step);

    b.default_step.dependOn(&rom.step);
}
