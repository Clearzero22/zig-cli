const std = @import("std");

// 颜色定义
pub const Color = enum(u8) {
    black, red, green, yellow, blue, magenta, cyan, white,
    bright_black, bright_red, bright_green, bright_yellow,
    bright_blue, bright_magenta, bright_cyan, bright_white,
    reset,
};

// 生成 ANSI 颜色代码
pub fn colorCode(c: Color) []const u8 {
    return switch (c) {
        .reset => "\x1b[0m",
        .black => "\x1b[30m",
        .red => "\x1b[31m",
        .green => "\x1b[32m",
        .yellow => "\x1b[33m",
        .blue => "\x1b[34m",
        .magenta => "\x1b[35m",
        .cyan => "\x1b[36m",
        .white => "\x1b[37m",
        .bright_black => "\x1b[90m",
        .bright_red => "\x1b[91m",
        .bright_green => "\x1b[92m",
        .bright_yellow => "\x1b[93m",
        .bright_blue => "\x1b[94m",
        .bright_magenta => "\x1b[95m",
        .bright_cyan => "\x1b[96m",
        .bright_white => "\x1b[97m",
    };
}

// 生成 RGB 颜色代码
pub fn rgbColorCode(r: u8, g: u8, b: u8) struct { array: [20]u8, len: usize } {
    var buf: [20]u8 = undefined;
    const temp_str = std.fmt.allocPrint(std.heap.page_allocator, "\x1b[38;2;{};{};{}m", .{r, g, b}) catch unreachable;
    defer std.heap.page_allocator.free(temp_str);

    var i: usize = 0;
    while (i < temp_str.len and i < buf.len) : (i += 1) {
        buf[i] = temp_str[i];
    }
    return .{ .array = buf, .len = i };
}

// 带颜色输出字符串 - 修复版本
pub fn printColor(comptime fmt: []const u8, color: Color, args: anytype) !void {
    var buf: [1024]u8 = undefined;
    const formatted_str = try std.fmt.bufPrint(&buf, fmt, args);
    try std.io.getStdOut().writer().print("{s}{s}{s}", .{
        colorCode(color),
        formatted_str,
        colorCode(.reset),
    });
}

// 简化的无参数彩色打印
pub fn printlnColor(text: []const u8, color: Color) !void {
    try printColor("{s}\n", color, .{text});
}

// 打印 RGB 颜色文本
pub fn printRgbColor(comptime fmt: []const u8, r: u8, g: u8, b: u8, args: anytype) !void {
    const color_code_info = rgbColorCode(r, g, b);
    const color_code = color_code_info.array[0..color_code_info.len];

    var text_buf: [1024]u8 = undefined; // Buffer for formatted text
    const formatted_str = try std.fmt.bufPrint(&text_buf, fmt, args);

    try std.io.getStdOut().writer().print("{s}{s}{s}", .{
        color_code,
        formatted_str,
        colorCode(.reset),
    });
}

test "color codes" {
    try std.testing.expectEqualStrings("\x1b[31m", colorCode(.red));
    try std.testing.expectEqualStrings("\x1b[97m", colorCode(.bright_white));
}

test "rgb color codes" {
    const info1 = rgbColorCode(255, 0, 0);
    try std.testing.expectEqualStrings("\x1b[38;2;255;0;0m", info1.array[0..info1.len]);
    const info2 = rgbColorCode(0, 128, 255);
    try std.testing.expectEqualStrings("\x1b[38;2;0;128;255m", info2.array[0..info2.len]);
    const info3 = rgbColorCode(10, 20, 30);
    try std.testing.expectEqualStrings("\x1b[38;2;10;20;30m", info3.array[0..info3.len]);
    const info4 = rgbColorCode(255, 255, 255);
    try std.testing.expectEqualStrings("\x1b[38;2;255;255;255m", info4.array[0..info4.len]);
    const info5 = rgbColorCode(0, 0, 0);
    try std.testing.expectEqualStrings("\x1b[38;2;0;0;0m", info5.array[0..info5.len]);
}
