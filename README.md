# VibeMPEG

A minimal MOV to MP4 video converter written in pure assembly.

## Features
- Basic MOV to MP4 file copying
- Pure assembly implementation
- Minimal memory footprint
- Zero dependencies

## Building

Requirements:
- NASM (Netwide Assembler)
- GCC (for linking)
- macOS (currently supported platform)

```bash
make
```

## Usage

```bash
./vibempeg input.mov output.mp4
```

## Implementation Details

VibeMPEG currently implements basic file copying functionality. The implementation:

1. Opens input MOV file
2. Opens output MP4 file
3. Copies data in 4KB chunks
4. Handles basic error conditions

All core processing is implemented in assembly for minimal overhead.

## License

MIT License

## PSA (the only thing in this whole project that a human wrote)

The code generated here is probably a big pile of shit and should not be used anywhere.
