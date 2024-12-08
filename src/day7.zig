const std = @import("std");
const mem = std.mem;
const fmt = std.fmt;

const input = @embedFile("inputs/day7.in");
//const input = @embedFile("sample.in");

fn part1(allocator: mem.Allocator, stdout: std.io.AnyWriter) !void {
    var sum: u64 = 0;
    var line_it = mem.splitSequence(u8, mem.trim(u8, input, " \n"), "\n");
    while (line_it.next()) |line| {
        var expr_it = mem.splitSequence(u8, line, ": ");
        const target = try fmt.parseInt(u64, expr_it.next().?, 10);
        const raw_nums = expr_it.next().?;
        var nums_it = mem.splitSequence(u8, raw_nums, " ");
        var nums = std.ArrayList(u64).init(allocator);
        while (nums_it.next()) |raw_num| {
            try nums.append(try fmt.parseInt(u64, raw_num, 10));
        }

        var f = false;
        for (0..std.math.pow(u64, 3, nums.items.len - 1)) |i| {
            var operators = i;
            var x = nums.items[0];
            for (1..nums.items.len) |j| {
                defer operators /= 3;
                if (operators % 3 == 0) {
                    x += nums.items[j];
                } else if (operators % 3 == 1) {
                    x *= nums.items[j];
                } else {
                    var tmp = nums.items[j];
                    var reverse: u64 = 1;
                    while (tmp > 0) : (tmp /= 10) reverse = reverse * 10 + tmp % 10;
                    while (reverse > 1) : (reverse /= 10) x = x * 10 + reverse % 10;
                }
                if (x > target) break;
            }
            if (x == target) f = true;
        }

        if (f) sum += target;
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

    try bw.flush(); // don't forget to flush!
}
