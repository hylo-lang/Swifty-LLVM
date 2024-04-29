# Swifty-LLVM

[![codecov](https://codecov.io/gh/hylo-lang/Swifty-LLVM/graph/badge.svg?token=M80FBR8JX8)](https://codecov.io/gh/hylo-lang/Swifty-LLVM)

**Swifty-LLVM** is a Swifty interface for the [LLVM](https://llvm.org) compiler infrastructure, currently wrapping LLVM's C API.

See also: [swift-llvm-bindings](https://github.com/apple/swift-llvm-bindings)

## Installation:

### Development/Use Requirements

### Swift

This package requires Swift 5.9

### LLVM

This package requires LLVM 17.  Major versions of LLVM are not
interchangeable or backward-compatible.

If you are using this package for development we strongly recommend
the use of an LLVM with assertions enabled such as
[these](https://github.com/hylo-lang/llvm-build); otherwise it's much
too easy to violate LLVM's preconditions without knowing it.  This
package's devcontainer (in the `.devcontainer` subdirectory) has
assert-enabled LLVM builds preinstalled in `/opt/llvm-Debug` and
`/opt/llvm-MinSizeRel`.

*If* you want to build with the Swift Package Manager and you choose
to get LLVM some other way, you'll need an installation with an
`llvm-config` executable, which we will use to create a `pkg-config`
file for LLVM.

## Building with CMake and Ninja

1. **Configure**: choose a *build-directory* and a CMake `build-type`
   (usually `Debug` or `Release`) and then, where `<LLVM>` is the path
   to the root directory of your LLVM installation,

	```
	cmake -D CMAKE_BUILD_TYPE=<build-type> \
	  -D LLVM_DIR=<LLVM>/lib/cmake/llvm   \
      -G Ninja -S . -B <build-directory>
    ```

    (on Windows substitute your shell's line continuation character
    for `\` or just remove the line breaks and backslashes).
    
    If you want to run tests, add `-DBUILD_TESTING=1`.
    
    **Note:** on macOS, if you are not using your Xcode's default
    toolchain, [you may need `-D
    CMAKE_Swift_COMPILER=swiftc`](https://gitlab.kitware.com/cmake/cmake/-/issues/25750)
    to prevent CMake from using Xcode's default `swift`.
    
    If this command fails it could be because you have an LLVM without
    CMake support installed; we suggest you try one of
    [these](https://github.com/hylo-lang/llvm-build) packages instead.

2.  **Build**: 

    ```
    cmake --build <build-directory>
    ```

3. **Test** (requires `-DBUILD_TESTING=1` in step 1):

   ```
   ctest --test-dir <build-directory>
   ```

## Building with CMake and Xcode

1. **Generate Xcode project**: choose a *build-directory* and then,
   where `<LLVM>` is the path to the root directory of your LLVM
   installation,

    ```
    cmake -D LLVM_DIR=<LLVM>/lib/cmake/llvm \
      -G Xcode -S . -B <build-directory>
    ```

    If you want to run tests, add `-DBUILD_TESTING=1`.

2. **Profit**: open the `.xcodeproj` file in the *build-directory* and
   use Xcode's UI to build.

## Building with Swift Package Manager

First, you need to create a `pkgconfig` file specific to your
installation and make it visible to your build tools.  We use a `bash`
script as follows in the top-level directory of this project:

```bash
./Tools/make-pkgconfig.sh ./llvm.pc
``` 

if you are on Windows, your `git` installation (which is required for
Swift) contains a `bash` executable so you can do something like:

```bash
C:\Program Files\Git\bin\bash ./Tools/make-pkgconfig.sh ./llvm.pc
``` 

The command above generates `llvm.pc` in the current directory and
prints its contents to the terminal.  You can either add its directory
to your `PKG_CONFIG_PATH` environtment variable for use with
command-line tools:

```bash
export PKG_CONFIG_PATH=$PWD
```

or you can put it somewhere that `pkg_config` already searches (needed
for use with Xcode):

```bash
sudo mkdir -p /usr/local/lib/pkgconfig && sudo mv llvm.pc /usr/local/lib/pkgconfig/
```

Once `llvm.pc` is set up, you should be able to **build this project**
using Swift package manager:

```bash
swift build -c release
```

### Running the tests

To test your compiler,

```bash
swift test -c release --parallel
```

### Notes to macOS users:

1. Add `platforms: [.macOS("xxx")]` to `Package.swift` where `xxx` is
   your macOS version to address the warning complaining that an
   "object file was built for newer macOS version than being linked".
2. You may need to add the path to `zstd` library in `llvm.pc`.
