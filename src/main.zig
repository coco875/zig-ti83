const ti_screen = @cImport(@cInclude("ti/screen.h"));
const ti_getcsc = @cImport(@cInclude("ti/getcsc.h"));
const std = @import("std");
const dbg = @cImport(@cInclude("debug.h"));

const dbgout: [*c]u8 = @ptrFromInt(0xFB0000);

pub export fn main() c_int {
    ti_screen.os_ClrHome();

    var array = std.ArrayList(u8).init(std.heap.raw_c_allocator);
    defer array.deinit();
    array.appendSlice("Hello, World!\n") catch return 1;
    array.append(0) catch return 1;

    const cstr: [*:0]u8 = @ptrCast(array.items.ptr);
    _ = dbg.sprintf(dbgout, "Debug: about to print '%s'", cstr);
    _ = ti_screen.os_PutStrFull(cstr);

    while (ti_getcsc.os_GetCSC() == 0) {}
    return 0;
}
