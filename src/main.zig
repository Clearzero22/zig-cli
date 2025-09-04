const std = @import("std");
const cli_color = @import("lib/cli_color.zig");
const cli_style = @import("lib/cli_style.zig");
const progress = @import("lib/progress.zig");

pub fn main() !void {
    // Demonstrate color printing
    try cli_color.printlnColor("This is red text", .red);
    try cli_color.printlnColor("This is green text", .green);
    try cli_color.printlnColor("This is blue text", .blue);

    // Demonstrate styled printing
    try cli_style.printStyled("This is bold blue text\n", .{ .color = .blue, .style = .bold }, .{});
    try cli_style.printStyled("This is italic yellow text\n", .{ .color = .yellow, .style = .italic }, .{});
    try cli_style.printStyled("This is underlined cyan text\n", .{ .color = .cyan, .style = .underline }, .{});

    // Demonstrate formatted and styled printing
    const name = "Zig";
    const version = "0.15.0";
    try cli_style.printStyled("Welcome to {s} v{s}\n", .{ .color = .magenta, .style = .bold }, .{ name, version });

    // Demonstrate RGB color printing
    try cli_color.printRgbColor("This is text with custom RGB color (255, 165, 0)\n", 255, 165, 0, .{});
    try cli_color.printRgbColor("Another RGB color (128, 0, 128) with number {d}\n", 128, 0, 128, .{123});

    // Add 10 different RGB test cases
    var i: u8 = 0;
    while (i < 10) : (i += 1) {
        const r = i * 25;
        const g = 255 - (i * 25);
        const b = i * 10;
        try cli_color.printRgbColor("RGB Test {d}: ({d}, {d}, {d})\n", r, g, b, .{ i, r, g, b });
    }

    // Demonstrate progress bar
    try cli_color.printlnColor("\n--- Progress Bar Demo ---", .yellow);

    // Basic progress bar
    try cli_color.printlnColor("Basic progress bar:", .cyan);
    var pb1 = try progress.ProgressBar.init(100, null);
    var j: usize = 0;
    while (j <= 100) : (j += 1) {
        try pb1.update(j);
        std.time.sleep(1000000 / 20); // Sleep 50ms
    }
    try pb1.finish();

    // Custom progress bar
    try cli_color.printlnColor("Custom progress bar:", .cyan);
    const custom_config = progress.ProgressBarConfig{
        .width = 30,
        .complete_char = '#',
        .incomplete_char = '.',
        .show_percentage = true,
        .show_eta = true,
        .color = .magenta,
    };
    var pb2 = try progress.ProgressBar.init(50, custom_config);
    j = 0;
    while (j <= 50) : (j += 1) {
        try pb2.update(j);
        std.time.sleep(1000000 / 10); // Sleep 100ms
    }
    try pb2.finish();

    // Progress bar with increment
    try cli_color.printlnColor("Progress bar with increment:", .cyan);
    var pb3 = try progress.ProgressBar.init(100, null);
    j = 0;
    while (j <= 100) : (j += 5) {
        try pb3.increment(5);
        std.time.sleep(1000000 / 4); // Sleep 250ms
    }
    try pb3.finish();

    // File download simulation
    try cli_color.printlnColor("File download simulation:", .cyan);
    const file_size: usize = 1024 * 1024; // 1MB
    var pb4 = try progress.ProgressBar.init(file_size, progress.ProgressBarConfig{
        .width = 30,
        .complete_char = '=',
        .incomplete_char = ' ',
        .show_percentage = true,
        .show_eta = true,
        .color = .blue,
    });

    var downloaded: usize = 0;
    const chunk_size: usize = file_size / 50;
    while (downloaded < file_size) {
        const to_download = @min(chunk_size, file_size - downloaded);
        downloaded += to_download;
        try pb4.update(downloaded);
        // Simulate network delay - shorter delays for more realistic demo
        std.time.sleep(1000000 / 20); // Sleep 50ms
    }
    try pb4.finish();
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit();
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
