# Development Guide

This document provides an overview of the project structure, build process, and guidelines for contributing to the Zig CLI Library.

## Project Structure

The project is organized as follows:

-   `src/`: Contains all source code files.
    -   `src/lib/`: Core CLI library modules.
        -   `cli_color.zig`: Handles text coloring (standard and RGB).
        -   `cli_style.zig`: Handles text styling (bold, italic, underline).
        -   `progress.zig`: Handles progress bar functionality.
        -   `spinner.zig`: Handles spinner functionality.
        -   `table.zig`: Handles table display functionality.
        -   `menu.zig`: Handles menu selection functionality.
    -   `src/main.zig`: The main application entry point and example usage of the library.
    -   `src/performance_test.zig`: Contains code for performance benchmarking of the library's features.
-   `build.zig`: The Zig build system configuration file, defining how the project is built, tested, and run.
-   `README.md`: User-facing documentation, providing an overview of features and usage instructions.
-   `DEVELOPMENT.md`: This document, for developers.

## Building and Running

To build the project, navigate to the project root and run:

```bash
zig build
```

To run the example application (defined in `src/main.zig`):

```bash
zig build run
```

To run the unit tests (defined in `src/main.zig`, `src/lib/cli_color.zig`, `src/lib/cli_style.zig`, `src/lib/progress.zig`, `src/lib/spinner.zig`, `src/lib/table.zig`, and `src/lib/menu.zig`):

```bash
zig build test
```

To run the performance tests (defined in `src/performance_test.zig`):

```bash
zig build perf
```

## Core Modules Explanation

### `src/lib/cli_color.zig`

This module provides functions for coloring text output in the terminal.

-   `Color` enum: Defines standard terminal colors (e.g., `red`, `green`, `blue`, `bright_white`).
-   `colorCode(c: Color) []const u8`: Returns the ANSI escape code for a given `Color`.
-   `printColor(comptime fmt: []const u8, color: Color, args: anytype) !void`: Prints formatted text in a specified standard color.
-   `printlnColor(text: []const u8, color: Color) !void`: A convenience function to print a line of text in a specified standard color.
-   `printRgbColor(comptime fmt: []const u8, r: u8, g: u8, b: u8, args: anytype) !void`: Prints formatted text using custom 24-bit RGB colors.

### `src/lib/cli_style.zig`

This module provides functions for applying styles to text output in the terminal.

-   `Style` enum: Defines text styles (e.g., `bold`, `italic`, `underline`).
-   `styleCode(s: Style) []const u8`: Returns the ANSI escape code for a given `Style`.
-   `printStyled(comptime fmt: []const u8, options: struct { color: cli_color.Color, style: Style }, args: anytype) !void`: Prints formatted text with a combination of color and style.

### `src/lib/progress.zig`

This module provides functions for creating and managing progress bars in the terminal.

-   `ProgressBarConfig` struct: Configuration options for customizing progress bars.
  - `width`: Width of the progress bar in characters (default: 40).
  - `complete_char`: Character to use for the completed portion (default: '=').
  - `incomplete_char`: Character to use for the incomplete portion (default: '-').
  - `show_percentage`: Whether to show the completion percentage (default: true).
  - `show_eta`: Whether to show the estimated time of arrival (default: true).
  - `color`: Color of the progress bar (default: .green).
-   `ProgressBar` struct: The main progress bar structure.
-   `init(total: usize, config: ?ProgressBarConfig) !ProgressBar`: Creates a new progress bar with the specified total steps and optional configuration.
-   `update(self: *ProgressBar, current: usize) !void`: Updates the progress bar to the specified step.
-   `increment(self: *ProgressBar, amount: usize) !void`: Increments the progress bar by the specified amount.
-   `display(self: *ProgressBar) !void`: Displays the current state of the progress bar.
-   `finish(self: *ProgressBar) !void`: Completes the progress bar and moves to a new line.

### `src/lib/spinner.zig`

This module provides functions for creating and managing animated loading indicators in the terminal.

-   `SpinnerConfig` struct: Configuration options for customizing spinners.
  - `frames`: Array of characters to use for the animation frames (default: braille characters).
  - `interval`: Update interval in microseconds (default: 100000).
  - `color`: Color of the spinner (default: .cyan).
