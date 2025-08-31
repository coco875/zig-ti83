const stdlib = @cImport(@cInclude("stdlib.h"));

// ArrayListLite: sous-ensemble minimal de std.ArrayList pour éviter l'intrinsic
// @llvm.returnaddress sur ce backend. Pas d'allocateur paramétrable: utilise
// directement malloc/realloc/free C; interface proche (items, capacity, append...).
// Erreurs: seulement error.OutOfMemory.
pub fn ArrayListLite(comptime T: type) type {
    return struct {
        items: []T = &[_]T{}, // slice reflétant len
        capacity: usize = 0,
        ptr: [*]T = undefined, // mémoire (valide si capacity > 0)
        len: usize = 0,

        const Self = @This();
        pub const Error = error{OutOfMemory};

        pub fn init() Self {
            return .{};
        }

        fn grow(self: *Self, min_needed: usize) Error!void {
            var new_cap: usize = if (self.capacity == 0) 16 else self.capacity * 2;
            while (new_cap < min_needed) new_cap *= 2;
            const raw = if (self.capacity == 0)
                stdlib.malloc(new_cap * @sizeOf(T))
            else
                stdlib.realloc(@ptrCast(self.ptr), new_cap * @sizeOf(T));
            if (raw == null) return error.OutOfMemory;
            self.ptr = @ptrCast(raw.?);
            self.capacity = new_cap;
            // reconstruire slice
            self.items = self.ptr[0..self.len];
        }

        pub fn ensureTotalCapacity(self: *Self, needed: usize) Error!void {
            if (needed > self.capacity) try self.grow(needed);
        }

        pub fn append(self: *Self, value: T) Error!void {
            if (self.len == self.capacity) try self.grow(self.len + 1);
            self.ptr[self.len] = value;
            self.len += 1;
            self.items = self.ptr[0..self.len];
        }

        pub fn appendSlice(self: *Self, slice: []const T) Error!void {
            if (slice.len == 0) return;
            const new_len = self.len + slice.len;
            if (new_len > self.capacity) try self.grow(new_len);
            var i: usize = 0;
            while (i < slice.len) : (i += 1) self.ptr[self.len + i] = slice[i];
            self.len = new_len;
            self.items = self.ptr[0..self.len];
        }

        pub fn clearRetainingCapacity(self: *Self) void {
            self.len = 0;
            self.items = self.ptr[0..0];
        }

        pub fn shrinkRetainingCapacity(self: *Self, new_len: usize) void {
            if (new_len <= self.len) {
                self.len = new_len;
                self.items = self.ptr[0..self.len];
            }
        }

        pub fn deinit(self: *Self) void {
            if (self.capacity != 0) stdlib.free(@ptrCast(self.ptr));
            self.* = .{};
        }
    };
}
