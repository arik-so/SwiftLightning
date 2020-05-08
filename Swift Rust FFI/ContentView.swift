//
//  ContentView.swift
//  Swift Rust FFI
//
//  Created by Arik Sosman on 3/3/20.
//  Copyright © 2020 Arik Sosman. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    private var peer = Peer()
    
    @State private var isConnecting = false
    @State public var isConnected = false
    @State public var isPinging = false
    
    @State var logText = ""
    
    var body: some View {
        VStack {
                        
            if !self.isConnecting {
            
//                Button(action: {
//                    self.isConnecting = true
//                    self.peer.contentView = self
//                    self.peer.beginHandshake()
//                }) {
//                    Text("Connect")
//                }
                
                Button(action: {
//                    self.isConnecting = true
//                    self.peer.contentView = self
//                    self.peer.createPeerManager()
                    // self.peer.createNode();
                    Experimentation.setupPeerManager()
                }) {
                    Text("Test")
                }
                
            }   else {
                
                if !self.isConnected {
                    Text("Connecting…")
                }else if !self.isPinging{
                    Button(action: {
                        self.isPinging = true
                    }) {
                        Text("Send Ping")
                    }
                }
                
                Spacer()
                
                Text("Log:\n" + self.logText)
                    .lineLimit(nil)
                    .foregroundColor(Color.gray)
                    .font(.body)
            }
            
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
