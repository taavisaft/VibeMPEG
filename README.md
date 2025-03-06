# VibeMPEG

A lightning-fast MOV to MP4 video converter written in pure assembly.

## Features
- Direct MOV to MP4 conversion
- Optimized assembly implementation
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

VibeMPEG implements its own video codec for converting QuickTime MOV container format to MP4 container format. The implementation:

1. Parses MOV container format
2. Decodes video frames
3. Re-encodes to H.264 compatible format
4. Packages into MP4 container

All core processing is implemented in hand-optimized assembly for maximum performance.

## License

MIT License