//
// Created by Arik Sosman on 5/13/20.
// Copyright (c) 2020 Arik Sosman. All rights reserved.
//

import Foundation

class ChannelMessageHandler {

    var cMessageHandler: LDKChannelMessageHandler?

    init() {

        let instance = RawLDKTypes.instanceToPointer(instance: self);

        func handleOpenChannel(instancePointer: UnsafeRawPointer?, publicKey: LDKPublicKey, initFeatures: LDKInitFeatures, openChannel: UnsafePointer<LDKOpenChannel>?) -> Void {
            let instance: ChannelMessageHandler = RawLDKTypes.pointerToInstance(pointer: instancePointer!)
            print("opened channel");
        }

        func handleAcceptChannel(instancePointer: UnsafeRawPointer?, publicKey: LDKPublicKey, initFeatures: LDKInitFeatures, acceptChannel: UnsafePointer<LDKAcceptChannel>?) -> Void {
            let instance: ChannelMessageHandler = RawLDKTypes.pointerToInstance(pointer: instancePointer!)
            print("accepted channel");
        }

        func handleFundingCreated(instancePointer: UnsafeRawPointer?, publicKey: LDKPublicKey, fundingCreated: UnsafePointer<LDKFundingCreated>?) -> Void {
            let instance: ChannelMessageHandler = RawLDKTypes.pointerToInstance(pointer: instancePointer!)
            print("funding created");
        }

        func handleFundingSigned(instancePointer: UnsafeRawPointer?, publicKey: LDKPublicKey, fundingSigned: UnsafePointer<LDKFundingSigned>?) -> Void {
            let instance: ChannelMessageHandler = RawLDKTypes.pointerToInstance(pointer: instancePointer!)
            print("funding signed");
        }

        func handleFundingLocked(instancePointer: UnsafeRawPointer?, publicKey: LDKPublicKey, fundingLocked: UnsafePointer<LDKFundingLocked>?) -> Void {
            let instance: ChannelMessageHandler = RawLDKTypes.pointerToInstance(pointer: instancePointer!)
            print("funding locked");
        }

        func handleShutdown(instancePointer: UnsafeRawPointer?, publicKey: LDKPublicKey, shutdown: UnsafePointer<LDKShutdown>?) -> Void {
            let instance: ChannelMessageHandler = RawLDKTypes.pointerToInstance(pointer: instancePointer!)
            print("shut down");
        }

        func handleClosingSigned(instancePointer: UnsafeRawPointer?, publicKey: LDKPublicKey, closingSigned: UnsafePointer<LDKClosingSigned>?) -> Void {
            let instance: ChannelMessageHandler = RawLDKTypes.pointerToInstance(pointer: instancePointer!)
            print("closing signed");
        }

        func handleUpdateAddHTLC(instancePointer: UnsafeRawPointer?, publicKey: LDKPublicKey, updateAddHTLC: UnsafePointer<LDKUpdateAddHTLC>?) -> Void {
            let instance: ChannelMessageHandler = RawLDKTypes.pointerToInstance(pointer: instancePointer!)
            print("added HTLC");
        }

        func handleUpdateFulfillHTLC(instancePointer: UnsafeRawPointer?, publicKey: LDKPublicKey, updateFulfillHTLC: UnsafePointer<LDKUpdateFulfillHTLC>?) -> Void {
            let instance: ChannelMessageHandler = RawLDKTypes.pointerToInstance(pointer: instancePointer!)
            print("fulfilled HTLC");
        }

        func handleUpdateFailHTLC(instancePointer: UnsafeRawPointer?, publicKey: LDKPublicKey, updateFailHTLC: UnsafePointer<LDKUpdateFailHTLC>?) -> Void {
            let instance: ChannelMessageHandler = RawLDKTypes.pointerToInstance(pointer: instancePointer!)
            print("failed HTLC");
        }

        func handleUpdateFailMalformedHTLC(instancePointer: UnsafeRawPointer?, publicKey: LDKPublicKey, updateFailMalformedHTLC: UnsafePointer<LDKUpdateFailMalformedHTLC>?) -> Void {
            let instance: ChannelMessageHandler = RawLDKTypes.pointerToInstance(pointer: instancePointer!)
            print("failed malformed HTLC");
        }

        func handleCommitmentSigned(instancePointer: UnsafeRawPointer?, publicKey: LDKPublicKey, commitmentSigned: UnsafePointer<LDKCommitmentSigned>?) -> Void {
            let instance: ChannelMessageHandler = RawLDKTypes.pointerToInstance(pointer: instancePointer!)
            print("commitment signed");
        }

        func handleRevokeAndAck(instancePointer: UnsafeRawPointer?, publicKey: LDKPublicKey, revokeAndAck: UnsafePointer<LDKRevokeAndACK>?) -> Void {
            let instance: ChannelMessageHandler = RawLDKTypes.pointerToInstance(pointer: instancePointer!)
            print("revoked and acked");
        }

        func handleUpdateFee(instancePointer: UnsafeRawPointer?, publicKey: LDKPublicKey, updateFee: UnsafePointer<LDKUpdateFee>?) -> Void {
            let instance: ChannelMessageHandler = RawLDKTypes.pointerToInstance(pointer: instancePointer!)
            print("updated fee");
        }

        func handleAnnouncementSignatures(instancePointer: UnsafeRawPointer?, publicKey: LDKPublicKey, announcementSignatures: UnsafePointer<LDKAnnouncementSignatures>?) -> Void {
            let instance: ChannelMessageHandler = RawLDKTypes.pointerToInstance(pointer: instancePointer!)
            print("announcement signatures");
        }

        func peerDisconnected(instancePointer: UnsafeRawPointer?, publicKey: LDKPublicKey, no_connection_possible: Bool) -> Void {
            let instance: ChannelMessageHandler = RawLDKTypes.pointerToInstance(pointer: instancePointer!)
            print("peer disconnected");
        }

        func peerConnected(instancePointer: UnsafeRawPointer?, publicKey: LDKPublicKey, init: UnsafePointer<LDKInit>?) -> Void {
            let instance: ChannelMessageHandler = RawLDKTypes.pointerToInstance(pointer: instancePointer!)

            Demonstration.contentView?.isConnecting = false
            Demonstration.contentView?.isConnected = true
            Demonstration.logInUI(message: "Peer connected")

            print("peer connected");
        }

        func handleChannelReestablish(instancePointer: UnsafeRawPointer?, publicKey: LDKPublicKey, channelReestablish: UnsafePointer<LDKChannelReestablish>?) -> Void {
            let instance: ChannelMessageHandler = RawLDKTypes.pointerToInstance(pointer: instancePointer!)
            print("channel reestablished");
        }

        func handleError(instancePointer: UnsafeRawPointer?, publicKey: LDKPublicKey, error: UnsafePointer<LDKErrorMessage>?) -> Void {
            let instance: ChannelMessageHandler = RawLDKTypes.pointerToInstance(pointer: instancePointer!)
            print("some sort of error");
        }

        let eventsProvider = LDKMessageSendEventsProvider(this_arg: instance)

        self.cMessageHandler = LDKChannelMessageHandler(
            this_arg: instance,
            handle_open_channel: handleOpenChannel,
            handle_accept_channel: handleAcceptChannel,
            handle_funding_created: handleFundingCreated,
            handle_funding_signed: handleFundingSigned,
            handle_funding_locked: handleFundingLocked,
            handle_shutdown: handleShutdown,
            handle_closing_signed: handleClosingSigned,
            handle_update_add_htlc: handleUpdateAddHTLC,
            handle_update_fulfill_htlc: handleUpdateFulfillHTLC,
            handle_update_fail_htlc: handleUpdateFailHTLC,
            handle_update_fail_malformed_htlc: handleUpdateFailMalformedHTLC,
            handle_commitment_signed: handleCommitmentSigned,
            handle_revoke_and_ack: handleRevokeAndAck,
            handle_update_fee: handleUpdateFee,
            handle_announcement_signatures: handleAnnouncementSignatures,
            peer_disconnected: peerDisconnected,
            peer_connected: peerConnected,
            handle_channel_reestablish: handleChannelReestablish,
            handle_error: handleError,
            MessageSendEventsProvider: eventsProvider
        )

    }

}
