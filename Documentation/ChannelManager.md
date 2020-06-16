# ChannelManager ([Rust](https://docs.rs/lightning/0.0.11/lightning/ln/channelmanager/index.html))

## Prerequisites

* Knowledge of current chain height
* Ability to broadcast transactions

## Instantiation

The ChannelManager instantiation is, quite frankly, rather involved:

```c
ChannelManager_new(LDKNetwork network, LDKFeeEstimator fee_est, LDKManyChannelMonitor monitor, LDKBroadcasterInterface tx_broadcaster, LDKLogger logger, LDKKeysInterface keys_manager, LDKUserConfig config, uintptr_t current_blockchain_height)
```

Once broken down, though, the arguments start to make much more sense.

### Network ([Rust](https://docs.rs/bitcoin/0.21.0/bitcoin/network/constants/enum.Network.html))

For now, everything is experimental, so `network` should always be `LDKNetwork_Testnet`.

### Fee Estimator ([Rust](https://docs.rs/lightning/0.0.11/lightning/chain/chaininterface/trait.FeeEstimator.html))

Fee estimation is a very sophisticated problem that involves knowing the priority of a transaction,
the current mempool congestion, and a little bit of game theory.

However, for a working prototype, we will cheat a little bit and settle on a fixed fee rate:

```swift
func get_est_sat_per_1000_weight(instancePointer: UnsafeRawPointer?, confirmationTarget: LDKConfirmationTarget) -> UInt64 {
    253 // minimum value this method may return
}

let feeEstimator = LDKFeeEstimator(
    this_arg: instance,
    get_est_sat_per_1000_weight: get_est_sat_per_1000_weight
)
```

### ManyChannelMonitor ([Rust](https://docs.rs/lightning/0.0.11/lightning/ln/channelmonitor/trait.ManyChannelMonitor.html))

The channel monitor is responsible for registering monitors for relevant on-chain events. For now,
in the interest of simplicity, we will simply stub out all the methods it supports without
putting in actual processing. The following snippet of Swift could should give you an idea
of what such a stub would look like:

```swift
func addMonitor(this_arg: UnsafeRawPointer?, funding_txo: LDKOutPoint, monitor: LDKChannelMonitor) -> LDKCResult_NoneChannelMonitorUpdateErrZ {
    print("adding monitor")
    return LDKCResult_NoneChannelMonitorUpdateErrZ()
}

func updateMonitor(this_arg: UnsafeRawPointer?, funding_txo: LDKOutPoint, update: LDKChannelMonitorUpdate) -> LDKCResult_NoneChannelMonitorUpdateErrZ {
    print("updating monitor")
    return LDKCResult_NoneChannelMonitorUpdateErrZ()
}

func clearPendingHTLCs(this_arg: UnsafeRawPointer?) -> LDKCVec_HTLCUpdateZ {
    print("clearing pending HTLCs")
    return LDKCVec_HTLCUpdateZ()
}

let manyChannelMonitor = LDKManyChannelMonitor(
        this_arg: instance,
        add_monitor: addMonitor,
        update_monitor: updateMonitor,
        get_and_clear_pending_htlcs_updated: clearPendingHTLCs
)
``` 

The above example is, as of yet, stubbed out, but it will be a **critical** component to update later on.

### Broadcaster Interface ([Rust](https://docs.rs/lightning/0.0.11/lightning/chain/chaininterface/trait.BroadcasterInterface.html))

The `LDKBroadcasterInterface` instance we'll be creating here is the key component responsible
for receiving callbacks about transactions that need broadcasting to the blockchain.

A simplified implementation could look thus:

```swift
func broadcastTransactionCallback(instancePointer: UnsafeRawPointer?, tx: LDKTransaction) -> Void {
    let instance: ChannelManager = RawLDKTypes.pointerToInstance(pointer: instancePointer!)
    instance.broadcastTransaction(tx: tx)
}

let broadcaster = LDKBroadcasterInterface(this_arg: instance, broadcast_transaction: broadcastTransactionCallback)
```

### Logger ([Rust](https://docs.rs/lightning/0.0.11/lightning/util/logger/trait.Logger.html))

