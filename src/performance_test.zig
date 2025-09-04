const std = @import("std");
const cli_color = @import("lib/cli_color.zig");
const cli_style = @import("lib/cli_style.zig");
const progress = @import("lib/progress.zig");

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

    // Performance test for progress bar
    try stdout.print("Performance test for progress bar:\n", .{});
    const total_steps = 1000;
    var pb = try progress.ProgressBar.init(total_steps, null);
    var timer_progress = try std.time.Timer.start();

    for (0..total_steps) |i| {
        // We don't actually update the display for each step in the performance test
        // to avoid terminal I/O overhead skewing the results
        pb.current = i;
    }

    const elapsed_progress = timer_progress.read();
    try pb.finish(); // Just finish once at the end
    try stdout.print("Time to process {d} progress steps: {d} ns\n", .{ total_steps, elapsed_progress });
}

pub fn main() !void {
    try runPerformanceTests();
}
