const std = @import("std");
const keymap = @import("keymap.zig");

fn testCallback(event: keymap.KeyEvent) anyerror!void {
    _ = event; // 未使用参数
    // 空回调，仅用于测试
}

test "keymap add and handle event" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var mapper = keymap.KeyMapper.init(allocator);
    defer mapper.deinit();

    // 添加映射
    try mapper.addMapping("c", true, false, false, testCallback);

    // 创建事件
    const event = keymap.KeyEvent{ .key = "c", .ctrl = true, .alt = false, .shift = false };

    // 处理事件（这里我们只是确保它不会崩溃）
    try mapper.handleKeyEvent(event);
}

test "keymap handle non-existent event" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var mapper = keymap.KeyMapper.init(allocator);
    defer mapper.deinit();

    // 创建事件
    const event = keymap.KeyEvent{ .key = "z", .ctrl = true, .alt = false, .shift = false };

    // 处理不存在的事件（应该不执行任何回调）
    try mapper.handleKeyEvent(event);
}