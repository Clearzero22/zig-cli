const std = @import("std");
const cli_color = @import("cli_color.zig");

pub const Style = enum(u8) {
    bold,
    italic,
    underline,
    reset,
};

pub fn styleCode(s: Style) []const u8 {
    return switch (s) {
        .reset => "\x1b[0m",
        .bold => "\x1b[1m",
        .italic => "\x1b[3m",
        .underline => "\x1b[4m",
    };
}

pub fn printStyled(comptime fmt: []const u8, options: struct { color: cli_color.Color, style: Style }, args: anytype) !void {
    var buf: [1024]u8 = undefined;
    const formatted_str = try std.fmt.bufPrint(&buf, fmt, args);
    try std.io.getStdOut().writer().print("{s}{s}{s}{s}{s}", .{
        cli_color.colorCode(options.color),
        styleCode(options.style),
        formatted_str,
        cli_color.colorCode(.reset),
        styleCode(.reset),
    });
}

test "style codes" {
    try std.testing.expectEqualStrings("\x1b[1m", styleCode(.bold));
    try std.testing.expectEqualStrings("\x1b[3m", styleCode(.italic));
    try std.testing.expectEqualStrings("\x1b[4m", styleCode(.underline));
    try std.testing.expectEqualStrings("\x1b[0m", styleCode(.reset));
}