const std = @import("std");
const mem = std.mem;

const input = @embedFile("inputs/day19.in");

fn part1(allocator: mem.Allocator, stdout: std.io.AnyWriter) !void {
    const List = std.ArrayList([]const u8);

    var section_iter = mem.splitSequence(u8, mem.trim(u8, input, "\n"), "\n\n");

    const patterns_section = section_iter.next().?;
    const targets_section = section_iter.next().?;

    var patterns = List.init(allocator);
    var patterns_iter = mem.splitSequence(u8, patterns_section, ", ");
    while (patterns_iter.next()) |pattern| {
        try patterns.append(pattern);
    }

    var sum: u64 = 0;
    var targets_iter = mem.splitSequence(u8, targets_section, "\n");
    while (targets_iter.next()) |target| {
        if (target.len == 0) {
            sum += 1;
            continue;
        }

        var dp = try allocator.alloc(bool, target.len + 1);
        @memset(dp, false);
        dp[0] = true;
        for (0..target.len) |i| {
            if (!dp[i]) continue;
            for (patterns.items) |pattern| {
                if (mem.startsWith(u8, target[i..], pattern)) dp[i + pattern.len] = true;
            }
        }

        if (dp[target.len]) sum += 1;
    }

    try stdout.print("{d}\n", .{sum});
}

fn part2(allocator: mem.Allocator, stdout: std.io.AnyWriter) !void {
    const List = std.ArrayList([]const u8);

    var section_iter = mem.splitSequence(u8, mem.trim(u8, input, "\n"), "\n\n");

    const patterns_section = section_iter.next().?;
    const targets_section = section_iter.next().?;

    var patterns = List.init(allocator);
    var patterns_iter = mem.splitSequence(u8, patterns_section, ", ");
    while (patterns_iter.next()) |pattern| {
        try patterns.append(pattern);
    }

    var sum: u64 = 0;
    var targets_iter = mem.splitSequence(u8, targets_section, "\n");
    while (targets_iter.next()) |target| {
        var dp = try allocator.alloc(u64, target.len + 1);
        @memset(dp, 0);
        dp[0] = 1;
        for (0..target.len) |i| {
            for (patterns.items) |pattern| {
                if (mem.startsWith(u8, target[i..], pattern)) dp[i + pattern.len] += dp[i];
            }
        }
        sum += dp[target.len];
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
