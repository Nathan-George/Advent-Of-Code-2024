const std = @import("std");
const mem = std.mem;
const math = std.math;

const input = @embedFile("inputs/day16.in");

const Direction = enum {
    North,
    East,
    South,
    West,
};

const State = struct {
    points: u64,
    position: usize,
    direction: Direction,
    parent: usize,

    const Self = @This();
    fn init(points: u64, position: usize, direction: Direction, parent: usize) Self {
        return Self{
            .points = points,
            .position = position,
            .direction = direction,
            .parent = parent,
        };
    }
};

fn hash(a: State) usize {
    return a.position * 4 + @intFromEnum(a.direction);
}

const Order = math.Order;
fn lessThan(context: void, a: State, b: State) Order {
    _ = context;
    return math.order(a.points, b.points);
}

fn part1(allocator: mem.Allocator, stdout: std.io.AnyWriter) !void {
    const PriorityQueue = std.PriorityQueue(State, void, lessThan);
    const List = std.ArrayList(usize);

    var maze = try allocator.alloc(u8, input.len);
    @memcpy(maze, input);

    const width = mem.indexOf(u8, maze, "\n").? + 1;

    const start = mem.indexOf(u8, maze, "S").?;
    const end = mem.indexOf(u8, maze, "E").?;
    maze[start] = '.';
    maze[end] = '.';

    var map = try allocator.alloc(?u64, input.len * 4);
    @memset(map, null);
    var parents = try allocator.alloc(List, input.len * 4);

    var pq = PriorityQueue.init(allocator, {});
    try pq.add(State.init(0, start, .East, 0));

    var best_points: u64 = 0;
    var end_hash: usize = 0;

    while (pq.removeOrNull()) |current| {
        if (maze[current.position] == '#') continue;

        const i = hash(current);
        if (map[i]) |points| {
            if (current.points == points) try parents[i].append(current.parent);
            continue;
        }
        map[i] = current.points;
        parents[i] = List.init(allocator);
        try parents[i].append(current.parent);

        if (current.position == end) {
            best_points = current.points;
            end_hash = i;
            break;
        }

        // turn right
        try pq.add(switch (current.direction) {
            .North => State.init(current.points + 1000, current.position, .East, i),
            .East => State.init(current.points + 1000, current.position, .South, i),
            .South => State.init(current.points + 1000, current.position, .West, i),
            .West => State.init(current.points + 1000, current.position, .North, i),
        });
        // turn left
        try pq.add(switch (current.direction) {
            .North => State.init(current.points + 1000, current.position, .West, i),
            .East => State.init(current.points + 1000, current.position, .North, i),
            .South => State.init(current.points + 1000, current.position, .East, i),
            .West => State.init(current.points + 1000, current.position, .South, i),
        });
        // go forward
        try pq.add(switch (current.direction) {
            .North => State.init(current.points + 1, current.position - width, .North, i),
            .East => State.init(current.points + 1, current.position + 1, .East, i),
            .South => State.init(current.points + 1, current.position + width, .South, i),
            .West => State.init(current.points + 1, current.position - 1, .West, i),
        });
    }

    // trace back
    var reached = try allocator.alloc(bool, 4 * maze.len);
    @memset(reached, false);
    var stack = List.init(allocator);
    try stack.append(end_hash);
    while (stack.popOrNull()) |i| {
        if (i == 0) continue;
        if (reached[i]) continue;
        reached[i] = true;
        maze[i / 4] = 'O';
        for (parents[i].items) |p| try stack.append(p);
    }

    try stdout.print("{d}\n", .{best_points});
    try stdout.print("{d}\n", .{mem.count(u8, maze, "O")});
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
