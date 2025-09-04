const std = @import("std");
const cli_color = @import("cli_color.zig");

/// 旋转状态条配置
pub const SpinnerConfig = struct {
    /// 旋转字符序列
    frames: []const []const u8 = &.{ "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
    /// 更新间隔（微秒）
    interval: u64 = 100000, // 100ms
    /// 是否使用颜色
    color: ?cli_color.Color = .cyan,
};

/// 旋转状态条结构体
pub const Spinner = struct {
    config: SpinnerConfig,
    current_frame: usize,
    message: []const u8,
    writer: std.io.BufferedWriter(4096, std.fs.File.Writer),
    timer: ?std.time.Timer,
    is_running: bool,

    /// 创建新的旋转状态条
    pub fn init(message: []const u8, config: ?SpinnerConfig) !Spinner {
        return Spinner{
            .config = config orelse SpinnerConfig{},
            .current_frame = 0,
            .message = message,
            .writer = std.io.bufferedWriter(std.io.getStdErr().writer()),
            .timer = null,
            .is_running = false,
        };
    }

    /// 开始旋转动画
    pub fn start(self: *Spinner) !void {
        self.is_running = true;
        self.timer = try std.time.Timer.start();
        try self.display();
    }

    /// 更新旋转状态（显示下一帧）
    pub fn update(self: *Spinner) !void {
        if (!self.is_running) return;

        self.current_frame = (self.current_frame + 1) % self.config.frames.len;
        try self.display();
    }

    /// 显示当前帧
    pub fn display(self: *Spinner) !void {
        const writer = self.writer.writer();

        // 移动光标到行首并清除行
        try writer.writeAll("\r\x1b[K");

        // 写入颜色代码（如果指定）
        if (self.config.color) |color| {
            try writer.writeAll(cli_color.colorCode(color));
        }

        // 显示当前帧和消息
        try writer.print("{s} {s}", .{ self.config.frames[self.current_frame], self.message });

        // 重置颜色
        try writer.writeAll(cli_color.colorCode(.reset));

        // 刷新输出
        try self.writer.flush();
    }

    /// 停止旋转动画并显示完成状态
    pub fn stop(self: *Spinner, success_message: ?[]const u8) !void {
        if (!self.is_running) return;

        self.is_running = false;

        // 移动光标到行首并清除行
        const writer = self.writer.writer();
        try writer.writeAll("\r\x1b[K");

        // 显示完成消息
        if (self.config.color) |color| {
            try writer.writeAll(cli_color.colorCode(color));
        }

        if (success_message) |msg| {
            try writer.print("✓ {s}\n", .{msg});
        } else {
            try writer.print("✓ {s}\n", .{self.message});
        }

        try writer.writeAll(cli_color.colorCode(.reset));
        try self.writer.flush();
    }

    /// 停止旋转动画并显示错误状态
    pub fn stopWithError(self: *Spinner, error_message: ?[]const u8) !void {
        if (!self.is_running) return;

        self.is_running = false;

        // 移动光标到行首并清除行
        const writer = self.writer.writer();
        try writer.writeAll("\r\x1b[K");

        // 显示错误消息
        try writer.writeAll(cli_color.colorCode(.red));
        if (error_message) |msg| {
            try writer.print("✗ {s}\n", .{msg});
        } else {
            try writer.print("✗ {s}\n", .{self.message});
        }
        try writer.writeAll(cli_color.colorCode(.reset));
        try self.writer.flush();
    }
};

test "spinner basic functionality" {
    var spinner = try Spinner.init("Loading...", null);
    defer _ = spinner.writer.flush() catch {};

    try spinner.start();
    try spinner.update();
    try spinner.stop("Done!");
}

test "spinner with custom config" {
    const config = SpinnerConfig{
        .frames = &.{ "|", "/", "-", "\\" },
        .interval = 200000,
        .color = .yellow,
    };

    var spinner = try Spinner.init("Processing...", config);
    defer _ = spinner.writer.flush() catch {};

    try spinner.start();
    try spinner.update();
    try spinner.stop("Finished!");
}
