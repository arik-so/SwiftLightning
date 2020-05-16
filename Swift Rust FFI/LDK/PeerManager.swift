//
//  PeerManager.swift
//  Swift Rust FFI
//
//  Created by Arik Sosman on 5/7/20.
//  Copyright © 2020 Arik Sosman. All rights reserved.
//

import Foundation
import PromiseKit

class PeerManager {

    // private var cPeerManager: LDKPeerManager;
    private var cPeerManager: OpaquePointer?;
    private var logger: Logger?
    private var channelMessageHandler: ChannelMessageHandler?

    private var tickPromise: Guarantee<Void>?

    // private var cSecretKey: LDKSecretKey;

    init(privateKey: Data, ephemeralSeed: Data) {
        // let privateKeyPointer = RawLDKTypes.dataToPointer(data: privateKey)
        // let ephemeralSeedPointer = RawLDKTypes.dataToPointer(data: ephemeralSeed)
        // self.cPeerManager = peer_manager_create(privateKeyPointer, ephemeralSeedPointer)
        // let messageHandler = LDKMessageHandler()
        let privateKeyBytes = RawLDKTypes.dataToPrivateKeyTuple(data: privateKey);
        let secretKey = LDKSecretKey(bytes: privateKeyBytes);
        let cEphemeralSeed = RawLDKTypes.dataToPrivateKeyTuple(data: ephemeralSeed);

        self.channelMessageHandler = ChannelMessageHandler();

        func shouldRequestFullSync(pointer: UnsafeRawPointer?, key: LDKPublicKey) -> Bool {
            false
        }

        let routeMessageHandler = LDKRoutingMessageHandler(this_arg: RawLDKTypes.instanceToPointer(instance: self), should_request_full_sync: shouldRequestFullSync)

        let messageHandler = MessageHandler_new(self.channelMessageHandler!.cMessageHandler!, routeMessageHandler)


        self.logger = Logger()

        let peerManager = peer_manager_create(RawLDKTypes.dataToPointer(data: privateKey), RawLDKTypes.dataToPointer(data: ephemeralSeed), messageHandler, self.logger!.cLogger!);
        self.cPeerManager = peerManager;

        // DispatchQueue.global(qos: .background).async {
        //     self.forceTick()
        // }
    }

    public func singleTick(){
        peer_force_tick(self.cPeerManager);
    }

    private func forceTick() -> Guarantee<Void> {

        guard let promise = self.tickPromise else {
            print("initiating ticks")
            self.tickPromise = firstly { () -> Guarantee<Void> in
                after(seconds: 1)
            }.then { () -> Guarantee<Void> in
                self.forceTick()
            }
            return self.tickPromise!
        }

        DispatchQueue.main.async {
            print("Forcing tick")
            peer_force_tick(self.cPeerManager);
        }

        return after(seconds: 10).then { () -> Guarantee<Void> in
            self.forceTick()
        };

    }

    func initiateOutboundConnection(remotePublicKey: Data, peer: Peer = Peer()) {
        let remotePublicKeyPointer = RawLDKTypes.dataToPointer(data: remotePublicKey)
        let peerInstancePointer = RawLDKTypes.instanceToPointer(instance: peer)
        let errorPlaceholder = RawLDKTypes.errorPlaceholder();

        func socketCallback(pointer: UnsafeRawPointer?, buffer: UnsafeMutablePointer<LDKBufferResponse>?) -> UInt {
            let instance: Peer = RawLDKTypes.pointerToInstance(pointer: pointer!)
            let data = RawLDKTypes.bufferResponseToData(buffer: buffer!)
            return instance.sendDataCallback(data: data)
        }

        func destructionCallback(pointer: UnsafeRawPointer?) {
            let instance: Peer = RawLDKTypes.pointerToInstance(pointer: pointer!)
            instance.destructionCallback()
        }

        peer.manager = self;
        let descriptorPointer = peer_manager_new_outbound(self.cPeerManager, remotePublicKeyPointer, peerInstancePointer, socketCallback, destructionCallback, errorPlaceholder)
        peer.cSocketDescriptor = descriptorPointer
        peer.canReceiveData = true
    }

    func receiveData(peer: Peer, data: Data) {

        let rawActDataPointer = (data as NSData).bytes.assumingMemoryBound(to: UInt8.self);
        let dataArgument = LDKBufferArgument(data: rawActDataPointer, length: UInt(data.count));
        let dataPointer = withUnsafePointer(to: dataArgument) { (dataArgumentPointer) in
            dataArgumentPointer
        }
        peer_read(self.cPeerManager, peer.cSocketDescriptor!, dataPointer);
    }

    deinit {
        peer_manager_free(self.cPeerManager)
        print("peer manager destroyed")
    }

}
