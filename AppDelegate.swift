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
    
    struct Connectivity {
        static let sharedInstance = NetworkReachabilityManager()!
        static var isConnectedToInternet:Bool {
            return self.sharedInstance.isReachable
        }
    }
    
    
    var backgroundTask:UIBackgroundTaskIdentifier?
    var window: UIWindow?
    
    var serverURL: String?
    var notificationOnGoing = false
    var appPlayYn = "N"
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Initialize sign-in
        //        FirebaseApp.configure()
        //        Messaging.messaging().remoteMessageDelegate = self
        
        
        GIDSignIn.sharedInstance().clientID = "855259523788-p97fg9b2h94g9ghlv7btv90h60evnlnc.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        
        appVerCheck()
        
        
        // iOS 10 support
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            application.registerForRemoteNotifications()
            print(" iOS 10 support")
        } else if #available(iOS 9, *) {
            // iOS 9 support
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
            print(" iOS 9 support")
        } else if #available(iOS 8, *) {
            // iOS 8 support
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
            print(" iOS 8 support")
        } else {
            // iOS 7 support
            print(" iOS 7 support")
            application.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
        }
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
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
                    let json = JSON(data!)
                    print("json : \(json)")
                    //                    let fromFileId = json["fromFileId"].string
                    let toDevUuid:String = json["toDevUuid"].stringValue
                    let fromFileNm:String = json["fromFileNm"].stringValue
                    let fromDevUuid:String = json["fromDevUuid"].stringValue
                    let toUserId:String = json["toUserId"].stringValue
                    let toFoldr:String = json["toFoldr"].stringValue
                    let queId:String = json["queId"].stringValue
                    let intFileId = json["fromFileId"].intValue
                    let fromFileId = String(describing: intFileId)
                    let fromFoldr = json["fromFoldr"].stringValue
                    let toOsCd = json["toOsCd"].stringValue
                    let fromUserId = json["fromUserId"].stringValue
                    let fromOsCd = json["fromOsCd"].stringValue
                    appPlayYn = json["appPlay"].stringValue
                    
                    if(toDevUuid == Util.getUuid()){
                        print("fromFileNm: \(fromFileNm), fromFileId: \(fromFileId)")
                        if let remoteDownLoadStyle = UserDefaults.standard.string(forKey: "remoteDownLoadStyle") {
                            print("remoteDownLoadStyle : \(remoteDownLoadStyle)")
                            switch remoteDownLoadStyle {
                            case "remoteDownLoad":
                                let path = "\(fromDevUuid)/\(fromFoldr)"
                                
                                if(!notificationOnGoing){
                                    notificationOnGoing = true
                                    print("noti get")
                                    downloadFromRemote(userId: fromUserId, name: fromFileNm, path: path, fileId: fromFileId)
                                }
                                
                                break
                                
                            case "remoteDownLoadToNas" :
                                let fileDict = ["fromUserId": fromUserId, "fromFileNm": fromFileNm, "fromFoldr": fromFoldr, "fromFileId": fromFileId, "queId":queId, "fromDevUuid":fromDevUuid,"fromOsCd":fromOsCd]
                                NotificationCenter.default.post(name: Notification.Name("downloadFromRemoteToNas"), object: self, userInfo: fileDict)
                                
                            case "remoteDownLoadToExcute":
                                
                                let path = "\(fromDevUuid)/\(fromFoldr)"
                                // let fileDict = ["fromUserId": fromUserId, "fromFileNm": fromFileNm, "fromFoldr": fromFoldr, "fromFileId": fromFileId]
                                downloadFromRemoteToExcute(userId: fromUserId, name: fromFileNm, path: path, fileId: fromFileId)
                                
                                
                            case "remoteDownLoadMulti":
                                //let fileDict = ["fromUserId": fromUserId, "fromFileNm": fromFileNm, "fromFoldr": fromFoldr, "fromFileId": fromFileId, "fromDevUuid":fromDevUuid]
                                let path = "\(fromDevUuid)/\(fromFoldr)"
                                
                                if(!notificationOnGoing){
                                    //                                    notificationOnGoing = true
                                    print("noti get")
                                    downloadFromRemoteMulti(userId: fromUserId, name: fromFileNm, path: path, fileId: fromFileId)
                                    //                                    downloadFromRemote(userId: fromUserId, name: fromFileNm, path: path, fileId: fromFileId)
                                }
                                
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
                        
                        print("toOsCd : \(toOsCd)" )
                        print("fromFileNm: \(fromFileNm), fromFileId: \(fromFileId)")
                        if(toOsCd == "G" || toOsCd == "S"){
                            let fileUrl:URL = FileUtil().getFileUrlWithFoldr(fileNm: fromFileNm, foldrWholePathNm: "/Mobile", amdDate: "self.amdDate")!
                            sendToNasFromLocal(url: fileUrl, name: fromFileNm, toOsCd:toOsCd, fileId: fromFileId, toUserId: toUserId, newFoldrWholePathNm:toFoldr)
                        } else {
                            
                            showFileInfo(fileId: fromFileId, fileNm:fromFileNm, queId:queId, fromFoldr:fromFoldr, fromDevUuid:fromDevUuid)
                        }
                        
                    }
                    
                }
            }
            
        } else {
            print("background")
            
            
            if let aps = userInfo["aps"] as? NSDictionary {
                if let dataString = aps["data"] as? String {
                    print("\(dataString)")
                    let data = dataString.data(using: .utf8, allowLossyConversion: false)
                    let json = JSON(data!)
                    //                    let fromFileId = json["fromFileId"].string
                    let fromFileNm:String = json["fromFileNm"].stringValue
                    //let fromDevUuid:String = json["fromDevUuid"].stringValue
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
                    
                    if UserDefaults.standard.bool(forKey: "syncOngoing") {
                        print("aleady Syncing")
                    } else {
                        SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
                    }
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: nil, message: "파일 다운로드를 성공하였습니다.", preferredStyle: .alert)
                        //                        let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel)
                        let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                            UIAlertAction in
                            self.notificationOnGoing = false
                        }
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
                print("fileAmdDate : \(amdDate), fromFoldr: \(fromFoldr)")
                //                let fileUrl:URL = FileUtil().getFileUrl(fileNm: fileNm, amdDate: amdDate)!
                if let fileUrl:URL = FileUtil().getFileUrlWithFoldr(fileNm: fileNm, foldrWholePathNm: fromFoldr, amdDate: amdDate) {
                    self.createTmpFolder(fileUrl: fileUrl, name: fileNm, queId: queId, fromFoldr:fromFoldr, fromDevUuid:fromDevUuid)
                }
                
                //                self.sendToNasFromLocalForDownload(url: fileUrl, name: fileNm, queId: queId, fromFoldr:fromFoldr, fromDevUuid:fromDevUuid)
            }
            return
        }
    }
    func createTmpFolder(fileUrl:URL, name:String, queId:String, fromFoldr:String,fromDevUuid:String){
        let userId = App.defaults.userId
        let password:String = UserDefaults.standard.string(forKey: "userPassword")!
        
        let credentialData = "\(App.nasFoldrFrontNm)\(App.defaults.userId):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        let headers = [
            "Authorization": "Basic \(base64Credentials)",
            "x-isi-ifs-target-type":"container"
        ]
        print("headers : \(headers)")
        var stringUrl = "\(App.URL.nasServer)\(App.nasFoldrFrontNm)\(userId)/\(fromDevUuid)\(fromFoldr)?recursive=true"
        stringUrl = stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        print("stringUrl : \(stringUrl)" )
        
        Alamofire.request(stringUrl,
                          method: .put,
                          encoding : JSONEncoding.default,
                          headers: headers).responseJSON { response in
                            
                            let statusCode = (response.response?.statusCode)! //example : 200
                            print("create folder status code : \(statusCode)")
                            
                            if statusCode == 200 || statusCode == 204 {
                                self.sendToNasFromLocalForDownload(url: fileUrl, name: name, queId: queId, fromFoldr:fromFoldr, fromDevUuid:fromDevUuid)
                            } else {
                                // 실패
                            }
                            
        }
    }
    
    
    func sendToNasFromLocalForDownload(url:URL, name:String, queId:String, fromFoldr:String,fromDevUuid:String){
        
        let userId = App.defaults.userId
        let password:String = UserDefaults.standard.string(forKey: "userPassword")!
        
        let credentialData = "\(App.nasFoldrFrontNm)\(App.defaults.userId):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        let headers = [
            "Authorization": "Basic \(base64Credentials)",
            "x-isi-ifs-target-type":"object"
            
        ]
        
        print("headers : \(headers)")
        var stringUrl = "\(App.URL.nasServer)\(App.nasFoldrFrontNm)\(userId)/\(fromDevUuid)\(fromFoldr)/\(name)?overwrite=true"
        stringUrl = stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        print("stringUrl : \(stringUrl)" )
        
        let filePath = url.path
        let fileExtension = url.pathExtension
        print("fileExtension : \(fileExtension)")
        print("file path : \(filePath)")
        

        
        var fileSize = 0.0
        do {
            let attribute = try FileManager.default.attributesOfItem(atPath: filePath)
            if let size = attribute[FileAttributeKey.size] as? NSNumber {
                fileSize =  size.doubleValue / 1000000.0
            }
        } catch {
            print("Error: \(error)")
        }
        print("FILE Yes AVAILABLE")
        print("stream upload, fileSize : \(fileSize)")
        
        let stream:InputStream = InputStream(url: url)!
        let newName = name.precomposedStringWithCanonicalMapping
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            //                    multipartFormData.append(url, withName: encodedSavedFileName)
            multipartFormData.append(stream, withLength: UInt64(fileSize), name: "file", fileName: newName, mimeType: fileExtension)
            
        }, usingThreshold: UInt64.init(), to: stringUrl, method: .put, headers: headers,
           encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    let statusCode = (response.response?.statusCode)! //example : 200
                    print("statusCode : \(statusCode), response : \(response)")
                    if(statusCode == 200) {
                        self.notifyNasUploadFinishToRemoteDownload(name: newName, queId:queId)
                    }
                }
                upload.uploadProgress { progress in
                    
                    print(progress.fractionCompleted)
                }
                break
            case .failure(let encodingError):
                print(encodingError.localizedDescription)
                
                break
            }
        })
        
    }
    
    func notifyNasUploadFinishToRemoteDownload(name:String, queId:String){
        let urlString = App.URL.hostIpServer+"upldCmplt.do"
        let jsonHeader:[String:String] = [
            "Content-Type": "application/json",
            "X-Auth-Token": UserDefaults.standard.string(forKey: "token") ?? "nil",
            "Cookie": UserDefaults.standard.string(forKey: "cookie") ?? "nil"
        ]
        let paramas:[String : Any] = ["queId":queId,"nasStatusCode":"100","appPlay":appPlayYn]
        print("notifyNasUploadFinish param : \(paramas)")
        Alamofire.request(urlString,
                          method: .post,
                          parameters: paramas,
                          encoding : JSONEncoding.default,
                          headers: jsonHeader).responseJSON { response in
                            let statusCode = (response.response?.statusCode)! //example : 200
                            print("notifyNasUploadFinishToRemoteDownload  status code : \(statusCode)")
                            
                            if statusCode == 200 {
                                if let task = self.backgroundTask {
                                    self.endBackgroundTask(taskID: task)
                                }
                            }
        }
    }
    
    func sendToNasFromLocal(url:URL, name:String, toOsCd:String, fileId:String, toUserId:String, newFoldrWholePathNm:String){
        
        let password:String = UserDefaults.standard.string(forKey: "userPassword")!
        let loginUserId = UserDefaults.standard.string(forKey: "userId")
        var userId:String = toUserId
        if(toUserId.isEmpty){
            userId = loginUserId!
        }
        
        print("loginUserId : \(String(describing: loginUserId!))")
        let credentialData = "\(App.nasFoldrFrontNm)\(String(describing: loginUserId!)):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        
        let decodedData = Data(base64Encoded: base64Credentials)!
        let decodedString = String(data: decodedData, encoding: .utf8)!
        print("decodedString : \(decodedString)")
        
        var headers = [
            "Authorization": "Basic \(base64Credentials)",
            "x-isi-ifs-target-type":"object"
            
        ]
        if(toOsCd != "G"){
            headers = [
                "Authorization": "Basic \(base64Credentials)",
                "x-isi-ifs-target-type":"object",
                "x-isi-ifs-access-control":"770"
                
            ]
        }
        print("headers : \(headers)")
        var stringUrl = "\(App.URL.nasServer)\(App.nasFoldrFrontNm)\(userId)/\(userId)-gs\(newFoldrWholePathNm)/\(name)?overwrite=true"
        stringUrl =  stringUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let filePath = url.path
        let fileExtension = url.pathExtension
        
        var fileSize = 0.0
        do {
            let attribute = try FileManager.default.attributesOfItem(atPath: filePath)
            if let size = attribute[FileAttributeKey.size] as? NSNumber {
                fileSize =  size.doubleValue / 1000000.0
            }
        } catch {
            print("Error: \(error)")
        }
//        print("FILE Yes AVAILABLE")
//        print("stream upload, fileSize : \(fileSize)")
        
        let stream:InputStream = InputStream(url: url)!
        let newName = name.precomposedStringWithCanonicalMapping
        Alamofire.upload(multipartFormData: { multipartFormData in
            //                    multipartFormData.append(url, withName: encodedSavedFileName)
            multipartFormData.append(stream, withLength: UInt64(fileSize), name: "file", fileName: newName, mimeType: fileExtension)
            
        }, usingThreshold: UInt64.init(), to: stringUrl, method: .put, headers: headers,
           encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    let statusCode = (response.response?.statusCode)! //example : 200
                    print("statusCode : \(statusCode), response : \(response)")
                    if(statusCode == 200) {
                        self.notifyNasUploadFinish(name: newName, toOsCd:toOsCd, fileId:fileId, toUserId:toUserId, toFoldr:newFoldrWholePathNm)
                    }
                }
                upload.uploadProgress { progress in
                    
                    print(progress.fractionCompleted)
                }
                break
            case .failure(let encodingError):
                print(encodingError.localizedDescription)
                
                break
            }
        })
    }
    
    
    
    func notifyNasUploadFinish(name:String, toOsCd:String, fileId:String, toUserId:String, toFoldr:String){
        let urlString = App.URL.hostIpServer+"nasUpldCmplt.do"
        var jsonHeader:[String:String] = [
            "Content-Type": "application/json",
            "X-Auth-Token": UserDefaults.standard.string(forKey: "token")!,
            "Cookie": UserDefaults.standard.string(forKey: "cookie")!
        ]
        
        
        let paramas:[String : Any] = ["userId":toUserId,"fileId":fileId,"toFoldr":toFoldr,"toFileNm":name,"toOsCd":toOsCd]
        print("notifyNasUploadFinish param : \(paramas)")
        Alamofire.request(urlString,
                          method: .post,
                          parameters: paramas,
                          encoding : JSONEncoding.default,
                          headers: jsonHeader).responseJSON { response in
                            switch response.result {
                            case .success(let JSON):
                                
                                print(response.result.value)
                                let responseData = JSON as! NSDictionary
                                let message = responseData.object(forKey: "message")
                                print("message : \(message)")
                                
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
        
        let versioncheckURL:String = App.URL.appCheck
        
        let bundleIdentifierS : String = (Bundle.main.bundleIdentifier)!
        let versionNumberS : String = (Bundle.main.infoDictionary?["CFBundleShortVersionString"]) as! String
        
        Alamofire.request(versioncheckURL
            , method: .post
            , parameters: ["os":"I", "identifier":bundleIdentifierS, "version":versionNumberS]
            , encoding: URLEncoding.default
            , headers: ["Content-Type":"application/x-www-form-urlencoded"]
            ).validate(statusCode: 200..<300).responseJSON { response in
                
                switch response.result {
                case .success (let value):
                    let json = JSON(value)
                    print("JSON: \(json)")
                    print(json["downloadUrl"])
                    print(json["fileName"])
                    print(json["latest"])
                    let downloadUrl = json["downloadUrl"].string!
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
        let time = DispatchTime.now() + .seconds(3)
        DispatchQueue.main.asyncAfter(deadline: time) {
            exit(0)
        }
    }
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if Connectivity.isConnectedToInternet {
            print("Connected")
            
        } else {
            print("No Internet")
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: "네트워크 연결이 차단 되었습니다.", message: "네트워크 연결 상태를 확인 후\n다시 실행해 주세요.", preferredStyle: .alert)
                let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    
                    
                    print("finish")
                    exit(0)
                }
                alertController.addAction(yesAction)
                let alertWindow = UIWindow(frame: UIScreen.main.bounds)
                alertWindow.rootViewController = UIViewController()
                alertWindow.windowLevel = UIWindowLevelAlert + 1;
                alertWindow.makeKeyAndVisible()
                alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
                
            }
        }
    }
    
    func deviceOff(){
        NSLog("+=+=+=1")
        let cookie:String = UserDefaults.standard.string(forKey: "cookie")!
        let token:String = UserDefaults.standard.string(forKey: "token")!
        let urlString = App.URL.hostIpServer+"devStatusUpdate.do"
        let headers = [
            "Content-Type": "application/json",
            "X-Auth-Token": token,
            "Cookie": cookie
        ]
        let params:[String:Any] = ["userId": App.defaults.userId, "devUuid":Util.getUuid(), "onoff":"N"]
        print("cookie: \(cookie), token : \(token)")
        Alamofire.request(urlString,
                          method: .post,
                          parameters : params,
                          encoding : JSONEncoding.default,
                          headers: headers).responseJSON { response in
                            switch response.result {
                            case .success(let JSON):
                                NSLog("+=+=+=")
                                NSLog(response.result.value as Any as! String)
                                let responseData = JSON as! NSDictionary
                                let message = responseData.object(forKey: "message")
                                print("message : \(String(describing: message))")
                                
                                NotificationCenter.default.post(name: NSNotification.Name("dismissContainerView"), object: nil)
                                UserDefaults.standard.set(false, forKey: "autoLoginCheck")
                                break
                            case .failure(let error):
                                
                                print(error)
                            }
        }
        
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("applicationWillTerminate")
        deviceOff()
        let defaults = UserDefaults.standard
        defaults.set("no", forKey: "googleDriveLoginState")
        GIDSignIn.sharedInstance().signOut()
        
        
        
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

