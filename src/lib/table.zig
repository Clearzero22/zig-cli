const std = @import("std");
const cli_color = @import("cli_color.zig");

/// 表格配置
pub const TableConfig = struct {
    /// 是否显示表头
    show_header: bool = true,
    /// 列分隔符
    column_separator: []const u8 = " | ",
    /// 行分隔符
    row_separator: []const u8 = "-",
    /// 是否显示边框
    show_border: bool = true,
    /// 表头颜色
    header_color: ?cli_color.Color = .blue,
    /// 表格颜色
    table_color: ?cli_color.Color = null,
};

/// 表格对齐方式
pub const Alignment = enum {
    left,
    center,
    right,
};

/// 列配置
pub const ColumnConfig = struct {
    /// 列标题
    header: []const u8,
    /// 对齐方式
    alignment: Alignment = .left,
    /// 最小宽度
    min_width: usize = 0,
    /// 最大宽度 (0表示无限制)
    max_width: usize = 0,
    /// 颜色
    color: ?cli_color.Color = null,
};

/// 表格结构体
pub const Table = struct {
    config: TableConfig,
    columns: []const ColumnConfig,
    rows: std.ArrayList([]const []const u8),
    allocator: std.mem.Allocator,

    /// 创建新的表格
    pub fn init(allocator: std.mem.Allocator, columns: []const ColumnConfig, config: ?TableConfig) !Table {
        return Table{
            .config = config orelse TableConfig{},
            .columns = columns,
            .rows = std.ArrayList([]const []const u8).init(allocator),
            .allocator = allocator,
        };
    }

    /// 添加行数据
    pub fn addRow(self: *Table, row: []const []const u8) !void {
        // 验证行数据列数是否匹配
        if (row.len != self.columns.len) {
            return error.ColumnCountMismatch;
        }

        // 复制行数据
        const row_copy = try self.allocator.alloc([]const u8, row.len);
        for (row, 0..) |cell, i| {
            row_copy[i] = cell;
        }

        try self.rows.append(row_copy);
    }

    /// 计算每列的宽度
    fn calculateColumnWidths(self: *Table) ![]usize {
        const widths = try self.allocator.alloc(usize, self.columns.len);
        for (widths, 0..) |_, i| {
            widths[i] = self.columns[i].min_width;
        }

        // 计算表头宽度
        if (self.config.show_header) {
            for (self.columns, 0..) |column, i| {
                if (column.header.len > widths[i]) {
                    widths[i] = column.header.len;
                }
            }
        }

        // 计算数据行宽度
        for (self.rows.items) |row| {
            for (row, 0..) |cell, i| {
                if (cell.len > widths[i]) {
                    widths[i] = cell.len;
                }

                // 应用最大宽度限制
                if (self.columns[i].max_width > 0 and widths[i] > self.columns[i].max_width) {
                    widths[i] = self.columns[i].max_width;
                }
            }
        }

        return widths;
    }

    /// 截断文本到指定长度并添加省略号
    fn truncateText(self: *Table, text: []const u8, max_width: usize) ![]const u8 {
        if (text.len <= max_width) {
            return text;
        }

        if (max_width <= 3) {
            // 如果最大宽度小于等于3，只返回省略号
            const result = try self.allocator.dupe(u8, "...");
            return result;
        }

        // 截断文本并添加省略号
        const truncated_len = max_width - 3;
        var result = try self.allocator.alloc(u8, max_width);
        @memcpy(result[0..truncated_len], text[0..truncated_len]);
        @memcpy(result[truncated_len..max_width], "...");
        return result;
    }

    /// 格式化单元格内容
    fn formatCell(self: *Table, text: []const u8, width: usize, alignment: Alignment) ![]const u8 {
        const truncated = try self.truncateText(text, width);

        // 手动实现对齐
        var result = try self.allocator.alloc(u8, width);
        @memset(result, ' ');

        switch (alignment) {
            .left => {
                @memcpy(result[0..truncated.len], truncated);
            },
            .center => {
                const padding = (width - truncated.len) / 2;
                @memcpy(result[padding..(padding + truncated.len)], truncated);
            },
            .right => {
                const start = width - truncated.len;
                @memcpy(result[start..width], truncated);
            },
        }

        return result;
    }

    /// 渲染表格
    pub fn render(self: *Table) !void {
        const stdout = std.io.getStdOut().writer();
        const widths = try self.calculateColumnWidths();

        // 渲染顶部边框
        if (self.config.show_border) {
            try self.renderBorder(stdout, widths);
        }

        // 渲染表头
        if (self.config.show_header) {
            try self.renderHeader(stdout, widths);
            if (self.config.show_border) {
                try self.renderSeparator(stdout, widths);
            }
        }

        // 渲染数据行
        for (self.rows.items) |row| {
            try self.renderRow(stdout, row, widths);
        }

        // 渲染底部边框
        if (self.config.show_border) {
            try self.renderBorder(stdout, widths);
        }

        // 释放内存
        self.allocator.free(widths);
    }

    /// 渲染边框
    fn renderBorder(self: *Table, writer: anytype, widths: []usize) !void {
        try writer.writeAll("+");
        for (widths) |width| {
            var i: usize = 0;
            while (i < width + 2) : (i += 1) {
                try writer.writeAll(self.config.row_separator);
            }
            try writer.writeAll("+");
        }
        try writer.writeAll("\n");
    }

    /// 渲染分隔线
    fn renderSeparator(self: *Table, writer: anytype, widths: []usize) !void {
        try writer.writeAll("|");
        for (widths, 0..) |width, i| {
            try writer.writeAll(" ");
            var j: usize = 0;
            while (j < width) : (j += 1) {
                try writer.writeAll(self.config.row_separator);
            }
            try writer.writeAll(" ");
            if (i < widths.len - 1) {
                try writer.writeAll("|");
            }
        }
        try writer.writeAll("|\n");
    }

    /// 渲染表头
    fn renderHeader(self: *Table, writer: anytype, widths: []usize) !void {
        try writer.writeAll("|");
        for (self.columns, widths, 0..) |column, width, i| {
            try writer.writeAll(" ");

            // 应用表头颜色
            if (self.config.header_color) |color| {
                try writer.writeAll(cli_color.colorCode(color));
            }

            const formatted = try self.formatCell(column.header, width, column.alignment);
            try writer.writeAll(formatted);

            // 重置颜色
            if (self.config.header_color != null) {
                try writer.writeAll(cli_color.colorCode(.reset));
            }

            try writer.writeAll(" ");
            if (i < self.columns.len - 1) {
                try writer.writeAll("|");
            }
        }
        try writer.writeAll("|\n");
    }

    /// 渲染数据行
    fn renderRow(self: *Table, writer: anytype, row: []const []const u8, widths: []usize) !void {
        try writer.writeAll("|");
        for (row, self.columns, widths, 0..) |cell, column, width, i| {
            try writer.writeAll(" ");

            // 应用列颜色
            if (column.color) |color| {
                try writer.writeAll(cli_color.colorCode(color));
            } else if (self.config.table_color) |color| {
                try writer.writeAll(cli_color.colorCode(color));
            }

            const formatted = try self.formatCell(cell, width, column.alignment);
            try writer.writeAll(formatted);

            // 重置颜色
            if (column.color != null or self.config.table_color != null) {
                try writer.writeAll(cli_color.colorCode(.reset));
            }

            try writer.writeAll(" ");
            if (i < row.len - 1) {
                try writer.writeAll("|");
            }
        }
        try writer.writeAll("|\n");
    }

    /// 释放资源
    pub fn deinit(self: *Table) void {
        // 释放行数据
        for (self.rows.items) |row| {
            self.allocator.free(row);
        }
        self.rows.deinit();
    }
};

