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
    var name: String?
    
    func sendDataCallback(data: Data) -> UInt {
        let plaintextBytes = [UInt8](data)
        print("plaintext bytes:", plaintextBytes)
        return 4
    }

    final func receiveData(data: Data) {
        self.manager?.receiveData(peer: self, data: data)
    }

    deinit {
        socket_descriptor_free(self.cSocketDescriptor)
        print("socket descriptor", self.name, "destroyed")
    }

}
