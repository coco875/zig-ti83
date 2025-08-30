const ti_screen = @cImport(@cInclude("ti/screen.h"));
const ti_getcsc = @cImport(@cInclude("ti/getcsc.h"));

pub export fn main() c_int {
    ti_screen.os_ClrHome();
    _ = ti_screen.os_PutStrFull("Hello, World!");
    while (ti_getcsc.os_GetCSC() == 0) {}
    return 0;
}
