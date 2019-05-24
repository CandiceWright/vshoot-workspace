//
//  AppDelegate.swift
//  VShootApplication
//
//  Created by Princess Candice on 7/28/18.
//  Copyright © 2018 Candice Wright. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("I am in app  delegate")
        //SocketIOManager.sharedInstance.establishConnection()
        FirebaseApp.configure()
        
        // Define the custom actions.
        let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION",
                                                title: "Accept",
                                                options: .foreground)
        let declineAction = UNNotificationAction(identifier: "DECLINE_ACTION",
                                                 title: "Decline",
                                                 options: UNNotificationActionOptions(rawValue: 0))
        // Define the notification type
        let vshootReqCat = UNNotificationCategory(identifier: "VSHOOT_REQUEST",
                                   actions: [acceptAction, declineAction],
                                   intentIdentifiers: [],
                                   hiddenPreviewsBodyPlaceholder: "",
                                   options: .customDismissAction)
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.badge, .alert, .sound], completionHandler: {(granted, error) in })
        center.setNotificationCategories([vshootReqCat])
        application.registerForRemoteNotifications()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        SocketIOManager.sharedInstance.socket.emit("goingToBackground", SocketIOManager.sharedInstance.currUserObj.username)
        
        SocketIOManager.sharedInstance.socket.disconnect()
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.

        
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        print("inside of did become active")
        print(SocketIOManager.sharedInstance.currUserObj.username)
        if (SocketIOManager.sharedInstance.currUserObj.username != ""){ //someone is logged in
            print("user is logged in so I am establishing connection again")
            SocketIOManager.sharedInstance.establishConnection(username: SocketIOManager.sharedInstance.currUserObj.username, fromLogin: false, completion: {
                print("successfully established connection")
            })
        }
       

        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    /******** user notification funcs *******/
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        //let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        //print("success in registering for remote notifications with token \(deviceTokenString)")
        
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("failed to register for remote notifications: \(error.localizedDescription)")
        
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("Received push notification: \(userInfo)")
        let aps = userInfo["aps"] as! [String: Any]
        print("\(aps)")
        print(aps["category"]!)
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    {
        print("in didreceive")
        print(response)
        
        switch response.actionIdentifier {
        case "ACCEPT_ACTION":
            print("accepted")
            if (SocketIOManager.sharedInstance.currUserObj.username == ""){
                
            }
            break
            
        case "DECLINE_ACTION":
           print("declined")
            break
        
        default:
            break
        }
        
        completionHandler()
    }


}

