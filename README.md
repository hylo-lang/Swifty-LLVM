# Swifty-LLVM

[![codecov](https://codecov.io/gh/hylo-lang/Swifty-LLVM/graph/badge.svg?token=M80FBR8JX8)](https://codecov.io/gh/hylo-lang/Swifty-LLVM)

**Swifty-LLVM** is a Swifty interface for the [LLVM](https://llvm.org) compiler infrastructure, currently wrapping LLVM's C API.

See also: [swift-llvm-bindings](https://github.com/apple/swift-llvm-bindings)

## Development/Use Requirements

### Swift

This package requires Swift 6.2

### LLVM

This package requires LLVM 20.  Major versions of LLVM are not
interchangeable or backward-compatible.

If you are using this package for development we strongly recommend
the use of an LLVM with assertions enabled such as
[these](https://github.com/hylo-lang/llvm-build); otherwise it's much
too easy to violate LLVM's preconditions without knowing it.  This
package's devcontainer (in the `.devcontainer` subdirectory) has
assert-enabled LLVM builds preinstalled in `/opt/llvm-Debug` and
`/opt/llvm-MinSizeRel`.

## Building with CMake and Ninja

1. **Configure**: choose a *build-directory* and a CMake *build type*
   (usually `Debug` or `Release`) and then, where `<LLVM>` is the path
   to the root directory of your LLVM installation,

	```
	cmake -D CMAKE_BUILD_TYPE=<build-type> \
	  -D LLVM_DIR=<LLVM>/lib/cmake/llvm    \
     -G Ninja -S . -B <build-directory>
   ```

   (on Windows substitute your shell's line continuation character
   for `\` or just remove the line breaks and backslashes).
    
   If you want to run tests, add `-DBUILD_TESTING=1`.
    
   **Note:** on macOS, if you are not using your Xcode's default
   toolchain, [you may need `-D CMAKE_Swift_COMPILER=swiftc`](https://gitlab.kitware.com/cmake/cmake/-/issues/25750)
   to prevent CMake from using Xcode's default `swift`.
   
   If this command fails it could be because you have an LLVM without
   CMake support installed; we suggest you try one of
   [these](https://github.com/hylo-lang/llvm-build) packages instead.

2. **Build**: 

   ```
   cmake --build <build-directory>
   ```

3. **Test** (requires `-DBUILD_TESTING=1` in step 1):

   ```
   ctest --parallel --test-dir <build-directory>
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
   use Xcode's UI to build and test.

## Building with Swift Package Manager or Xcode

You can skip the following steps if you are using development containers.

1. Install [pkg-config](https://en.wikipedia.org/wiki/Pkg-config).
  - Ubuntu: `sudo apt install pkg-config`
  - Windows: `choco install pkgconfiglite` ([Chocolatey](https://community.chocolatey.org/packages/pkgconfiglite)) or [install it manually](https://sourceforge.net/projects/pkgconfiglite/)
  - MacOS: `sudo port install pkgconfig` ([Mac Ports](https://ports.macports.org/port/pkgconfig/))
2. a) When not using Xcode: Add your [LLVM installation](https://github.com/hylo-lang/llvm-build)'s `pkgconfig` subfolder to `PKG_CONFIG_PATH` unless you are using Xcode.

   b) When using Xcode: You will need to install `llvm.pc` in a directory that's already searched by Xcode, e.g. `/usr/local/lib/pkgconfig/`. The Hylo LLVM installation includes a script in [`<LLVM>/pkgconfig/install-pc.sh`](https://github.com/hylo-lang/llvm-build/blob/main/scripts/install-pc.sh) that helps with this:
    ```
    cd <LLVM>/pkgconfig
    ./install-pc.sh llvm.pc /usr/local/lib/pkgconfig/
    ```

Now you should be able to build and test the project:

```bash
swift build -c release
swift test -c release
```

## Notes to macOS users:

1. Add `platforms: [.macOS("xxx")]` to `Package.swift` where `xxx` is
   your macOS version to address the warning complaining that an
   "object file was built for newer macOS version than being linked".
2. You may need to add the path to `zstd` library in `llvm.pc`.
