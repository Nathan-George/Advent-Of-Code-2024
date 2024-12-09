const std = @import("std");
const mem = std.mem;

const input = @embedFile("inputs/day9.in");

fn part1(allocator: mem.Allocator, stdout: std.io.AnyWriter) !void {
    const List = std.ArrayList(?usize);
    var file_system = List.init(allocator);
    for (mem.trim(u8, input, " \n"), 0..) |block, i| {
        const size = block - '0';
        for (0..size) |_| {
            if (i & 1 == 0) try file_system.append(i >> 1) else try file_system.append(null);
        }
    }

    var l = @as(usize, 0);
    var r = file_system.items.len - 1;
    while (file_system.items[l]) |_| l += 1;
    while (file_system.items[r] == null) r -= 1;
    while (l < r) {
        file_system.items[l] = file_system.items[r];
        file_system.items[r] = null;
        while (file_system.items[l]) |_| l += 1;
        while (file_system.items[r] == null) r -= 1;
    }

    var check_sum = @as(u64, 0);
    for (file_system.items[0..l], 0..) |id, i| {
        check_sum += id.? * i;
    }

    try stdout.print("{d}\n", .{check_sum});
}

fn part2(allocator: mem.Allocator, stdout: std.io.AnyWriter) !void {
    const List = std.ArrayList(?usize);
    var file_system = List.init(allocator);
    for (mem.trim(u8, input, " \n"), 0..) |block, i| {
        const size = block - '0';
        for (0..size) |_| {
            if (i & 1 == 0) try file_system.append(i >> 1) else try file_system.append(null);
        }
    }

    const block = [_]?usize{null} ** 10;

    var l = [_]usize{0} ** 10;
    var r = file_system.items.len;
    while (r > 0) {
        r -= 1;
        while (file_system.items[r] == null) r -= 1;
        var length: usize = 1;
        while (r > 0 and file_system.items[r] == file_system.items[r - 1]) : (r -= 1) length += 1;

        const loc = &l[length];
        if (mem.indexOfPos(?usize, file_system.items, loc.*, block[0..length])) |i| {
            if (i > r) continue;
            loc.* = i;
            @memset(file_system.items[loc.* .. loc.* + length], file_system.items[r]);
            @memset(file_system.items[r .. r + length], null);
        } else {
            loc.* = file_system.items.len;
        }
    }

    var check_sum = @as(u64, 0);
    for (file_system.items, 0..) |opt_id, i| {
        if (opt_id) |id| check_sum += id * i;
    }

    try stdout.print("{d}\n", .{check_sum});
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
