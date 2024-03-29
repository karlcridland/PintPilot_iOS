//
//  AppDelegate.swift
//  pint pilot
//
//  Created by Karl Cridland on 23/11/2020.
//

import UIKit
import Firebase
import Stripe

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        StripeAPI.defaultPublishableKey = "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"
        STPPaymentConfiguration.shared.appleMerchantIdentifier = "merchant.karlcridland.pintpilot"
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

