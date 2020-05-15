//
// Created by Arik Sosman on 5/7/20.
// Copyright (c) 2020 Arik Sosman. All rights reserved.
//

import Foundation
import SwiftSocket
import PromiseKit

class CustomPeer: Peer {

    private var tcpClient: TCPClient?
    private var awaitPromise: Guarantee<Void>?

    init(tcpClient: TCPClient) {
        self.tcpClient = tcpClient
        self.tcpClient!.connect(timeout: 5)
    }

    override func sendDataCallback(data: Data) -> UInt {
        self.tcpClient!.send(data: data)
        print("Sent data to peer:", [UInt8](data))

        Demonstration.logInUI(message: "Sending: " + data.hexEncodedString())

        if(self.awaitPromise == nil){
            self.awaitResponse();
        }
        return UInt(data.count)
    }

    override func destructionCallback() {
        print("Disconnecting from peer")

        // reconnect
        self.tcpClient?.close()
        self.tcpClient = nil

        print("Auto-reconnect to peer")
        // Experimentation.logInUI(message: "Auto-reconnecting")
        let tcpClient = TCPClient(address: "testnet-lnd.yalls.org", port: 9735)
        self.tcpClient = tcpClient
        self.manager?.initiateOutboundConnection(remotePublicKey: self.publicKey!, peer: self)
    }

    private func awaitResponse() -> Guarantee<Void> {

        guard let promise = self.awaitPromise else {
            print("initiating response chain")
            self.awaitPromise = firstly { () -> Guarantee<Void> in
                after(seconds: 1)
            }.then { () -> Guarantee<Void> in
                self.awaitResponse()
            }
            return self.awaitPromise!
        }

        let continuationPromise = after(seconds: 1).then { () -> Guarantee<Void> in
            self.awaitResponse()
        };

        guard let tcpClient = self.tcpClient else {
            print("No TCP client")
            return continuationPromise
        }
        if(!self.canReceiveData){
            print("Cannot receive data")
            return continuationPromise
        }

        DispatchQueue.global(qos: .background).async {
            // the TCP read has to be in a background thread because it's blocking the UI otherwise
            guard let response = tcpClient.read(50, timeout: 10) else { return }
            DispatchQueue.main.async {
                print("Received data from peer:", response)
                self.receiveData(data: Data(response))
                Demonstration.logInUI(message: "Received: " + Data(response).hexEncodedString())
            }
        }

        return continuationPromise


    }

}