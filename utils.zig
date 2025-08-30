const std = @import("std");
const fs = std.fs;
const dirname = std.fs.path.dirname;
const basename = std.fs.path.basename;

/// Looks for build.zig by traversing from current directory and upwards,
/// ideal for setting builder.build_root starting from builder.build_root
pub fn root(cwd: []const u8) ![]const u8 {
    const dir = try std.fs.openDirAbsolute(cwd, .{ .iterate = true });
    var iter = dir.iterate();
    while (try iter.next()) |entry| {
        if (std.mem.eql(u8, entry.name, "build.zig")) return cwd;
    }
    return if (dirname(cwd)) |up| try root(up) else error.BuildZigNotFound;
}

/// Run shell command
pub fn exec(allocator: std.mem.Allocator, cwd: []const u8, argv: []const []const u8) !void {
    var child = std.process.Child.init(argv, allocator);
    child.cwd = cwd;
    // Comportement des flux selon options
    child.stdin_behavior = .Pipe;
    child.stdout_behavior = .Pipe;
    child.stderr_behavior = .Pipe;

    try child.spawn();
    const term = child.wait() catch |err| {
        std.debug.print("Error: {}\n", .{err});
        return err;
    };

    if (term.Exited != 0) {
        std.debug.print("Command failed with exit code: {}\n", .{term.Exited});
        std.debug.print("Output:\n{s}", .{child.stdout.?.readToEndAlloc(allocator, 0x1000000) catch ""});
        std.debug.print("Error:\n{s}", .{child.stderr.?.readToEndAlloc(allocator, 0x1000000) catch ""});
        return error.CommandFailed;
    }
}

pub fn ensure_tar(allocator: std.mem.Allocator, cwd: []const u8, path: []const u8, url: []const u8) !void {
    const folder = try std.fs.openDirAbsolute(cwd, .{});
    folder.access(path, .{}) catch |err| if (err == error.FileNotFound) {
        try exec(allocator, cwd, &.{ "wget", "-q", url });
        try exec(allocator, cwd, &.{ "tar", "-xf", basename(url) });
        try folder.deleteFile(basename(url));
    };
}

pub fn ensure_file(allocator: std.mem.Allocator, cwd: []const u8, path: []const u8, url: []const u8) !bool {
    const folder = try std.fs.openDirAbsolute(cwd, .{});
    folder.access(path, .{}) catch |err| if (err == error.FileNotFound) {
        try exec(allocator, cwd, &.{ "wget", "-q", url });
        return false;
    };
    return true;
}

// Recursively collect all .c files starting at a root directory.
fn recursive_search_c_files_(allocator: std.mem.Allocator, dir: fs.Dir, path_string: []const u8) !std.ArrayList([]const u8) {
    var it = dir.iterate();
    var files = std.ArrayList([]const u8).init(allocator);
    while (try it.next()) |entry| switch (entry.kind) {
        .file => if (std.mem.endsWith(u8, entry.name, ".c")) {
            const full = std.fs.path.join(allocator, &.{ path_string, entry.name }) catch continue;
            try files.append(full);
        },
        .directory => {
            var sub_dir = try dir.openDir(entry.name, .{ .iterate = true });
            defer sub_dir.close();
            const sub_files = try recursive_search_c_files_(allocator, sub_dir, try std.fs.path.join(allocator, &.{ path_string, entry.name }));
            for (sub_files.items) |f| try files.append(f);
            sub_files.deinit();
        },
        else => {},
    };
    return files;
}

pub fn recursive_search_c_files(allocator: std.mem.Allocator, path: std.Build.Cache.Path, path_string: []const u8) !std.ArrayList([]const u8) {
    var dir = try path.openDir(".", .{ .iterate = true });
    defer dir.close();

    return recursive_search_c_files_(allocator, dir, path_string);
}
