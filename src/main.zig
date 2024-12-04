const std = @import("std");
const mem = std.mem;

const input = @embedFile("inputs/day1.in");

fn part1(allocator: mem.Allocator, stdout: std.io.AnyWriter) !void {
    _ = allocator;
    _ = stdout;
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

    try bw.flush(); // don't forget to flush!
}
