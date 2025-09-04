const std = @import("std");
const keymap = @import("keymap_enhanced.zig");

// 示例回调函数
fn exampleCallback(event: keymap.KeyEvent) anyerror!void {
    // 打印按键信息
    switch (event.key) {
        .char => |c| {
            std.debug.print("字符键被触发: '{c}', Ctrl: {}, Alt: {}, Shift: {}", .{
                c, event.ctrl, event.alt, event.shift,
            });
        },
        .f1 => {
            std.debug.print("F1键被触发, Ctrl: {}, Alt: {}, Shift: {}", .{
                event.ctrl, event.alt, event.shift,
            });
        },
        .up => {
            std.debug.print("上方向键被触发, Ctrl: {}, Alt: {}, Shift: {}", .{
                event.ctrl, event.alt, event.shift,
            });
        },
        .enter => {
            std.debug.print("回车键被触发, Ctrl: {}, Alt: {}, Shift: {}", .{
                event.ctrl, event.alt, event.shift,
            });
        },
        else => {            std.debug.print("其他键被触发, Ctrl: {}, Alt: {}, Shift: {}", .{
                event.ctrl, event.alt, event.shift,
            });
        },
    }
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
    try mapper.addMapping(.{ .char = 'c' }, true, false, false, exampleCallback); // Ctrl+C
    try mapper.addMapping(.{ .char = 'x' }, true, false, false, exampleCallback); // Ctrl+X
    try mapper.addMapping(.f1, false, false, false, exampleCallback); // F1
    try mapper.addMapping(.up, false, false, false, exampleCallback); // Up arrow
    try mapper.addMapping(.enter, false, false, false, exampleCallback); // Enter

    // 模拟按键事件
    const event1 = keymap.KeyEvent{ .key = .{ .char = 'c' }, .ctrl = true, .alt = false, .shift = false };
    const event2 = keymap.KeyEvent{ .key = .f1, .ctrl = false, .alt = false, .shift = false };
    const event3 = keymap.KeyEvent{ .key = .up, .ctrl = false, .alt = false, .shift = false };
    const event4 = keymap.KeyEvent{ .key = .enter, .ctrl = false, .alt = false, .shift = false };
    const event5 = keymap.KeyEvent{ .key = .{ .char = 'z' }, .ctrl = true, .alt = false, .shift = false }; // 未注册的快捷键

    // 处理按键事件
    std.debug.print("处理按键事件:", .{});
    try mapper.handleKeyEvent(event1); // 应该触发回调
    try mapper.handleKeyEvent(event2); // 应该触发回调
    try mapper.handleKeyEvent(event3); // 应该触发回调
    try mapper.handleKeyEvent(event4); // 应该触发回调
    try mapper.handleKeyEvent(event5); // 应该不触发任何回调
}