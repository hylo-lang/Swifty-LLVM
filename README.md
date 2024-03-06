# Swifty-LLVM

[![codecov](https://codecov.io/gh/hylo-lang/Swifty-LLVM/graph/badge.svg?token=M80FBR8JX8)](https://codecov.io/gh/hylo-lang/Swifty-LLVM)

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

or, using [homebrew](https://brew.sh):

```bash
brew install llvm
```

Now make sure `llvm-config` is in your path (homebrew doesn't do that automatically; you'd need export PATH="$HOMEBREW_PREFIX/opt/llvm/bin:$PATH").
The command below should print the LLVM version installed on your system. 

```bash
llvm-config --version
```

Next, you need to create a `pkgconfig` file specific to your installation and make it visible to your build tools.

```bash
./Tools/make-pkgconfig.sh ./llvm.pc
``` 

The above command generates the `pkgconfig` file `./llvm.pc`.  You can either add its directory to your `PKG_CONFIG_PATH`
for use with command-line tools:

```bash
export PKG_CONFIG_PATH=$PWD
```

or you can put it somewhere that `pkg_config` already searches (needed for use with Xcode):

```bash
sudo mkdir -p /usr/local/lib/pkgconfig && sudo mv llvm.pc /usr/local/lib/pkgconfig/
```

### Build

You should be able to build this project using Swift package manager:

```bash
swift build -c release
```

> Note to macOS users: Add `platforms: [.macOS("xxx")]` to `Package.swift` where `xxx` is your macOS version to address the warning complaining that an "object file was built for newer macOS version than being linked".

### Troubleshooting:

On macOS, you may need to add the path to `zstd` library in `llvm.pc`.
