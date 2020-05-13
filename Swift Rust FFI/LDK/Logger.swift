//
// Created by Arik Sosman on 5/12/20.
// Copyright (c) 2020 Arik Sosman. All rights reserved.
//

import Foundation

class Logger {

    var cLogger: LDKLogger?;

    init() {
        func logCallback(pointer: UnsafeRawPointer?, buffer: UnsafePointer<Int8>?) -> Void {
            let instance: Logger = RawLDKTypes.pointerToInstance(pointer: pointer!)
            let message = String(cString: buffer!)
            instance.log(message: message)
        }

        self.cLogger = LDKLogger(this_arg: RawLDKTypes.instanceToPointer(instance: self), log: logCallback);
    }

    func log(message: String) {
        Experimentation.logInUI(message: "Log event:\n"+message)
        print("Log event:", message);
    }

}
