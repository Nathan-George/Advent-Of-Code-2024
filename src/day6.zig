const std = @import("std");
const mem = std.mem;

const input = @embedFile("inputs/day6.in");
//const input = @embedFile("sample.in");

const Dir = enum(u2) {
    up,
    down,
    right,
    left,
};

fn part1(allocator: mem.Allocator, stdout: std.io.AnyWriter) !void {
    const grid = try allocator.alloc(u8, input.len);
    @memcpy(grid, input);

    const width = mem.indexOf(u8, grid, "\n").? + 1;

    var dir: Dir = .up;
    const start = mem.indexOf(u8, grid, "^").?;
    var loc = start;
    while (true) {
        if (grid[loc] == '#') {
            switch (dir) {
                .up => {
                    loc += width;
                    dir = .right;
                },
                .down => {
                    loc -= width;
                    dir = .left;
                },
                .right => {
                    loc -= 1;
                    dir = .down;
                },
                .left => {
                    loc += 1;
                    dir = .up;
                },
            }
            continue;
        }
        grid[loc] = 'X';
        switch (dir) {
            .up => {
                if (loc < width) break;
                loc -= width;
            },
            .down => {
                if (loc + width >= grid.len) break;
                loc += width;
            },
            .right => {
                if (loc % width + 1 == width) break;
                loc += 1;
            },
            .left => {
                if (loc % width == 0) break;
                loc -= 1;
            },
        }
    }

    // part 1
    try stdout.print("{d}\n", .{mem.count(u8, grid, "X")});

    var sum: u64 = 0;
    const path = try allocator.alloc(u8, input.len);
    for (0..input.len) |i| {
        if (i == start) continue;
        if (input[i] == '\n') continue;
        if (grid[i] != 'X') continue;

        grid[i] = '#';
        defer grid[i] = 'X';

        loc = start;
        dir = .up;

        @memset(path, 0);
        while (true) {
            if (grid[loc] == '#') {
                switch (dir) {
                    .up => {
                        loc += width;
                        dir = .right;
                    },
                    .down => {
                        loc -= width;
                        dir = .left;
                    },
                    .right => {
                        loc -= 1;
                        dir = .down;
                    },
                    .left => {
                        loc += 1;
                        dir = .up;
                    },
                }
                continue;
            }

            const bit = @as(u8, 1) << @intFromEnum(dir);
            if (path[loc] & bit > 0) {
                sum += 1;
                break;
            }
            path[loc] |= bit;

            switch (dir) {
                .up => {
                    if (loc < width) break;
                    loc -= width;
                },
                .down => {
                    if (loc + width >= grid.len) break;
                    loc += width;
                },
                .right => {
                    if (loc % width + 1 == width) break;
                    loc += 1;
                },
                .left => {
                    if (loc % width == 0) break;
                    loc -= 1;
                },
            }
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

    try bw.flush(); // don't forget to flush!
}
