//
// Created by Arik Sosman on 6/5/20.
// Copyright (c) 2020 Arik Sosman. All rights reserved.
//

import Foundation

class ManyChannelMonitor {

    var cManyChannelMonitor: LDKManyChannelMonitor?

    init(){

        let instance = RawLDKTypes.instanceToPointer(instance: self)

        func addMonitor(this_arg: UnsafeRawPointer?, funding_txo: LDKOutPoint, monitor: LDKChannelMonitor) -> LDKCResult_NoneChannelMonitorUpdateErrZ {
            print("adding monitor")
            return LDKCResult_NoneChannelMonitorUpdateErrZ()
        }

        func updateMonitor(this_arg: UnsafeRawPointer?, funding_txo: LDKOutPoint, update: LDKChannelMonitorUpdate) -> LDKCResult_NoneChannelMonitorUpdateErrZ {
            print("updating monitor")
            return LDKCResult_NoneChannelMonitorUpdateErrZ()
        }

        func clearPendingHTLCs(this_arg: UnsafeRawPointer?) -> LDKCVec_HTLCUpdateZ {
            print("clearing pending HTLCs")
            return LDKCVec_HTLCUpdateZ()
        }

        self.cManyChannelMonitor = LDKManyChannelMonitor(
                this_arg: instance,
                add_monitor: addMonitor,
                update_monitor: updateMonitor,
                get_and_clear_pending_htlcs_updated: clearPendingHTLCs
        )

    }

}