For the logger, let's reuse the global logger instance we have already created [here](PeerManager.md#logger-rust).

### KeysInterface ([Rust](https://docs.rs/lightning/0.0.11/lightning/chain/keysinterface/trait.KeysInterface.html))

The KeysInterface trait will soon be renamed to reflect its upcoming support for [external signing](README.md#signing).

But in the meantime, it can be used on the basis of an `LDKKeysManager`. Assuming some private
key seed `keySeed: Data` for the channel, this could be an approximation of the instantiation flow:

```swift
let seed = RawLDKTypes.dataToPrivateKeyTuple(data: keySeed)
let seedPointer = withUnsafePointer(to: seed) { (pointer: UnsafePointer<RawLDKTypes.SecretKey>) in
    pointer
}
let keysManager = KeysManager_new(seedPointer, network, 0, 0)
let keysManagerPointer = withUnsafePointer(to: keysManager) { (pointer: UnsafePointer<LDKKeysManager>) in
    pointer
}
let keysInterface = KeysManager_as_KeysInterface(keysManagerPointer)
```

### User Config ([Rust](https://docs.rs/lightning/0.0.11/lightning/util/config/struct.UserConfig.html))

For now, I recommend sticking with the default config:

```swift
let config = UserConfig_default()
```

### Current Blockchain Height

As you can see, to instantiate a channel manager, it is imperative to know the latest height of the (testnet)
chain. Due to other components' reliance on blockchain interaction, some sort of blockchain monitor may be
a reasonable thing to kick off the application is started. 

## Handling messages

Once we have an instance of a `ChannelManager`, we should refer back to the [PeerManager's message handler](PeerManager.md#message-handler-rust)
and replace the first argument with `ChannelManager_as_ChannelMessageHandler(channelMessageHandlerPointer)`,
as outlined [here](PeerManager.md#next).

## Opening a channel

With an instance of `ChannelManager` available, [opening a channel](https://docs.rs/lightning/0.0.11/lightning/ln/channelmanager/struct.ChannelManager.html#method.create_channel) should be but a matter of calling
`ChannelManager_create_channel(const LDKChannelManager *this_arg, LDKPublicKey their_network_key, uint64_t channel_value_satoshis, uint64_t push_msat, uint64_t user_id, LDKUserConfig override_config)`.

The arguments are all fairly straightforward. Notably, `user_id` should be some integer, preferably not 0, that
will be used in future callbacks pertaining to the new channel, such as funding events.

The result of this function is of the type `LDKCResult_NoneAPIErrorZ` which, similar to the result type
of the [connection initiation](PeerManager.md#first-message), has the following structure:

```c
{
   LDKCResultPtr_u8__APIError contents;
   bool result_good;
}
```

As the name suggests, if `result_good` is true, the result should be good. After this call, the user should receive
a callback with the output script to send the channel funds to.

## Handling events

Note that once you have at least one channel open, this method should be called at regular
intervals (e. g. every 5-10 seconds) to make sure pending channel events are handled:

```swift
PeerManager_process_events(peerManagerPointer)
```

This will push events to the channel's queue, whereupon they can be read by calling
the `get_and_clear_pending_events` method on a converted ChannelManager instance:

```swift
let eventsProvider: LDKEventsProvider = ChannelManager_as_EventsProvider(managerPointer)
let events: LDKCVecTempl_Event = (eventsProvider.get_and_clear_pending_events)(eventsProvider.this_arg)
```

Here, once again, you will recognize `LDKCVecTempl_Event`'s familiar template structure, though
this time with the custom underlying type `LDKEvent`:

```c
{
    LDKEvent *data;
    uintptr_t datalen;
}
```

## Next

To make the channel funding work, we need to set up a blockchain monitor that will be able to tell when
the above mentioned output script received funds, such that it can extract the transaction id and send
corresponding communication to the peer.

For the purpose of a prototype, we will be using the [BlockNotifier](BlockNotifier.md) struct for that.

The way the notifier works, it actually ties into the second argument of the `MessageHandler_new(…)`
method we used for the PeerManager.
