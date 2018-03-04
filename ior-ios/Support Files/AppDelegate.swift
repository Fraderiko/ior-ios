//
//  AppDelegate.swift
//  ior-ios
//
//  Created by me on 19/10/2017.
//  Copyright © 2017 home. All rights reserved.
//

import UIKit
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        if let type = Settings.userType() {
            if type == .OrderDetails {
                window?.rootViewController = UINavigationController(rootViewController: OrderForRecepientViewController())
            } else {
                let tabBarContoller = UITabBarController()
                let profile = UINavigationController(rootViewController: ProfileViewController())
                let orders = UINavigationController(rootViewController: OrderListViewController())
                let favorites = UINavigationController(rootViewController: OrderListViewController(favMode: true))
                let feedback = UINavigationController(rootViewController: TextViewViewController(value: "", mode: .Feedback, title: "Поддержка"))
                
                let controllers = [orders, favorites, profile, feedback]
                tabBarContoller.viewControllers = controllers
                
                profile.tabBarItem = UITabBarItem(title: "Профиль", image: UIImage(named: "profile"), tag: 0)
                orders.tabBarItem = UITabBarItem(title: "Заказы", image: UIImage(named: "orders"), tag: 1)
                favorites.tabBarItem = UITabBarItem(title: "Избранные", image: UIImage(named: "star-tab"), tag: 2)
                feedback.tabBarItem = UITabBarItem(title: "Поддержка", image: UIImage(named: "support"), tag: 3)
                window?.rootViewController = tabBarContoller
            }
        } else {
            window?.rootViewController = LoginViewController()
        }
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "50f12693-ffef-48b7-ba86-0e38607dbe31",
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
            
        })

        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .badge, .sound])
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if (application.applicationState == .active) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pushReceived"), object: nil)
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

