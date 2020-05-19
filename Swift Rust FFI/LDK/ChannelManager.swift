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
            Demonstration.logInUI(message: "Getting node secret");
            let instance: ChannelManager = RawLDKTypes.pointerToInstance(pointer: instancePointer!);
            return instance.getPrivateKey()
        }
        func getShutdownPublicKey(instancePointer: UnsafeRawPointer?) -> LDKPublicKey {
            Demonstration.logInUI(message: "Getting shutdown public key");
            let remotePublicKey = Data.init(base64Encoded: "Ao11AN1MEmhdH1aLTCtQSOhTS4czGfOo2qYStGkTLsf3")!;
            let keyTuple = RawLDKTypes.dataToPublicKeyTuple(data: remotePublicKey)
            return LDKPublicKey(compressed_form: keyTuple)
        }
        func getChannelID(instancePointer: UnsafeRawPointer?) -> LDKThirtyTwoBytes {
            Demonstration.logInUI(message: "Getting channel ID");
            let ephemeralPrivateKey = Data.init(base64Encoded: "EhISEhISEhISEhISEhISEhISEhISEhISEhISEhISEhI=")!;
            let keyTuple = RawLDKTypes.dataToPrivateKeyTuple(data: ephemeralPrivateKey)
            return LDKThirtyTwoBytes(data: keyTuple)
        }

        let fundingKey = RawLDKTypes.dataToPointer(data: privateKey);
        let revocationBaseKey = RawLDKTypes.dataToPointer(data: privateKey);
        let paymentKey = RawLDKTypes.dataToPointer(data: privateKey);
        let delayedPaymentBaseKey = RawLDKTypes.dataToPointer(data: privateKey);
        let htlcBaseKey = RawLDKTypes.dataToPointer(data: privateKey);
        let commitmentSeed = RawLDKTypes.dataToPointer(data: privateKey);
        let inMemoryChannelKeys = in_memory_channel_keys_create(fundingKey, revocationBaseKey, paymentKey, delayedPaymentBaseKey, htlcBaseKey, commitmentSeed, 1000);

        let keyManager = LDKKeysInterface(
                this_arg: instance,
                get_node_secret: getNodeSecret,
                get_shutdown_pubkey: getShutdownPublicKey,
                get_channel_id: getChannelID,
                channel_keys: inMemoryChannelKeys
        )

        let config = UserConfig_default()
        print("instantiating channel manager")
        self.cChannelManager = ChannelManager_new(network, feeEstimator.cFeeEstimator!, channelMonitor, broadcaster, logger.cLogger!, keyManager, config, currentBlockchainHeight)
    }

    func openChannel(peerPublicKey: Data, channelSatoshiValue: UInt64, pushMillisatoshiAmount: UInt64, userID: UInt64) {
        // fix result

        Demonstration.logInUI(message: "Opening channel");

        let errorPlaceholder = RawLDKTypes.errorPlaceholder()
        withUnsafePointer(to: self.cChannelManager!) { (pointer: UnsafePointer<LDKChannelManager>) in
            channel_manager_open_channel(pointer, RawLDKTypes.dataToPointer(data: peerPublicKey), channelSatoshiValue, pushMillisatoshiAmount, userID, errorPlaceholder)
            print("Opened channel")
            Demonstration.logInUI(message: "Channel open");
        }

        /*

        let error = RawLDKTypes.errorFromPlaceholder(error: errorPlaceholder);
        if let errorString = error {
            print(errorString)
        }

        */

    }

    private func getPrivateKey() -> LDKSecretKey {
        let privateKey = Data.init(base64Encoded: "ERERERERERERERERERERERERERERERERERERERERERE=")!;
        let keyTuple = RawLDKTypes.dataToPrivateKeyTuple(data: privateKey)
        return LDKSecretKey(bytes: keyTuple)
    }

}