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
 
   
    
    var backgroundTask:UIBackgroundTaskIdentifier?
    var window: UIWindow?

    var serverURL: String?
    var notificationOnGoing = false
    
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
            
            if let aps = userInfo["aps"] as? NSDictionary {
                if let dataString = aps["data"] as? String {
                    print("\(dataString)")
                    let data = dataString.data(using: .utf8, allowLossyConversion: false)
                    let json = JSON(data)
//                    let fromFileId = json["fromFileId"].string
                    let toDevUuid:String = json["toDevUuid"].stringValue
                    if(toDevUuid == Util.getUuid()){
                        let fromUserId = json["fromUserId"].stringValue
                        let fromFoldr = json["fromFoldr"].stringValue
                        let fromFileNm = json["fromFileNm"].stringValue
                        let fromFileId = json["fromFileId"].stringValue
                        let fromDevUuid:String = json["fromDevUuid"].stringValue
                        let fromOsCd = json["fromOsCd"].stringValue
                        let queId:String = json["queId"].stringValue
                        print("fromFileNm: \(fromFileNm), fromFileId: \(fromFileId)")
                        if let remoteDownLoadStyle = UserDefaults.standard.string(forKey: "remoteDownLoadStyle") {
                            print("remoteDownLoadStyle : \(remoteDownLoadStyle)")
                            switch remoteDownLoadStyle {
                            case "remoteDownLoad":
                                let path = "\(fromDevUuid)\(fromFoldr)"
                                let fileDict = ["fromUserId": fromUserId, "fromFileNm": fromFileNm, "fromFoldr": fromFoldr, "fromFileId": fromFileId]
                                downloadFromRemote(userId: fromUserId, name: fromFileNm, path: path, fileId: fromFileId)
                                break
                                
                            case "remoteDownLoadToNas" :
                                let fileDict = ["fromUserId": fromUserId, "fromFileNm": fromFileNm, "fromFoldr": fromFoldr, "fromFileId": fromFileId, "queId":queId, "fromDevUuid":fromDevUuid,"fromOsCd":fromOsCd]
                                NotificationCenter.default.post(name: Notification.Name("downloadFromRemoteToNas"), object: self, userInfo: fileDict)
                                
                            case "remoteDownLoadToExcute":
                                
                                let path = "\(fromDevUuid)\(fromFoldr)"
                                let fileDict = ["fromUserId": fromUserId, "fromFileNm": fromFileNm, "fromFoldr": fromFoldr, "fromFileId": fromFileId]
                                downloadFromRemoteToExcute(userId: fromUserId, name: fromFileNm, path: path, fileId: fromFileId)
                                
                                
                            case "remoteDownLoadMulti":
                                let fileDict = ["fromUserId": fromUserId, "fromFileNm": fromFileNm, "fromFoldr": fromFoldr, "fromFileId": fromFileId, "fromDevUuid":fromDevUuid]
                                let path = "\(fromDevUuid)\(fromFoldr)"
                                downloadFromRemoteMulti(userId: fromUserId, name: fromFileNm, path: path, fileId: fromFileId)
                                break
                            case "remoteDownLoadNasMulti":
                                
                                let fileDict = ["fromUserId": fromUserId, "fromFileNm": fromFileNm, "fromFoldr": fromFoldr, "fromFileId": fromFileId, "queId":queId, "fromDevUuid":fromDevUuid,"fromOsCd":fromOsCd]
                                NotificationCenter.default.post(name: Notification.Name("downloadFromRemoteToNas"), object: self, userInfo: fileDict)
                                
                                break
                            
                                
                            default:
                                
                                break
                            }
                           
                        }
                        
                        
                    } else {
                        let fromFileNm:String = json["fromFileNm"].stringValue                        
                        let fromDevUuid:String = json["fromDevUuid"].stringValue
                        let queId:String = json["queId"].stringValue
                        let intFileId = json["fromFileId"].intValue
                        let fromFileId = String(describing: intFileId)
                        let fromFoldr = json["fromFoldr"].stringValue
                        print("fromFileNm: \(fromFileNm), fromFileId: \(fromFileId)")
                        showFileInfo(fileId: fromFileId, fileNm:fromFileNm, queId:queId, fromFoldr:fromFoldr, fromDevUuid:fromDevUuid)
                    }
                    
                }
            }
            
        } else {
            print("background")

            
            if let aps = userInfo["aps"] as? NSDictionary {
                if let dataString = aps["data"] as? String {
                    print("\(dataString)")
                    let data = dataString.data(using: .utf8, allowLossyConversion: false)
                    let json = JSON(data)
                    //                    let fromFileId = json["fromFileId"].string
                    let fromFileNm:String = json["fromFileNm"].stringValue
                    let fromDevUuid:String = json["fromDevUuid"].stringValue
                    let queId:String = json["queId"].stringValue
                    let intFileId = json["fromFileId"].intValue
                    let fromFileId = String(describing: intFileId)
                    let fromFoldr = json["fromFoldr"].stringValue
                    print("fromFileNm: \(fromFileNm), fromFileId: \(fromFileId)")
                    backgroundTask = self.beginBackgroundTask()
                    
                    showFileInfo(fileId: fromFileId, fileNm:fromFileNm, queId:queId, fromFoldr:fromFoldr, fromDevUuid:Util.getUuid())
                    //                    fromFileNm
                    //                    let fileUrl:URL = FileUtil().getFileUrl(fileNm: fromFileNm, amdDate: amdDate)
                    
                    
//                    completionHandler(.newData)
                }
            }
        }

        // Print full message.
