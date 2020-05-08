//
//  Experimentation.swift
//  Swift Rust FFI
//
//  Created by Arik Sosman on 5/7/20.
//  Copyright © 2020 Arik Sosman. All rights reserved.
//

import Foundation
import SwiftSocket

class Experimentation {

    public static var contentView: ContentView?
    
    static func setupPeerManager() {
        
        let privateKey = Data.init(base64Encoded: "ERERERERERERERERERERERERERERERERERERERERERE=")!;
        let ephemeralPrivateKey = Data.init(base64Encoded: "EhISEhISEhISEhISEhISEhISEhISEhISEhISEhISEhI=")!;
//        let remotePublicKey = Data.init(base64Encoded: "Ao11AN1MEmhdH1aLTCtQSOhTS4czGfOo2qYStGkTLsf3")!;
        let remotePublicKey = Data.init(base64Encoded: "AnRVrvhFPZL0cGtWC2FSfMIX3fFNpBdw6O1mBxkKGFG4")!;

        let peerManager = PeerManager(privateKey: privateKey, ephemeralSeed: ephemeralPrivateKey)
        let tcpClient = TCPClient(address: "testnet-lnd.yalls.org", port: 9735)
        let peer = CustomPeer(tcpClient: tcpClient)
        peerManager.initiateOutboundConnection(remotePublicKey: remotePublicKey, peer: peer)
        
    }

    static func beginHandshake() {

        DispatchQueue.global(qos: .background).async {
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

//            let msg_component = wire_get_message_component();


            // connect to Alex Bosworth' testnet Lightning node
            let client = TCPClient(address: "testnet-lnd.yalls.org", port: 9735)
            let connection = client.connect(timeout: 5);

            print("CALCULATING FIRST ACT")
            let firstAct = try! handshake.process_act(actData: Data.init())
            print("SENDING FIRST ACT")
            self.logString(entry: "TX (Act I): " + firstAct.hexEncodedString())
            let firstActSendResult = client.send(data: firstAct);
            print("SENT FIRST ACT")
            let secondAct = try! client.read(50, timeout: 5);
            self.logString(entry: "RX (Act II): " + Data(secondAct!).hexEncodedString())
            print("RECEIVED SECOND ACT:", secondAct!)
            let thirdAct = try! handshake.process_act(actData: Data(secondAct!));

            // we should now be connected
            self.markConnected()
            self.logString(entry: "Processed second act and sent out third act, finishing handshake.")

            print("SENDING THIRD ACT")
            self.logString(entry: "TX (Act III): " + thirdAct.hexEncodedString())
            let thirdActSendResult = client.send(data: thirdAct);
            print("SENT THIRD ACT")
            let encryptedFirstMessage = try! client.read(50, timeout: 5);
            print("RECEIVED FIRST MESSAGE:", encryptedFirstMessage!)
            let firstMessage = try! handshake.decrypt_message(ciphertext: Data(encryptedFirstMessage!))
            print("DECRYPTED FIRST MESSAGE:", [UInt8](firstMessage))
            self.logString(entry: "RX (Msg 1): " + firstMessage.hexEncodedString() + " (" + Data(encryptedFirstMessage!).hexEncodedString() + ")")

            // response

        }

    }

    static func markConnected(){
        guard var contentView = self.contentView else { return }
        DispatchQueue.main.async {
            contentView.isConnected = true
        }
    }

    static func logString(entry: String){
        guard var contentView = self.contentView else { return }
        DispatchQueue.main.async {
            contentView.logText = contentView.logText + "\n" + entry + "\n"
        }
    }
    
}

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
