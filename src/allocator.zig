//! don't work for some reason that I don't understand

const stdlib = @cImport(@cInclude("stdlib.h"));
const std = @import("std");
const mem = std.mem;
const Allocator = std.mem.Allocator;

// Allocateur minimal basé sur malloc/realloc/free.
// Sur ez80 on suppose que les contraintes d'alignement strictes ne sont pas
// nécessaires (toutes les adresses suffisent) donc on ignore le paramètre
// d'alignement et on simplifie totalement la logique.

pub const raw_c_allocator: Allocator = .{ .ptr = undefined, .vtable = &raw_c_allocator_vtable };
const raw_c_allocator_vtable: Allocator.VTable = .{
    .alloc = rawAlloc,
    .resize = rawResize,
    .remap = rawRemap,
    .free = rawFree,
};

fn rawAlloc(
    _: *anyopaque,
    len: usize,
    _: mem.Alignment,
    _: usize,
) ?[*]u8 {
    if (len == 0) {
        // Fournir un pointeur non-null stable pour len 0 (optionnel).
        const p0 = stdlib.malloc(1);
        if (p0 == null) return null;
        const many: [*]u8 = @ptrCast(p0.?);
        return many;
    }
    const p = stdlib.malloc(len);
    if (p == null) return null;
    const many: [*]u8 = @ptrCast(p.?);
    return many;
}

fn rawResize(
    _: *anyopaque,
    _: []u8,
    _: mem.Alignment,
    _: usize,
    _: usize,
) bool {
    // Pas de resize in-place garanti; std utilisera remap.
    return false;
}

fn rawRemap(
    _: *anyopaque,
    memory: []u8,
    _: mem.Alignment,
    new_len: usize,
    _: usize,
) ?[*]u8 {
    if (memory.len == 0) return rawAlloc(undefined, new_len, .fromByteUnits(1), 0);
    const new_ptr = stdlib.realloc(@ptrCast(memory.ptr), new_len);
    if (new_ptr == null) return null;
    const many: [*]u8 = @ptrCast(new_ptr.?);
    return many;
}

fn rawFree(
    _: *anyopaque,
    memory: []u8,
    _: mem.Alignment,
    _: usize,
) void {
    if (memory.len == 0) return;
    stdlib.free(@ptrCast(memory.ptr));
}
