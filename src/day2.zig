const std = @import("std");
const mem = std.mem;

const input = @embedFile("inputs/day2.in");
//const input = @embedFile("sample.in");

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

    var sum: u64 = 0;

    var file_iter = mem.splitScalar(u8, input, '\n');
    tag: while (file_iter.next()) |line| {
        if (line.len == 0) continue;
        var list = std.ArrayList(i64).init(allocator);

        var line_iter = mem.splitScalar(u8, line, ' ');
        while (line_iter.next()) |raw_level| {
            const level = try std.fmt.parseInt(i64, raw_level, 10);
            try list.append(level);
        }

        const levels = list.items;

        var prev = levels[1];
        var f_asc = true;
        var f_dec = true;
        for (levels[2..]) |level| {
            if (level - prev > 3 or level - prev < 1) f_asc = false;
            if (level - prev < -3 or level - prev > -1) f_dec = false;
            prev = level;
        }
        if (f_asc or f_dec) {
            sum += 1;
            continue;
        }

        for (1..levels.len) |i| {
            prev = levels[0];
            f_asc = true;
            f_dec = true;
            for (1..levels.len) |j| {
                if (j == i) continue;
                const level = levels[j];
                if (level - prev > 3 or level - prev < 1) f_asc = false;
                if (level - prev < -3 or level - prev > -1) f_dec = false;
                prev = level;
            }
            if (f_asc or f_dec) {
                sum += 1;
                continue :tag;
            }
        }
        //std.debug.print("{any}\n", .{list.items});
    }

    try stdout.print("{d}\n", .{sum});
    try bw.flush(); // don't forget to flush!
}
