//
//  PeerManager.swift
//  Swift Rust FFI
//
//  Created by Arik Sosman on 5/7/20.
//  Copyright © 2020 Arik Sosman. All rights reserved.
//

import Foundation

class PeerManager {
    
    private var cPeerManager: OpaquePointer;
    
    init(privateKey: Data, ephemeralSeed: Data) {
        let privateKeyPointer = RawLDKTypes.dataToPointer(data: privateKey)
        let ephemeralSeedPointer = RawLDKTypes.dataToPointer(data: ephemeralSeed)
        self.cPeerManager = peer_manager_create(privateKeyPointer, ephemeralSeedPointer)
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
        peer.cPointer = descriptorPointer
    }

    func receiveData(peer: Peer, data: Data) {
        let rawData = RawLDKTypes.dataToBufferArgument(data: data) { dataPointer in
            // the pointer access is lost, so we need to strongly retain it
            peer_read(self.cPeerManager, peer.cPointer, dataPointer);
        };
    }
    
    deinit {
        peer_manager_free(self.cPeerManager)
        print("peer manager destroyed")
    }
    
}
