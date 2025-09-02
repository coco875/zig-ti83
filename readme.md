# Zig TI-84+/83-Premium-CE

Experimental repo to run Zig code on the TI‑84+/83-Premium-CE (ez80) by emitting C and compiling with the [CE-Programming ez80 LLVM fork](https://github.com/CE-Programming/llvm-project).

## Status

Highly experimental. Expect rough edges, missing safety checks and potential undefined behavior. Use at your own risk.

## Prerequisites

You currently only need Zig (Linux only for now). The CE-Programming toolchain components (ez80 Clang/LLVM fork, fasmg, convbin, headers) are downloaded / provided automatically from the CE-Programming distribution.

MacOS / Windows could be supported later with path / tooling adaptations.

## Build

```sh
zig build
```

(Wrapper logic: invoke Zig -> emit C -> compile with ez80-clang -> link with fasmg -> convert with convbin.)

## Compilation Pipeline

1. Zig sources are compiled using Zig's C backend (`-femit-c`) instead of targeting an LLVM ez80 backend (none is upstream).
2. Generated C code is compiled by the CE-Programming fork of Clang that understands ez80.
3. Assembly is produced and linked (fasmg).
4. The linked artifact is converted into a TI-83+ compatible format via `convbin`.

## Why Not Rebuild Zig With The Fork?

Recompiling Zig against the forked LLVM would increase maintenance cost. Using the C emission path isolates the experiment and avoids maintaining a custom Zig toolchain.

## Architecture / Target Choice

Zig is invoked with a target like: `arm-freestanding-eabi` (placeholder):

- arm: Chosen mainly to discourage x86-specific lowering / optimizations in generated C assumptions and to ensure ≥32-bit pointer expectations.
- freestanding: Avoids accidental inclusion of OS-specific headers.
- eabi: A generic embedded ABI supported by the freestanding profile.

This target does NOT reflect the final ez80 architecture; it only influences what C Zig emits. The emitted C is later recompiled for ez80 by the forked Clang.

## 24-bit Integer Handling

The ez80 uses 8/16/24-bit registers. Some toolchain headers expose 24-bit types (commonly `int24_t`). Zig does not define `int24_t` unless `__INT24_TYPE__` is provided by the target, which it is not in this setup.

Workaround:

- Provide an alias: `typedef intptr_t int24_t;` (Based on hardware documentation: https://ce-programming.github.io/toolchain/static/hardware.html#the-24-bit-ez80-cpu stating pointer size alignment with required width in this context.)
- Manually patch headers to introduce the alias and remove constructs Zig rejects (e.g. specific bitfields relying on `int24_t`).

modified header can be find: https://github.com/coco875/ti83-zig-lib
Bitfields are removed/flattened because Zig's translate-c currently does not support the relevant C bitfields here (especially 24-bit or non-standard width layouts). As a result we can't use them to recreate 24bit int.

## Patches

### zig.h modifications
- Disable atomics (the ez80 toolchain lacks support for the builtin atomics sequence Zig would expect).
- Adjust `zig_return_address` to avoid unsupported builtin usage.

### Post-generation C adjustments
- Reintroduce the `tiflags` function attribute by patching emitted C sources (Zig strips it during C emission; not added inside zig.h).

## Current Limitations & Risks

- Toolchain header divergence may require periodic updates on the other repo.
- Error handling / panic paths from Zig may rely on runtime pieces not adapted to this environment.
- Not so much test have been done, so expect potential issues.

## Future Work

- Add more option for building like original makefile.
- Recreate all examples.
- Try find a way to use original function instead of relay on `addSystemCommand`.
- Redo headers in zig to avoid some problem of translate-c not being able to convert some macros.
- Cross-platform build scripts.
