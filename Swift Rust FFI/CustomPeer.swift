//
// Created by Arik Sosman on 5/7/20.
// Copyright (c) 2020 Arik Sosman. All rights reserved.
//

import Foundation
import SwiftSocket

class CustomPeer : Peer {

    private var tcpClient: TCPClient

    init(tcpClient: TCPClient) {
        self.tcpClient = tcpClient
        self.tcpClient.connect(timeout: 5)
    }


    override func sendDataCallback(data: Data) -> UInt {
        self.tcpClient.send(data: data)
        print("Sent data to peer:", [UInt8](data))
        Experimentation.logInUI(message: "Sending: " + data.hexEncodedString())
        // start a background thread waiting for data
        DispatchQueue.global(qos: .background).async {
            self.awaitResponse()
        }
        return UInt(data.count)
    }

    override func destructionCallback() {
        print("Disconnecting from peer")
        Experimentation.logInUI(message: "Disconnecting")
        Experimentation.contentView?.isConnected = false
        // Experimentation.contentView?.isConnecting = false
        //Experimentation.peer = nil

        // reconnect
        self.tcpClient.close()

        print("Auto-reconnect to peer")
        Experimentation.logInUI(message: "Auto-reconnecting")
        let tcpClient = TCPClient(address: "testnet-lnd.yalls.org", port: 9735)
        self.tcpClient = tcpClient
        self.manager?.initiateOutboundConnection(remotePublicKey: self.publicKey!, peer: self)
    }

    private func awaitResponse(){
        guard let response = try! self.tcpClient.read(50, timeout: 10) else {
            print("Not received any data, waiting one second")
            sleep(1) // wait one second
            return awaitResponse()
        }
        print("Received data from peer:", response)
        Experimentation.logInUI(message: "Received: " + Data(response).hexEncodedString())
        DispatchQueue.main.async {
            self.receiveData(data: Data(response))
        }
    }

}