//
// Created by Arik Sosman on 6/2/20.
// Copyright (c) 2020 Arik Sosman. All rights reserved.
//

import Foundation

protocol BlockListener {
    func connectBlock(block: BlockInfo)

    func disconnectBlock(block: BlockInfo)
}