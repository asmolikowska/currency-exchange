//
//  AppDelegate.swift
//  CurrencyExchange
//
//  Created by Alicja Smolikowska on 30/03/2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.backgroundColor = .red
        window?.rootViewController = CurrencyCounterViewController()
        return true
    }
}
