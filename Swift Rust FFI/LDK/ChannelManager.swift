//
// Created by Arik Sosman on 5/15/20.
// Copyright (c) 2020 Arik Sosman. All rights reserved.
//

import Foundation

class ChannelManager {

    private var cChannelManager: LDKChannelManager?

    init(privateKey: Data, logger: Logger, currentBlockchainHeight: UInt) {
        let instance = RawLDKTypes.instanceToPointer(instance: self);

        func broadcastTransactionCallback(instancePointer: UnsafeRawPointer?, tx: LDKTransaction) -> Void {
            print("needs to broadcast transaction")
        }

        let network = Testnet
        let feeEstimator = FeeEstimator()
        let channelMonitor = LDKManyChannelMonitor(this_arg: instance)
        let broadcaster = LDKBroadcasterInterface(this_arg: instance, broadcast_transaction: broadcastTransactionCallback)

        func getNodeSecret(instancePointer: UnsafeRawPointer?) -> LDKSecretKey {
            let instance: ChannelManager = RawLDKTypes.pointerToInstance(pointer: instancePointer!);
            return instance.getPrivateKey()
        }
        func getShutdownPublicKey(instancePointer: UnsafeRawPointer?) -> LDKPublicKey {
            let remotePublicKey = Data.init(base64Encoded: "Ao11AN1MEmhdH1aLTCtQSOhTS4czGfOo2qYStGkTLsf3")!;
            let keyTuple = RawLDKTypes.dataToPublicKeyTuple(data: remotePublicKey)
            return LDKPublicKey(compressed_form: keyTuple)
        }
        func getChannelID(instancePointer: UnsafeRawPointer?) -> LDKThirtyTwoBytes {
            let ephemeralPrivateKey = Data.init(base64Encoded: "EhISEhISEhISEhISEhISEhISEhISEhISEhISEhISEhI=")!;
            let keyTuple = RawLDKTypes.dataToPrivateKeyTuple(data: ephemeralPrivateKey)
            return LDKThirtyTwoBytes(data: keyTuple)
        }

        let keyManager = LDKKeysInterface(
                this_arg: instance,
                get_node_secret: getNodeSecret,
                get_shutdown_pubkey: getShutdownPublicKey,
                get_channel_id: getChannelID
        )

        let config = LDKUserConfig()
        self.cChannelManager = ChannelManager_new(network, feeEstimator.cFeeEstimator!, channelMonitor, broadcaster, logger.cLogger!, keyManager, config, currentBlockchainHeight)
    }

    func openChannel() {
        // fix result
    }

    private func getPrivateKey() -> LDKSecretKey {
        let privateKey = Data.init(base64Encoded: "ERERERERERERERERERERERERERERERERERERERERERE=")!;
        let keyTuple = RawLDKTypes.dataToPrivateKeyTuple(data: privateKey)
        return LDKSecretKey(bytes: keyTuple)
    }

}