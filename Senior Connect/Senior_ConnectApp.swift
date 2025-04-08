//
//  Senior_ConnectApp.swift
//  Senior Connect
//
//  Created by SUN TAM on 16/11/2024.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import SwiftUI
import SwiftData
import FBSDKCoreKit


import UIKit
import Firebase
import FBSDKCoreKit

class AppDelegate: NSObject, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase
        //FirebaseApp.configure()
        
        // Initialize Facebook SDK
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Set the Facebook App ID and display name programmatically
        Settings.shared.appID = "531374033193485"
        Settings.shared.displayName = "Senior Connect"
        
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if Auth.auth().canHandle(url) {
            return true
        }
        
        // Handle Facebook URL
        if ApplicationDelegate.shared.application(app, open: url, options: options) {
            return true
        }
        
        // Handle other URLs
        return false
    }

    // Handle remote notifications
    func application(_ application: UIApplication,
                    didReceiveRemoteNotification notification: [AnyHashable : Any],
                    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
            return
        }
        // Handle other notifications if needed
        completionHandler(.noData)
    }


    // Handle remote notification registration
    func application(_ application: UIApplication,
                    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Auth.auth().setAPNSToken(deviceToken, type: .prod)
    }

    func application(_ application: UIApplication,
                    didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
}
@Model
final class Event {
    var id = UUID()
    var title: String
    var category: String
    var date: Date
    var time: String
    var location: String
    var des: String
    var rating: Int
    var saved: Bool
    
    // Include all properties in the initializer
    init(title: String, category: String, date: Date, time: String, location: String, des: String, rating: Int, saved: Bool = false) {
        self.title = title
        self.category = category
        self.date = date
        self.time = time
        self.location = location
        self.des = des
        self.rating = rating
        self.saved = saved
    }
    
}


@main
struct Senior_ConnectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var sharedModelContainer: ModelContainer = {
         let schema = Schema([
             Event.self,
         ])
         let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
         
         do {
             return try ModelContainer(for: schema, configurations: [modelConfiguration])
             
         } catch {
             fatalError("Could not create ModelContainer: \(error)")
         }
     }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
