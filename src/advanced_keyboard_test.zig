const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn();

    try stdout.print("Advanced Keyboard Input Test\n", .{});
    try stdout.print("This test attempts to capture special keys and key combinations.\n", .{});
    try stdout.print("Press keys to see their codes (Ctrl+C to exit):\n", .{});
    try stdout.print("Note: Full support for special keys depends on terminal capabilities.\n\n", .{});

    var buffer: [100]u8 = undefined;
    
    try stdout.print("Ready for input (type characters, press function keys, try combinations):\n", .{});
    
    while (true) {
        // 读取输入
        const bytes_read = stdin.read(&buffer) catch |err| {
            try stdout.print("Error reading input: {}\n", .{err});
            break;
        };
        
        if (bytes_read == 0) break;
        
        // 显示接收到的字节
        try stdout.print("Received {d} byte(s):", .{bytes_read});
        for (buffer[0..bytes_read]) |byte| {
            try stdout.print(" {d}(0x{X})", .{ byte, byte });
        }
        try stdout.print("\n", .{});
        
        // 尝试解释常见的转义序列
        if (bytes_read >= 1) {
            const first_byte = buffer[0];
            
            // 单字节控制字符
            if (first_byte < 32 or first_byte == 127) {
                switch (first_byte) {
                    3 => try stdout.print("  -> Ctrl+C\n", .{}),
                    10 => try stdout.print("  -> Enter/Line Feed\n", .{}),
                    27 => {
                        if (bytes_read == 1) {
                            try stdout.print("  -> Escape\n", .{});
                        } else if (bytes_read >= 3 and buffer[1] == '[') {
                            // 可能是转义序列
                            try stdout.print("  -> Possible escape sequence\n", .{});
                            
                            // 常见的转义序列
                            if (bytes_read >= 3) {
                                switch (buffer[2]) {
                                    'A' => try stdout.print("    -> Up Arrow\n", .{}),
                                    'B' => try stdout.print("    -> Down Arrow\n", .{}),
                                    'C' => try stdout.print("    -> Right Arrow\n", .{}),
                                    'D' => try stdout.print("    -> Left Arrow\n", .{}),
                                    'F' => try stdout.print("    -> End (Key Pad)\n", .{}),
                                    'H' => try stdout.print("    -> Home (Key Pad)\n", .{}),
                                    'P' => try stdout.print("    -> F1\n", .{}),
                                    'Q' => try stdout.print("    -> F2\n", .{}),
                                    'R' => try stdout.print("    -> F3\n", .{}),
                                    'S' => try stdout.print("    -> F4\n", .{}),
                                    else => {},
                                }
                            }
                            
                            // 处理更长的转义序列
                            if (bytes_read >= 4 and buffer[2] == '[') {
                                switch (buffer[3]) {
                                    'A' => try stdout.print("    -> Up Arrow (Alternative)\n", .{}),
                                    'B' => try stdout.print("    -> Down Arrow (Alternative)\n", .{}),
                                    'C' => try stdout.print("    -> Right Arrow (Alternative)\n", .{}),
                                    'D' => try stdout.print("    -> Left Arrow (Alternative)\n", .{}),
                                    else => {},
                                }
                            }
                            
                            // 处理以[数字开头的序列（如F5-F12）
                            if (bytes_read >= 5 and buffer[2] >= '1' and buffer[2] <= '9') {
                                if (buffer[3] == '~') {
                                    switch (buffer[2]) {
                                        '1' => try stdout.print("    -> Home\n", .{}),
                                        '2' => try stdout.print("    -> Insert\n", .{}),
                                        '3' => try stdout.print("    -> Delete\n", .{}),
                                        '4' => try stdout.print("    -> End\n", .{}),
                                        '5' => try stdout.print("    -> Page Up\n", .{}),
                                        '6' => try stdout.print("    -> Page Down\n", .{}),
                                        else => {},
                                    }
                                }
                            }
                        }
                    },
                    127 => try stdout.print("  -> Backspace/Delete\n", .{}),
                    else => try stdout.print("  -> Control character\n", .{}),
                }
            } else {
                // 可打印字符
                try stdout.print("  -> Character: '{c}'\n", .{first_byte});
            }
        }
        
        try stdout.print("\n", .{});
    }
}