const std = @import("std");
const mem = std.mem;

const input = @embedFile("inputs/day4.in");
//const input = @embedFile("sample.in");

pub fn part1(allocator: mem.Allocator, stdout: std.io.AnyWriter) !void {
    var lines = std.ArrayList([]const u8).init(allocator);
    var line_iter = mem.splitScalar(u8, input, '\n');
    while (line_iter.next()) |line| {
        if (line.len == 0) continue;
        try lines.append(line);
    }

    const height = lines.items.len;
    const width = lines.items[0].len;

    const horizontal = lines.items;
    const vertical = try allocator.alloc([]u8, width);
    for (0..width) |i| {
        vertical[i] = try allocator.alloc(u8, height);
        for (0..height) |j| {
            vertical[i][j] = horizontal[j][i];
        }
    }

    const up_diagonal = try allocator.alloc([]u8, width + height - 1);
    const down_diagonal = try allocator.alloc([]u8, width + height - 1);
    for (0..width + height - 1) |i| {
        const len = @min(i + 1, width) + @min(i + 1, height) - (i + 1);
        up_diagonal[i] = try allocator.alloc(u8, len);
        down_diagonal[i] = try allocator.alloc(u8, len);
        for (0..len) |j| {
            up_diagonal[i][j] = horizontal[@min(height - 1, i) - j][j + (i + 1 - @min(i + 1, height))];
            down_diagonal[i][j] = horizontal[j + (i + 1 - @min(i + 1, width))][j + (width - @min(width, i + 1))];
        }
    }

    //for (horizontal) |line| std.debug.print("{s}\n", .{line});
    //std.debug.print("\n", .{});
    //for (vertical) |line| std.debug.print("{s}\n", .{line});
    //std.debug.print("\n", .{});
    //for (up_diagonal) |line| std.debug.print("{s}\n", .{line});
    //std.debug.print("\n", .{});
    //for (down_diagonal) |line| std.debug.print("{s}\n", .{line});
    //std.debug.print("\n", .{});

    const word_searches = [_][]const []const u8{ horizontal, vertical, up_diagonal, down_diagonal };
    var sum: u64 = 0;
    for (word_searches) |search| {
        for (search) |line| {
            sum += mem.count(u8, line, "XMAS");
            sum += mem.count(u8, line, "SAMX");
        }
    }
    try stdout.print("{d}\n", .{sum});
}

pub fn part2(allocator: mem.Allocator, stdout: std.io.AnyWriter) !void {
    var lines = std.ArrayList([]const u8).init(allocator);
    var line_iter = mem.splitScalar(u8, input, '\n');
    while (line_iter.next()) |line| {
        if (line.len == 0) continue;
        try lines.append(line);
    }

    const height = lines.items.len;
    const width = lines.items[0].len;
    const horizontal = lines.items;

    var sum: u64 = 0;
    for (1..height - 1) |i| {
        for (1..width - 1) |j| {
            if (horizontal[i][j] == 'A' and horizontal[i - 1][j - 1] + horizontal[i + 1][j + 1] == 'M' + 'S' and horizontal[i - 1][j + 1] + horizontal[i + 1][j - 1] == 'M' + 'S') {
                sum += 1;
            }
        }
    }
    try stdout.print("{d}\n", .{sum});
}

pub fn main() !void {
    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    try part1(allocator, stdout.any());
    try part2(allocator, stdout.any());

    try bw.flush(); // don't forget to flush!
}
