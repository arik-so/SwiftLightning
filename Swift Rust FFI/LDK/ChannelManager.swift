//
// Created by Arik Sosman on 5/15/20.
// Copyright (c) 2020 Arik Sosman. All rights reserved.
//

import Foundation
import PromiseKit

class ChannelManager {

    private var cChannelManager: LDKChannelManager?
    // private var inMemoryChannelKeys: LDKInMemoryChannelKeys?

    private var keyDerivationParamA: UInt64 = 0
    private var keyDerivationParamB: UInt64 = 0

    init(privateKey: Data, logger: Logger, currentBlockchainHeight: UInt) {
        let instance = RawLDKTypes.instanceToPointer(instance: self);

        func broadcastTransactionCallback(instancePointer: UnsafeRawPointer?, tx: LDKTransaction) -> Void {
            let instance: ChannelManager = RawLDKTypes.pointerToInstance(pointer: instancePointer!)
            instance.broadcastTransaction(tx: tx)
        }

        let network = Testnet
        print("creating fee estimater")
        let feeEstimator = FeeEstimator()
        print("creating broadcaster interface")
        let broadcaster = LDKBroadcasterInterface(this_arg: instance, broadcast_transaction: broadcastTransactionCallback)


        /*
        let fundingKey = LDKSecretKey(bytes: RawLDKTypes.dataToPrivateKeyTuple(data: privateKey));
        let revocationBaseKey = LDKSecretKey(bytes: RawLDKTypes.dataToPrivateKeyTuple(data: privateKey));
        let paymentKey = LDKSecretKey(bytes: RawLDKTypes.dataToPrivateKeyTuple(data: privateKey));
        let delayedPaymentBaseKey = LDKSecretKey(bytes: RawLDKTypes.dataToPrivateKeyTuple(data: privateKey));
        let htlcBaseKey = LDKSecretKey(bytes: RawLDKTypes.dataToPrivateKeyTuple(data: privateKey));
        let commitmentSeed = LDKThirtyTwoBytes(data: RawLDKTypes.dataToPrivateKeyTuple(data: privateKey));
        let keyDerivationParamAPointer = withUnsafeMutablePointer(to: &self.keyDerivationParamA) { (pointer: UnsafeMutablePointer<UInt64>) in
            pointer
        }
        let keyDerivationParamBPointer = withUnsafeMutablePointer(to: &self.keyDerivationParamB) { (pointer: UnsafeMutablePointer<UInt64>) in
            pointer
        }
        let keyDerivationParams = LDKC2TupleTempl_u64__u64(a: keyDerivationParamAPointer, b: keyDerivationParamBPointer)
        print("creating inmemory channel keys")
        self.inMemoryChannelKeys = InMemoryChannelKeys_new(fundingKey, revocationBaseKey, paymentKey, delayedPaymentBaseKey, htlcBaseKey, commitmentSeed, 1000, keyDerivationParams)

        print("setting up callbacks for keys interface")
        func getNodeSecret(instancePointer: UnsafeRawPointer?) -> LDKSecretKey {
            Demonstration.logInUI(message: "Getting node secret");
            let instance: ChannelManager = RawLDKTypes.pointerToInstance(pointer: instancePointer!);
            return instance.getPrivateKey()
        }

        func getDestinationScript(instancePointer: UnsafeRawPointer?) -> LDKCVec_u8Z {
            LDKCVec_u8Z() // todo
        }

        func getShutdownPublicKey(instancePointer: UnsafeRawPointer?) -> LDKPublicKey {
            Demonstration.logInUI(message: "Getting shutdown public key");
            let remotePublicKey = Data.init(base64Encoded: "Ao11AN1MEmhdH1aLTCtQSOhTS4czGfOo2qYStGkTLsf3")!;
            let keyTuple = RawLDKTypes.dataToPublicKeyTuple(data: remotePublicKey)
            return LDKPublicKey(compressed_form: keyTuple)
        }

        func getChannelKeys(instancePointer: UnsafeRawPointer?, inbound: Bool, channelSatoshiValue: UInt64) -> LDKChannelKeys {
            Demonstration.logInUI(message: "Getting channel keys");
            let instance: ChannelManager = RawLDKTypes.pointerToInstance(pointer: instancePointer!);
            return instance.getChannelKeys()
        }

        func getOnionRand(instancePointer: UnsafeRawPointer?) -> LDKC2Tuple_SecretKey_u832Z {
            LDKC2Tuple_SecretKey_u832Z() // todo
        }

        func getChannelID(instancePointer: UnsafeRawPointer?) -> LDKThirtyTwoBytes {
            Demonstration.logInUI(message: "Getting channel ID");
            let ephemeralPrivateKey = Data.init(base64Encoded: "EhISEhISEhISEhISEhISEhISEhISEhISEhISEhISEhI=")!;
            let keyTuple = RawLDKTypes.dataToPrivateKeyTuple(data: ephemeralPrivateKey)
            return LDKThirtyTwoBytes(data: keyTuple)
        }

        // let fundingKey = RawLDKTypes.dataToPointer(data: privateKey);
        // let revocationBaseKey = RawLDKTypes.dataToPointer(data: privateKey);
        // let paymentKey = RawLDKTypes.dataToPointer(data: privateKey);
        // let delayedPaymentBaseKey = RawLDKTypes.dataToPointer(data: privateKey);
        // let htlcBaseKey = RawLDKTypes.dataToPointer(data: privateKey);
        // let commitmentSeed = RawLDKTypes.dataToPointer(data: privateKey);

        // let inMemoryChannelKeys = in_memory_channel_keys_create(fundingKey, revocationBaseKey, paymentKey, delayedPaymentBaseKey, htlcBaseKey, commitmentSeed, 1000);

        print("creating keys interface")
        let keyManager = LDKKeysInterface(
                this_arg: instance,
                get_node_secret: getNodeSecret,
                get_destination_script: getDestinationScript,
                get_shutdown_pubkey: getShutdownPublicKey,
                get_channel_keys: getChannelKeys,
                get_onion_rand: getOnionRand,
                get_channel_id: getChannelID
        ) */

        let manyChannelMonitor = ManyChannelMonitor()

        let seed = RawLDKTypes.dataToPrivateKeyTuple(data: privateKey)
        let seedPointer = withUnsafePointer(to: seed) { (pointer: UnsafePointer<RawLDKTypes.SecretKey>) in
            pointer
        }
        let keysManager = KeysManager_new(seedPointer, network, 0, 0)
        let keysManagerPointer = withUnsafePointer(to: keysManager) { (pointer: UnsafePointer<LDKKeysManager>) in
            pointer
        }
        let keysInterface = KeysManager_as_KeysInterface(keysManagerPointer)

        let config = UserConfig_default()
        print("instantiating channel manager")
        self.cChannelManager = ChannelManager_new(network, feeEstimator.cFeeEstimator!, manyChannelMonitor.cManyChannelMonitor!, broadcaster, logger.cLogger!, keysInterface, config, currentBlockchainHeight)
    }

