# Swifty-LLVM

**Swifty-LLVM** is a Swifty interface for the [LLVM](https://llvm.org) compiler infrastructure, currently wrapping LLVM's C API.

See also: [swift-llvm-bindings](https://github.com/apple/swift-llvm-bindings)

## Insallation:

### Setting the Environment

On Windows, the official version of llvm does not include `llvm-config.exe`, so you need to compile LLVM by yourself or use third-party versions of LLVM.

For details about how to configure the environment in Windows, see Windows CI.

On MacOS and Linux:

First, install LLVM 15.0+ on your system using your favorite package manager and make sure `llvm-config` is in your path.
For example, using [MacPorts](https://www.macports.org) on macOS:

```bash
port install llvm-15 llvm_select
port select llvm mp-llvm-15
```

Then, make sure `llvm-config` is in your path.
The command below should print the LLVM version installed on your system. 

```bash
llvm-config --version
```

Next, you need to create a `pkgconfig` file specific to your installation.

You can run the script `Tools/make-pkgconfig.sh`.
It will create a file `/usr/local/lib/pkgconfig/llvm.pc`:

```bash
./Tools/make-pkgconfig.sh
``` 

### Build

You should be able to build this project using Swift package manager:

```bash
swift build -c release
```

> Note to macOS users: Add `platforms: [.macOS("xxx")]` to `Package.swift` where `xxx` is your macOS version to address the warning complaining that an "object file was built for newer macOS version than being linked".

### Troubleshooting:

On macOS, you may need to add the path to `zstd` library in `llvm.pc`.
