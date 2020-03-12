//
//  Greeter.swift
//  Swift Rust FFI
//
//  Created by Arik Sosman on 3/3/20.
//  Copyright © 2020 Arik Sosman. All rights reserved.
//

import Foundation
import SwiftSocket


class Peer {
    func beginHandshake() {
        
        let privateKey = Data.init(base64Encoded: "ERERERERERERERERERERERERERERERERERERERERERE=")!;
        let ephemeralPrivateKey = Data.init(base64Encoded: "EhISEhISEhISEhISEhISEhISEhISEhISEhISEhISEhI=")!;
        let remotePublicKey = Data.init(base64Encoded: "Ao11AN1MEmhdH1aLTCtQSOhTS4czGfOo2qYStGkTLsf3")!;
        
        let alexPublicKey = Data.init(base64Encoded: "AnRVrvhFPZL0cGtWC2FSfMIX3fFNpBdw6O1mBxkKGFG4")!;
        // 027455aef8453d92f4706b560b61527cc217ddf14da41770e8ed6607190a1851b8@testnet-lnd.yalls.org:9735
    
        
        let privateKeyPointer = (privateKey as NSData).bytes.assumingMemoryBound(to: UInt8.self);
        let ephemeralPrivateKeyPointer = (ephemeralPrivateKey as NSData).bytes.assumingMemoryBound(to: UInt8.self);
//        let remotePublicKeyPointer = (remotePublicKey as NSData).bytes.assumingMemoryBound(to: UInt8.self);
        let remotePublicKeyPointer = (alexPublicKey as NSData).bytes.assumingMemoryBound(to: UInt8.self);
        
        
        let cHandshake = peer_handshake_new_outbound(privateKeyPointer, ephemeralPrivateKeyPointer, remotePublicKeyPointer);
        let handshake = Handshake.init(cHandshake: cHandshake!)
        
        
        // connect to Alex Bosworth' testnet Lightning node
        let client = TCPClient(address: "testnet-lnd.yalls.org", port: 9735)
        let connection = client.connect(timeout: 5);
        
        print("CALCULATING FIRST ACT")
        let firstAct = try! handshake.process_act(actData: Data.init())
        print("SENDING FIRST ACT")
        let firstActSendResult = client.send(data: firstAct);
        print("SENT FIRST ACT")
        let secondAct = try! client.read(50, timeout: 5);
        print("RECEIVED SECOND ACT:", secondAct!)
        let thirdAct = try! handshake.process_act(actData: Data(secondAct!));
        print("SENDING THIRD ACT")
        let thirdActSendResult = client.send(data: thirdAct);
        print("SENT THIRD ACT")
        let encryptedFirstMessage = try! client.read(50, timeout: 5);
        print("RECEIVED FIRST MESSAGE:", encryptedFirstMessage!)
        let firstMessage = try! handshake.decrypt_message(ciphertext: Data(encryptedFirstMessage!))
        print("DECRYPTED FIRST MESSAGE:", [UInt8](firstMessage))
    }
}
