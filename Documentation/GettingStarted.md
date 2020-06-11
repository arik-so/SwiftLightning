# Getting Started

Disclaimer: this guide is based on a currently unreleased and rapidly changing [experimental
branch](https://github.com/TheBlueMatt/rust-lightning/tree/2020-05-sample-c-bindings) of 
Rust Lightning. It may become out of date at any point.

That being said, the first thing you will need to do is check out above experimental branch:

```shell script
git clone --single-branch --branch 2020-05-sample-c-bindings git@github.com:TheBlueMatt/rust-lightning.git
```

The relevant directory and Cargo crate is `lightning-c-bindings`.

## Header Files

The bindings are exposed through a compiled binary and, depending on the bound environment,
either C or C++ header files. The header files don't vary between architectures, so for your
convenience, they are already provided in the `include` subdirectory. (The full path from 
the project root is thus `lightning-c-bindings/include`.)

As we're primarily focused on the application in Swift, we cannot use C++ header files, so the
only two files from that directory we need are `lightning.h` and `rust_types.h`.

If you're working with C++, you will instead only need `lightning.hpp`.

## Compilation

Depending on your requirement, you may need to compile a static or dynamic library to link your
project against.

### iOS

In Swift's case, we need to compile a static library for Apple's mobile architecture. 
If you haven't done so already, install these architectures to your Rust target list:

```shell script
rustup target add aarch64-apple-ios x86_64-apple-ios
```

Then, once again only if you haven't done so already, install `cargo-lipo` to simplify the 
compilation of universal binaries.

```shell script
cargo install cargo-lipo
```

Now you are ready to compile the static library for Rust Lightning bindings!

Inside the `lightning-c-bindings` directory, run

```shell script
cargo lipo --release
```

Navigate to the parent directory, and you should now be able to locate the library file at `/target/universal/release/liblightning.a`.

### Other

For other architectures where, unlike iOS, you don't need to compile the equivalent of a universally
linked library, running

```shell script
cargo build --release
```

should suffice to produce both a statically and a dynamically linked library.

## Linking

### iOS

If you're building an iOS application, you need to make sure to link your Xcode project against
the static library and header files. That involves updating the `Library Search Paths` and
`Header Search Paths` values to point to the directories that `liblightning.a` and the header files
are contained in, respectively.

Additionally, if you're using Swift, as I will be assuming for this guide, you will need to create
an Objective-C bridging header, and include the two C header files in it:

```objectivec
#import "rust_types.h"
#import "ldk_ffi.h"
```

You should now be good to go to call any of the exposed C methods from any Swift file!

## Next

Before you start working with the actual exposed types outlined in the [Readme](README.md), 
there are a couple of primitive types that will be reused in between method calls that you
may want to build conversion utility methods for for your project's language. To that end,
the [Primitives](Primitives.md) guide should hopefully be a handy reference for when you work
on integrating the major components.

The first major component you will likely want to support is the [PeerManager](PeerManager.md).  