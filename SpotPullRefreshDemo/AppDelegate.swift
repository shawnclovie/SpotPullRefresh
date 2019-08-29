//
//  AppDelegate.swift
//  SpotPullRefreshDemo
//
//  Created by Shawn Clovie on 14/8/2019.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		let window = UIWindow(frame: UIScreen.main.bounds)
		window.rootViewController = ViewController(nibName: nil, bundle: nil)
		self.window = window
		window.makeKeyAndVisible()
		return true
	}
}
