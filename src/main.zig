const std = @import("std");
const cli_color = @import("lib/cli_color.zig");
const cli_style = @import("lib/cli_style.zig");
const progress = @import("lib/progress.zig");
const spinner = @import("lib/spinner.zig");
const table = @import("lib/table.zig");
const menu = @import("lib/menu.zig");

pub fn main() !void {
    // Demonstrate color printing
    try cli_color.printlnColor("This is red text", .red);
    try cli_color.printlnColor("This is green text", .green);
    try cli_color.printlnColor("This is blue text", .blue);

    // Demonstrate styled printing
    try cli_style.printStyled("This is bold blue text\n", .{ .color = .blue, .style = .bold }, .{});
    try cli_style.printStyled("This is italic yellow text\n", .{ .color = .yellow, .style = .italic }, .{});
    try cli_style.printStyled("This is underlined cyan text\n", .{ .color = .cyan, .style = .underline }, .{});

    // Demonstrate formatted and styled printing
    const name = "Zig";
    const version = "0.15.0";
    try cli_style.printStyled("Welcome to {s} v{s}\n", .{ .color = .magenta, .style = .bold }, .{ name, version });

    // Demonstrate RGB color printing
    try cli_color.printRgbColor("This is text with custom RGB color (255, 165, 0)\n", 255, 165, 0, .{});
    try cli_color.printRgbColor("Another RGB color (128, 0, 128) with number {d}\n", 128, 0, 128, .{123});

    // Add 10 different RGB test cases
    var i: u8 = 0;
    while (i < 10) : (i += 1) {
        const r = i * 25;
        const g = 255 - (i * 25);
        const b = i * 10;
        try cli_color.printRgbColor("RGB Test {d}: ({d}, {d}, {d})\n", r, g, b, .{ i, r, g, b });
    }

    // Demonstrate progress bar
    try cli_color.printlnColor("\n--- Progress Bar Demo ---", .yellow);

    // Basic progress bar
    try cli_color.printlnColor("Basic progress bar:", .cyan);
    var pb1 = try progress.ProgressBar.init(100, null);
    var j: usize = 0;
    while (j <= 100) : (j += 1) {
        try pb1.update(j);
        std.time.sleep(1000000 / 5); // Sleep 200ms
    }
    try pb1.finish();

    // Custom progress bar
    try cli_color.printlnColor("Custom progress bar:", .cyan);
    const progress_config = progress.ProgressBarConfig{
        .width = 30,
        .complete_char = '#',
        .incomplete_char = '.',
        .show_percentage = true,
        .show_eta = true,
        .color = .magenta,
    };
    var pb2 = try progress.ProgressBar.init(50, progress_config);
    j = 0;
    while (j <= 50) : (j += 1) {
        try pb2.update(j);
        std.time.sleep(10000000 / 2); // Sleep 500ms
    }
    try pb2.finish();

    // Progress bar with increment
    try cli_color.printlnColor("Progress bar with increment:", .cyan);
    var pb3 = try progress.ProgressBar.init(100, null);
    j = 0;
    while (j <= 100) : (j += 5) {
        try pb3.increment(5);
        std.time.sleep(100000000); // Sleep 1s
    }
    try pb3.finish();

    // File download simulation
    try cli_color.printlnColor("File download simulation:", .cyan);
    const file_size: usize = 1024 * 1024; // 1MB
    var pb4 = try progress.ProgressBar.init(file_size, progress.ProgressBarConfig{
        .width = 30,
        .complete_char = '=',
        .incomplete_char = ' ',
        .show_percentage = true,
        .show_eta = true,
        .color = .blue,
    });

    var downloaded: usize = 0;
    const chunk_size: usize = file_size / 50;
    while (downloaded < file_size) {
        const to_download = @min(chunk_size, file_size - downloaded);
        downloaded += to_download;
        try pb4.update(downloaded);
        // Simulate network delay - longer delays for better visualization
        std.time.sleep(1000000 * 2); // Sleep 2s
    }
    try pb4.finish();

    // Demonstrate spinner
    try cli_color.printlnColor("\n--- Spinner Demo ---", .yellow);
    // Basic spinner
    try cli_color.printlnColor("Basic spinner:", .cyan);
    var s1 = try spinner.Spinner.init("Loading...", null);
    try s1.start();
    var k: usize = 0;
    while (k < 20) : (k += 1) {
        try s1.update();
        std.time.sleep(100000000 * 2); // Sleep 2s
    }
    try s1.stop("Loading complete!");

    // Custom spinner
    try cli_color.printlnColor("Custom spinner:", .cyan);
    const custom_spinner_config = spinner.SpinnerConfig{
        .frames = &.{ "|", "/", "-", "\\" },
        .interval = 200000,
        .color = .yellow,
    };
    var s2 = try spinner.Spinner.init("Processing files...", custom_spinner_config);
    try s2.start();
    k = 0;
    while (k < 20) : (k += 1) {
        try s2.update();
        std.time.sleep(1000000 * 2); // Sleep 2s
    }
    try s2.stop("Processing finished!");

    // Error spinner
    try cli_color.printlnColor("Error spinner:", .cyan);
    var s3 = try spinner.Spinner.init("Connecting to server...", null);
    try s3.start();
    k = 0;
    while (k < 10) : (k += 1) {
        try s3.update();
        std.time.sleep(1000000 * 2); // Sleep 2s
    }
    try s3.stopWithError("Connection failed!");

    // Demonstrate table
    try cli_color.printlnColor("\n--- Table Demo ---", .yellow);

    // Basic table
    try cli_color.printlnColor("Basic table:", .cyan);
    const basic_columns = [_]table.ColumnConfig{
        table.ColumnConfig{ .header = "Name", .alignment = .left },
        table.ColumnConfig{ .header = "Age", .alignment = .right },
        table.ColumnConfig{ .header = "City", .alignment = .left },
    };

    var basic_table = try table.Table.init(std.heap.page_allocator, &basic_columns, null);
    defer basic_table.deinit();

    try basic_table.addRow(&[_][]const u8{ "Alice", "25", "New York" });
    try basic_table.addRow(&[_][]const u8{ "Bob", "30", "San Francisco" });
    try basic_table.addRow(&[_][]const u8{ "Charlie", "35", "London" });
    try basic_table.addRow(&[_][]const u8{ "Diana", "28", "Paris" });

    try basic_table.render();

    // Custom table with colors and alignment
    try cli_color.printlnColor("Custom table with colors:", .cyan);
    const custom_columns = [_]table.ColumnConfig{
        table.ColumnConfig{ .header = "ID", .alignment = .right, .color = .green },
        table.ColumnConfig{ .header = "Product", .alignment = .left, .min_width = 15 },
        table.ColumnConfig{ .header = "Price", .alignment = .right, .color = .yellow, .min_width = 10 },
        table.ColumnConfig{ .header = "Stock", .alignment = .center, .color = .magenta },
    };

    const custom_config = table.TableConfig{
        .show_header = true,
        .header_color = .blue,
        .table_color = .cyan,
        .show_border = true,
    };

    var custom_table = try table.Table.init(std.heap.page_allocator, &custom_columns, custom_config);
    defer custom_table.deinit();

    try custom_table.addRow(&[_][]const u8{ "1", "Laptop", "$999.99", "5" });
    try custom_table.addRow(&[_][]const u8{ "2", "Mouse", "$29.99", "50" });
    try custom_table.addRow(&[_][]const u8{ "3", "Keyboard", "$79.99", "25" });
    try custom_table.addRow(&[_][]const u8{ "4", "Monitor", "$299.99", "15" });

    try custom_table.render();

    // Demonstrate menu
    try cli_color.printlnColor("\n--- Menu Demo ---", .yellow);

    // Basic menu
    try cli_color.printlnColor("Basic menu:", .cyan);
    const menu_items = [_]menu.MenuItem{
        menu.MenuItem{ .text = "查看文件" },
        menu.MenuItem{ .text = "编辑配置" },
        menu.MenuItem{ .text = "系统信息" },
        menu.MenuItem{ .text = "退出程序" },
    };

    var basic_menu = try menu.Menu.init(std.heap.page_allocator, &menu_items, null);

    // 运行菜单交互（在实际应用中会等待用户输入）
    const result = try basic_menu.run();
    _ = result; // 在实际应用中我们会使用这个结果
    try cli_color.printlnColor("Menu interaction completed", .green);
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit();
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
