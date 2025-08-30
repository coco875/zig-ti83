// const c = @cImport({
//     @cInclude("int24.h"); // pour uint24_t
//     @cInclude("ti/screen.h");
//     @cInclude("ti/getcsc.h");
// });

const ti_screen = @import("ti/screen.zig");
const ti_getcsc = @import("ti/getcsc.zig");

pub export fn main() u32 {
    ti_screen.os_ClrHome();
    _ = ti_screen.os_PutStrFull("Hello, World!");
    while (ti_getcsc.os_GetCSC() == 0) {}
    return 0;
}
