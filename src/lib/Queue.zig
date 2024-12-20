const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn Queue(T: type) type {
    return struct {
        const Self = @This();

        allocator: Allocator,
        data: []T,
        front_ptr: ?*T,
        back_ptr: *T,

        pub fn init(allocator: Allocator) Self {
            var instance: Self = undefined;
            instance.allocator = allocator;
            instance.data = &[_]T{};
            instance.front_ptr = instance.data.ptr;
            instance.back_ptr = instance.data.ptr;
            return instance;
        }

        pub fn enqueue(self: *Self, element: T) !void {
            try self.tnsureCapacity();
            self.back_ptr.* = element;
            if (self.front_ptr == null) self.front_ptr = self.back_ptr;
            if (self.back_ptr + 1 == self.data.ptr + self.data.len) {
                self.back_ptr = self.data.ptr;
            } else {
                self.back_ptr += 1;
            }
        }

        pub fn dequeue(self: *Self) ?T {
            if (self.front_ptr) |front| {
                const element_ptr = front;
                if (self.front_ptr + 1 == self.data.ptr + self.data.len) {
                    self.front_ptr = self.data.ptr;
                } else {
                    self.front_ptr += 1;
                }
                if (self.front_ptr == self.back_ptr) self.front_ptr = null;
                return element_ptr.*;
            }
            return null;
        }

        fn ensureCapacity(self: *Self) !void {
            if (self.back_ptr != self.front_ptr) return;
            if (self.data.len == 0) {
                self.data = try self.allocator.alloc(T, 1);
                self.front_ptr = null;
                self.back_ptr = self.data.ptr;
            }

            const old_memory = self.data;
            defer self.allocator.free(old_memory);

            const new_capacity = self.data.len << 1;
            self.data = try self.allocator.alloc(T, new_capacity);
            if (self.front_ptr < self.back_ptr) {
                const size = self.back_ptr - self.front_ptr;
                @memcpy(self.data[0..size], self.front_ptr[0..size]);
            } else {
                const size1 = old_memory.ptr + old_memory.len - self.front_ptr;
                const size2 = self.back_ptr - old_memory.ptr;
                @memcpy(self.data[0..size1], self.front_ptr[0..size1]);
                @memcpy(self.data[size1 .. size1 + size2], old_memory[0..size2]);
            }
        }
    };
}
