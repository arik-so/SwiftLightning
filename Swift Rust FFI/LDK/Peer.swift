//
//  Greeter.swift
//  Swift Rust FFI
//
//  Created by Arik Sosman on 3/3/20.
//  Copyright © 2020 Arik Sosman. All rights reserved.
//

import Foundation

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
}


class Peer {

    final var cPointer: OpaquePointer?
    final var manager: PeerManager?
    
    func sendDataCallback(data: Data) -> UInt {
        let plaintextBytes = [UInt8](data)
        print("plaintext bytes:", plaintextBytes)
        return 4
    }

    final func receiveData(data: Data) {
        self.manager?.receiveData(peer: self, data: data)
    }
    
    func sayHello(){
        print("hello")
    }
}
