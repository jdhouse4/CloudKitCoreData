//
//  AppDelegate.swift
//  CloudKitCoreData
//
//  Created by James Hillhouse IV on 3/6/19.
//  Copyright © 2019 PortableFrontier. All rights reserved.
//

import UIKit
import CloudKit
import UserNotifications




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate
{

    var window: UIWindow?


    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        // Override point for customization after application launch.


        // UIUserNotificationSettings was depricated in iOS 10. If you want to support pre-iOS 10 users,
        // you'll need to add an #available statement for iOS 10, else...
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate     = self

        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (authorized, error) in

            guard error == nil else {
                print("notificationCenter.requestAuthorization returns error: \(String(describing: error))")

                return
            }

            if authorized {
                print("notificationCenter.requestAuthorization is granted!")

                // Register for RemoteNotifications. Your Remote Notifications can display alerts now :)
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
            else {
                print("notificationCenter.requestAuthorization is not granted!")
            }
        }

        // Register for remote notifications.. If permission above is NOT granted, all notifications are delivered silently to AppDelegate.
        application.registerForRemoteNotifications()

        application.applicationIconBadgeNumber  = 0

        return true
    }



    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {

        print("\n\n*** Just received a remote notification. Yipeee! ****\n\n")

        //if let pushInfo = userInfo as? [String: NSObject]
        if ((userInfo as? [String: NSObject]) != nil)
        {
            print("userInfo exists as non-nil. Yea!!! :-)")

            let alertController     = UIAlertController(title: "Country Information Updated", message: "Country information was updated.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

            if let navigationController = self.window?.rootViewController as? UINavigationController
            {
                if let viewController       = navigationController.visibleViewController as? CountriesTableViewController
                {
                    viewController.present(alertController, animated: true, completion: nil)

                    print("\nAppDelegate application(_:, didReceiveRemoteNotification userInfo:, completionHandler:")
                    print("***Getting ready to retrieve launch data via viewController.getLaunchesData()***\n")
                    //viewController.getLaunchesData()
                }
            }
        }
        else
        {
            print("No pushInfo or userInfo exists. :-(")
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

