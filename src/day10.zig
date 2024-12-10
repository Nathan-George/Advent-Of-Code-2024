const std = @import("std");
const mem = std.mem;

const Allocator = mem.Allocator;

const input = @embedFile("inputs/day10.in");
//const input = @embedFile("inputs/sample.in");

const AdjacencyList = []std.ArrayList(usize);
fn count_nines(adj: AdjacencyList, vertex: usize, reached: []bool) u64 {
    if (reached[vertex]) return 0;
    reached[vertex] = true;
    if (input[vertex] == '9') return 1;

    var sum: u64 = 0;
    for (adj[vertex].items) |neighbor| {
        sum += count_nines(adj, neighbor, reached);
    }
    return sum;
}
fn reset(adj: AdjacencyList, vertex: usize, reached: []bool) void {
    if (!reached[vertex]) return;
    reached[vertex] = false;
    for (adj[vertex].items) |neighbor| reset(adj, neighbor, reached);
}

fn part1(allocator: mem.Allocator, stdout: std.io.AnyWriter) !void {
    const List = std.ArrayList(usize);

    const width = mem.indexOf(u8, input, "\n").? + 1;
    const size = input.len;

    var adj = try allocator.alloc(List, input.len);
    for (adj) |*neighbors| neighbors.* = List.init(allocator);
    for (input, 0..) |height, i| {
        if (i % width > 0 and input[i - 1] == height + 1) try adj[i].append(i - 1);
        if ((i + 1) % width > 0 and input[i + 1] == height + 1) try adj[i].append(i + 1);
        if (i >= width and input[i - width] == height + 1) try adj[i].append(i - width);
        if (i + width < size and input[i + width] == height + 1) try adj[i].append(i + width);
    }

    var sum: u64 = 0;
    const reached = try allocator.alloc(bool, input.len);
    for (input, 0..) |height, i| {
        if (height == '0') {
            sum += count_nines(adj, i, reached);
            reset(adj, i, reached);
        }
    }

    try stdout.print("{d}\n", .{sum});
}

fn part2(allocator: mem.Allocator, stdout: std.io.AnyWriter) !void {
    const width = mem.indexOf(u8, input, "\n").? + 1;
    const size = input.len;

    const paths = try allocator.alloc(u64, input.len);
    @memset(paths, 0);
    for (input, 0..) |height, i| {
        if (height == '9') paths[i] = 1;
    }
    for (0..9) |i| {
        const target = 8 - i + '0';
        for (input, 0..) |height, j| {
            if (height != target) continue;
            if (j % width > 0 and input[j - 1] == height + 1) paths[j] += paths[j - 1];
            if ((j + 1) % width > 0 and input[j + 1] == height + 1) paths[j] += paths[j + 1];
            if (j >= width and input[j - width] == height + 1) paths[j] += paths[j - width];
            if (j + width < size and input[j + width] == height + 1) paths[j] += paths[j + width];
        }
    }

    var sum: u64 = 0;
    for (input, 0..) |height, i| {
        if (height == '0') sum += paths[i];
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
