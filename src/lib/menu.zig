const std = @import("std");
const cli_color = @import("cli_color.zig");

/// 菜单配置
pub const MenuConfig = struct {
    /// 提示文本
    prompt: []const u8 = "请选择一个选项:",
    /// 是否启用数字键选择
    enable_number_keys: bool = true,
    /// 是否启用箭头键导航
    enable_arrow_keys: bool = true,
    /// 是否循环导航（到达末尾时回到开头）
    cycle_navigation: bool = true,
    /// 菜单颜色
    color: ?cli_color.Color = .cyan,
    /// 选中项颜色
    selected_color: ?cli_color.Color = .green,
};

/// 菜单选项
pub const MenuItem = struct {
    /// 选项文本
    text: []const u8,
    /// 选项值（可选）
    value: ?[]const u8 = null,
    /// 是否禁用
    disabled: bool = false,
};

/// 菜单结构体
pub const Menu = struct {
    config: MenuConfig,
    items: []const MenuItem,
    selected_index: usize,
    allocator: std.mem.Allocator,

    /// 创建新的菜单
    pub fn init(allocator: std.mem.Allocator, items: []const MenuItem, config: ?MenuConfig) !Menu {
        return Menu{
            .config = config orelse MenuConfig{},
            .items = items,
            .selected_index = 0,
            .allocator = allocator,
        };
    }

    /// 显示菜单
    pub fn display(self: *Menu) !void {
        const stdout = std.io.getStdOut().writer();

        // 清屏并移动光标到顶部
        try stdout.writeAll("\x1b[2J\x1b[H");

        // 显示提示文本
        if (self.config.color) |color| {
            try stdout.writeAll(cli_color.colorCode(color));
        }
        try stdout.print("{s}\n", .{self.config.prompt});
        if (self.config.color != null) {
            try stdout.writeAll(cli_color.colorCode(.reset));
        }

        // 显示菜单选项
        for (self.items, 0..) |item, i| {
            if (item.disabled) {
                try stdout.writeAll(cli_color.colorCode(.bright_black));
            } else if (i == self.selected_index) {
                if (self.config.selected_color) |color| {
                    try stdout.writeAll(cli_color.colorCode(color));
                }
            } else if (self.config.color) |color| {
                try stdout.writeAll(cli_color.colorCode(color));
            }

            if (self.config.enable_number_keys) {
                try stdout.print("{d}. ", .{i + 1});
            }

            if (i == self.selected_index) {
                try stdout.writeAll("> ");
            } else {
                try stdout.writeAll("  ");
            }

            try stdout.print("{s}\n", .{item.text});

            // 重置颜色
            try stdout.writeAll(cli_color.colorCode(.reset));
        }

        try stdout.writeAll("使用箭头键或数字键选择，按回车确认\n");
        // Flush the output
    }

    /// 更新选中项
    pub fn select(self: *Menu, index: usize) !void {
        if (index < self.items.len and !self.items[index].disabled) {
            self.selected_index = index;
        }
    }

    /// 向上移动选择
    pub fn moveUp(self: *Menu) void {
        if (self.selected_index > 0) {
            self.selected_index -= 1;
        } else if (self.config.cycle_navigation) {
            self.selected_index = self.items.len - 1;
        }
    }

    /// 向下移动选择
    pub fn moveDown(self: *Menu) void {
        if (self.selected_index < self.items.len - 1) {
            self.selected_index += 1;
        } else if (self.config.cycle_navigation) {
            self.selected_index = 0;
        }
    }

    /// 获取选中的选项
    pub fn getSelected(self: *Menu) MenuItem {
        return self.items[self.selected_index];
    }

    /// 获取选中项的索引
    pub fn getSelectedIndex(self: *Menu) usize {
        return self.selected_index;
    }

    /// 处理键盘输入
    fn handleInput(self: *Menu) !?usize {
        const stdin = std.io.getStdIn().reader();

        // 读取一个字符
        const char = try stdin.readByte();

        switch (char) {
            // 上箭头键 (ANSI转义序列: \x1b[A)
            27 => {
                // 读取接下来的两个字符
                const next1 = try stdin.readByte();
                const next2 = try stdin.readByte();

                if (next1 == '[' and next2 == 'A') {
                    self.moveUp();
                    try self.display();
                } else if (next1 == '[' and next2 == 'B') {
                    // 下箭头键 (ANSI转义序列: \x1b[B)
                    self.moveDown();
                    try self.display();
                }
            },
            // 回车键
            '\r', '\n' => {
                return self.selected_index;
            },
            // 数字键 1-9
            '1'...'9' => {
                const index = char - '1';
                if (index < self.items.len) {
                    try self.select(index);
                    try self.display();
                }
            },
            // q 或 Q 退出
            'q', 'Q' => {
                return null;
            },
            else => {
                // 忽略其他输入
            },
        }

        return undefined;
    }

    /// 运行菜单交互
    pub fn run(self: *Menu) !?usize {
        // 设置终端为原始模式以捕获单个按键
        const term = try std.posix.tcgetattr(std.io.getStdIn().handle);
        var raw_term = term;
        raw_term.lflag.ECHO = false;
        raw_term.lflag.ICANON = false;
        try std.posix.tcsetattr(std.io.getStdIn().handle, .FLUSH, raw_term);

        defer {
            // 恢复终端设置
            std.posix.tcsetattr(std.io.getStdIn().handle, .FLUSH, term) catch {};
        }

        // 显示初始菜单
        try self.display();

        // 循环处理输入直到用户选择或退出
        while (true) {
            const result = try self.handleInput();
            if (result) |index| {
                return index;
            } else if (result == null) {
                return null;
            }
        }
    }
};

test "menu basic functionality" {
    const allocator = std.testing.allocator;

    const items = [_]MenuItem{
        MenuItem{ .text = "选项 1" },
        MenuItem{ .text = "选项 2" },
        MenuItem{ .text = "选项 3" },
    };

    var menu = try Menu.init(allocator, &items, null);

    try std.testing.expectEqual(@as(usize, 0), menu.getSelectedIndex());
    try std.testing.expectEqualStrings("选项 1", menu.getSelected().text);
}

test "menu with custom config" {
    const allocator = std.testing.allocator;

    const items = [_]MenuItem{
        MenuItem{ .text = "是" },
        MenuItem{ .text = "否" },
    };

    const config = MenuConfig{
        .prompt = "请选择是或否:",
        .enable_number_keys = true,
        .enable_arrow_keys = true,
        .cycle_navigation = false,
        .color = .blue,
        .selected_color = .yellow,
    };

    var menu = try Menu.init(allocator, &items, config);

    try std.testing.expectEqual(@as(usize, 0), menu.getSelectedIndex());
}
