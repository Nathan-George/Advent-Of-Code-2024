const std = @import("std");
const mem = std.mem;

const input = @embedFile("inputs/day11.in");
//const input = @embedFile("inputs/sample.in");

fn log10(a: anytype) u16 {
    var num = a;
    var length: u16 = 0;
    while (num > 0) : (num /= 10) {
        length += 1;
    }
    return length;
}

fn part1(allocator: mem.Allocator, stdout: std.io.AnyWriter) !void {
    const List = std.ArrayList(u256);

    var current = List.init(allocator);
    var nums_iter = mem.splitSequence(u8, mem.trim(u8, input, " \n"), " ");
    while (nums_iter.next()) |raw_num| {
        const num = try std.fmt.parseInt(u256, raw_num, 10);
        try current.append(num);
    }
    var next = List.init(allocator);
    for (0..25) |_| {
        while (current.popOrNull()) |num| {
            const length = log10(num);
            if (num == 0) {
                try next.append(1);
            } else if (length & 1 > 0) {
                try next.append(num * 2024);
            } else {
                const pow = std.math.pow(u256, 10, length / 2);
                try next.append(num % pow);
                try next.append(num / pow);
            }
        }
        mem.swap(List, &current, &next);
    }
    //std.debug.print("{any}\n", .{current.items});
    try stdout.print("{d}\n", .{current.items.len});
}

fn part2(allocator: mem.Allocator, stdout: std.io.AnyWriter) !void {
    const BigInt = u512;
    //const List = std.ArrayList(BigInt);
    const Map = std.hash_map.AutoHashMap(BigInt, BigInt);

    var current = Map.init(allocator);
    var nums_iter = mem.splitSequence(u8, mem.trim(u8, input, " \n"), " ");
    while (nums_iter.next()) |raw_num| {
        const num = try std.fmt.parseInt(BigInt, raw_num, 10);
        (try current.getOrPutValue(num, 0)).value_ptr.* += 1;
    }
    for (0..75) |_| {
        var next = Map.init(allocator);
        var map_iter = current.iterator();
        while (map_iter.next()) |entry| {
            const num = entry.key_ptr.*;
            const count = entry.value_ptr.*;

            const length = log10(num);
            if (num == 0) {
                (try next.getOrPutValue(1, 0)).value_ptr.* += count;
            } else if (length & 1 > 0) {
                (try next.getOrPutValue(num * 2024, 0)).value_ptr.* += count;
            } else {
                const pow = std.math.pow(BigInt, 10, length / 2);
                (try next.getOrPutValue(num % pow, 0)).value_ptr.* += count;
                (try next.getOrPutValue(num / pow, 0)).value_ptr.* += count;
            }
        }
        mem.swap(Map, &next, &current);
    }
    //std.debug.print("{any}\n", .{current.items});
    var sum: BigInt = 0;
    var map_iter = current.iterator();
    while (map_iter.next()) |entry| sum += entry.value_ptr.*;
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
