const std = @import("std");
const mem = std.mem;
const fmt = std.fmt;

const input = @embedFile("inputs/day18.in");

const HEIGHT = 71;
const WIDTH = 71;

const Allocator = mem.Allocator;
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
    const List = std.ArrayList(usize);
    const size: usize = HEIGHT * WIDTH;
    var maze: [HEIGHT * WIDTH]bool = undefined;
    @memset(&maze, false);

    var line_iter = mem.splitSequence(u8, mem.trim(u8, input, "\n"), "\n");

    var i: usize = 0;
    while (line_iter.next()) |line| {
        if (i == 1024) break;
        defer i += 1;
        var coords_iter = mem.splitSequence(u8, line, ",");

        const x = try fmt.parseInt(usize, coords_iter.next().?, 10);
        const y = try fmt.parseInt(usize, coords_iter.next().?, 10);
        maze[WIDTH * y + x] = true;
    }

    //for (maze, 0..) |wall, j| {
    //    const char: u8 = if (wall) '#' else '.';
    //    std.debug.print("{c}", .{char});
    //    if ((j + 1) % WIDTH == 0) std.debug.print("\n", .{});
    //}

    var reached: [HEIGHT * WIDTH]bool = undefined;
    @memset(&reached, false);

    var current = List.init(allocator);
    var next = List.init(allocator);

    try current.append(0);
    var distance: u64 = 0;
    bfs: while (current.items.len > 0) {
        defer distance += 1;
        while (current.popOrNull()) |position| {
            if (position + 1 == size) break :bfs;
            if (maze[position]) continue;
            if (reached[position]) continue;
            reached[position] = true;

            if (position % WIDTH > 0) try next.append(position - 1);
            if ((position + 1) % WIDTH > 0) try next.append(position + 1);
            if (position >= WIDTH) try next.append(position - WIDTH);
            if (position + WIDTH < size) try next.append(position + WIDTH);
        }
        mem.swap(List, &current, &next);
    }

    try stdout.print("{d}\n", .{distance - 1});
}

fn part2(allocator: mem.Allocator, stdout: std.io.AnyWriter) !void {
    const List = std.ArrayList(usize);
    const size: usize = HEIGHT * WIDTH;
    var maze: [HEIGHT * WIDTH]u64 = undefined;
    @memset(&maze, 0);

    var line_iter = mem.splitSequence(u8, mem.trim(u8, input, "\n"), "\n");

    var coords = List.init(allocator);
    while (line_iter.next()) |line| {
        var coords_iter = mem.splitSequence(u8, line, ",");
        const x = try fmt.parseInt(usize, coords_iter.next().?, 10);
        const y = try fmt.parseInt(usize, coords_iter.next().?, 10);
        maze[WIDTH * y + x] += 1;
        try coords.append(WIDTH * y + x);
    }

    //for (maze, 0..) |wall, j| {
    //    const char: u8 = if (wall) '#' else '.';
    //    std.debug.print("{c}", .{char});
    //    if ((j + 1) % WIDTH == 0) std.debug.print("\n", .{});
    //}

    var uf = try UnionFind.init(allocator, size);
    for (0..size) |position| {
        if (maze[position] > 0) continue;
        if (position % WIDTH > 0 and maze[position - 1] == 0) uf.merge(position, position - 1);
        if ((position + 1) % WIDTH > 0 and maze[position + 1] == 0) uf.merge(position, position + 1);
        if (position >= WIDTH and maze[position - WIDTH] == 0) uf.merge(position, position - WIDTH);
        if (position + WIDTH < size and maze[position + WIDTH] == 0) uf.merge(position, position + WIDTH);
    }

    var rev_iter = mem.reverseIterator(coords.items);
    while (rev_iter.next()) |position| {
        maze[position] -= 1;

        if (maze[position] > 0) continue;
        if (position % WIDTH > 0 and maze[position - 1] == 0) uf.merge(position, position - 1);
        if ((position + 1) % WIDTH > 0 and maze[position + 1] == 0) uf.merge(position, position + 1);
        if (position >= WIDTH and maze[position - WIDTH] == 0) uf.merge(position, position - WIDTH);
        if (position + WIDTH < size and maze[position + WIDTH] == 0) uf.merge(position, position + WIDTH);

        if (uf.sameSet(0, size - 1)) {
            const x = position % WIDTH;
            const y = position / HEIGHT;
            try stdout.print("{d},{d}\n", .{ x, y });
            break;
        }
    }
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
