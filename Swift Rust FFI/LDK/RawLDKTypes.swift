//
//  RawLDKTypes.swift
//  Swift Rust FFI
//
//  Created by Arik Sosman on 5/6/20.
//  Copyright © 2020 Arik Sosman. All rights reserved.
//

import Foundation

class RawLDKTypes {
    
    static func dataToPointer(data: Data) -> UnsafePointer<UInt8>{
        let pointer = (data as NSData).bytes.assumingMemoryBound(to: UInt8.self);
        return pointer;
    }
    
    static func dataToBufferArgument(data: Data, callback: (UnsafePointer<LDKBufferArgument>) -> Void) {
        let rawActDataPointer = (data as NSData).bytes.assumingMemoryBound(to: UInt8.self);
        let dataArgument = LDKBufferArgument(data: rawActDataPointer, length: UInt(data.count));
        withUnsafePointer(to: dataArgument) { (dataArgumentPointer) in
            callback(dataArgumentPointer)
        }
    }
    
    static func bufferResponseToData(buffer: UnsafeMutablePointer<LDKBufferResponse>) -> Data {
        let bufferData = buffer.pointee
        let data = Data.init(bytes: bufferData.data, count: Int(bufferData.length))
        buffer_response_free(buffer)
        return data
    }
    
    static func errorPlaceholder() -> UnsafeMutablePointer<LDKError> {
        let error = UnsafeMutablePointer<LDKError>.allocate(capacity: 1) //error_placeholder()
        return error;
    }
    
    static func errorFromPlaceholder(error: UnsafeMutablePointer<LDKError>) -> String? {
        if(error == nil){
            return nil;
        }
        
        // error handling
        let error_text = String(cString: error.pointee.message)
        return error_text;
    }
    
    static func instanceToPointer(instance: AnyObject) -> UnsafeMutableRawPointer {
        return Unmanaged.passUnretained(instance).toOpaque()
    }
    
    static func pointerToInstance<T: AnyObject>(pointer: UnsafeRawPointer) -> T{
        Unmanaged<T>.fromOpaque(pointer).takeUnretainedValue()
    }
    
}
