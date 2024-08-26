//
//  AppDelegate.swift
//  GoogleMap_Demo
//
//  Created by jeremy on 2024/8/24.
//

import UIKit
import GoogleMaps

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  private var services: Any?
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    GMSServices.provideAPIKey(SDKConstants.apiKey)
    // Metal is the preferred renderer.
    GMSServices.setMetalRendererEnabled(true)
    services = GMSServices.sharedServices()
    
    window = UIWindow(frame:UIScreen.main.bounds)
    let detailController = ViewController.init()
    let navigationController = UINavigationController(rootViewController: detailController)
    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()
    return true
  }
}