//        print(userInfo)
    }
    
    func downloadFromRemote(userId:String, name:String, path:String, fileId:String){
        ContextMenuWork().downloadFromRemote(userId:userId, fileNm:name, path:path, fileId:fileId){ responseObject, error in
            if let success = responseObject {
                print(success)
                if(success == "success"){
                    SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: nil, message: "파일 다운로드를 성공하였습니다.", preferredStyle: .alert)
                        let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel)
                        alertController.addAction(yesAction)
                        print("download Success")
                        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
                        alertWindow.rootViewController = UIViewController()
                        alertWindow.windowLevel = UIWindowLevelAlert + 1;
                        alertWindow.makeKeyAndVisible()
                        alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
                    }
                }
            }
            return
        }
    }
    func downloadFromRemoteToExcute(userId:String, name:String, path:String, fileId:String){
        ContextMenuWork().downloadFromRemoteToExcute(userId:userId, fileNm:name, path:path, fileId:fileId){ responseObject, error in
            if let success = responseObject {
                print(success)
                 if(success.isEmpty){
                 } else {
                    print("localUrl : \(success)")
                    let url:URL = URL(string: success)!
                    let urlDict = ["url":url]
                    NotificationCenter.default.post(name: Notification.Name("openDocument"), object: self, userInfo: urlDict)
                }
            }
            return
        }
    }
    
    func downloadFromRemoteMulti(userId:String, name:String, path:String, fileId:String){
        ContextMenuWork().downloadFromRemote(userId:userId, fileNm:name, path:path, fileId:fileId){ responseObject, error in
            if let success = responseObject {
                print(success)
                if(success == "success"){
                    
                   NotificationCenter.default.post(name: Notification.Name("countRemoteDownloadFinished"), object: self)
                }
            }
            return
        }
    }
    
    func showFileInfoToNas(fromUserId:String, fileId:String, fileNm:String, queId:String, fromFoldr:String, fromDevUuid:String, fromOsCd:String){
        ContextMenuWork().getFileDetailInfo(fileId: fileId){ responseObject, error in
            let json = JSON(responseObject!)
            print("showFileInfo json : \(json)")
            if(json["fileData"].exists()){
                let fileData = json["fileData"]
                let amdDate = fileData["amdDate"].stringValue
                print("filNm: \(fileNm),fileAmdDate : \(amdDate)")

                self.downloadFromRemoteToNas(fromUserId: fromUserId, name: fileNm, path: fromFoldr, fileId: fileId, amdDate:amdDate, fromOsCd:fromOsCd, fromDevUuid:fromDevUuid, fromFoldr:fromFoldr)
            }
            return
        }
    }
    
    func downloadFromRemoteToNas(fromUserId:String, name:String, path:String, fileId:String, amdDate:String, fromOsCd:String, fromDevUuid:String, fromFoldr:String){
       print("downloadFromRemoteToNas")
        ContextMenuWork().downloadFromRemote(userId:fromUserId, fileNm:name, path:path, fileId:fileId){ responseObject, error in
            if let success = responseObject {
                print(success)
                if(success == "success"){
                    DispatchQueue.main.async {
                        let fileDict = ["fileId":fileId, "fileNm":name,"amdDate":amdDate, "oldFoldrWholePathNm":path,"state":"remote","fromUserId":fromUserId, "fromOsCd":fromOsCd, "fromDevUuid" : fromDevUuid, "fromFoldr" : fromFoldr]
                        print("fileDict : \(fileDict)")
                        SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
                        
                        NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
                    }
                }
            }
            return
        }
    }
    
    
    func beginBackgroundTask() -> UIBackgroundTaskIdentifier {
        return UIApplication.shared.beginBackgroundTask(expirationHandler: {})
    }
    
    func endBackgroundTask(taskID: UIBackgroundTaskIdentifier) {
        UIApplication.shared.endBackgroundTask(taskID)
    }
    
    func showFileInfo(fileId:String, fileNm:String, queId:String, fromFoldr:String, fromDevUuid:String){
        ContextMenuWork().getFileDetailInfo(fileId: fileId){ responseObject, error in
            let json = JSON(responseObject!)
            print("showFileInfo json : \(json)")
            if(json["fileData"].exists()){
                let fileData = json["fileData"]
                let amdDate = fileData["amdDate"].stringValue
                print("fileAmdDate : \(amdDate)")
                let fileUrl:URL = FileUtil().getFileUrl(fileNm: fileNm, amdDate: amdDate)!
                self.createTmpFolder(fileUrl: fileUrl, name: fileNm, queId: queId, fromFoldr:fromFoldr, fromDevUuid:fromDevUuid)
//                self.sendToNasFromLocalForDownload(url: fileUrl, name: fileNm, queId: queId, fromFoldr:fromFoldr, fromDevUuid:fromDevUuid)
            }
            return
        }
    }
    func createTmpFolder(fileUrl:URL, name:String, queId:String, fromFoldr:String,fromDevUuid:String){
        let userId = App.defaults.userId
        let password = "1234"
        
        let credentialData = "gs-\(App.defaults.userId):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        var headers = [
            "Authorization": "Basic \(base64Credentials)",
            "x-isi-ifs-target-type":"container"
        ]
        print("headers : \(headers)")
        var stringUrl = "https://araise.iptime.org/namespace/ifs/home/gs-\(userId)/\(fromDevUuid)\(fromFoldr)?recursive=true"
        stringUrl = stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        print("stringUrl : \(stringUrl)" )
        let parameters: [String: AnyObject] // fill in your params

        Alamofire.request(stringUrl,
                          method: .put,
                          encoding : JSONEncoding.default,
                          headers: headers).responseJSON { response in
                            print(response.result.value)
                            let statusCode = (response.response?.statusCode)! //example : 200
                            print("create folder status code : \(statusCode)")
                            switch response.result {
                            case .success(let JSON):
                                let responseData = JSON as! NSDictionary
                                let message = responseData.object(forKey: "message")
                                print("message : \(message)")
                                self.sendToNasFromLocalForDownload(url: fileUrl, name: name, queId: queId, fromFoldr:fromFoldr, fromDevUuid:fromDevUuid)
                                break
                            case .failure(let error):
                                print("create temp folder error : \(error.localizedDescription)")
                                self.sendToNasFromLocalForDownload(url: fileUrl, name: name, queId: queId, fromFoldr:fromFoldr, fromDevUuid:fromDevUuid)
                            }
        }
    }
    
    
    func sendToNasFromLocalForDownload(url:URL, name:String, queId:String, fromFoldr:String,fromDevUuid:String){
        
        let userId = App.defaults.userId
        let password = "1234"
        
        let credentialData = "gs-\(App.defaults.userId):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        var headers = [
            "Authorization": "Basic \(base64Credentials)",
            "x-isi-ifs-target-type":"object"
            
        ]
     
        print("headers : \(headers)")
        var stringUrl = "https://araise.iptime.org/namespace/ifs/home/gs-\(userId)/\(fromDevUuid)\(fromFoldr)/\(name)?overwrite=true"
        stringUrl = stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        print("stringUrl : \(stringUrl)" )
        
        let filePath = url.path
        let fileExtension = url.pathExtension
        print("fileExtension : \(fileExtension)")
        print("file path : \(filePath)")
        
        Alamofire.upload(url, to: stringUrl, method: .put, headers: headers)
            .uploadProgress { progress in // main queue by default
                print("Upload Progress: \(progress.fractionCompleted)")
                
            }
            .downloadProgress { progress in // main queue by default
                print("Download Progress: \(progress.fractionCompleted)")
            }
            .responseString { response in
//                print("Success: \(response.result.isSuccess)")
                print("Response String : \(response)")
                if let alamoError = response.result.error {
                    print("upload error : \(alamoError.localizedDescription)")
                    let alamoCode = alamoError._code
//                    let statusCode = (response.response?.statusCode)!
                } else { //no errors
                    let statusCode = (response.response?.statusCode)! //example : 200
                    print("statusCode : \(statusCode)")
                    self.notifyNasUploadFinishToRemoteDownload(name: name, queId:queId)
                    
                }
        }
    }
    
    func notifyNasUploadFinishToRemoteDownload(name:String, queId:String){
        let urlString = App.URL.server+"upldCmplt.do"
        var jsonHeader:[String:String] = [
            "Content-Type": "application/json",
            "X-Auth-Token": UserDefaults.standard.string(forKey: "token") ?? "nil",
            "Cookie": UserDefaults.standard.string(forKey: "cookie") ?? "nil"
        ]
        let paramas:[String : Any] = ["queId":queId,"nasStatusCode":"100"]
        print("notifyNasUploadFinish param : \(paramas)")
        Alamofire.request(urlString,
                          method: .post,
                          parameters: paramas,
                          encoding : JSONEncoding.default,
                          headers: jsonHeader).responseJSON { response in
                            let statusCode = (response.response?.statusCode)! //example : 200
                            print("notifyNasUploadFinishToRemoteDownload  status code : \(statusCode)")
                            switch response.result {
                            case .success(let JSON):
                                print(response.result.value)
                                let responseData = JSON as! NSDictionary
                                let message = responseData.object(forKey: "message")
                                print("message : \(message)")
                                if let task = self.backgroundTask {
                                        self.endBackgroundTask(taskID: task)
                                }
                                
                                break
                            case .failure(let error):
                                
                                print(error.localizedDescription)
                            }
        }
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
//        self.createInitialTmpFolder(fromFoldr: "/Mobile", fromDevUuid: Util.getUuid())
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
        GIDSignIn.sharedInstance().signOut()
        print("applicationWillTerminate")
        
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

