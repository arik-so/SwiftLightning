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
import Alamofire

class Demonstration {

    public static var contentView: ContentView?
    public static var peer: Peer?
    static var channelManager: ChannelManager?

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


        print("Creating Alex Bosworth peer")
        let tcpClient = TCPClient(address: "testnet-lnd.yalls.org", port: 9735)
        let peer = CustomPeer(tcpClient: tcpClient)
        peer.name = "Alex"
        peer.publicKey = alexPublicKey

        // print("Creating local peer")
        // let tcpClient = TCPClient(address: "127.0.0.1", port: 1337)
        // let peer = CustomPeer(tcpClient: tcpClient)
        // peer.name = "Local"

        self.peer = peer;
        peerManager.initiateOutboundConnection(remotePublicKey: alexPublicKey, peer: peer)
    }

    enum BlockchainFetchError: Error {
        case didntWork
    }

    static func setupChannelManager() -> Promise<ChannelManager> {
        let heightPromise = Promise { (resolver: Resolver<UInt>) in
            let latestBlockUrl = "https://test.bitgo.com/api/v2/tbtc/public/block/latest"
            AF.request(latestBlockUrl).responseJSON { response in
                print("block data:", response.value)
                guard let blockData = response.value as? [String: Any] else {
                    resolver.reject(BlockchainFetchError.didntWork)
                    return
                }

                guard let height = blockData["height"] as? UInt else {
                    resolver.reject(BlockchainFetchError.didntWork)
                    return
                }

                resolver.fulfill(height)
            }

        };

        return firstly {
            heightPromise
        }.map { height -> ChannelManager in
            self.logInUI(message: "Retrieved testnet chain height: " + String(height))
            let privateKey = Data.init(base64Encoded: "ERERERERERERERERERERERERERERERERERERERERERE=")!;
            let logger = Logger()
            return ChannelManager(privateKey: privateKey, logger: logger, currentBlockchainHeight: height)
        }
    }

    static func openChannel() {
        self.setupChannelManager().done { manager in
            self.channelManager = manager
            let alexPublicKey = Data.init(base64Encoded: "AnRVrvhFPZL0cGtWC2FSfMIX3fFNpBdw6O1mBxkKGFG4")!;
            Demonstration.channelManager?.openChannel(peerPublicKey: alexPublicKey, channelSatoshiValue: 1000, pushMillisatoshiAmount: 2, userID: 13)
        }

    }

    static func logInUI(message: String) {
        Demonstration.contentView?.logText = "\n" + message + "\n" + Demonstration.contentView!.logText
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
