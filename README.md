# Zig CLI Library

A simple library for creating command-line interfaces in Zig.

## Features

-   **Text Coloring:** Print text in different colors.
-   **Text Styling:** Apply styles like bold, italic, and underline to text.

## Usage

To use the library, import the `cli_color.zig` and `cli_style.zig` files from the `src/lib` directory.

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

