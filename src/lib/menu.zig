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

        try stdout.writeAll("\n使用箭头键或数字键选择，按回车确认\n");
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

    /// 运行菜单交互（简化版本）
    pub fn run(self: *Menu) !usize {
        // 显示初始菜单
        try self.display();

        // 在实际实现中，这里会处理键盘输入
        // 现在我们只返回当前选中的索引
        return self.selected_index;
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
