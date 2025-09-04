# Zig CLI Library

A simple library for creating command-line interfaces in Zig.

## Features

-   **Text Coloring:** Print text in different colors.
-   **Text Styling:** Apply styles like bold, italic, and underline to text.
-   **RGB Colors:** Use custom RGB colors for text.
-   **Progress Bars:** Display customizable progress bars in the terminal.
-   **Spinners:** Display animated loading indicators in the terminal.

## Usage

To use the library, import the `cli_color.zig`, `cli_style.zig`, `progress.zig`, and `spinner.zig` files from the `src/lib` directory.

### Coloring Text

```zig
const cli_color = @import("lib/cli_color.zig");

try cli_color.printlnColor("This is red text", .red);
```

### Styling Text

```zig
const cli_style = @import("lib/cli_style.zig");

try cli_style.printStyled("This is bold blue text\n", .{ .color = .blue, .style = .bold }, .{});
```

### RGB Colors

```zig
const cli_color = @import("lib/cli_color.zig");

try cli_color.printRgbColor("This is text with custom RGB color (255, 165, 0)\n", 255, 165, 0, .{});
```

### Progress Bars

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

### Spinners

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

## Building the Project

To build the project, run:

```bash
zig build
```

To run the example application:

```bash
zig build run
```

To run the tests:

```bash
zig build test
```

To run performance tests:

```bash
zig build perf
```