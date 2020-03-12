//
//  Handshake.swift
//  Swift Rust FFI
//
//  Created by Arik Sosman on 3/12/20.
//  Copyright © 2020 Arik Sosman. All rights reserved.
//

import Foundation

enum HandshakeError : Error {
    case other(message: String)
}

class Handshake {
    
    private var cHandshake: OpaquePointer;
    private var cConduit: OpaquePointer?;
    
    init(cHandshake: OpaquePointer){
        self.cHandshake = cHandshake;
    }
    
    func process_act(actData: Data) throws -> Data {
        let rawActDataPointer = (actData as NSData).bytes.assumingMemoryBound(to: UInt8.self);
        let dataArgument = LDKBufferArgument(data: rawActDataPointer, length: UInt(actData.count));
        let dataArgumentPointer = withUnsafePointer(to: dataArgument) { (dataArgumentPointer) -> UnsafePointer<LDKBufferArgument> in
            return dataArgumentPointer
        }
        
        let error = UnsafeMutablePointer<LDKError>.allocate(capacity: 1) //error_placeholder()
        let cActResult = peer_handshake_process_act(self.cHandshake, dataArgumentPointer, error)
        
        if(cActResult == nil){
            // error handling
            let error_text = String(cString: error.pointee.message)
            print("error:", error_text)
            throw HandshakeError.other(message: error_text)
        }
        
        let buffer = cActResult?.pointee.next_act.pointee
        let conduit = cActResult?.pointee.conduit;
        
        if conduit != nil {
            self.cConduit = conduit!
        }
        
        let nextAct = Data.init(bytes: buffer!.data, count: Int(buffer!.length))
        free_buffer(cActResult?.pointee.next_act)
        
        let nextActBytes = [UInt8](nextAct)
        print("next act bytes:", nextActBytes)
        
        return nextAct
    }
    
    func decrypt_message(ciphertext: Data) throws -> Data {
        let rawMessagePointer = (ciphertext as NSData).bytes.assumingMemoryBound(to: UInt8.self);
        let dataArgument = LDKBufferArgument(data: rawMessagePointer, length: UInt(ciphertext.count));
        let dataArgumentPointer = withUnsafePointer(to: dataArgument) { (dataArgumentPointer) -> UnsafePointer<LDKBufferArgument> in
            return dataArgumentPointer
        }
        
        let error = UnsafeMutablePointer<LDKError>.allocate(capacity: 1) //error_placeholder()
        let decryptionResult = peer_conduit_decrypt(self.cConduit!, dataArgumentPointer, error)
        
        if(decryptionResult == nil){
            // error handling
            let error_text = String(cString: error.pointee.message)
            print("error:", error_text)
            throw HandshakeError.other(message: error_text)
        }
        
        let buffer = decryptionResult?.pointee
        let plaintext = Data.init(bytes: buffer!.data, count: Int(buffer!.length))
        free_buffer(decryptionResult!)
        
        let plaintextBytes = [UInt8](plaintext)
        print("plaintext bytes:", plaintextBytes)
        
        return plaintext
    }
    
}
