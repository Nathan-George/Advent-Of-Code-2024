const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;

const input = @embedFile("inputs/day12.in");
//const input = @embedFile("inputs/sample.in");

const UnionFind = struct {
    const Element = union(enum) {
        parent: usize,
        size: usize,
    };

    const Self = @This();

    allocator: Allocator,
    uf: []Element,
    fn init(allocator: Allocator, len: usize) !Self {
        const uf = try allocator.alloc(Element, len);
        @memset(uf, .{ .size = 1 });
        return Self{ .allocator = allocator, .uf = uf };
    }
    fn deinit(self: *Self) void {
        self.allocator.free(self.uf);
    }

    fn find(self: *Self, a: usize) usize {
        switch (self.uf[a]) {
            .size => return a,
            .parent => |*p| {
                p.* = self.find(p.*);
                return p.*;
            },
        }
    }

    fn sizeOf(self: *Self, a: usize) usize {
        return self.uf[self.find(a)].size;
    }

    fn sameSet(self: *Self, a: usize, b: usize) bool {
        return self.find(a) == self.find(b);
    }

    fn merge(self: *Self, a: usize, b: usize) void {
        var small = self.find(a);
        var large = self.find(b);
        if (small == large) return;
        if (self.uf[large].size > self.uf[small].size) mem.swap(usize, &small, &large);
        self.uf[large].size += self.uf[small].size;
        self.uf[small] = .{ .parent = large };
    }
};

fn part1(allocator: mem.Allocator, stdout: std.io.AnyWriter) !void {
    const width = mem.indexOf(u8, input, "\n").? + 1;
    const size = input.len;
    var uf = try UnionFind.init(allocator, input.len);
    for (input, 0..) |plant, i| {
        if (plant == '\n') continue;
        if (i % width > 0 and plant == input[i - 1]) uf.merge(i, i - 1);
        if (i >= width and plant == input[i - width]) uf.merge(i, i - width);
    }

    var sum: u64 = 0;
    for (input, 0..) |plant, i| {
        if (plant == '\n') continue;
        if (!(i % width > 0 and plant == input[i - 1])) sum += @intCast(uf.sizeOf(i));
        if (!((i + 1) % width > 0 and plant == input[i + 1])) sum += @intCast(uf.sizeOf(i));
        if (!(i >= width and plant == input[i - width])) sum += @intCast(uf.sizeOf(i));
        if (!(i + width < size and plant == input[i + width])) sum += @intCast(uf.sizeOf(i));
    }
    try stdout.print("{d}\n", .{sum});
}

fn part2(allocator: mem.Allocator, stdout: std.io.AnyWriter) !void {
    const width = mem.indexOf(u8, input, "\n").? + 1;
    const size = input.len;
    var uf = try UnionFind.init(allocator, input.len);
    for (input, 0..) |plant, i| {
        if (plant == '\n') continue;
        if (i % width > 0 and plant == input[i - 1]) uf.merge(i, i - 1);
        if (i >= width and plant == input[i - width]) uf.merge(i, i - width);
    }

    var sum: u64 = 0;
    for (input, 0..) |plant, i| {
        if (plant == '\n') continue;
        if ((i % width == 0 or plant != input[i - 1]) and (i < width or plant != input[i - width])) sum += @intCast(2 * uf.sizeOf(i));
        if ((i % width == width - 1 or plant != input[i + 1]) and (i + width >= size or plant != input[i + width])) sum += @intCast(2 * uf.sizeOf(i));
        if (i % width > 0 and i + width < size and input[i - 1] == input[i + width] and input[i + width - 1] == input[i - 1] and input[i - 1] != input[i]) sum += @intCast(2 * uf.sizeOf(i - 1));
        if ((i + 1) % width > 0 and i >= width and input[i + 1] == input[i - width] and input[i - width + 1] == input[i + 1] and input[i + 1] != input[i]) sum += @intCast(2 * uf.sizeOf(i + 1));
    }
    try stdout.print("{d}\n", .{sum});
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try part1(allocator, stdout.any());
    try part2(allocator, stdout.any());

    try bw.flush(); // don't forget to flush!
}
