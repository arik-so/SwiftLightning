//
//  Greeter.swift
//  Swift Rust FFI
//
//  Created by Arik Sosman on 3/3/20.
//  Copyright © 2020 Arik Sosman. All rights reserved.
//

import Foundation

class Peer {

    final var cSocketDescriptor: OpaquePointer?
    final var manager: PeerManager?
    final var publicKey: Data?
    var name: String?

    func sendDataCallback(data: Data) -> UInt {
        let plaintextBytes = [UInt8](data)
        print("should send plaintext bytes:", plaintextBytes)
        print("Peer.swift:sendDataCallback has to be overridden!")
        abort()
    }

    func destructionCallback() {

    }

    final func receiveData(data: Data) {
        self.manager?.receiveData(peer: self, data: data)
    }

    deinit {
        socket_descriptor_free(self.cSocketDescriptor)
        print("socket descriptor", self.name, "destroyed")
    }


}
