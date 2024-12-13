const std = @import("std");
const mem = std.mem;
const fmt = std.fmt;
const math = std.math;

const input = @embedFile("inputs/day13.in");

fn parse_cords(line: []const u8, x: *u64, y: *u64) !void {
    var start = mem.indexOf(u8, line, "X").? + 2;
    var end = mem.indexOf(u8, line, ",").?;
    x.* = try fmt.parseInt(u64, line[start..end], 10);
    start = mem.indexOf(u8, line, "Y").? + 2;
    end = line.len;
    y.* = try fmt.parseInt(u64, line[start..end], 10);
}

fn part1(allocator: mem.Allocator, stdout: std.io.AnyWriter) !void {
    _ = allocator;
    var sum: u64 = 0;

    var block_iter = mem.splitSequence(u8, mem.trim(u8, input, " \n"), "\n\n");
    while (block_iter.next()) |input_block| {
        var lines_iter = mem.splitSequence(u8, input_block, "\n");
        const input_button_a = lines_iter.next().?;
        const input_button_b = lines_iter.next().?;
        const input_target = lines_iter.next().?;

        var ax: u64 = undefined;
        var ay: u64 = undefined;
        var bx: u64 = undefined;
        var by: u64 = undefined;
        var tx: u64 = undefined;
        var ty: u64 = undefined;
        try parse_cords(input_button_a, &ax, &ay);
        try parse_cords(input_button_b, &bx, &by);
        try parse_cords(input_target, &tx, &ty);

        var a_cost: ?u64 = null;
        var b_cost: ?u64 = null;

        outer: for (0..101) |a_presses| {
            for (0..101) |b_presses| {
                if (a_presses * ax + b_presses * bx == tx and
                    a_presses * ay + b_presses * by == ty)
                {
                    a_cost = a_presses * 3 + b_presses;
                    break :outer;
                }
            }
        }
        outer: for (0..101) |b_presses| {
            for (0..101) |a_presses| {
                if (a_presses * ax + b_presses * bx == tx and
                    a_presses * ay + b_presses * by == ty)
                {
                    b_cost = a_presses * 3 + b_presses;
                    break :outer;
                }
            }
        }

        sum += if (a_cost != null and b_cost != null) @min(a_cost.?, b_cost.?) else a_cost orelse b_cost orelse 0;
    }
    try stdout.print("{d}\n", .{sum});
}

fn parse_cords_signed(line: []const u8, x: *i64, y: *i64) !void {
    var start = mem.indexOf(u8, line, "X").? + 2;
    var end = mem.indexOf(u8, line, ",").?;
    x.* = try fmt.parseInt(i64, line[start..end], 10);
    start = mem.indexOf(u8, line, "Y").? + 2;
    end = line.len;
    y.* = try fmt.parseInt(i64, line[start..end], 10);
}

fn part2(allocator: mem.Allocator, stdout: std.io.AnyWriter) !void {
    _ = allocator;
    var sum: u64 = 0;

    var block_iter = mem.splitSequence(u8, mem.trim(u8, input, " \n"), "\n\n");
    while (block_iter.next()) |input_block| {
        var lines_iter = mem.splitSequence(u8, input_block, "\n");
        const input_button_a = lines_iter.next().?;
        const input_button_b = lines_iter.next().?;
        const input_target = lines_iter.next().?;

        var ax: i64 = undefined;
        var ay: i64 = undefined;
        var bx: i64 = undefined;
        var by: i64 = undefined;
        var tx: i64 = undefined;
        var ty: i64 = undefined;
        try parse_cords_signed(input_button_a, &ax, &ay);
        try parse_cords_signed(input_button_b, &bx, &by);
        try parse_cords_signed(input_target, &tx, &ty);

        tx += 10000000000000;
        ty += 10000000000000;

        const det = ax * by - ay * bx;
        if (det == 0) {
            if (ax * ty - ay * tx != 0) continue;
            if (@abs(tx) % math.gcd(@abs(ax), @abs(bx)) > 0) continue;

            var a_count: i64 = 0;
            while (@mod(a_count * ax, bx) != @mod(tx, bx)) a_count += 1;
            var b_count: i64 = 0;
            while (@mod(b_count * bx, ax) != @mod(tx, ax)) b_count += 1;
            sum += @intCast(@min(
                @divExact(tx - a_count * ax, bx) + a_count * 3,
                @divExact(tx - b_count * bx, ax) * 3 + b_count,
            ));
            continue;
        }

        // matrix stuff
        const a_count = by * tx - bx * ty;
        const b_count = -ay * tx + ax * ty;
        if (@abs(a_count) % @abs(det) > 0 or @abs(a_count) % @abs(det) > 0) continue;
        sum += @intCast(@divExact(a_count, det) * 3 + @divExact(b_count, det));
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
