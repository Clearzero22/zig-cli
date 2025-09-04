const std = @import("std");
const keymap = @import("keymap_enhanced.zig");

fn testCallback(event: keymap.KeyEvent) anyerror!void {
    _ = event; // 未使用参数
    // 空回调，仅用于测试
}

test "keymap add and handle character key event" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var mapper = keymap.KeyMapper.init(allocator);
    defer mapper.deinit();

    // 添加映射
    try mapper.addMapping(.{ .char = 'c' }, true, false, false, testCallback);

    // 创建事件
    const event = keymap.KeyEvent{ .key = .{ .char = 'c' }, .ctrl = true, .alt = false, .shift = false };

    // 处理事件（这里我们只是确保它不会崩溃）
    try mapper.handleKeyEvent(event);
}

test "keymap add and handle function key event" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var mapper = keymap.KeyMapper.init(allocator);
    defer mapper.deinit();

    // 添加映射
    try mapper.addMapping(.f1, false, false, false, testCallback);

    // 创建事件
    const event = keymap.KeyEvent{ .key = .f1, .ctrl = false, .alt = false, .shift = false };

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
    const event = keymap.KeyEvent{ .key = .{ .char = 'z' }, .ctrl = true, .alt = false, .shift = false };

    // 处理不存在的事件（应该不执行任何回调）
    try mapper.handleKeyEvent(event);
}

test "keymap key equality" {
    // 测试字符键相等性
    try std.testing.expect(keymap.KeyMapper.keyEqual(.{ .char = 'a' }, .{ .char = 'a' }));
    try std.testing.expect(!keymap.KeyMapper.keyEqual(.{ .char = 'a' }, .{ .char = 'b' }));
    
    // 测试功能键相等性
    try std.testing.expect(keymap.KeyMapper.keyEqual(.f1, .f1));
    try std.testing.expect(!keymap.KeyMapper.keyEqual(.f1, .f2));
    
    // 测试字符键与功能键不相等
    try std.testing.expect(!keymap.KeyMapper.keyEqual(.{ .char = 'a' }, .f1));
}