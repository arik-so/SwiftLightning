# Overview

This guide aims to give the reader an overview of the structure of Rust Lightning functionality,
as well as a reference for integrating the exported bindings in an object-oriented language using
Swift as the example.

## Architecture

To run a Lightning node, there are several fundamental components that need setting up.

### Peer-to-peer communication

A Lightning node needs to be able to set up connections with other nodes on the Lightning network
and announce its presence. In Rust Lightning, this role is assumed by the [PeerManager](https://docs.rs/lightning/0.0.11/lightning/ln/peer_handler/struct.PeerManager.html)
struct.

Once instantiated, it allows the creation of inbound and outbound connections. As this guide is
based on Swift and is therefore primarily focused on mobile integrations, we will be primarily
focused on the outbound scenario. (TODO: link!)

### Channel Management

Once a connection is established, you may want yourself opening a channel. That is done
using the [ChannelManager](https://docs.rs/lightning/0.0.11/lightning/ln/channelmanager/index.html)
struct, but there is a lot more involved in instantiating one that we will go over in a
dedicated section (TODO: link!).

Rust Lightning's ChannelManager is very sophisticated at managing the state machine,
understanding incoming messages the PeerManager receives, and knowing what messages to send back.
However, its scope is limited, and it relies on us to imbue it with a context of what is
happening on-chain, and to broadcast transactions. 

### Chain Monitoring

This brings us to the chain monitor. There are several approaches here. One approach is 
implementing the [ChainWatchInterface](https://docs.rs/lightning/0.0.11/lightning/chain/chaininterface/trait.ChainWatchInterface.html)
trait, which would allow Rust Lightning to tell us when new transactions or outpoints become
relevant and should be watched for on-chain.

An alternatively, for the developer slightly more naïve approach, is relying on the 
[BlockNotifier](https://docs.rs/lightning/0.0.11/lightning/chain/chaininterface/struct.BlockNotifier.html)
struct, which will let us feed raw block data to it and simply keep track of reorgs to deregister
or unconfirm blocks if need be.

### Transaction Handling

#### Broadcasting

Managing a channel involves having to broadcast transactions. Be it a funding transaction, a
close, or a breach remedy, the ChannelManager will tell us what it needs broadcast, and we
need to make sure that there is a way to submit that transaction to a bitcoin node. Some 
transactions may be more time-sensitive than others, such as breach remedies, so there should
be a certain level of guarantee that a transaction will be broadcast within a reasonable time frame.

#### Signing

A particularly appealing use case of language bindings is the dissociation of key management from
the Lightning state machine, allowing external signing procedures that follow custom protocols.

For the time being, however, as well as for the sake of simplicity, we will be relying on the
[InMemoryChannelKeys](https://docs.rs/lightning/0.0.11/lightning/chain/keysinterface/struct.InMemoryChannelKeys.html) struct,
which handles the rather complicated task of key management and transaction signing for us.

### Routing

Due to this guide's focus on mobile applications, routing functionality is not yet discussed
in this document.

## Usage

* [Getting Started](GettingStarted.md)
* [Primitives](Primitives.md)
* Major Components
    * [PeerManager](PeerManager.md)
    * [ChannelManager](ChannelManager.md)
* [Coordination](Coordination.md)