const std = @import("std");
const mem = std.mem;

const input = @embedFile("inputs/day5.in");
//const input = @embedFile("sample.in");

fn part1(allocator: mem.Allocator, stdout: std.io.AnyWriter) !void {
    var it = mem.splitSequence(u8, input, "\n\n");
    const rules = mem.trim(u8, it.next().?, " \n");
    const updates = mem.trim(u8, it.next().?, " \n");

    var map = std.hash_map.AutoHashMap(u64, std.ArrayList(u64)).init(allocator);
    var line_it = mem.splitScalar(u8, rules, '\n');
    while (line_it.next()) |rule| {
        var rule_it = mem.splitScalar(u8, rule, '|');
        const page1 = try std.fmt.parseInt(u64, rule_it.next().?, 10);
        const page2 = try std.fmt.parseInt(u64, rule_it.next().?, 10);
        const entry = try map.getOrPutValue(page2, std.ArrayList(u64).init(allocator));
        try entry.value_ptr.append(page1);
    }

    var sum: u64 = 0;
    line_it = mem.splitScalar(u8, updates, '\n');
    while (line_it.next()) |line| {
        var page_it = mem.splitScalar(u8, line, ',');
        var set: [100]bool = undefined;
        @memset(&set, false);
        var f = true;

        var pages = std.ArrayList(u64).init(allocator);
        while (page_it.next()) |raw_page| {
            const page = try std.fmt.parseInt(u64, raw_page, 10);
            try pages.append(page);
            if (set[page]) {
                f = false;
                break;
            }

            const dependencies = map.get(page) orelse continue;
            for (dependencies.items) |dep| {
                set[dep] = true;
            }
        }

        if (f) {
            //sum += 1;
            sum += pages.items[pages.items.len / 2];
        }
    }
    try stdout.print("{d}\n", .{sum});
}

fn dfs(adj: [100]std.ArrayList(u64), set: *[100]bool, sorted: *std.ArrayList(u64), u: u64) !void {
    for (adj[u].items) |v| {
        if (!set[v]) continue;
        try dfs(adj, set, sorted, v);
    }
    try sorted.append(u);
    set[u] = false;
}
fn part2(allocator: mem.Allocator, stdout: std.io.AnyWriter) !void {
    var it = mem.splitSequence(u8, input, "\n\n");
    const rules = mem.trim(u8, it.next().?, " \n");
    const updates = mem.trim(u8, it.next().?, " \n");

    var adj: [100]std.ArrayList(u64) = undefined;
    for (0..100) |i| adj[i] = std.ArrayList(u64).init(allocator);

    var line_it = mem.splitScalar(u8, rules, '\n');
    while (line_it.next()) |rule| {
        var rule_it = mem.splitScalar(u8, rule, '|');
        const page1 = try std.fmt.parseInt(u64, rule_it.next().?, 10);
        const page2 = try std.fmt.parseInt(u64, rule_it.next().?, 10);
        try adj[page2].append(page1);
    }

    var sum: u64 = 0;
    line_it = mem.splitScalar(u8, updates, '\n');
    while (line_it.next()) |line| {
        var page_it = mem.splitScalar(u8, line, ',');
        var pages = std.ArrayList(u64).init(allocator);

        var set: [100]bool = undefined;
        @memset(&set, false);
        var f = true;
        while (page_it.next()) |raw_page| {
            const page = try std.fmt.parseInt(u64, raw_page, 10);
            try pages.append(page);

            if (set[page]) {
                f = false;
            }

            for (adj[page].items) |dep| {
                set[dep] = true;
            }
        }
        @memset(&set, false);
        for (pages.items) |page| set[page] = true;

        if (!f) {
            pages.clearAndFree();
            for (0..100) |u| if (set[u]) try dfs(adj, &set, &pages, u);
            sum += pages.items[pages.items.len / 2];
        }
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
