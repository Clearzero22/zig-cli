//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention


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

// 颜色定义
   
pub fn main() !void {
    // 启用Windows终端的ANSI支持

    // 使用简化的无参数打印函数
    try printlnColor("这是红色文本", .red);
    try printlnColor("这是绿色文本", .green);
    try printlnColor("这是蓝色文本", .blue);
    
    // 使用带格式化参数的打印函数
    const name = "Zig";
    const version = "0.15.0";
    try printColor("欢迎使用 {s} v{s}\n", .bright_magenta, .{name, version});
    
    // 打印带数字的格式化文本
    const score = 95;
    try printColor("你的得分: {d}\n", .yellow, .{score});
    
    // 组合使用不同颜色
    try std.io.getStdOut().writer().print(
        "{s}警告：{s}这是一条重要信息{s}\n",
        .{
            colorCode(.bright_yellow),
            colorCode(.bright_red),
            colorCode(.reset)
        }
    );
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // Try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "use other module" {
    try std.testing.expectEqual(@as(i32, 150), lib.add(100, 50));
}

test "fuzz example" {
    const Context = struct {
        fn testOne(context: @This(), input: []const u8) anyerror!void {
            _ = context;
            // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
            try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
        }
    };
    try std.testing.fuzz(Context{}, Context.testOne, .{});
}

const std = @import("std");

/// This imports the separate module containing `root.zig`. Take a look in `build.zig` for details.
const lib = @import("zig_cli_lib_lib");
