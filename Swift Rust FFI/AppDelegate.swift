//
//  AppDelegate.swift
//  Swift Rust FFI
//
//  Created by Arik Sosman on 3/3/20.
//  Copyright © 2020 Arik Sosman. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // let txHex = "010000000001011c834737e82dd99e7b9cfe7bdb27ea031e1fe8b9762de59460f8a84372872b450000000000fdffffff027991bc00000000001600149ef9d628218a40cc3f01c47e9f4518e093f1cef00000000000000000226a20a614724882420621c6424bcd4637568dade9cd5d7b5dc82e9caedb25556d363802473044022079f5a655659c74814c5d66d29fe4b1471bae8dc905eb5cb28d7932f6b365e4690220587e6d9a03daa7e1b783ba01b240bef7ae65c760a68194a0f83f57b93d0b5755012103dc94fdb548b17f7e94f908b87a9f3466923e048975124660f34d2b8b6ddbf9a414ab1a00"
        // let txBin = Data(hexString: txHex)
        // BlockstreamBroadcaster.submitTransaction(transaction: txBin!)

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