    func broadcastTransaction(tx: LDKTransaction) {
        print("needs to broadcast transaction")
        let txBin = RawLDKTypes.transactionToData(tx: tx)
        firstly {
            BlockstreamBroadcaster.submitTransaction(transaction: txBin)
        }
        .map { response in
            print("Submission result:", response)
        }
    }

    func openChannel(peerPublicKey: Data, channelSatoshiValue: UInt64, pushMillisatoshiAmount: UInt64, userID: UInt64) {
        // fix result

        Demonstration.logInUI(message: "Opening channel");
        print("Opening channel")

        // let errorPlaceholder = RawLDKTypes.errorPlaceholder()
        // withUnsafePointer(to: self.cChannelManager!) { (pointer: UnsafePointer<LDKChannelManager>) in
        //     channel_manager_open_channel(pointer, RawLDKTypes.dataToPointer(data: peerPublicKey), channelSatoshiValue, pushMillisatoshiAmount, userID, errorPlaceholder)
        //     print("Opened channel")
        //     Demonstration.logInUI(message: "Channel open");
        // }

        let theirNetworkKey = LDKPublicKey(compressed_form: RawLDKTypes.dataToPublicKeyTuple(data: peerPublicKey));
        let overrideConfig = UserConfig_default();

        let cmPointer = withUnsafePointer(to: self.cChannelManager!) { (pointer: UnsafePointer<LDKChannelManager>) in
            pointer
        };
        print("Creating channel with manager")
        ChannelManager_create_channel(cmPointer, theirNetworkKey, channelSatoshiValue, pushMillisatoshiAmount, userID, overrideConfig)
        print("Finished creating channel with manager")
        /*

        let error = RawLDKTypes.errorFromPlaceholder(error: errorPlaceholder);
        if let errorString = error {
            print(errorString)
        }

        */

    }

    private func getPrivateKey() -> LDKSecretKey {
        print("Obtaining private key")
        let privateKey = Data.init(base64Encoded: "ERERERERERERERERERERERERERERERERERERERERERE=")!;
        let keyTuple = RawLDKTypes.dataToPrivateKeyTuple(data: privateKey)
        return LDKSecretKey(bytes: keyTuple)
    }

    /*
    private func getChannelKeys() -> LDKChannelKeys {
        print("Obtaining channel keys")
        let channelKeyPointer = withUnsafePointer(to: self.inMemoryChannelKeys!) { (pointer: UnsafePointer<LDKInMemoryChannelKeys>) in
            pointer
        }
        return InMemoryChannelKeys_as_ChannelKeys(channelKeyPointer)
    }
    */

}
