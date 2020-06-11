# PeerManager ([Rust](https://docs.rs/lightning/0.0.11/lightning/ln/peer_handler/struct.PeerManager.html))

## Prerequisites

* Ability to create TCP connections
* Knowledge of a peer's Lightning node identity key (aka static key)

## Instantiation

In principle, to instantiate a PeerManager through the bindings, you simply need to call

```c
PeerManager_new(LDKMessageHandler message_handler, LDKSecretKey our_node_secret, const uint8_t (*ephemeral_random_data)[32], LDKLogger logger)
```

However, let's walk through how to obtain each of the four arguments.

### Message Handler ([Rust](https://docs.rs/lightning/0.0.11/lightning/ln/peer_handler/struct.MessageHandler.html))

The message handler can be instantiated by calling 

```c
MessageHandler_new(LDKChannelMessageHandler chan_handler_arg, LDKRoutingMessageHandler route_handler_arg)
```

The two arguments it relies on, `ChannelMessageHandler` and `RoutingMessageHandler`, can initially
have placeholder values, so in Swift, we will temporarily use

```swift
let messageHandler = MessageHandler_new(LDKChannelMessageHandler(), LDKRoutingMessageHandler())
```

Once we set up a channel manager and blockchain listener later, we will then tie those in to
the channel message handler and routing message handler arguments, respectively.

### Our Node Secret

This is our node's identity private key. This is a private key that Rust Lightning can't do without,
as it is necessary for the noise protocol that is involved in handshake between two Lightning nodes.

As discussed [here](Primitives.md#secretkey), this is a 32-byte, fixed-length array of `UInt8`s,
passed by value to the C function. Assuming you have that tuple stored in a variable called
`privateKeyBytes`, we can then call

```swift
let ourNodeSecret = LDKSecretKey(bytes: privateKeyBytes)
```

### Ephemeral Random Data

This is the same type of [private key tuple](Primitives.md#secretkey), in this instance, not
even encapsulated by a special type. 

### Logger ([Rust](https://docs.rs/lightning/0.0.11/lightning/util/logger/trait.Logger.html))

This can be a global logging object that simply implements the `log` method of the `LDKLogger` type.

An elaborate Swift example could be:

```swift
func logCallback(pointer: UnsafeRawPointer?, buffer: UnsafePointer<Int8>?) -> Void {
    let instance: Logger = RawLDKTypes.pointerToInstance(pointer: pointer!)
    let message = String(cString: buffer!)
    instance.log(message: message)
}

let logger = LDKLogger(this_arg: RawLDKTypes.instanceToPointer(instance: self), log: logCallback)
```

### Tying it together

The resulting instantiation call would simply be

```swift
let peerManager = PeerManager_new(messageHandler, ourNodeSecret, ephemeralRandomDataBytes, logger)
```

## Initiating an outbound connection

Once we have the `LDKPeerManager` instance, we can now start communicating with other dwellers
of the Lightning network. 

The method call definition is simple:

```c
PeerManager_new_outbound_connection(const LDKPeerManager *this_arg, LDKPublicKey their_node_id, LDKSocketDescriptor descriptor)
```

The first argument is simply a pointer to the previously mentioned instance, `their_node_id`
is an encapsulated [33-byte-tuple](Primitives.md#publickey), and the descriptor is a bit more interesting.

### Descriptor

As Rust Lightning is oblivious to all networking, it cannot internally guarantee a bijective
mapping between socket connections and the peers' identity keys. To enable such a mapping,
it relies on us to create so-called socket descriptors, which bear the responsibility of
exposing the traffic between peers.

Firstly, we need to make sure that by the time we call this method, we have an open TCP connection
to the peer we wish to communicate with. We then instantiate an `LDKSocketDescriptor` and implement its `hash` method,
which aims to map each socket descriptor to a unique numeric id. This should enable the bijection we previously
discussed.

We further need to implement its `eq` method, which takes two descriptors and checks if they're describing
the same connection. The simplest approach would be checking if they have the same id.

Most importantly, we need to implement the `send_data` field, which will be called whenever
we need to send data to the peer. That callback should take the data, which comes in the form
of an [`LDKu8slice`](Primitives.md#u8slice), convert the data to a type the host environment
language natively understands, and pipe it into the TCP connection with the peer.

We should also implement the destructor callback, `disconnect_socket`, which ought to close the
TCP connection and stop all attached event listeners.

A partial approximation of all that is the following Swift snippet:

```swift
func sendDataCallback(pointer: UnsafeMutableRawPointer?, buffer: LDKu8slice, something: Bool) -> UInt {
    let instance: Peer = RawLDKTypes.pointerToInstance(pointer: pointer!)
    let data = RawLDKTypes.u8SliceToData(buffer: buffer)
    return instance.sendDataCallback(data: data)
}

func destructionCallback(pointer: UnsafeMutableRawPointer?) {
    let instance: Peer = RawLDKTypes.pointerToInstance(pointer: pointer!)
    instance.destructionCallback()
}

func eq(descriptor1: UnsafeRawPointer?, descriptor2: UnsafeRawPointer?) -> Bool {
    return Peer.eq(descriptor1: descriptor1, descriptor2: descriptor2)
}

func hash(descriptor: UnsafeRawPointer?) -> UInt64 {
    return Peer.hash(descriptor: descriptor)
}

let descriptor = LDKSocketDescriptor(
        this_arg: peerInstancePointer,
        send_data: sendDataCallback,
        disconnect_socket: destructionCallback,
        eq: eq,
        hash: hash
);
``` 

### First message

Notably, when opening an outbound connection, Rust Lightning synchronously [returns the first message](https://docs.rs/lightning/0.0.11/lightning/ln/peer_handler/struct.PeerManager.html#method.new_outbound_connection)
(as opposed to calling the descriptor's `send_data` callback). It's of the type `LDKCResult_CVec_u8ZPeerHandleErrorZ`,
and that type needs some unwrapping. In Swift, one approach to unwrapping the response could be

```swift
static func resultToData(result: LDKCResultTempl_CVecTempl_u8_____PeerHandleError) -> Data?{
    if(!result.result_good){
        return nil;
    }
    let contents: LDKCResultPtr_CVecTempl_u8_____PeerHandleError = result.contents
    let successfulResult: LDKCVecTempl_u8 = contents.result.pointee
    let data = Data.init(bytes: successfulResult.data, count: Int(successfulResult.datalen))

    return data
}
```

As you can see, the data instantiation is based on a type just like [`u8slice`](Primitives.md#u8slice).

## Next

You should now be able to send and receive basic messages to peers on the Lightning network, most notably
pings and pongs.

The major step to be taken now is creating a [`ChannelManager`](ChannelManager.md).

Keep in mind, when all things are tied together, the ChannelManager instance is actually 
created _before_ the PeerManager, such that the first argument to `MessageHandler_new(…)` can be
`ChannelManager_as_ChannelMessageHandler(…)` instead of the placeholder we defined above.