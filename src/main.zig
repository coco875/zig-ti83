const ti_screen = @cImport(@cInclude("ti/screen.h"));
const ti_getcsc = @cImport(@cInclude("ti/getcsc.h"));
// Implémentation légère type ArrayList évitant les intrinsic LLVM problématiques.
const ArrayListLite = @import("array_list_lite.zig").ArrayListLite;
const StrList = ArrayListLite(u8);

pub export fn main() c_int {
    ti_screen.os_ClrHome();

    var list = StrList.init();
    defer list.deinit();
    list.appendSlice("Hello, World!\n") catch return 1;
    list.append(0) catch return 1; // terminator
    if (list.len == 0) return 1;
    const cstr: [*:0]u8 = @ptrCast(list.items.ptr);
    _ = ti_screen.os_PutStrFull(cstr);

    while (ti_getcsc.os_GetCSC() == 0) {}
    return 0;
}
