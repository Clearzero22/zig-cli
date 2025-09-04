const std = @import("std");
const keymap = @import("lib/keymap.zig");

// 示例回调函数
fn exampleCallback(event: keymap.KeyEvent) anyerror!void {
    std.debug.print("快捷键被触发: {s}, Ctrl: {}, Alt: {}, Shift: {}\n", .{
        event.key, event.ctrl, event.alt, event.shift,
    });
}

// 测试键盘映射功能
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 创建键盘映射器
    var mapper = keymap.KeyMapper.init(allocator);
    defer mapper.deinit();

    // 添加快捷键映射
    try mapper.addMapping("c", true, false, false, exampleCallback); // Ctrl+C
    try mapper.addMapping("x", true, false, false, exampleCallback); // Ctrl+X
    try mapper.addMapping("s", true, false, false, exampleCallback); // Ctrl+S

    // 模拟按键事件
    const event1 = keymap.KeyEvent{ .key = "c", .ctrl = true, .alt = false, .shift = false };
    const event2 = keymap.KeyEvent{ .key = "z", .ctrl = true, .alt = false, .shift = false };

    // 处理按键事件
    std.debug.print("处理按键事件:\n", .{});
    try mapper.handleKeyEvent(event1); // 应该触发回调
    try mapper.handleKeyEvent(event2); // 应该不触发任何回调
}