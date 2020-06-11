# Coordination

Now that we have all the major components set up, how do we link them and integrate the sum
in an object-oriented environment?

## Flow

1. The first thing we need is a native monitor that keeps track of the blockchain. We should 
know what the current block is, know its height and header, and know when a new one appears
or gets reorged. This native monitor need not be hooked up to a [BlockNotifier](BlockNotifier.md)
a priori, but it should be able to catch one up once one is connected.

2. We need a [ChannelManager](ChannelManager.md) as a handle for opening new channels, and as a
basis for interpreting peer-to-peer messages in the context of the channel state.

3. We need a [BlockNotifier](BlockNotifier.md), which relies on a chain watch interface, which
is also something that the routing message handler relies on for the peer manager. Its function
is simple enough to not need summarizing, but its prerequisities are such that they need to exist
before the peer manager instance.

4. Lastly, the [PeerManager](PeerManager.md), which relies on the channel manager and routing
message handler, is responsible for peer-to-peer-communication. Even though it has the most
involved prerequisites, it is the first Rust Lightning component most developers integrating
the bindings will interact and experiment with.

## Next

There are still aspects of the bindings this guide doesn't touch on yet, such as the proper
instantiation of a [ManyChannelMonitor](https://docs.rs/lightning/0.0.11/lightning/ln/channelmonitor/trait.ManyChannelMonitor.html),
custom key management and external signing, as well as user-triggered channel state updates.

We hope to add those very soon!