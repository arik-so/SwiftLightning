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

    private var cPeerManager: LDKPeerManager;
    // private var cPeerManager: OpaquePointer?;
    private var logger: Logger?
    private var channelMessageHandler: ChannelMessageHandler?
    public private(set) var routingMessageHandler: RoutingMessageHandler?

    private var tickPromise: Guarantee<Void>?

    private var peerCount: UInt = 0

    // private var cSecretKey: LDKSecretKey;

    init(privateKey: Data, ephemeralSeed: Data, channelManager: LDKChannelManager) {
        // let privateKeyPointer = RawLDKTypes.dataToPointer(data: privateKey)
        // let ephemeralSeedPointer = RawLDKTypes.dataToPointer(data: ephemeralSeed)
        // self.cPeerManager = peer_manager_create(privateKeyPointer, ephemeralSeedPointer)
        // let messageHandler = LDKMessageHandler()
        let privateKeyBytes = RawLDKTypes.dataToPrivateKeyTuple(data: privateKey);
        let secretKey = LDKSecretKey(bytes: privateKeyBytes);
        // let cEphemeralSeed = RawLDKTypes.dataToPrivateKeyTuple(data: ephemeralSeed);

        self.logger = Logger()

        self.channelMessageHandler = ChannelMessageHandler()
        let channelManagerPointer = withUnsafePointer(to: channelManager) { (pointer: UnsafePointer<LDKChannelManager>) in
            pointer
        }
        let channelMessageHandler = ChannelManager_as_ChannelMessageHandler(channelManagerPointer)
        self.routingMessageHandler = RoutingMessageHandler(logger: self.logger!)

        // let chainWatchInterface = ChainWatchInterfaceUtil_new(LDKNetwork_Testnet)
        // let chainWatchInterfacePointer = withUnsafePointer(to: chainWatchInterface) { (pointer: UnsafePointer<LDKChainWatchInterfaceUtil>) -> UnsafePointer<LDKChainWatchInterfaceUtil> in
        //     pointer
        // }
        // let blockNotifier = BlockNotifier_new(ChainWatchInterfaceUtil_as_ChainWatchInterface(chainWatchInterfacePointer))


        let messageHandler = MessageHandler_new(channelMessageHandler, routingMessageHandler!.cRoutingMessageHandler!)
        // let messageHandler = MessageHandler_new(self.channelMessageHandler!.cMessageHandler!, routingMessageHandler!.cRoutingMessageHandler!)


        let ourNodeSecret = LDKSecretKey(bytes: privateKeyBytes);
        let ephemeralRandomData = RawLDKTypes.dataToPrivateKeyTuple(data: ephemeralSeed);
        let randomDataPointer = withUnsafePointer(to: ephemeralRandomData) { (pointer: UnsafePointer<RawLDKTypes.SecretKey>) -> UnsafePointer<RawLDKTypes.SecretKey> in
            pointer
        }
        let peerManager = PeerManager_new(messageHandler, ourNodeSecret, randomDataPointer, self.logger!.cLogger!);
        // let peerManager = peer_manager_create(RawLDKTypes.dataToPointer(data: privateKey), RawLDKTypes.dataToPointer(data: ephemeralSeed), messageHandler, self.logger!.cLogger!);
        self.cPeerManager = peerManager;

        // DispatchQueue.global(qos: .background).async {
        //     self.forceTick()
        // }

        self.monitorPeerCount();

    }

    public func singleTick() {
        // TODO: fix
        // peer_force_tick(self.cPeerManager);
    }

    private func monitorPeerCount() {
        let peerManagerPointer = withUnsafePointer(to: self.cPeerManager) { pointer in
            pointer
        }
        let peers: LDKCVecTempl_PublicKey = PeerManager_get_peer_node_ids(peerManagerPointer);
        let peerCount = peers.datalen;
        if (peerCount > self.peerCount) {
            self.peerConnected()
        }

        let backgroundQueue = DispatchQueue.global(qos: .background);

        Promise<Void> { seal in
            self.peerCount = peerCount;
            seal.fulfill(())
        }.then(on: backgroundQueue) {
            after(seconds: 1) // wait five seconds
        }.done {
            self.monitorPeerCount()
        }
    }

    private func peerConnected() {
        Demonstration.contentView?.isConnecting = false
        Demonstration.contentView?.isConnected = true
        Demonstration.logInUI(message: "Peer connected")
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

        // TODO: fix
        // DispatchQueue.main.async {
        //     print("Forcing tick")
        //     peer_force_tick(self.cPeerManager);
        // }

        return after(seconds: 10).then { () -> Guarantee<Void> in
            self.forceTick()
        };

    }

    func initiateOutboundConnection(remotePublicKey: Data, peer: Peer = Peer()) {
        let remotePublicKeyPointer = RawLDKTypes.dataToPointer(data: remotePublicKey)
        let peerInstancePointer = RawLDKTypes.instanceToPointer(instance: peer)
        // let errorPlaceholder = RawLDKTypes.errorPlaceholder();

        // func socketCallback(pointer: UnsafeRawPointer?, buffer: UnsafeMutablePointer<LDKBufferResponse>?) -> UInt {
        //     let instance: Peer = RawLDKTypes.pointerToInstance(pointer: pointer!)
        //     let data = RawLDKTypes.bufferResponseToData(buffer: buffer!)
        //     return instance.sendDataCallback(data: data)
        // }
        //
        // func destructionCallback(pointer: UnsafeRawPointer?) {
        //     let instance: Peer = RawLDKTypes.pointerToInstance(pointer: pointer!)
        //     instance.destructionCallback()
        // }

        func socketCallback(pointer: UnsafeMutableRawPointer?, buffer: LDKu8slice, something: Bool) -> UInt {
            let instance: Peer = RawLDKTypes.pointerToInstance(pointer: pointer!)
            let data = RawLDKTypes.u8SliceToData(buffer: buffer)
            return instance.sendDataCallback(data: data)
        }

        func destructionCallback(pointer: UnsafeMutableRawPointer?) {
            let instance: Peer = RawLDKTypes.pointerToInstance(pointer: pointer!)
            instance.destructionCallback()
        }

        func eq(descriptor1: UnsafeRawPointer?, descriptor2: UnsafeRawPointer?) -> Bool {
            return Peer.eq(descriptor1: descriptor1, descriptor2: descriptor2)
        }

        func hash(descriptor: UnsafeRawPointer?) -> UInt64 {
            return Peer.hash(descriptor: descriptor)
        }

        let descriptor = LDKSocketDescriptor(
                this_arg: peerInstancePointer,
                send_data: socketCallback,
                disconnect_socket: destructionCallback,
                eq: eq,
                hash: hash
        );

        peer.manager = self;
        // let descriptorPointer = peer_manager_new_outbound(self.cPeerManager, remotePublicKeyPointer, peerInstancePointer, socketCallback, destructionCallback, errorPlaceholder)
        let remotePublicKey = RawLDKTypes.dataToPublicKeyTuple(data: remotePublicKey);
        let peerManagerPointer = withUnsafePointer(to: self.cPeerManager) { (pointer: UnsafePointer<LDKPeerManager>) -> UnsafePointer<LDKPeerManager> in
            pointer
        }
        let publicKey = LDKPublicKey(compressed_form: remotePublicKey);
        let firstMessageResult = PeerManager_new_outbound_connection(peerManagerPointer, publicKey, descriptor);
        let firstMessage = RawLDKTypes.resultToData(result: firstMessageResult)

        peer.cSocketDescriptor = descriptor
        peer.canReceiveData = true

        peer.sendDataCallback(data: firstMessage!)
    }

    func receiveData(peer: Peer, data: Data) {

        // let rawActDataPointer = (data as NSData).bytes.assumingMemoryBound(to: UInt8.self);
        // let dataArgument = LDKBufferArgument(data: rawActDataPointer, length: UInt(data.count));
        // let dataPointer = withUnsafePointer(to: dataArgument) { (dataArgumentPointer) in
        //     dataArgumentPointer
        // }
        // peer_read(self.cPeerManager, peer.cSocketDescriptor!, dataPointer);
        let peerManagerPointer = withUnsafePointer(to: self.cPeerManager) { (pointer: UnsafePointer<LDKPeerManager>) -> UnsafePointer<LDKPeerManager> in
            pointer
        }
        let descriptorPointer = withUnsafeMutablePointer(to: &peer.cSocketDescriptor!) { (pointer: UnsafeMutablePointer<LDKSocketDescriptor>) -> UnsafeMutablePointer<LDKSocketDescriptor> in
            pointer
        }
        let u8Slice = RawLDKTypes.dataToU8Slice(data: data);
        PeerManager_read_event(peerManagerPointer, descriptorPointer, u8Slice)
    }

    deinit {
        PeerManager_free(self.cPeerManager);
        print("peer manager destroyed")
    }

}
