# Swifty-LLVM

**Swifty-LLVM** is a Swifty interface for the [LLVM](https://llvm.org) compiler infrastructure, currently wrapping LLVM's C API.

See also: [swift-llvm-bindings](https://github.com/apple/swift-llvm-bindings)

## Insallation:

First, install LLVM 15.0+ on your system using your favorite package manager and make sure `llvm-config` is in your path.
For example, using [MacPorts](https://www.macports.org) on macOS:

```bash
port install llvm-15 llvm_select
port select llvm mp-llvm-15
```

The official version of llvm for Windows does not contain `llvm-config`, so you need to compile it by yourself or find someone else who has already compiled it.

Then, make sure `llvm-config` is in your path.
The command below should print the LLVM version installed on your system. 

```bash
llvm-config --version
```

Next, you need to create a `pkgconfig` file specific to your installation.

On Unix systems, you can run the script `Tools/make-pkgconfig.sh`.
It will create a file `/usr/local/lib/pkgconfig/llvm.pc`:

```bash
./Tools/make-pkgconfig.sh
``` 

On Windows, you can copy the file in LLVM's `include` folder to the C++ standard library folder or customize `Sources/llvmc/llvmc.h`.

Finally, you should be able to build this project using Swift package manager:

```bash
swift build -c release
```

> Note to macOS users: Add `platforms: [.macOS("xxx")]` to `Package.swift` where `xxx` is your macOS version to address the warning complaining that an "object file was built for newer macOS version than being linked".

### Troubleshooting:

On macOS, you may need to add the path to `zstd` library in `llvm.pc`.
