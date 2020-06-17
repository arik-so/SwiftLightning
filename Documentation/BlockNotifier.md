# BlockNotifier ([Rust](https://docs.rs/lightning/0.0.11/lightning/chain/chaininterface/struct.BlockNotifier.html))

As discussed [here](README.md#chain-monitoring), the BlockNotifier struct allows us to
monitor the blockchain much more easily, by doing the work of extracting relevant information
from raw block data for us.

## Setup

Before we can use the BlockNotifier, however, we need some prior setup that involves the PeerManager.

Specifically, the BlockNotifier needs to be connected to a [ChainWatchInterface](https://docs.rs/lightning/0.0.11/lightning/chain/chaininterface/trait.ChainWatchInterface.html).

The reason being that `ChainWatchInterface` is responsible for keeping track of which outputs and 
transactions we care about, whereas the BlockNotifier keeps track of objects which want to hear about
new blocks, using the ChainWatchInterface to filter for relevant transactions.

When using the bindings, that chain watch interface is a component of an `LDKNetGraphMsgHandler`,
which in turn can be converted to a [RoutingMessageHandler](https://docs.rs/lightning/0.0.11/lightning/ln/msgs/trait.RoutingMessageHandler.html).

To better visualize the picture, here is an approximation of a Swift setup inside a class method:

```swift
// HostRoutingMessageHandler.swift

self.cChainWatchInterfaceUtil = ChainWatchInterfaceUtil_new(LDKNetwork_Testnet)
let chainWatchInterfacePointer = withUnsafePointer(to: self.cChainWatchInterfaceUtil!) { (pointer: UnsafePointer<LDKChainWatchInterfaceUtil>) -> UnsafePointer<LDKChainWatchInterfaceUtil> in
    pointer
}
self.cChainWatchInterface = ChainWatchInterfaceUtil_as_ChainWatchInterface(chainWatchInterfacePointer);

self.cNetGraphMessageHandler = NetGraphMsgHandler_new(self.cChainWatchInterface, logger.cLogger!)
let netGraphMessageHandlerPointer = withUnsafePointer(to: self.cNetGraphMessageHandler!) { (pointer: UnsafePointer<LDKNetGraphMsgHandler>) -> UnsafePointer<LDKNetGraphMsgHandler> in
    pointer
}
self.cRoutingMessageHandler = NetGraphMsgHandler_as_RoutingMessageHandler(netGraphMessageHandlerPointer)
```

Notably, references to several of the objects are retained for later exposure. Tying together
the information from [ChannelManager](ChannelManager.md#next), we can now fully replace the 
placeholder values for the PeerManager's [message handler instantiation](PeerManager.md#message-handler-rust):

```swift
let messageHandler = MessageHandler_new(ChannelManager_as_ChannelMessageHandler(channelMessageHandlerPointer), HostRoutingMessageHandler.cRoutingMessageHandler)
```

## Instantiation

The reason for the setup is that to create a BlockNotifier, we need to refer back to the chain watch interface:

```swift
let blockNotifier = BlockNotifier_new(HostRoutingMessageHandler.cChainWatchInterface)
```

## Notifying

The actual notifying happens when we learn about a new block, or a block being reorged. For example,
if we're at block `n`, and we learn about blocks `(n+1, n+2, n+3)`, then
we need to call `BlockNotifier_block_connected()` for block `n+1`, then `n+2`, and then `n+3`. 

For one block, such a call could look like this:

```swift
BlockNotifier_block_connected(blockNotifierPointer, blockData, height)
``` 

Similarly, assuming we're at block `n`, and we learn that there has been a reorg, and blocks
`(n, n-1, n-2)` are no more and instead we have blocks `(m, m+1, m+2, m+3)`, we need to call
`BlockNotifier_block_disconnected()` for blocks `n`, `n-1`, and `n-2`, and then call 
`BlockNotifier_block_connected()` for blocks `m`, `m+1`, `m+2`, and `m+3`.

An example of a disconnection call would be:

```swift
BlockNotifier_block_disconnected(blockNotifierPointer, blockHeaderPointer, height)
```

## Next

This should have covered most of the critical functionality. At this point, I think it makes 
sense to take a step back and put everything in perspective with a look at the big picture of
how all the components should be [coordinated](Coordination.md).