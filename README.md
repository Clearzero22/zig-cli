# 🚀 Zig CLI Library

🎨 A powerful and easy-to-use library for creating beautiful command-line interfaces in Zig.

## 🌟 Philosophy

At the heart of this library lies a simple philosophy: **Make CLI applications beautiful and intuitive without sacrificing performance or simplicity.**

We believe that command-line tools don't have to be boring or hard to use. With the power of Zig and thoughtful design, we can create CLI applications that are:
- 🚀 **Fast and efficient** - Leveraging Zig's performance
- 🎨 **Visually appealing** - With colors, styling, and animations
- 🧠 **Intuitive to use** - With clear interfaces and feedback
- 🛠️ **Easy to integrate** - Simple APIs that just work

This library aims to provide developers with the tools they need to create CLI applications that users actually enjoy interacting with.

## 📦 Features

-   🎨 **Text Coloring:** Print text in different colors.
-   ✨ **Text Styling:** Apply styles like bold, italic, and underline to text.
-   🌈 **RGB Colors:** Use custom RGB colors for text.
-   📊 **Progress Bars:** Display customizable progress bars in the terminal.
-   ⏳ **Spinners:** Display animated loading indicators in the terminal.
-   📋 **Tables:** Display structured data in tabular format in the terminal.
-   📋 **Menus:** Interactive menu system for user selections.
-   ⌨️ **Key Mapping:** Define and handle keyboard shortcuts.

## 🚀 Usage

To use the library, import the `cli_color.zig`, `cli_style.zig`, `progress.zig`, `spinner.zig`, `table.zig`, `menu.zig`, and `keymap.zig` files from the `src/lib` directory.

### 🎨 Coloring Text

```zig
const cli_color = @import("lib/cli_color.zig");

try cli_color.printlnColor("This is red text", .red);
```

### ✨ Styling Text

```zig
const cli_style = @import("lib/cli_style.zig");

try cli_style.printStyled("This is bold blue text\n", .{ .color = .blue, .style = .bold }, .{});
```

### 🌈 RGB Colors

```zig
const cli_color = @import("lib/cli_color.zig");

try cli_color.printRgbColor("This is text with custom RGB color (255, 165, 0)\n", 255, 165, 0, .{});
```

### 📊 Progress Bars

```zig
const progress = @import("lib/progress.zig");

// Create a basic progress bar
var pb = try progress.ProgressBar.init(100, null);

// Update the progress bar
for (0..100) |i| {
    try pb.update(i);
    // Do some work...
}

// Finish the progress bar
try pb.finish();
```

#### Customizing Progress Bars

```zig
const progress = @import("lib/progress.zig");

// Create a custom progress bar configuration
const config = progress.ProgressBarConfig{
    .width = 30,
    .complete_char = '#',
    .incomplete_char = '.',
    .show_percentage = true,
    .show_eta = true,
    .color = .magenta,
};

var pb = try progress.ProgressBar.init(50, config);
// ... use the progress bar
try pb.finish();
```

### ⏳ Spinners

```zig
const spinner = @import("lib/spinner.zig");

// Create a basic spinner
var s = try spinner.Spinner.init("Loading...", null);

// Start the spinner
try s.start();

// Update the spinner (usually in a loop)
for (0..10) |_| {
    try s.update();
    // Do some work...
}

// Stop the spinner with success message
try s.stop("Loading complete!");
```

#### Customizing Spinners

```zig
const spinner = @import("lib/spinner.zig");

// Create a custom spinner configuration
const config = spinner.SpinnerConfig{
    .frames = &.{ "|", "/", "-", "\\" },
    .interval = 200000,
    .color = .yellow,
};

var s = try spinner.Spinner.init("Processing...", config);
// ... use the spinner
try s.stop("Processing finished!");
```

#### Error Spinners

```zig
const spinner = @import("lib/spinner.zig");

var s = try spinner.Spinner.init("Connecting...", null);
try s.start();

// ... do some work ...

// Stop the spinner with error message
try s.stopWithError("Connection failed!");
```

### 📋 Tables

```zig
const table = @import("lib/table.zig");

// Define table columns
const columns = [_]table.ColumnConfig{
    table.ColumnConfig{ .header = "Name", .alignment = .left },
    table.ColumnConfig{ .header = "Age", .alignment = .right },
    table.ColumnConfig{ .header = "City", .alignment = .left },
};

// Create a table
var t = try table.Table.init(allocator, &columns, null);
defer t.deinit();

// Add rows
try t.addRow(&[_][]const u8{ "Alice", "25", "New York" });
try t.addRow(&[_][]const u8{ "Bob", "30", "San Francisco" });

// Render the table
try t.render();
```

#### Customizing Tables

