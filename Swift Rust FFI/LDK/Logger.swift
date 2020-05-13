//
// Created by Arik Sosman on 5/12/20.
// Copyright (c) 2020 Arik Sosman. All rights reserved.
//

import Foundation

class Logger {

    var cLogger: LDKLogger?;

    init(){
        func logCallback(pointer: UnsafeRawPointer?, buffer: UnsafePointer<Int8>?) -> Void {
            // let instance: Logger = RawLDKTypes.pointerToInstance(pointer: pointer!)
            print("something got logged!");
        }

        self.cLogger = LDKLogger(this_arg: RawLDKTypes.instanceToPointer(instance: self), log: logCallback);
    }

}
