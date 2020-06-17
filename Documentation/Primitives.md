# Primitives

## u8slice

The most essential task in working with the bindings is sending and processing data. The u8slice,
exposed as `LDKu8slice`, is the quintessential component for that task.

At its core, it's simply a struct of the form

```c
LDKu8slice {
   const uint8_t *data;
   uintptr_t datalen;
}
```

It's not the only type of such form, however. As you work with object-specific types such as `LDKCResultTempl_CVecTempl_u8_____PeerHandleError`,
you will find that they may contain other structs of the exact same form, e. g. `LDKCVecTempl_u8`.

Note that most types will need to be released, even though some others may not. The best heuristic for if 
you should is whether there is an exposed C method with the type's name and a `_free` suffix, like `CVec_u8Z_free()`.
Running [Valgrind](https://www.valgrind.org/) with LLVM's [LeakSanitizer](https://clang.llvm.org/docs/LeakSanitizer.html)
should help you get your host implementation leak-free production-ready.

## Fixed-length-types

There are certain data types that are comprised of a fixed number of primitives. If your language
does not support length-annotated types, or fixed-length arrays whose size is known a priori and
immutable, you may need to circumvent this issue by relying on tuples, as is the case in Swift.

Typically, you should encounter such exposed (typically binary) types that take data not by reference, 
so corresponding exposed methods that take those types as arguments may instead present themselves 
as taking a tuple of single bytes in your environment.

In Swift, it would be a tuple comprised of `n` elements of the type `UInt8`. The most common such types
are listed below, where the only variable is `n`. 

### SecretKey

32 bytes.

### PublicKey

33 bytes.

### BlockHeader

80 bytes.

## Instance Pointer

To be able to handle callbacks in an object-oriented manner, that is, to tie them to an instance,
you will find a lot of structs of the form

```c
Foo {
   void *this_arg;
    
   /* … */
   void (*bar)(const void *this_arg, LDKTransaction tx);
}
```

When instantiating `Foo`, if it is to be tied to some class instance in the host language, say
`HostFoo`, you can set `this_arg` as a pointer to the `HostFoo` instance. However, the point
of `this_arg` is that it can be set to a pointer to absolutely anything, as the library
is completely agnostic to its type. The host language then deals with the pointer as is
most convenient.

The callback methods you define should be extremely simple and not capture any context. To achieve that,
when defining the `bar` implementation, it should be something as simple as

```swift
func bar(this_arg: UnsafeRawPointer?, tx: LDKTransaction) -> Void {
    // find the host language's instance of HostFoo using the pointer
    let instance: HostFoo = pointerToInstance(pointer: this_arg!)

    // call the corresponding relevant function, passing the remaining arguments
    instance.bar(tx: tx)
}
``` 