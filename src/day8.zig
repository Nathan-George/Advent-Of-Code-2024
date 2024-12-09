const std = @import("std");
const mem = std.mem;

const input = @embedFile("inputs/day8.in");
//const input = @embedFile("sample.in");

fn part1(allocator: mem.Allocator, stdout: std.io.AnyWriter) !void {
    const List = std.ArrayList(usize);

    var grid = try allocator.alloc(u8, input.len);
    @memcpy(grid, input);

    var antena_map: [256]List = undefined;
    @memset(&antena_map, List.init(allocator));

    const width = mem.indexOf(u8, grid, "\n").? + 1;
    const size = grid.len;

    for (grid, 0..) |frequency, i| {
        if (frequency == '.' or frequency == '\n') continue;
        try antena_map[frequency].append(i);
    }

    for (antena_map) |antenas| {
        mem.sort(usize, antenas.items, {}, std.sort.asc(usize));
        for (antenas.items, 0..) |loc1, i| {
            for (antenas.items[i + 1 ..]) |loc2| {
                const height = loc2 / width - loc1 / width;
                const delta = (loc2 - loc1) / std.math.gcd(loc2 - loc1, height);

                grid[loc1] = '#';
                var antinode = loc1 + delta;
                const delta_height = (antinode) / width - (loc1) / width;
                while (antinode < size and delta_height == (antinode) / width - (antinode - delta) / width) {
                    defer antinode += delta;
                    if (grid[antinode] != '\n') grid[antinode] = '#';
                }
                antinode = loc1;
                while (antinode > delta - 1 and delta_height == (antinode) / width - (antinode - delta) / width) {
                    antinode -= delta;
                    if (grid[antinode] != '\n') grid[antinode] = '#';
                }
            }
        }
    }

    std.debug.print("{s}", .{grid});
    try stdout.print("{d}\n", .{mem.count(u8, grid, "#")});
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
