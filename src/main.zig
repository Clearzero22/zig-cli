const std = @import("std");
const cli_color = @import("cli_color.zig");

pub fn main() !void {
    // 使用简化的无参数打印函数
    try cli_color.printlnColor("这是红色文本", .red);
    try cli_color.printlnColor("这是绿色文本", .green);
    try cli_color.printlnColor("这是蓝色文本", .blue);
    
    // 使用带格式化参数的打印函数
    const name = "Zig";
    const version = "0.15.0";
    try cli_color.printColor("欢迎使用 {s} v{s}\n", .bright_magenta, .{name, version});
    
    // 打印带数字的格式化文本
    const score = 95;
    try cli_color.printColor("你的得分: {d}\n", .yellow, .{score});
    
    // 组合使用不同颜色
    try std.io.getStdOut().writer().print(
        "{s}警告：{s}这是一条重要信息{s}\n",
        .{
            cli_color.colorCode(.bright_yellow),
            cli_color.colorCode(.bright_red),
            cli_color.colorCode(.reset)
        }
    );
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // Try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}