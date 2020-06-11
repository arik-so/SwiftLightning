//
// Created by Arik Sosman on 5/15/20.
// Copyright (c) 2020 Arik Sosman. All rights reserved.
//

import Foundation

class FeeEstimator {

    var cFeeEstimator: LDKFeeEstimator?

    init() {
        let instance = RawLDKTypes.instanceToPointer(instance: self);

        func get_est_sat_per_1000_weight(instancePointer: UnsafeRawPointer?, confirmationTarget: LDKConfirmationTarget) -> UInt64 {
            1
        }

        self.cFeeEstimator = LDKFeeEstimator(
            this_arg: instance,
            get_est_sat_per_1000_weight: get_est_sat_per_1000_weight
        )

    }
}