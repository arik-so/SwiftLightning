//
//  RawLDKTypes.swift
//  Swift Rust FFI
//
//  Created by Arik Sosman on 5/6/20.
//  Copyright © 2020 Arik Sosman. All rights reserved.
//

import Foundation



class RawLDKTypes {

    typealias SecretKey = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
    typealias PublicKey = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)

    static func dataToPointer(data: Data) -> UnsafePointer<UInt8>{
        let pointer = (data as NSData).bytes.assumingMemoryBound(to: UInt8.self);
        return pointer;
    }

    static func dataToPrivateKeyTuple(data: Data) -> SecretKey {
        let bytes = [UInt8](data)
        let tuple = (
                bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7],
                bytes[8], bytes[9], bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15],
                bytes[16], bytes[17], bytes[18], bytes[19], bytes[20], bytes[21], bytes[22], bytes[23],
                bytes[24], bytes[25], bytes[26], bytes[27], bytes[28], bytes[29], bytes[30], bytes[31]
        )
        return tuple
    }

    static func dataToPublicKeyTuple(data: Data) -> PublicKey {
        let bytes = [UInt8](data)
        let tuple = (
                bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7],
                bytes[8], bytes[9], bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15],
                bytes[16], bytes[17], bytes[18], bytes[19], bytes[20], bytes[21], bytes[22], bytes[23],
                bytes[24], bytes[25], bytes[26], bytes[27], bytes[28], bytes[29], bytes[30], bytes[31],
                bytes[32]
        )
        return tuple
    }

    static func privateKeyTupleToData(tuple: SecretKey) -> Data {
        let bytes = [
            tuple.0, tuple.1, tuple.2, tuple.3, tuple.4, tuple.5, tuple.6, tuple.7,
            tuple.8, tuple.9, tuple.10, tuple.11, tuple.12, tuple.13, tuple.14, tuple.15,
            tuple.16, tuple.17, tuple.18, tuple.19, tuple.20, tuple.21, tuple.22, tuple.23,
            tuple.24, tuple.25, tuple.26, tuple.27, tuple.28, tuple.29, tuple.30, tuple.31
        ]
        return Data(bytes)
    }

    static func publicKeyTupleToData(tuple: PublicKey) -> Data {
        let bytes = [
                tuple.0, tuple.1, tuple.2, tuple.3, tuple.4, tuple.5, tuple.6, tuple.7,
                tuple.8, tuple.9, tuple.10, tuple.11, tuple.12, tuple.13, tuple.14, tuple.15,
                tuple.16, tuple.17, tuple.18, tuple.19, tuple.20, tuple.21, tuple.22, tuple.23,
                tuple.24, tuple.25, tuple.26, tuple.27, tuple.28, tuple.29, tuple.30, tuple.31,
                tuple.32
        ]
        return Data(bytes)
    }

    static func u8SliceToData(buffer: LDKu8slice) -> Data {
        let data = Data.init(bytes: buffer.data, count: Int(buffer.datalen))
        return data
    }

    static func dataToU8Slice(data: Data) -> LDKu8slice {
        let rawActDataPointer = (data as NSData).bytes.assumingMemoryBound(to: UInt8.self);
        let dataArgument = LDKu8slice(data: rawActDataPointer, datalen: UInt(data.count));
        return dataArgument;
    }

    static func resultToData(result: LDKCResultTempl_CVecTempl_u8_____PeerHandleError) -> Data?{
        if(!result.result_good){
            return nil;
        }
        let contents: LDKCResultPtr_CVecTempl_u8_____PeerHandleError = result.contents
        let successfulResult: LDKCVecTempl_u8 = contents.result.pointee
        let data = Data.init(bytes: successfulResult.data, count: Int(successfulResult.datalen))

        return data
    }

    /*
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
    */
    
    static func instanceToPointer(instance: AnyObject) -> UnsafeMutableRawPointer {
        Unmanaged.passUnretained(instance).toOpaque()
    }
    
    static func pointerToInstance<T: AnyObject>(pointer: UnsafeRawPointer) -> T{
        Unmanaged<T>.fromOpaque(pointer).takeUnretainedValue()
    }

}
