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

// 带颜色输出字符串 - 修复版本
pub fn printColor(comptime fmt: []const u8, color: Color, args: anytype) !void {
    // 正确构建包含颜色代码的格式化字符串和参数列表
    const full_fmt = colorCode(color) ++ fmt ++ colorCode(.reset);
    try std.io.getStdOut().writer().print(full_fmt, args);
}

// 简化的无参数彩色打印
pub fn printlnColor(text: []const u8, color: Color) !void {
    try printColor("{s}\n", color, .{text});
}
    
