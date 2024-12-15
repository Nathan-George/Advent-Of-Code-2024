const std = @import("std");
const mem = std.mem;

const input = @embedFile("inputs/day15.in");
//const input = @embedFile("inputs/sample.in");

fn cast(T: type, a: anytype) T {
    return @intCast(a);
}

fn part1(allocator: mem.Allocator, stdout: std.io.AnyWriter) !void {
    var input_iter = std.mem.splitSequence(u8, input, "\n\n");

    const input_warehouse = input_iter.next().?;
    const input_instructions = input_iter.next().?;

    const width = mem.indexOf(u8, input_warehouse, "\n").? + 1;
    var warehouse = try allocator.alloc(u8, input_warehouse.len);
    @memcpy(warehouse, input_warehouse);

    for (input_instructions) |instruction| {
        if (instruction == '\n') continue;
        const delta: isize = switch (instruction) {
            '<' => -1,
            '>' => 1,
            '^' => -cast(isize, width),
            'v' => cast(isize, width),
            else => unreachable,
        };

        const robot = mem.indexOf(u8, warehouse, "@").?;
        var end = robot;
        while (warehouse[end] != '.' and warehouse[end] != '#') end = cast(usize, cast(isize, end) + delta);
        if (warehouse[end] == '#') continue;

        warehouse[end] = 'O';
        warehouse[robot] = '.';
        warehouse[cast(usize, cast(isize, robot) + delta)] = '@';
    }

    //std.debug.print("{s}\n", .{warehouse});
    var sum: u64 = 0;
    for (warehouse, 0..) |element, i| {
        if (element != 'O') continue;
        sum += 100 * (i / width) + i % width;
    }
    try stdout.print("{d}\n", .{sum});
}

fn add(a: anytype, b: anytype) @TypeOf(a) {
    return cast(@TypeOf(a), cast(@TypeOf(b), a) + b);
}

fn part2(allocator: mem.Allocator, stdout: std.io.AnyWriter) !void {
    const List = std.ArrayList(usize);

    var input_iter = std.mem.splitSequence(u8, input, "\n\n");

    const input_warehouse = input_iter.next().?;
    const input_instructions = input_iter.next().?;

    var warehouse = try allocator.alloc(u8, input_warehouse.len * 2);
    for (input_warehouse, 0..) |element, i| {
        switch (element) {
            '\n' => @memcpy(warehouse[2 * i .. 2 * i + 2], " \n"),
            '#' => @memcpy(warehouse[2 * i .. 2 * i + 2], "##"),
            '.' => @memcpy(warehouse[2 * i .. 2 * i + 2], ".."),
            'O' => @memcpy(warehouse[2 * i .. 2 * i + 2], "[]"),
            '@' => @memcpy(warehouse[2 * i .. 2 * i + 2], "@."),
            else => unreachable,
        }
    }
    const width = mem.indexOf(u8, warehouse, "\n").? + 1;

    var push_queue = List.init(allocator);
    var boxes = List.init(allocator);
    for (input_instructions) |instruction| {
        if (instruction == '\n') continue;
        const delta: isize = switch (instruction) {
            '<' => -1,
            '>' => 1,
            '^' => -cast(isize, width),
            'v' => cast(isize, width),
            else => unreachable,
        };

        const robot = mem.indexOf(u8, warehouse, "@").?;

        push_queue.clearRetainingCapacity();
        boxes.clearRetainingCapacity();
        try push_queue.append(add(robot, delta));
        var f = false;
        while (push_queue.popOrNull()) |event| {
            switch (warehouse[event]) {
                '.', '(', ')' => continue,
                '#' => {
                    f = true;
                    break;
                },
                '[' => {
                    warehouse[event] = '(';
                    try push_queue.append(event + 1);
                },
                ']' => {
                    warehouse[event] = ')';
                    try push_queue.append(event - 1);
                },
                else => unreachable,
            }
            try push_queue.append(add(event, delta));
            try boxes.append(event);
        }
        if (f) {
            for (boxes.items) |box| {
                warehouse[box] = switch (warehouse[box]) {
                    '(' => '[',
                    ')' => ']',
                    else => unreachable,
                };
            }
            continue;
        }

        if (delta > 0) mem.sort(usize, boxes.items, {}, std.sort.desc(usize)) else mem.sort(usize, boxes.items, {}, std.sort.asc(usize));

        for (boxes.items) |box| {
            warehouse[add(box, delta)] = switch (warehouse[box]) {
                '(' => '[',
                ')' => ']',
                else => unreachable,
            };
            warehouse[box] = '.';
        }

        warehouse[robot] = '.';
        warehouse[cast(usize, cast(isize, robot) + delta)] = '@';
    }

    //std.debug.print("{s}\n", .{warehouse});
    var sum: u64 = 0;
    for (warehouse, 0..) |element, i| {
        if (element != '[') continue;
        sum += 100 * (i / width) + i % width;
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
