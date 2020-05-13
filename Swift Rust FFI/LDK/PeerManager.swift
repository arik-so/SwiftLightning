//
//  PeerManager.swift
//  Swift Rust FFI
//
//  Created by Arik Sosman on 5/7/20.
//  Copyright © 2020 Arik Sosman. All rights reserved.
//

import Foundation

class PeerManager {

    // private var cPeerManager: LDKPeerManager;
    private var cPeerManager: OpaquePointer?;
    // private var cSecretKey: LDKSecretKey;
    
    init(privateKey: Data, ephemeralSeed: Data) {
        // let privateKeyPointer = RawLDKTypes.dataToPointer(data: privateKey)
        // let ephemeralSeedPointer = RawLDKTypes.dataToPointer(data: ephemeralSeed)
        // self.cPeerManager = peer_manager_create(privateKeyPointer, ephemeralSeedPointer)
        // let messageHandler = LDKMessageHandler()
        let privateKeyBytes = RawLDKTypes.dataToPrivateKeyTuple(data: privateKey);
        let secretKey = LDKSecretKey(bytes: privateKeyBytes);
        let cEphemeralSeed = RawLDKTypes.dataToPrivateKeyTuple(data: ephemeralSeed);

        var channelMessageHandler = ChannelMessageHandler();

        func shouldRequestFullSync(pointer: UnsafeRawPointer?, key: LDKPublicKey) -> Bool {
            false
        }
        let routeMessageHandler = LDKRoutingMessageHandler(this_arg: RawLDKTypes.instanceToPointer(instance: self), should_request_full_sync: shouldRequestFullSync)

        let messageHandler = MessageHandler_new(channelMessageHandler.cMessageHandler!, routeMessageHandler)
        
        // let fixedSize

        /*let messageHandler = withUnsafePointer(to: rawMessageHandler) { (pointer: UnsafePointer<LDKChannelMessageHandler>) -> LDKMessageHandler in
            LDKMessageHandler(inner: OpaquePointer.init(pointer))
        }*/

        let logger = Logger()


        let peerManager = peer_manager_create(RawLDKTypes.dataToPointer(data: privateKey), RawLDKTypes.dataToPointer(data: ephemeralSeed), messageHandler, logger.cLogger!);

        /* let peerManager = withUnsafePointer(to: cEphemeralSeed) { (pointer: UnsafePointer<RawLDKTypes.SecretKey>) -> LDKPeerManager in
            let peerManager = PeerManager_new(messageHandler, secretKey, pointer, logger.cLogger!)

            return peerManager;
        }; */
        self.cPeerManager = peerManager;

        forceTick()
    }

    private func forceTick(){
        DispatchQueue.global(qos: .background).async {
            print("Waiting 10 seconds for next tick")
            sleep(10);
            DispatchQueue.main.async {
                print("Forcing tick")
                peer_force_tick(self.cPeerManager);
                self.forceTick();
            }
        }

    }

    func initiateOutboundConnection(remotePublicKey: Data, peer: Peer = Peer()){
        let remotePublicKeyPointer = RawLDKTypes.dataToPointer(data: remotePublicKey)
        let peerInstancePointer = RawLDKTypes.instanceToPointer(instance: peer)
        let errorPlaceholder = RawLDKTypes.errorPlaceholder();
        
        func socketCallback(pointer: UnsafeRawPointer?, buffer: UnsafeMutablePointer<LDKBufferResponse>?) -> UInt {
            let instance: Peer = RawLDKTypes.pointerToInstance(pointer: pointer!)
            let data = RawLDKTypes.bufferResponseToData(buffer: buffer!)
            return instance.sendDataCallback(data: data)
        }

        peer.manager = self;
        let descriptorPointer = peer_manager_new_outbound(self.cPeerManager, remotePublicKeyPointer, peerInstancePointer, socketCallback, errorPlaceholder)
        peer.cSocketDescriptor = descriptorPointer
    }

    func receiveData(peer: Peer, data: Data) {

        let rawData = RawLDKTypes.dataToBufferArgument(data: data) { dataPointer in
            // the pointer access is lost, so we need to strongly retain it
            peer_read(self.cPeerManager, peer.cSocketDescriptor, dataPointer);
        };
    }
    
    deinit {
        peer_manager_free(self.cPeerManager)
        print("peer manager destroyed")
    }


}
