//
//  Experimentation.swift
//  Swift Rust FFI
//
//  Created by Arik Sosman on 5/7/20.
//  Copyright © 2020 Arik Sosman. All rights reserved.
//

import Foundation
import SwiftSocket
import PromiseKit

class Demonstration {

    public static var contentView: ContentView?
    public static var peer: Peer?

    static func setupPeerManager() {

        let privateKey = Data.init(base64Encoded: "ERERERERERERERERERERERERERERERERERERERERERE=")!;
        let ephemeralPrivateKey = Data.init(base64Encoded: "EhISEhISEhISEhISEhISEhISEhISEhISEhISEhISEhI=")!;
        let remotePublicKey = Data.init(base64Encoded: "Ao11AN1MEmhdH1aLTCtQSOhTS4czGfOo2qYStGkTLsf3")!;
        let alexPublicKey = Data.init(base64Encoded: "AnRVrvhFPZL0cGtWC2FSfMIX3fFNpBdw6O1mBxkKGFG4")!;
        let localPublicKey = Data.init(base64Encoded: "Ai/bcTpKVRYmMWTmDDLOvG9MrW5v7xRNY5vXzcsLIPZZ")!;

        let peerManager = PeerManager(privateKey: privateKey, ephemeralSeed: ephemeralPrivateKey)


        /*
        // a connection to be discarded
        peerManager.initiateOutboundConnection(remotePublicKey: remotePublicKey)

        // a custom peer to be discarded
        print("Creating Google Peer")
        let googleClient = TCPClient(address: "google.com", port: 443)
        let fakePeer = CustomPeer(tcpClient: googleClient)
        fakePeer.name = "Google"
        */


        // print("Creating Alex Bosworth peer")
        // let tcpClient = TCPClient(address: "testnet-lnd.yalls.org", port: 9735)
        // let peer = CustomPeer(tcpClient: tcpClient)
        // peer.name = "Alex"
        // peer.publicKey = alexPublicKey

        print("Creating local peer")
        let tcpClient = TCPClient(address: "127.0.0.1", port: 1337)
        let peer = CustomPeer(tcpClient: tcpClient)
        peer.name = "Local"

        self.peer = peer;
        peerManager.initiateOutboundConnection(remotePublicKey: localPublicKey, peer: peer)

        self.contentView?.isConnecting = true



    }

    /*

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
    */

    static func logInUI(message: String) {
        Demonstration.contentView?.logText = "\n" + message + "\n" + Demonstration.contentView!.logText
        // DispatchQueue.main.async {
        //     Experimentation.contentView?.logText = "\n" + message + "\n" + Experimentation.contentView!.logText
        // }
    }

}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map {
            String(format: format, $0)
        }.joined()
    }
}
