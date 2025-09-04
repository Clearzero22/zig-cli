const std = @import("std");
const cli_color = @import("lib/cli_color.zig");
const cli_style = @import("lib/cli_style.zig");

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
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit();
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}