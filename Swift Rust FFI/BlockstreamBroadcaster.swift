//
// Created by Arik Sosman on 6/4/20.
// Copyright (c) 2020 Arik Sosman. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

class BlockstreamBroadcaster {

    enum BroadcastingError: Error {
        case noResponse
        case errorResponse
        case timeout
    }

    private static let url = "https://blockstream.info/testnet/api/tx"

    static func submitTransaction(transaction: Data) -> Promise<String> {
        let submissionPromise = Promise { (resolver: Resolver<String>) in
            var request = try! URLRequest(url: BlockstreamBroadcaster.url, method: .post, headers: ["Content-Type": "text/plain"])
            request.httpBody = transaction.hexEncodedString().data(using: .utf8)

            AF.request(request).responseString { response in
                switch (response.result) {
                case .success(let responseValue):
                    resolver.fulfill(responseValue)
                case .failure(let error):
                    resolver.reject(error)
                }
            }
        }

        return submissionPromise
    }

}