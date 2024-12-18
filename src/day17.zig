const std = @import("std");
const mem = std.mem;
const fmt = std.fmt;
const math = std.math;

//const input = @embedFile("inputs/day17.in");
const input = @embedFile("inputs/sample.in");

// a = 51064159
// b = 0
// c = 0
//
// do {
//      b = a % 8;
//      b = b ^ 5;
//      c = a >> b;
//      b = b ^ 6;
//      a = a >> 3;
//      b = b ^ c;
//      out b % 8;
// } while(a > 0);

const Opcode = enum(u3) {
    adv = 0,
    bxl = 1,
    bst = 2,
    jnz = 3,
    bxc = 4,
    out = 5,
    bdv = 6,
    cdv = 7,
};

const Register = u128;

fn part1(allocator: mem.Allocator, stdout: std.io.AnyWriter) !void {
    const List = std.ArrayList(u3);
    var register_a: Register = undefined;
    var register_b: Register = undefined;
    var register_c: Register = undefined;

    var line_iter = std.mem.splitSequence(u8, mem.trim(u8, input, "\n"), "\n");

    const register_input_offset: usize = "Register X: ".len;
    register_a = try fmt.parseInt(Register, line_iter.next().?[register_input_offset..], 10);
    register_b = try fmt.parseInt(Register, line_iter.next().?[register_input_offset..], 10);
    register_c = try fmt.parseInt(Register, line_iter.next().?[register_input_offset..], 10);

    _ = line_iter.next().?;

    const program_input_offset: usize = "Program: ".len;
    var input_program_iter = std.mem.splitSequence(u8, line_iter.next().?[program_input_offset..], ",");
    var program = List.init(allocator);
    while (input_program_iter.next()) |bits| try program.append(try fmt.parseInt(u3, bits, 10));
    var output = List.init(allocator);

    var instruction_pointer: usize = 0;
    while (instruction_pointer + 1 < program.items.len) {
        const opcode: Opcode = @enumFromInt(program.items[instruction_pointer]);
        const literal_operand: u3 = program.items[instruction_pointer + 1];

        const combo_operand: Register = switch (literal_operand) {
            0...3 => |x| x,
            4 => register_a,
            5 => register_b,
            6 => register_c,
            7 => unreachable,
        };

        //std.debug.print("{d} {d} {d} {any} {d}\n", .{ register_a, register_b, register_c, opcode, combo_operand });

        switch (opcode) {
            .adv => register_a = math.shr(Register, register_a, combo_operand),
            .bxl => register_b = register_b ^ literal_operand,
            .bst => register_b = combo_operand % 8,
            .jnz => {
                if (register_a == 0) {
                    instruction_pointer += 2;
                } else {
                    instruction_pointer = @intCast(literal_operand);
                }
            },
            .bxc => register_b = register_b ^ register_c,
            .out => try output.append(@intCast(combo_operand % 8)),
            .bdv => register_b = math.shr(Register, register_a, combo_operand),
            .cdv => register_c = math.shr(Register, register_a, combo_operand),
        }
        if (opcode != .jnz) instruction_pointer += 2;
    }

    for (output.items) |num| {
        try stdout.print("{d},", .{num});
    }
    try stdout.print("\n", .{});
}

fn part2(allocator: mem.Allocator, stdout: std.io.AnyWriter) !void {
    const List = std.ArrayList(u3);

    var line_iter = std.mem.splitSequence(u8, mem.trim(u8, input, "\n"), "\n");

    const register_input_offset: usize = "Register X: ".len;
    _ = try fmt.parseInt(Register, line_iter.next().?[register_input_offset..], 10);
    _ = try fmt.parseInt(Register, line_iter.next().?[register_input_offset..], 10);
    _ = try fmt.parseInt(Register, line_iter.next().?[register_input_offset..], 10);

    _ = line_iter.next().?;

    const program_input_offset: usize = "Program: ".len;
    var input_program_iter = std.mem.splitSequence(u8, line_iter.next().?[program_input_offset..], ",");
    var program = List.init(allocator);
    while (input_program_iter.next()) |bits| try program.append(try fmt.parseInt(u3, bits, 10));

    //std.debug.print("{any}\n", .{program.items});

    var i: usize = program.items.len;
    var quine: Register = 0;
    while (i > 0) {
        i -= 1;

        const target = program.items[i];
        var output: u3 = undefined;

        var instruction_pointer: usize = 0;
        var register_a: Register = quine;
        var register_b: Register = 0;
        var register_c: Register = 0;
        while (true) {
            const opcode: Opcode = @enumFromInt(program.items[instruction_pointer]);
            const literal_operand: u3 = program.items[instruction_pointer + 1];

            const combo_operand: Register = switch (literal_operand) {
                0...3 => |x| x,
                4 => register_a,
                5 => register_b,
                6 => register_c,
                7 => unreachable,
            };

            //std.debug.print("{d} {d} {d} {any} {d}\n", .{ register_a, register_b, register_c, opcode, combo_operand });

            switch (opcode) {
                .adv => register_a = math.shr(Register, register_a, combo_operand),
                .bxl => register_b = register_b ^ literal_operand,
                .bst => register_b = combo_operand % 8,
                .jnz => {
                    if (register_a == 0) {
                        instruction_pointer += 2;
                    } else {
                        instruction_pointer = @intCast(literal_operand);
                    }
                },
                .bxc => register_b = register_b ^ register_c,
                .out => {
                    output = @intCast(combo_operand % 8);
                    break;
                },
                .bdv => register_b = math.shr(Register, register_a, combo_operand),
                .cdv => register_c = math.shr(Register, register_a, combo_operand),
            }
            if (opcode != .jnz) instruction_pointer += 2;
        }

        if (output == target) {
            //std.debug.print("{b} {d} {d}\n", .{ quine, i, target });
            if (i > 0) quine <<= 3;
            continue;
        }

        while (quine % 8 == 7) {
            quine >>= 3;
            i += 1;
        }

        quine += 1;
        i += 1;
    }

    try stdout.print("{d}\n", .{quine});
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
