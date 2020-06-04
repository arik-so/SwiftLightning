//
// Created by Arik Sosman on 6/2/20.
// Copyright (c) 2020 Arik Sosman. All rights reserved.
//

import Foundation

class BlockNotifierBasedBlockListener: BlockListener {

    private var cBlockNotifier: LDKBlockNotifier;

    init(chainWatchInterface: LDKChainWatchInterface){
        self.cBlockNotifier = BlockNotifier_new(chainWatchInterface)
    }

    func connectBlock(block: BlockInfo) {
        let notifierPointer = withUnsafePointer(to: self.cBlockNotifier) { (pointer: UnsafePointer<LDKBlockNotifier>) in
            pointer
        }
        let blockData = RawLDKTypes.dataToU8Slice(data: block.rawData!)
        let height = UInt32(block.height)
        print("Connecting block \(block.height): \(block.hash)")
        // BlockNotifier_block_connected(notifierPointer, blockData, height)
    }

    func disconnectBlock(block: BlockInfo) {
        print("BLOCK REORG NOT SUPPORTED YET!!!")
        let notifierPointer = withUnsafePointer(to: self.cBlockNotifier) { (pointer: UnsafePointer<LDKBlockNotifier>) in
            pointer
        }
        let header = RawLDKTypes.dataToBlockHeaderTuple(data: block.header!)
        let headerPointer = withUnsafePointer(to: header) { (pointer: UnsafePointer<RawLDKTypes.BlockHeader>) in
            pointer
        }
        let height = UInt32(block.height)
        print("Disconnecting block \(block.height): \(block.hash)")
        // BlockNotifier_block_disconnected(notifierPointer, headerPointer, height)
    }



}