const std = @import("std");
const mem = std.mem;

const input = @embedFile("inputs/day3.in");

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var sum: u64 = 0;
    var f = true;
    for (0..input.len) |i| {
        if (f) blk: {
            if (!mem.startsWith(u8, input[i..], "mul(")) break :blk;
            const i_comma = mem.indexOfPos(u8, input, i, ",") orelse break :blk;
            const i_end = mem.indexOfPos(u8, input, i, ")") orelse break :blk;
            if (i_end < i_comma) break :blk;

            const num1 = std.fmt.parseInt(u64, input[i + 4 .. i_comma], 10) catch break :blk;
            const num2 = std.fmt.parseInt(u64, input[i_comma + 1 .. i_end], 10) catch break :blk;

            sum += num1 * num2;
        }

        if (mem.startsWith(u8, input[i..], "do()")) f = true;
        if (mem.startsWith(u8, input[i..], "don't()")) f = false;
    }

    try stdout.print("{d}\n", .{sum});
    try bw.flush(); // don't forget to flush!
}
