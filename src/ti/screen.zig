const lie = @import("../int24.zig");
const ui = @import("ui.zig");

pub extern fn boot_NewLine() void;

/// Resets the OS homescreen; accounts for split screen.
pub fn os_ClrHome() void {
    os_ClrLCD();
    os_HomeUp();
    ui.os_DrawStatusBar();
}

// Resets the OS homescreen fully; ignores split screen mode.
pub fn os_ClrHomeFull() void {
    os_ClrLCDFull();
    os_HomeUp();
    ui.os_DrawStatusBar();
}

/// Inserts a new line at the current cursor posistion on the homescreen.
/// Does scroll.
pub extern fn os_NewLine() void;

/// Disables the OS cursor
pub extern fn os_DisableCursor() void;

/// Enables the OS cursor
pub extern fn os_EnableCursor() void;

/// Set the cursor posistion used on the homescreen
///
/// @param[in] curRow The row aligned offset
/// @param[in] curCol The column aligned offset
pub extern fn os_SetCursorPos(curRow: u8, curCol: u8) void;

/// Gets the cursor posistion used on the homescreen
///
/// @param[in] curRow Pointer to store the row aligned offset
/// @param[in] curCol Pointer to store the column aligned offset
pub extern fn os_GetCursorPos(curRow: *u32, curCol: *u32) void;

/// Puts some text at the current homescreen cursor location
///
/// @param[in] string Text to put on homescreen
/// @returns 1 if string fits on screen, 0 otherwise
pub extern fn os_PutStrFull([*c]const u8) lie.int24;

pub extern fn os_HomeUp() void;
pub extern fn os_ClrLCDFull() void;
pub extern fn os_ClrLCD() void;