-   `Spinner` struct: The main spinner structure.
-   `init(message: []const u8, config: ?SpinnerConfig) !Spinner`: Creates a new spinner with the specified message and optional configuration.
-   `start(self: *Spinner) !void`: Starts the spinner animation.
-   `update(self: *Spinner) !void`: Updates the spinner to the next frame.
-   `display(self: *Spinner) !void`: Displays the current frame of the spinner.
-   `stop(self: *Spinner, success_message: ?[]const u8) !void`: Stops the spinner and displays a success message.
-   `stopWithError(self: *Spinner, error_message: ?[]const u8) !void`: Stops the spinner and displays an error message.

### `src/lib/table.zig`

This module provides functions for creating and displaying tabular data in the terminal.

-   `TableConfig` struct: Configuration options for customizing tables.
  - `show_header`: Whether to display the table header (default: true).
  - `column_separator`: String to use as column separator (default: " | ").
  - `row_separator`: String to use as row separator (default: "-").
  - `show_border`: Whether to display table borders (default: true).
  - `header_color`: Color of the table header (default: .blue).
  - `table_color`: Color of the table content (default: null).
-   `ColumnConfig` struct: Configuration options for table columns.
  - `header`: Column header text.
  - `alignment`: Text alignment (left, center, right).
  - `min_width`: Minimum column width.
  - `max_width`: Maximum column width (0 for no limit).
  - `color`: Color of the column content.
-   `Table` struct: The main table structure.
-   `init(allocator: std.mem.Allocator, columns: []const ColumnConfig, config: ?TableConfig) !Table`: Creates a new table with the specified columns and optional configuration.
-   `addRow(self: *Table, row: []const []const u8) !void`: Adds a row of data to the table.
-   `render(self: *Table) !void`: Renders and displays the table.
-   `deinit(self: *Table) void`: Frees allocated resources.

### `src/lib/menu.zig`

This module provides functions for creating and managing interactive menus in the terminal.

-   `MenuConfig` struct: Configuration options for customizing menus.
  - `prompt`: Prompt text to display above the menu (default: "请选择一个选项:").
  - `enable_number_keys`: Whether to enable number key selection (default: true).
  - `enable_arrow_keys`: Whether to enable arrow key navigation (default: true).
  - `cycle_navigation`: Whether to cycle navigation (default: true).
  - `color`: Color of the menu (default: .cyan).
  - `selected_color`: Color of the selected item (default: .green).
-   `MenuItem` struct: Represents a menu item.
  - `text`: The text to display for the menu item.
  - `value`: Optional value associated with the menu item.
  - `disabled`: Whether the menu item is disabled.
-   `Menu` struct: The main menu structure.
-   `init(allocator: std.mem.Allocator, items: []const MenuItem, config: ?MenuConfig) !Menu`: Creates a new menu with the specified items and optional configuration.
-   `display(self: *Menu) !void`: Displays the menu.
-   `select(self: *Menu, index: usize) !void`: Selects the item at the specified index.
-   `moveUp(self: *Menu) void`: Moves the selection up.
-   `moveDown(self: *Menu) void`: Moves the selection down.
-   `getSelected(self: *Menu) MenuItem`: Returns the currently selected menu item.
-   `getSelectedIndex(self: *Menu) usize`: Returns the index of the currently selected item.
-   `run(self: *Menu) !usize`: Runs the menu interaction and returns the selected index.

## Adding New Features

When adding new features or modules, please follow these guidelines:

1.  **Modularity:** Organize new code into logical modules within the `src/lib/` directory.
2.  **Testing:** Always write unit tests for new functions and features. Place tests within `test` blocks in the relevant `.zig` files.
3.  **Documentation:** Update `README.md` for user-facing changes and `DEVELOPMENT.md` for developer-facing changes (e.g., new modules, build steps).
4.  **Build System:** If you add new executables or top-level modules that are not imported by `main.zig` or `performance_test.zig`, remember to update `build.zig` accordingly.

## Contribution Guidelines

-   **Code Style:** Adhere to the existing code style and formatting. Use `zig fmt` to format your code.
-   **Testing:** Ensure all existing tests pass (`zig build test`) and new features are covered by tests.
-   **Commit Messages:** Use clear and concise commit messages. A common convention is `type: Subject` (e.g., `feat: Add new feature`, `fix: Fix bug`, `docs: Update documentation`).

## Troubleshooting

-   **Build Errors:** If you encounter build errors, check the console output carefully. Often, the error message will point to the exact line and issue.
-   **Clean Build:** Sometimes, old build artifacts can cause issues. Try running `zig clean` to remove all build artifacts and then `zig build` again.
-   **Verbose Output:** For more detailed build information, run `zig build --verbose`.
