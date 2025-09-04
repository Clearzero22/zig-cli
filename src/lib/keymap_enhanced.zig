const std = @import("std");

// 定义按键类型枚举
pub const Key = union(enum) {
    // 字符键
    char: u8,
    // 功能键
    f1,
    f2,
    f3,
    f4,
    f5,
    f6,
    f7,
    f8,
    f9,
    f10,
    f11,
    f12,
    // 方向键
    up,
    down,
    left,
    right,
    // 控制键
    enter,
    escape,
    backspace,
    tab,
    space,
    // 修饰键
    ctrl,
    alt,
    shift,
    // 数字键
    num0,
    num1,
    num2,
    num3,
    num4,
    num5,
    num6,
    num7,
    num8,
    num9,
    // 符号键
    minus,        // -
    equal,        // =
    bracket_left, // [
    bracket_right, // ]
    backslash,    // \
    semicolon,    // ;
    quote,        // '
    backquote,    // `
    comma,        // ,
    period,       // .
    slash,        // /
    // 其他键
    insert,
    delete,
    home,
    end,
    page_up,
    page_down,
    caps_lock,
    scroll_lock,
    num_lock,
};

// 定义按键事件结构
pub const KeyEvent = struct {
    key: Key,
    ctrl: bool,
    alt: bool,
    shift: bool,
};

// 定义回调函数类型
pub const KeyCallback = *const fn (event: KeyEvent) anyerror!void;

// 定义快捷键映射结构
pub const KeyMap = struct {
    key: Key,
    ctrl: bool,
    alt: bool,
    shift: bool,
    callback: KeyCallback,
};

// 定义键盘映射模式结构
pub const KeyMapper = struct {
    allocator: std.mem.Allocator,
    mappings: std.ArrayList(KeyMap),
    
    pub fn init(allocator: std.mem.Allocator) KeyMapper {
        return KeyMapper{
            .allocator = allocator,
            .mappings = std.ArrayList(KeyMap).init(allocator),
        };
    }
    
    pub fn deinit(self: *KeyMapper) void {
        self.mappings.deinit();
    }
    
    // 添加快捷键映射
    pub fn addMapping(self: *KeyMapper, key: Key, ctrl: bool, alt: bool, shift: bool, callback: KeyCallback) !void {
        try self.mappings.append(KeyMap{
            .key = key,
            .ctrl = ctrl,
            .alt = alt,
            .shift = shift,
            .callback = callback,
        });
    }
    
    // 处理按键事件
    pub fn handleKeyEvent(self: *KeyMapper, event: KeyEvent) !void {
        for (self.mappings.items) |mapping| {
            if (keyEqual(mapping.key, event.key) and
                mapping.ctrl == event.ctrl and
                mapping.alt == event.alt and
                mapping.shift == event.shift) {
                try mapping.callback(event);
                return;
            }
        }
    }
    
    // 比较两个按键是否相等
    pub fn keyEqual(a: Key, b: Key) bool {
        switch (a) {
            .char => |c| {
                if (b == .char) {
                    return c == b.char;
                }
                return false;
            },
            else => {
                return std.meta.eql(a, b);
            },
        }
    }
};