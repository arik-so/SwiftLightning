//
// Created by Arik Sosman on 5/27/20.
// Copyright (c) 2020 Arik Sosman. All rights reserved.
//

import Foundation

class RoutingMessageHandler {

    var cRoutingMessageHandler: LDKRoutingMessageHandler?

    init(){
        func handleNodeAnnouncement(pointer: UnsafeRawPointer?, announcement: UnsafePointer<LDKNodeAnnouncement>?) -> LDKCResult_boolLightningErrorZ {
            LDKCResult_boolLightningErrorZ()
        }
        func handleChannelAnnouncement(pointer: UnsafeRawPointer?, announcement: UnsafePointer<LDKChannelAnnouncement>?) -> LDKCResult_boolLightningErrorZ {
            LDKCResult_boolLightningErrorZ()
        }
        func handleChannelUpdate(pointer: UnsafeRawPointer?, announcement: UnsafePointer<LDKChannelUpdate>?) -> LDKCResult_boolLightningErrorZ {
            LDKCResult_boolLightningErrorZ()
        }
        func handleHTLCFailChannelUpdate(pointer: UnsafeRawPointer?, announcement: UnsafePointer<LDKHTLCFailChannelUpdate>?) {
        }
        func shouldRequestFullSync(pointer: UnsafeRawPointer?, key: LDKPublicKey) -> Bool {
            false
        }
        self.cRoutingMessageHandler = LDKRoutingMessageHandler(
                this_arg: RawLDKTypes.instanceToPointer(instance: self),
                handle_node_announcement: handleNodeAnnouncement,
                handle_channel_announcement: handleChannelAnnouncement,
                handle_channel_update: handleChannelUpdate,
                handle_htlc_fail_channel_update: handleHTLCFailChannelUpdate,
                should_request_full_sync: shouldRequestFullSync
        )
    }

}