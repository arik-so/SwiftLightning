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
        // start a background thread waiting for data
        DispatchQueue.global(qos: .background).async {
            self.awaitResponse()
        }
        return UInt(data.count)
    }

    private func awaitResponse(){
        guard let response = try! self.tcpClient.read(50, timeout: 10) else {
            print("Not received any data, waiting one second")
            sleep(1) // wait a couple seconds
            return awaitResponse()
        }
        print("Received data from peer:", response)
        DispatchQueue.main.async {
            self.receiveData(data: Data(response))
        }
    }
}