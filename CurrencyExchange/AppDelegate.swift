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
        let navigationController = UINavigationController()
        let mainViewController = CurrencyCounterViewController(viewModel: CurrencyCounterViewModel())
        navigationController.viewControllers = [mainViewController]
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }
}