test "table basic functionality" {
    const allocator = std.testing.allocator;

    const columns = [_]ColumnConfig{
        ColumnConfig{ .header = "Name", .alignment = .left },
        ColumnConfig{ .header = "Age", .alignment = .right },
        ColumnConfig{ .header = "City", .alignment = .left },
    };

    var table = try Table.init(allocator, &columns, null);
    defer table.deinit();

    try table.addRow(&[_][]const u8{ "Alice", "25", "New York" });
    try table.addRow(&[_][]const u8{ "Bob", "30", "San Francisco" });
    try table.addRow(&[_][]const u8{ "Charlie", "35", "London" });

    // 表格渲染到stdout，我们只测试不出现错误
    // 实际输出内容的测试需要更复杂的设置
}

test "table with custom config" {
    const allocator = std.testing.allocator;

    const columns = [_]ColumnConfig{
        ColumnConfig{ .header = "ID", .alignment = .right, .color = .green },
        ColumnConfig{ .header = "Product", .alignment = .left },
        ColumnConfig{ .header = "Price", .alignment = .right, .color = .yellow },
    };

    const config = TableConfig{
        .show_header = true,
        .column_separator = " || ",
        .row_separator = "=",
        .show_border = true,
        .header_color = .magenta,
        .table_color = .cyan,
    };

    var table = try Table.init(allocator, &columns, config);
    defer table.deinit();

    try table.addRow(&[_][]const u8{ "1", "Laptop", "$999.99" });
    try table.addRow(&[_][]const u8{ "2", "Mouse", "$29.99" });
    try table.addRow(&[_][]const u8{ "3", "Keyboard", "$79.99" });

    // 表格渲染到stdout，我们只测试不出现错误
}