```zig
const table = @import("lib/table.zig");

// Define table columns with custom styling
const columns = [_]table.ColumnConfig{
    table.ColumnConfig{ .header = "ID", .alignment = .right, .color = .green },
    table.ColumnConfig{ .header = "Product", .alignment = .left, .min_width = 15 },
    table.ColumnConfig{ .header = "Price", .alignment = .right, .color = .yellow, .min_width = 10 },
};

// Create a custom table configuration
const config = table.TableConfig{
    .show_header = true,
    .header_color = .blue,
    .table_color = .cyan,
    .show_border = true,
};

var t = try table.Table.init(allocator, &columns, config);
defer t.deinit();

// Add rows
try t.addRow(&[_][]const u8{ "1", "Laptop", "$999.99" });
try t.addRow(&[_][]const u8{ "2", "Mouse", "$29.99" });

// Render the table
try t.render();
```

### 📋 Menus

```zig
const menu = @import("lib/menu.zig");

// Define menu items
const items = [_]menu.MenuItem{
    menu.MenuItem{ .text = "View Files" },
    menu.MenuItem{ .text = "Edit Configuration" },
    menu.MenuItem{ .text = "System Information" },
    menu.MenuItem{ .text = "Exit" },
};

// Create a menu
var m = try menu.Menu.init(allocator, &items, null);
defer _ = m;

// Run the menu (this would normally handle user input)
const selected_index = try m.run();
```

#### Customizing Menus

```zig
const menu = @import("lib/menu.zig");

// Define menu items
const items = [_]menu.MenuItem{
    menu.MenuItem{ .text = "Yes" },
    menu.MenuItem{ .text = "No" },
    menu.MenuItem{ .text = "Cancel", .disabled = true },
};

// Create a custom menu configuration
const config = menu.MenuConfig{
    .prompt = "Please select an option:",
    .enable_number_keys = true,
    .enable_arrow_keys = true,
    .cycle_navigation = false,
    .color = .blue,
    .selected_color = .yellow,
};

var m = try menu.Menu.init(allocator, &items, config);
defer _ = m;

// Run the menu
const selected_index = try m.run();
```

### ⌨️ Key Mapping

```zig
const keymap = @import("lib/keymap.zig");

// Define a callback function
fn myCallback(event: keymap.KeyEvent) anyerror!void {
    std.debug.print("Shortcut triggered: {s}, Ctrl: {}, Alt: {}, Shift: {}\n", .{
        event.key, event.ctrl, event.alt, event.shift,
    });
}

// Create a key mapper
var mapper = keymap.KeyMapper.init(allocator);
defer mapper.deinit();

// Add a key mapping
try mapper.addMapping("c", true, false, false, myCallback); // Ctrl+C

// Create and handle a key event
var event = keymap.KeyEvent{ .key = "c", .ctrl = true, .alt = false, .shift = false };
try mapper.handleKeyEvent(event);
```

### ⌨️ Enhanced Key Mapping

The library also provides an enhanced key mapping module that supports a wider range of keys:

```zig
const keymap = @import("lib/keymap_enhanced.zig");

// Define a callback function
fn myCallback(event: keymap.KeyEvent) anyerror!void {
    // Handle different key types
    switch (event.key) {
        .char => |c| {
            std.debug.print("Character key '{c}' triggered, Ctrl: {}, Alt: {}, Shift: {}\n", .{
                c, event.ctrl, event.alt, event.shift,
            });
        },
        .f1 => {
            std.debug.print("F1 key triggered, Ctrl: {}, Alt: {}, Shift: {}\n", .{
                event.ctrl, event.alt, event.shift,
            });
        },
        .up => {
            std.debug.print("Up arrow key triggered, Ctrl: {}, Alt: {}, Shift: {}\n", .{
                event.ctrl, event.alt, event.shift,
            });
        },
        else => {
            std.debug.print("Other key triggered, Ctrl: {}, Alt: {}, Shift: {}\n", .{
                event.ctrl, event.alt, event.shift,
            });
        },
    }
}

// Create a key mapper
var mapper = keymap.KeyMapper.init(allocator);
defer mapper.deinit();

// Add key mappings for different key types
try mapper.addMapping(.{ .char = 'c' }, true, false, false, myCallback); // Ctrl+C
try mapper.addMapping(.f1, false, false, false, myCallback); // F1
try mapper.addMapping(.up, false, false, false, myCallback); // Up arrow

// Create and handle key events
const event1 = keymap.KeyEvent{ .key = .{ .char = 'c' }, .ctrl = true, .alt = false, .shift = false };
const event2 = keymap.KeyEvent{ .key = .f1, .ctrl = false, .alt = false, .shift = false };
const event3 = keymap.KeyEvent{ .key = .up, .ctrl = false, .alt = false, .shift = false };

try mapper.handleKeyEvent(event1);
try mapper.handleKeyEvent(event2);
try mapper.handleKeyEvent(event3);
```

## 🏗️ Building the Project

To build the project, run:

```bash
zig build
```

To run the example application:

```bash
zig build run
```

To run the keymap example:

```bash
zig build keymap
```

To run the enhanced keymap example:

```bash
zig build keymap_enhanced
```

To run the tests:

```bash
zig build test
```

To run performance tests:

```bash
zig build perf
```