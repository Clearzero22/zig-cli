const std = @import("std");
const cli_color = @import("cli_color.zig");

/// 进度条配置
pub const ProgressBarConfig = struct {
    width: usize = 40,
    complete_char: u8 = '=',
    incomplete_char: u8 = '-',
    show_percentage: bool = true,
    show_eta: bool = true,
    color: ?cli_color.Color = .green,
};

/// 进度条结构体
pub const ProgressBar = struct {
    current: usize,
    total: usize,
    start_time: i64,
    config: ProgressBarConfig,
    writer: std.io.BufferedWriter(4096, std.fs.File.Writer),

    /// 创建新的进度条
    pub fn init(total: usize, config: ?ProgressBarConfig) !ProgressBar {
        const cfg = config orelse ProgressBarConfig{};
        return ProgressBar{
            .current = 0,
            .total = total,
            .start_time = std.time.microTimestamp(),
            .config = cfg,
            .writer = std.io.bufferedWriter(std.io.getStdErr().writer()),
        };
    }

    /// 更新进度
    pub fn update(self: *ProgressBar, current: usize) !void {
        self.current = current;
        try self.display();
    }

    /// 增加进度
    pub fn increment(self: *ProgressBar, amount: usize) !void {
        self.current += amount;
        if (self.current > self.total) {
            self.current = self.total;
        }
        try self.display();
    }

    /// 显示进度条
    pub fn display(self: *ProgressBar) !void {
        const writer = self.writer.writer();

        // 移动光标到行首并清除行
        try writer.writeAll("\r\x1b[K");

        // 计算进度百分比
        const percentage = @as(f64, @floatFromInt(self.current)) / @as(f64, @floatFromInt(self.total));
        const progress = @as(usize, @intFromFloat(percentage * @as(f64, @floatFromInt(self.config.width))));

        // 写入颜色代码（如果指定）
        if (self.config.color) |color| {
            try writer.writeAll(cli_color.colorCode(color));
        }

        // 绘制进度条
        try writer.writeByte('[');
        var i: usize = 0;
        while (i < self.config.width) : (i += 1) {
            if (i < progress) {
                try writer.writeByte(self.config.complete_char);
            } else {
                try writer.writeByte(self.config.incomplete_char);
            }
        }
        try writer.writeByte(']');

        // 重置颜色
        try writer.writeAll(cli_color.colorCode(.reset));

        // 显示百分比
        if (self.config.show_percentage) {
            try writer.print(" {d:.1}%", .{percentage * 100});
        }

        // 显示预计剩余时间
        if (self.config.show_eta and self.current > 0) {
            const elapsed = std.time.microTimestamp() - self.start_time;
            const estimated_total = @as(i64, @intFromFloat(@as(f64, @floatFromInt(elapsed)) / percentage));
            const remaining = estimated_total - elapsed;

            if (remaining > 0) {
                const seconds = @divTrunc(remaining, std.time.us_per_s);
                try writer.print(" ETA: {d}s", .{seconds});
            }
        }

        // 刷新输出
        try self.writer.flush();
    }

    /// 完成进度条（显示100%并换行）
    pub fn finish(self: *ProgressBar) !void {
        self.current = self.total;
        try self.display();
        const writer = self.writer.writer();
        try writer.writeAll("\n");
        try self.writer.flush();
    }
};

test "progress bar basic functionality" {
    var pb = try ProgressBar.init(100, null);
    defer pb.writer.flush() catch {};

    try pb.update(50);
    try pb.increment(25);
    try pb.finish();
}

test "progress bar with custom config" {
    const config = ProgressBarConfig{
        .width = 20,
        .complete_char = '#',
        .incomplete_char = '.',
        .show_percentage = true,
        .show_eta = false,
        .color = .blue,
    };

    var pb = try ProgressBar.init(100, config);
    defer pb.writer.flush() catch {};

    try pb.update(75);
    try pb.finish();
}
