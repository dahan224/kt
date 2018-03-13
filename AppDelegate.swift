//
//  AppDelegate.swift
//  KT
//
//  Created by 이다한 on 2018. 1. 22..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import GoogleSignIn

import UserNotifications
import Alamofire
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
 
    

    var window: UIWindow?

    var serverURL: String?
    
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Initialize sign-in
//        FirebaseApp.configure()
//        Messaging.messaging().remoteMessageDelegate = self

        
        GIDSignIn.sharedInstance().clientID = "855259523788-p97fg9b2h94g9ghlv7btv90h60evnlnc.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        

        // iOS 10 support
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            application.registerForRemoteNotifications()
        }
            // iOS 9 support
        else if #available(iOS 9, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
            // iOS 8 support
        else if #available(iOS 8, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
            // iOS 7 support
        else {
            application.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
        }

        return true
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        NSLog("***************notification \(userInfo)")
        print("노티피케이션을 받았습니다. : \(userInfo)")
        if application.applicationState == .active {
            print("foreground")
        } else {
            print("background")
        }


        // Print full message.
        print(userInfo)
        
//        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        UserDefaults.standard.set(deviceTokenString, forKey: "notification_token")
        print( "노티피케이션 등록을 성공함, 디바이스 토큰 : \(deviceTokenString)" )
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        let starttime = Date()
        UserDefaults.standard.set(starttime, forKey: "backgroundtime")

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        let starttime = UserDefaults.standard.object(forKey: "backgroundtime")
        
        let endtime = Date()
        
        //간격 초
        let gaptime:Double  = endtime.timeIntervalSince(starttime as! Date)
        
        print(gaptime)
        
        if((gaptime/60/60) > 3) {
            
            // app 버젼 확인
            appVerCheck()
        }

    }
    func appVerCheck() {
        print("appVerCheck() in")
        
        let versioncheckURL:String = "https://araise.iptime.org/GIGA_StorageAdmin/apps/checkLatestApp.do"
        
        let bundleIdentifierS : String = String(describing:Bundle.main.bundleIdentifier)
        let versionNumberS : String = String(describing:Bundle.main.infoDictionary?["CFBundleVersion"])
        //let bundleIdentifierS : String = "com.posco.poscosoftman3"
        //let versionNumberS : String = "3.0.7"
        
        Alamofire.request(versioncheckURL
            , method: .post
            , parameters: ["os":"I", "identifier":"net.araise.oneview", "version":"1.0"]
            , encoding: URLEncoding.default
            , headers: ["Content-Type":"application/x-www-form-urlencoded"]
            ).validate(statusCode: 200..<300).responseJSON { response in
                
                switch response.result {
                case .success (let value):
                    let json = JSON(value)
                    print("JSON: \(json)")
                    print(json["downloadUrl"])
                    //print(json["fileName"])
                    print(json["latest"])
                    let downloadUrl = "https://araise.iptime.org/GIGA_StorageAdmin/apps/makePlist.do?appId=6"
                    if json["latest"] == "N" {
                        // self.appUgradeconfirm(param1: String(describing:json["fileName"]),param2: String(describing:json["downloadUrl"]))
                        self.appUgradeconfirm(param1: String(describing:json["fileName"]),param2: downloadUrl)
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    func appUgradeconfirm(param1 fileName:String, param2 downloadUrl:String){
        print(downloadUrl)
        
        let alert = UIAlertController(title: "업데이트 알림", message:"새로운 버젼이 있습니다.\n 업데이트 하시겠습니까?", preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "지금 업데이트", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
            print("Handle 지금 업데이트")
            self.serverURL = "location.href ='itms-services://?action=download-manifest&url='+encodeURIComponent('" + downloadUrl+"');"
            self.appupopen()
        }))
        alert.addAction(UIAlertAction(title: "나중에", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
            print("Handle 나중에")
        }))
        
        // show the alert
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func appupopen() {
        let notificationName = Notification.Name("updateWebView")
        NotificationCenter.default.post(name: notificationName, object: nil)
    }

    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        let defaults = UserDefaults.standard
        defaults.set("no", forKey: "googleDriveLoginState")
        
        
    }
  
    
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String
        let annotation = options[UIApplicationOpenURLOptionsKey.annotation]
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
}

