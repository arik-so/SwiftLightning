//
//  Greeter.swift
//  Swift Rust FFI
//
//  Created by Arik Sosman on 3/3/20.
//  Copyright © 2020 Arik Sosman. All rights reserved.
//

import Foundation

class Peer {

    static var maxPeerID: UInt64 = 0;

    final var cSocketDescriptor: LDKSocketDescriptor?
    final var manager: PeerManager?
    final var publicKey: Data?
    final var canReceiveData: Bool = false
    var name: String?

    private var peerID: UInt64;

    init() {
        self.peerID = Peer.maxPeerID + 1;
        Peer.maxPeerID = self.peerID;
    }

    static func eq(descriptor1: UnsafeRawPointer?, descriptor2: UnsafeRawPointer?) -> Bool {
        let instance1: Peer = RawLDKTypes.pointerToInstance(pointer: descriptor1!)
        let instance2: Peer = RawLDKTypes.pointerToInstance(pointer: descriptor2!)
        // print("Comparing descriptors \(instance1.peerID) with \(instance2.peerID)")
        return instance1.peerID == instance2.peerID
    }

    static func hash(descriptor: UnsafeRawPointer?) -> UInt64 {
        let instance: Peer = RawLDKTypes.pointerToInstance(pointer: descriptor!)
        // print("Obtaining descriptor hash for \(instance.peerID)")
        return instance.peerID
    }

    func sendDataCallback(data: Data) -> UInt {
        let plaintextBytes = [UInt8](data)
        print("should send plaintext bytes:", plaintextBytes)
        print("Peer.swift:sendDataCallback has to be overridden!")
        abort()
    }

    func destructionCallback() {

    }

    func disconnect() {

    }

    final func receiveData(data: Data) {
        if(!self.canReceiveData){
            print("Peer cannot receive data yet")
            abort()
        }
        self.manager?.receiveData(peer: self, data: data)
    }

    deinit {
        // socket_descriptor_free(self.cSocketDescriptor) // TODO
        print("socket descriptor", self.name, "destroyed")
    }


}
