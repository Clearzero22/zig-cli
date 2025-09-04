const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn();

    try stdout.print("Keyboard Input Test\n", .{});
    try stdout.print("Press keys to see their codes (Ctrl+C to exit):\n", .{});
    try stdout.print("Note: This is a simple test that reads input character by character.\n", .{});

    // 创建缓冲区
    var buffer: [1]u8 = undefined;
    
    try stdout.print("Ready for input:\n", .{});
    
    // 简单的输入循环
    while (true) {
        // 读取一个字节
        const bytes_read = try stdin.read(&buffer);
        if (bytes_read == 0) break;
        
        const byte = buffer[0];
        
        // 显示按键信息
        try stdout.print("Key code: {d} (0x{X})", .{ byte, byte });
        
        // 如果是可打印字符，也显示字符本身
        if (byte >= 32 and byte <= 126) {
            try stdout.print(", Char: '{c}'", .{byte});
        }
        
        try stdout.print("\n", .{});
        
        // 特殊处理Ctrl+C (ASCII 3)
        if (byte == 3) {
            try stdout.print("Ctrl+C detected, exiting...\n", .{});
            break;
        }
    }
}