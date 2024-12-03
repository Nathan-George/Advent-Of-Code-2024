const std = @import("std");
const mem = std.mem;

const input = @embedFile("inputs/day1.in");

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
    var list1 = std.ArrayList(u64).init(allocator);
    // var list2 = std.ArrayList(u64).init(allocator);

    var map = std.hash_map.AutoHashMap(u64, u64).init(allocator);

    var iter = mem.splitScalar(u8, input, '\n');
    while (iter.next()) |line| {
        if (line.len == 0) continue;

        // std.debug.print("{s}\n", .{line[0..5]});
        // std.debug.print("{s}\n", .{line[8..13]});
        const num1 = try std.fmt.parseInt(u64, line[0..5], 10);
        const num2 = try std.fmt.parseInt(u64, line[8..13], 10);

        try list1.append(num1);
        if (map.getPtr(num2)) |value| {
            value.* += 1;
        } else {
            try map.put(num2, 1);
        }
        // try list2.append(num2);
    }

    var sum: u64 = 0;
    for (list1.items) |num1| {
        sum += num1 * (map.get(num1) orelse 0);
    }

    try stdout.print("{d}\n", .{sum});
    try bw.flush(); // don't forget to flush!
}
