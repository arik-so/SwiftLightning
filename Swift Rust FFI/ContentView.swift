//
//  ContentView.swift
//  Swift Rust FFI
//
//  Created by Arik Sosman on 3/3/20.
//  Copyright © 2020 Arik Sosman. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    // private var peer = Peer()

    @State public var isConnecting = false
    @State public var isConnected = false
    @State public var isPinging = false
    @State public var isOpeningChannel = false
    @State public var isChannelOpen = false

    @State var logText = ""

    var body: some View {
        VStack {

            if !self.isConnecting && !self.isConnected {

//                Button(action: {
//                    self.isConnecting = true
//                    self.peer.contentView = self
//                    self.peer.beginHandshake()
//                }) {
//                    Text("Connect")
//                }

                Button(action: {
                    self.isConnecting = true
//                    self.peer.contentView = self
//                    self.peer.createPeerManager()
                    // self.peer.createNode();

                    Demonstration.contentView = self
                    Demonstration.setupPeerManager()

                }) {
                    Text("Connect to Alex' Node")
                }

            } else {

                if !self.isConnected {
                    Text("Connecting…")
                } else if !self.isPinging {
                    /*Button(action: {
                        self.isPinging = true
                    }) {
                        Text("Send Ping")
                    }*/
                    Text("Connected to Alex")
                }

                Spacer()

                if (self.isConnected) {

                    if (!self.isChannelOpen && !self.isOpeningChannel) {
                        Button(action: {
                            Demonstration.openChannel()
                            self.isOpeningChannel = true
                        }) {
                            Text("Open Channel")
                        }
                    } else if (self.isOpeningChannel) {
                        Text("Opening channel…")
                    } else if (self.isChannelOpen) {
                        Text("Awaiting funding…")
                    }

                    Spacer()

                }


                Text("Reverse Log")

                List {
                    Text(self.logText)
                            .lineLimit(nil)
                            .foregroundColor(Color.gray)
                            .font(.body)
                }
            }

        }
                .padding()

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
