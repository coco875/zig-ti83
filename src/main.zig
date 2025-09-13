const ti_screen = @cImport(@cInclude("ti/screen.h"));
const ti_getcsc = @cImport(@cInclude("ti/getcsc.h"));
const std = @import("std");
const dbg = @cImport(@cInclude("debug.h"));

const dbgout: [*c]u8 = @ptrFromInt(0xFB0000);

pub export fn main() c_int {
    ti_screen.os_ClrHome();
    _ = ti_screen.os_PutStrFull("Hello, World!\n");

    while (ti_getcsc.os_GetCSC() == 0) {}
    return 0;
}
