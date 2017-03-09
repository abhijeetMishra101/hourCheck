//
//  AppDelegate.swift
//  hourCheck
//
//  Created by Abhijeet Mishra on 22/02/17.
//  Copyright © 2017 Abhijeet Mishra. All rights reserved.
//

import UIKit
import UserNotifications

enum NotificationAction:String {
    case ShowMe = "showMe"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    
    func removeAllLocalNotifications()  {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func scheduleNotification (at date:Date, message:String)  {

        UNUserNotificationCenter.current().delegate = self
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: date)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = "Hourly Check!"
        content.body = message
        content.sound = UNNotificationSound.default()
        
        //attaching the image
        if let path = Bundle.main.path(forResource: "clock", ofType: "png") {
            let url = URL.init(fileURLWithPath: path)
            
            do {
                let attachment = try UNNotificationAttachment.init(identifier: "clock", url: url, options: nil)
                content.attachments = [attachment]
            } catch  {
                print("attachment loading failed")
            }
        }
        
        let request = UNNotificationRequest(identifier:String(describing: date), content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case NotificationAction.ShowMe.rawValue:
            //TODO:: Handle showMe notification
           print("showMe notification received")
            break
        default: break
            
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
       
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (success, error) in
            if !success {
                print("No access given")
            }
        }
        //add action
        let showMeAction = UNNotificationAction.init(identifier: NotificationAction.ShowMe.rawValue, title: "Show Me", options: UNNotificationActionOptions.authenticationRequired)
        let showMeCatogry = UNNotificationCategory.init(identifier: NotificationAction.ShowMe.rawValue, actions: [showMeAction], intentIdentifiers: [], options: UNNotificationCategoryOptions.customDismissAction)
        UNUserNotificationCenter.current().setNotificationCategories([showMeCatogry])
        
        return true
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
        
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                print("My request" + String(describing: request))
            }
        })
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

