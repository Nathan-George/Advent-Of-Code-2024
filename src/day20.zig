const std = @import("std");
const mem = std.mem;

const input = @embedFile("inputs/day20.in");
//const input = @embedFile("inputs/sample.in");

fn part1(allocator: mem.Allocator, stdout: std.io.AnyWriter) !void {
    const List = std.ArrayList(usize);
    const width = mem.indexOf(u8, input, "\n").? + 1;
    const size = input.len;

    const start_index = mem.indexOf(u8, input, "S").?;
    const end_index = mem.indexOf(u8, input, "E").?;

    var maze = try allocator.alloc(u8, input.len);
    @memcpy(maze, input);
    maze[start_index] = '.';
    maze[end_index] = '.';

    var path = List.init(allocator);
    try path.append(start_index);
    while (path.getLast() != end_index) {
        const current = path.getLast();
        const previous = if (path.items.len < 2) start_index else path.items[path.items.len - 2];
        var next: usize = undefined;
        if (maze[current - 1] == '.' and current - 1 != previous) {
            next = current - 1;
        } else if (maze[current + 1] == '.' and current + 1 != previous) {
            next = current + 1;
        } else if (maze[current - width] == '.' and current - width != previous) {
            next = current - width;
        } else {
            next = current + width;
        }
        try path.append(next);
    }

    var distances = try allocator.alloc(u64, maze.len);
    for (path.items, 0..) |index, i| {
        distances[index] = @intCast(i);
    }
    //for (0..maze.len) |i| {
    //    std.debug.print("{d}{c} ", .{ distances[i] % 10, maze[i] });
    //    if ((i + 1) % width == 0) std.debug.print("\n", .{});
    //}

    const cutoff: u64 = 100 + 2;
    var count: u64 = 0;
    for (maze, 0..) |element, i| {
        if (element != '.') continue;
        if (i >= 2 * width and maze[i - 2 * width] == '.' and distances[i - 2 * width] >= distances[i] + cutoff) count += 1;
        if (i + 2 * width < size and maze[i + 2 * width] == '.' and distances[i + 2 * width] >= distances[i] + cutoff) count += 1;
        if (i % width > 1 and maze[i - 2] == '.' and distances[i - 2] >= distances[i] + cutoff) count += 1;
        if ((i + 2) % width > 1 and maze[i + 2] == '.' and distances[i + 2] >= distances[i] + cutoff) count += 1;
    }
    try stdout.print("{d}\n", .{count});
}

fn part2(allocator: mem.Allocator, stdout: std.io.AnyWriter) !void {
    const List = std.ArrayList(usize);
    const width = mem.indexOf(u8, input, "\n").? + 1;

    const start_index = mem.indexOf(u8, input, "S").?;
    const end_index = mem.indexOf(u8, input, "E").?;

    var maze = try allocator.alloc(u8, input.len);
    @memcpy(maze, input);
    maze[start_index] = '.';
    maze[end_index] = '.';

    var path = List.init(allocator);
    try path.append(start_index);
    while (path.getLast() != end_index) {
        const current = path.getLast();
        const previous = if (path.items.len < 2) start_index else path.items[path.items.len - 2];
        var next: usize = undefined;
        if (maze[current - 1] == '.' and current - 1 != previous) {
            next = current - 1;
        } else if (maze[current + 1] == '.' and current + 1 != previous) {
            next = current + 1;
        } else if (maze[current - width] == '.' and current - width != previous) {
            next = current - width;
        } else {
            next = current + width;
        }
        try path.append(next);
    }

    var distances = try allocator.alloc(u64, maze.len);
    @memset(distances, 0);
    for (path.items, 0..) |index, i| {
        distances[index] = @intCast(i);
    }

    const cutoff: u64 = 100;
    var count: u64 = 0;
    for (maze, 0..) |start, i| {
        if (start != '.') continue;
        for (maze, 0..) |end, j| {
            if (end != '.') continue;

            const dist = @max(i % width, j % width) - @min(i % width, j % width) + @max(i / width, j / width) - @min(i / width, j / width);
            if (dist > 20) continue;
            if (distances[j] < distances[i] + dist + cutoff) continue;
            count += 1;
        }
    }
    try stdout.print("{d}\n", .{count});
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
