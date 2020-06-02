//
// Created by Arik Sosman on 5/28/20.
// Copyright (c) 2020 Arik Sosman. All rights reserved.
//
//

import XCTest

//@testable import BlockchainMonitorTests

class BlockchainMonitorTests: XCTestCase {

    func testReconciliation() throws {
        // we deliberately don't have a block 0
        let localBlockInfoA = BlockInfo(height: 1, hash: "A", previousHash: nil)
        let localBlockInfoB = BlockInfo(height: 2, hash: "B", previousHash: "A")
        let localBlockInfoC = BlockInfo(height: 3, hash: "C", previousHash: "B")
        let localBlockInfoD = BlockInfo(height: 4, hash: "D", previousHash: "C")
        let localBlockInfoE = BlockInfo(height: 5, hash: "E", previousHash: "D")

        let localBlockA = Block(info: localBlockInfoA, previous: nil, next: nil)
        let localBlockB = Block(info: localBlockInfoB, previous: nil, next: nil)
        let localBlockC = Block(info: localBlockInfoC, previous: nil, next: nil)
        let localBlockD = Block(info: localBlockInfoD, previous: nil, next: nil)
        let localBlockE = Block(info: localBlockInfoE, previous: nil, next: nil)

        let chainTip = try localBlockA
                .insertAfter(newNext: localBlockB)
                .insertAfter(newNext: localBlockC)
                .insertAfter(newNext: localBlockD)
                .insertAfter(newNext: localBlockE)

        print(chainTip.toChainString(trailingInfo: nil) + "\n")

        let reorgBlockInfoC1 = BlockInfo(height: 4, hash: "C.1", previousHash: "C")
        let reorgBlockInfoC2 = BlockInfo(height: 5, hash: "C.2", previousHash: "C.1")
        let reorgBlockInfoC3 = BlockInfo(height: 6, hash: "C.3", previousHash: "C.3")

        let reorgBlockC1 = Block(info: reorgBlockInfoC1, previous: nil, next: nil)
        let reorgBlockC2 = Block(info: reorgBlockInfoC2, previous: nil, next: nil)
        let reorgBlockC3 = Block(info: reorgBlockInfoC3, previous: nil, next: nil)

        let reorgStart = try reorgBlockC3
                .insertBefore(newPrevious: reorgBlockC2)
                .insertBefore(newPrevious: reorgBlockC1)

        // now do the actual testing
        let reorgPath = chainTip.reconcile(newChain: reorgStart)
        if let orphans = reorgPath.orphanChain {
            print("Orphaned: \(orphans.latestBlock().toChainString(trailingInfo: nil))\n")
        }
        print("New: \(reorgPath.newChain.latestBlock().toChainString(trailingInfo: nil))\n")

        // validate reorg chain
        XCTAssertNil(reorgPath.orphanChain?.previous)

        XCTAssertEqual(reorgPath.orphanChain?.info.hash, "D")
        XCTAssertEqual(reorgPath.orphanChain?.info.height, 4)

        XCTAssertEqual(reorgPath.orphanChain?.next?.info.hash, "E")
        XCTAssertEqual(reorgPath.orphanChain?.next?.info.height, 5)

        XCTAssertNil(reorgPath.orphanChain?.next?.next)

        // validate new chain
        XCTAssertEqual(reorgPath.newChain.info.hash, "C.1")
        XCTAssertEqual(reorgPath.newChain.info.height, 4)

        XCTAssertEqual(reorgPath.newChain.next?.info.hash, "C.2")
        XCTAssertEqual(reorgPath.newChain.next?.info.height, 5)

        XCTAssertEqual(reorgPath.newChain.next?.next?.info.hash, "C.3")
        XCTAssertEqual(reorgPath.newChain.next?.next?.info.height, 6)

        XCTAssertNil(reorgPath.newChain.next?.next?.next)
    }

    func testInsertion() throws {
        // we deliberately don't have a block 0
        let localBlockInfoA = BlockInfo(height: 1, hash: "A", previousHash: nil)
        let localBlockInfoB = BlockInfo(height: 2, hash: "B", previousHash: "A")
        let localBlockInfoC = BlockInfo(height: 3, hash: "C", previousHash: "B")

        let localBlockA = Block(info: localBlockInfoA, previous: nil, next: nil)
        let localBlockB = Block(info: localBlockInfoB, previous: nil, next: nil)
        let localBlockC = Block(info: localBlockInfoC, previous: nil, next: nil)

        // now do the actual testing
        let reorgPathA = localBlockA.reconcile(newChain: localBlockB)

        // validate reorg chain
        XCTAssertNil(reorgPathA.orphanChain)

        // validate new chain
        XCTAssertEqual(reorgPathA.newChain.info.hash, "B")
        XCTAssertEqual(reorgPathA.newChain.info.height, 2)

        XCTAssertNil(reorgPathA.newChain.next)

        let reorgPathB = localBlockB.reconcile(newChain: localBlockC)
    }

}
