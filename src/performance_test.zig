const std = @import("std");
const cli_color = @import("lib/cli_color.zig");
const cli_style = @import("lib/cli_style.zig");

pub fn runPerformanceTests() !void {
    const stdout = std.io.getStdOut().writer();
    const num_iterations = 1000;

    // Performance test for colored text
    var timer_color = try std.time.Timer.start(); // Added 'try' here
    for (0..num_iterations) |_| {
        try cli_color.printlnColor("Performance test for colored text.", .red);
    }
    const elapsed_color = timer_color.read();
    try stdout.print("Time to print {d} colored lines: {d} ns\n", .{ num_iterations, elapsed_color });

    // Performance test for styled text
    var timer_style = try std.time.Timer.start(); // Added 'try' here
    for (0..num_iterations) |_| {
        try cli_style.printStyled("Performance test for styled text.\n", .{ .color = .green, .style = .bold }, .{});
    }
    const elapsed_style = timer_style.read();
    try stdout.print("Time to print {d} styled lines: {d} ns\n", .{ num_iterations, elapsed_style });

    // Performance test for RGB colored text
    var timer_rgb = try std.time.Timer.start(); // Added 'try' here
    for (0..num_iterations) |_| {
        try cli_color.printRgbColor("Performance test for RGB colored text.\n", 255, 100, 50, .{});
    }
    const elapsed_rgb = timer_rgb.read();
    try stdout.print("Time to print {d} RGB colored lines: {d} ns\n", .{ num_iterations, elapsed_rgb });
}

pub fn main() !void {
    try runPerformanceTests();
}