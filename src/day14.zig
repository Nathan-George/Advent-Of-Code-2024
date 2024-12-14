const std = @import("std");
const mem = std.mem;
const fmt = std.fmt;

const input = @embedFile("inputs/day14.in");

const width: i64 = 101;
const height: i64 = 103;

const Point = struct {
    x: i64,
    y: i64,
};

fn parsePoint(buffer: []const u8) !Point {
    var num_iter = mem.splitSequence(u8, buffer, ",");
    const x = try fmt.parseInt(i64, num_iter.next().?, 10);
    const y = try fmt.parseInt(i64, num_iter.next().?, 10);
    return Point{
        .x = x,
        .y = y,
    };
}

fn part1(allocator: mem.Allocator, stdout: std.io.AnyWriter) !void {
    _ = allocator;
    var quadrants = [2][2]u64{ [_]u64{ 0, 0 }, [_]u64{ 0, 0 } };

    var line_iter = mem.splitSequence(u8, mem.trim(u8, input, " \n"), "\n");
    while (line_iter.next()) |input_line| {
        var element_iter = mem.splitSequence(u8, input_line, " ");
        const input_position = element_iter.next().?[2..];
        const input_velocity = element_iter.next().?[2..];

        var position = try parsePoint(input_position);
        const velocity = try parsePoint(input_velocity);
        position.x = @mod(position.x + velocity.x * 100, width);
        position.y = @mod(position.y + velocity.y * 100, height);
        if (position.x == @divTrunc(width, 2) or position.y == @divTrunc(height, 2)) continue;
        quadrants[@intFromBool(position.x > @divTrunc(width, 2))][@intFromBool(position.y > @divTrunc(height, 2))] += 1;
    }

    const sum = quadrants[0][0] * quadrants[0][1] * quadrants[1][0] * quadrants[1][1];
    try stdout.print("{d}\n", .{sum});
}

fn part2(allocator: mem.Allocator, stdout: std.io.AnyWriter) !void {
    const List = std.ArrayList(Point);

    var positions = List.init(allocator);
    var velocities = List.init(allocator);

    var line_iter = mem.splitSequence(u8, mem.trim(u8, input, " \n"), "\n");
    while (line_iter.next()) |input_line| {
        var element_iter = mem.splitSequence(u8, input_line, " ");
        const input_position = element_iter.next().?[2..];
        const input_velocity = element_iter.next().?[2..];

        const position = try parsePoint(input_position);
        const velocity = try parsePoint(input_velocity);
        try positions.append(position);
        try velocities.append(velocity);
    }

    const robot_count = positions.items.len;

    for (0..(width - 1) * (height - 1)) |i| {
        //var x_counts: [width]u64 = undefined;
        //var y_counts: [height]u64 = undefined;
        //@memset(&x_counts, 0);
        //@memset(&y_counts, 0);
        //for (0..robot_count) |j| {
        //    x_counts[@intCast(@mod(positions.items[j].x + @as(i64, @intCast(i)) * velocities.items[j].x, width))] += 1;
        //    y_counts[@intCast(@mod(positions.items[j].y + @as(i64, @intCast(i)) * velocities.items[j].y, height))] += 1;
        //}
        var canvas: [height][width]u8 = undefined;
        for (0..height) |y| @memset(&canvas[y], ' ');
        for (0..robot_count) |j| {
            const x: usize = @intCast(@mod(positions.items[j].x + @as(i64, @intCast(i)) * velocities.items[j].x, width));
            const y: usize = @intCast(@mod(positions.items[j].y + @as(i64, @intCast(i)) * velocities.items[j].y, height));
            canvas[y][x] = '#';
        }

        var connections: u64 = 0;
        for (1..height) |y| {
            for (1..width) |x| {
                if (canvas[y][x] != '#') continue;
                if (canvas[y][x - 1] == '#') connections += 1;
                if (canvas[y - 1][x] == '#') connections += 1;
            }
        }

        if (connections < 500) continue;

        try stdout.print("{d}\n", .{i});
        for (0..height) |y| try stdout.print("{s}\n", .{&canvas[y]});
    }
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
