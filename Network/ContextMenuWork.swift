//
//  ContextMenuWork.swift
//  KT
//
//  Created by 이다한 on 2018. 3. 4..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ContextMenuWork {
    var upFoldersToDelete = ""
    var folderIdsToDownLoad:[Int] = []
    var folderIdsToUp:[Int] = []
    var folderPathToDownLoad:[String] = []
    var fileArrayToDownload:[App.FolderStruct] = []
    var foldersToDownLoad:[App.FolderStruct] = []
    var loginCookie = UserDefaults.standard.string(forKey: "cookie") ?? "nil"
    var loginToken = UserDefaults.standard.string(forKey: "token") ?? "nil"
    var jsonHeader:[String:String] = [
        "Content-Type": "application/json",
        "X-Auth-Token": UserDefaults.standard.string(forKey: "token") ?? "nil",
        "Cookie": UserDefaults.standard.string(forKey: "cookie") ?? "nil"
    ]
    var userId = UserDefaults.standard.string(forKey: "userId") as? String ?? "nil"
    var uuid = Util.getUuid()
    var selectedDevUuid = ""
    var selectedUserId = ""
    var selectedDeviceName = ""
    var rootFolderId = 0
    var rootFoldrWholePathNm = ""
    var upUpFolderId = 0
    var request: Alamofire.Request?
    
    func login(userId:String, password:String, completionHandler: @escaping (NSDictionary?, NSError?) -> ()){
        var params:[String:Any] = [String:Any]()
        params = ["userId":userId,"password":password]
        Alamofire.request(App.URL.server+"login.do"
            , method: .post
            , parameters:params
            , encoding : URLEncoding.default
            , headers: jsonHeader
            ).responseJSON { response in
                switch response.result {
                case .success(let value):
                    completionHandler(value as? NSDictionary, nil)
                    
                    break
                case .failure(let error):
                    NSLog(error.localizedDescription)
                    completionHandler(nil, error as NSError)
                    break
                }
        }
    }
    
    
    func getFileDetailInfo(fileId:String, completionHandler: @escaping (NSDictionary?, NSError?) -> ()){
        var params:[String:Any] = [String:Any]()
        params = ["userId":userId,"devUuid":uuid,"fileId":fileId]
        Alamofire.request(App.URL.server+"fileDtl.json"
            , method: .post
            , parameters:params
            , encoding : JSONEncoding.default
            , headers: jsonHeader
            ).responseJSON { response in
                switch response.result {
                    case .success(let value):
                        completionHandler(value as? NSDictionary, nil)
                        
                        break
                    case .failure(let error):
                        NSLog(error.localizedDescription)
                        completionHandler(nil, error as NSError)
                        break
                }
        }
    }
    func editFileTag(parameters:[[String:Any]], completionHandler: @escaping (NSDictionary?, NSError?) -> ()){
        var request = URLRequest(url: try! (App.URL.server+"nasFileTagUpdate.do").asURL())
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(loginToken, forHTTPHeaderField: "X-Auth-Token")
        request.setValue(loginCookie, forHTTPHeaderField: "Cookie")
        let values = parameters
        request.httpBody = try! JSONSerialization.data(withJSONObject: values)
        Alamofire.request(request).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                completionHandler(value as? NSDictionary, nil)
                
                break
            case .failure(let error):
                NSLog(error.localizedDescription)
                completionHandler(nil, error as NSError)
                break
            }
        }
    }
    func fromNasToNas(parameters:[String:Any], completionHandler: @escaping (NSDictionary?, NSError?) -> ()){
        Alamofire.request(App.URL.server+"nasFileCopy.do"
            , method: .post
            , parameters:parameters
            , encoding : JSONEncoding.default
            , headers: jsonHeader
            ).responseJSON { response in
                switch response.result {
                case .success(let value):
                    completionHandler(value as? NSDictionary, nil)
                    
                    break
                case .failure(let error):
                    NSLog(error.localizedDescription)
                    completionHandler(nil, error as NSError)
                    break
                }
        }
    }
  
    func fromNasToStorage(parameters:[String:Any], completionHandler: @escaping (NSDictionary?, NSError?) -> ()){
        Alamofire.request(App.URL.server+"shareNasFileCopy.do"
            , method: .post
            , parameters:parameters
            , encoding : JSONEncoding.default
            , headers: jsonHeader
            ).responseJSON { response in
                switch response.result {
                case .success(let value):
                    completionHandler(value as? NSDictionary, nil)
                    
                    break
                case .failure(let error):
                    NSLog(error.localizedDescription)
                    completionHandler(nil, error as NSError)
                    break
                }
        }
    }
    
    func copyNasFolder(parameters:[String:Any], completionHandler: @escaping (NSDictionary?, NSError?) -> ()){
        Alamofire.request(App.URL.server+"nasFoldrCopy.do"
            , method: .post
            , parameters:parameters
            , encoding : JSONEncoding.default
            , headers: jsonHeader
            ).responseJSON { response in
                switch response.result {
                case .success(let value):
                    completionHandler(value as? NSDictionary, nil)
                    
                    break
                case .failure(let error):
                    NSLog(error.localizedDescription)
                    completionHandler(nil, error as NSError)
                    break
                }
        }
    }
    func copyShareNasFolder(parameters:[String:Any], completionHandler: @escaping (NSDictionary?, NSError?) -> ()){
        Alamofire.request(App.URL.server+"shareNasFoldrCopy.do"
            , method: .post
            , parameters:parameters
            , encoding : JSONEncoding.default
            , headers:jsonHeader
            ).responseJSON { response in
                switch response.result {
                case .success(let value):
                    completionHandler(value as? NSDictionary, nil)
                    
                    break
                case .failure(let error):
                    NSLog(error.localizedDescription)
                    completionHandler(nil, error as NSError)
                    break
                }
        }
    }
    
    func downloadFromNas(userId:String, fileNm:String, path:String, fileId:String, completionHandler: @escaping (String?, NSError?) -> ()){
        var stringUrl = "https://araise.iptime.org/namespace/ifs/home/gs-\(userId)/\(userId)-gs\(path)/\(fileNm)"
        stringUrl = stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        let user = userId
        let password = "1234"
        let credentialData = "gs-\(user):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString()
        let headers = [
            "Authorization": "Basic \(base64Credentials)"
        ]
        var saveFileNm = ""
//        if(fileNm.contains(" ")){
//            saveFileNm = fileNm.split(separator: " ").map(String.init).joined(separator: "-")
//        }
        saveFileNm = fileNm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print("stringUrl : \(stringUrl)")
        let downloadUrl:URL = URL(string: stringUrl)!
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent("\(saveFileNm)")
            return (documentsURL, [.removePreviousFile])
        }
        
        request = Alamofire.download(downloadUrl, method: .get, headers:headers, to: destination)
            .downloadProgress(closure: { (progress) in
                print("download progress : \(progress.fractionCompleted)")
//                 completionHandler(progress.fractionCompleted, nil)
            })
            .response { response in
                print("response : \(response)")
                if response.destinationURL != nil {
                    print(response.destinationURL!)
                    if let path = response.destinationURL?.path{
                        let path2 = "/private\(path)"
                        
//                        DbHelper().localFileToSqlite(id: fileId, path: path2)
                        print("path2 : \(path2)" )
                        print("saved fileId : \(UserDefaults.standard.string(forKey: path2)), fileId : \(fileId)")
                        completionHandler("success", nil)
                    }
                    
                }
        }
    }
    
    func cancelAamofire(){
        self.request?.cancel()
        print("canceld")
    }
    
    func downloadFromNasToExcute(userId:String, fileNm:String, path:String, fileId:String, completionHandler: @escaping (String?, NSError?) -> ()){
        var stringUrl = "https://araise.iptime.org/namespace/ifs/home/gs-\(userId)/\(userId)-gs\(path)/\(fileNm)"
        stringUrl = stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        let user = userId
        let password = "1234"
        let credentialData = "gs-\(user):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString()
        let headers = [
            "Authorization": "Basic \(base64Credentials)"
        ]
        var saveFileNm = ""
        //        if(fileNm.contains(" ")){
        //            saveFileNm = fileNm.split(separator: " ").map(String.init).joined(separator: "-")
        //        }
        saveFileNm = fileNm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print("stringUrl : \(stringUrl)")
        let downloadUrl:URL = URL(string: stringUrl)!
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent("AppPlay/\(saveFileNm)")
            return (documentsURL, [.removePreviousFile])
        }
        
        Alamofire.download(downloadUrl, method: .get, headers:headers, to: destination)
            .downloadProgress(closure: { (progress) in
                print("download progress : \(progress.fractionCompleted)")
                //                 completionHandler(progress.fractionCompleted, nil)
            })
            .response { response in
                print("response : \(response)")
                if response.destinationURL != nil {
                    print(response.destinationURL!)
                    if let path = response.destinationURL?.path{
                        let path2 = "/private\(path)"
                        print("path2 : \(path2)" )
                        print("fileId : \(fileId)")
                        let stringDestinationUrl = response.destinationURL?.absoluteString
                        print(stringDestinationUrl)
                        completionHandler(stringDestinationUrl, nil)
                    }
                    
                }
        }
    }
    
    
    func downloadFromNasFolder(userId:String, fileNm:String, path:String, fileId:String, completionHandler: @escaping (String?, NSError?) -> ()){
        var stringUrl = "https://araise.iptime.org/namespace/ifs/home/gs-\(userId)/\(userId)-gs\(path)/\(fileNm)"
        stringUrl = stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        let user = userId
        let password = "1234"
        let credentialData = "gs-\(user):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString()
        let headers = [
            "Authorization": "Basic \(base64Credentials)"
        ]
        print("stringUrl : \(stringUrl)")
        var saveFileNm = ""
        saveFileNm = fileNm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let fullPath = path
        
        let editPath = fullPath.replacingOccurrences(of: upFoldersToDelete, with: "")
//        let fullNameArr = editPath.components(separatedBy: "/")
//        var folderName = ""
//        for (index, name) in fullNameArr.enumerated() {
//            print("name : \(name), index : \(index)")
//            if(1 < index && index < fullNameArr.count ){
//                folderName += "/\(fullNameArr[index])"
//            }
//        }
        print("file save folder : \(editPath), upFoldersToDelete: \(upFoldersToDelete)")
        let downloadUrl:URL = URL(string: stringUrl)!
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent("\(editPath)/\(saveFileNm)")
            return (documentsURL, [.removePreviousFile])
        }
        
        Alamofire.download(downloadUrl, method: .get, headers:headers, to: destination)
            .downloadProgress(closure: { (progress) in
                print("download progress : \(progress.fractionCompleted)")
                //                 completionHandler(progress.fractionCoprintmpleted, nil)
            })
            .response { response in
                print("response : \(response)")
                if response.destinationURL != nil {
                    print(response.destinationURL!)
                    if let path = response.destinationURL?.path{
                        let path2 = "/private\(path)"
                        
                        //                        DbHelper().localFileToSqlite(id: fileId, path: path2)
                        print("path2 : \(path2)" )
                        print("saved fileId : \(UserDefaults.standard.string(forKey: path2)), fileId : \(fileId)")
                        completionHandler("success", nil)
                    }
                    
                }
        }
    }
    
    func downloadFromNasToSend(userId:String, fileNm:String, path:String, completionHandler: @escaping (String?, NSError?) -> ()){
        var stringUrl = "https://araise.iptime.org/namespace/ifs/home/gs-\(userId)/\(userId)-gs\(path)/\(fileNm)"
        stringUrl = stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        let user = userId
        let password = "1234"
        let credentialData = "gs-\(user):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString()
        let headers = [
            "Authorization": "Basic \(base64Credentials)"
        ]
        var saveFileNm = ""
        saveFileNm = fileNm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        print("stringUrl : \(stringUrl)")
        let downloadUrl:URL = URL(string: stringUrl)!
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent("\(saveFileNm)")
            return (documentsURL, [.removePreviousFile])
        }
        
        Alamofire.download(downloadUrl, method: .get, headers:headers, to: destination)
            .downloadProgress(closure: { (progress) in
                print("download progress : \(progress.fractionCompleted)")
                //                 completionHandler(progress.fractionCompleted, nil)
            })
            .response { response in
                print("response : \(response)")
                if response.destinationURL != nil {
                    let stringDestinationUrl = response.destinationURL?.absoluteString
                    print(stringDestinationUrl)
                    completionHandler(stringDestinationUrl, nil)
                }
        }
    }
    
    
    //remote 관련
    
    func downloadFromRemote(userId:String, fileNm:String, path:String, fileId:String, completionHandler: @escaping (String?, NSError?) -> ()){
        var stringUrl = "https://araise.iptime.org/namespace/ifs/home/gs-\(userId)/\(path)/\(fileNm)"
        stringUrl = stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        let user = App.defaults.userId
        let password = "1234"
        let credentialData = "gs-\(user):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString()
        let headers = [
            "Authorization": "Basic \(base64Credentials)"
        ]
        var saveFileNm = ""
        //        if(fileNm.contains(" ")){
        //            saveFileNm = fileNm.split(separator: " ").map(String.init).joined(separator: "-")
        //        }
        saveFileNm = fileNm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print("stringUrl : \(stringUrl)")
        let downloadUrl:URL = URL(string: stringUrl)!
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent("\(saveFileNm)")
            return (documentsURL, [.removePreviousFile])
        }
        
        Alamofire.download(downloadUrl, method: .get, headers:headers, to: destination)
            .downloadProgress(closure: { (progress) in
                print("download progress : \(progress.fractionCompleted)")
                //                 completionHandler(progress.fractionCompleted, nil)
            })
            .response { response in
                print("response : \(response)")
                if response.destinationURL != nil {
                    print(response.destinationURL!)
                    if let path = response.destinationURL?.path{
                        let path2 = "/private\(path)"
                        
                        //                        DbHelper().localFileToSqlite(id: fileId, path: path2)
                        print("path2 : \(path2)" )
                        print("saved fileId : \(UserDefaults.standard.string(forKey: path2)), fileId : \(fileId)")
                        completionHandler("success", nil)
                    }
                    
                }
        }
    }
    
    func downloadFromRemoteToExcute(userId:String, fileNm:String, path:String, fileId:String, completionHandler: @escaping (String?, NSError?) -> ()){
        var stringUrl = "https://araise.iptime.org/namespace/ifs/home/gs-\(userId)/\(path)/\(fileNm)"
        stringUrl = stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        let user = App.defaults.userId
        let password = "1234"
        let credentialData = "gs-\(user):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString()
        let headers = [
            "Authorization": "Basic \(base64Credentials)"
        ]
        var saveFileNm = ""
        //        if(fileNm.contains(" ")){
        //            saveFileNm = fileNm.split(separator: " ").map(String.init).joined(separator: "-")
        //        }
        saveFileNm = fileNm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print("stringUrl : \(stringUrl)")
        let downloadUrl:URL = URL(string: stringUrl)!
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent("AppPlay/\(saveFileNm)")
            return (documentsURL, [.removePreviousFile])
        }
        
        Alamofire.download(downloadUrl, method: .get, headers:headers, to: destination)
            .downloadProgress(closure: { (progress) in
                print("download progress : \(progress.fractionCompleted)")
                //                 completionHandler(progress.fractionCompleted, nil)
            })
            .response { response in
                print("response : \(response)")
                if response.destinationURL != nil {
                    print(response.destinationURL!)
                    if let path = response.destinationURL?.path{
                        let path2 = "/private\(path)"
                        print("path2 : \(path2)" )
                        print("fileId : \(fileId)")
                        let stringDestinationUrl = response.destinationURL?.absoluteString
                        print(stringDestinationUrl)
                        completionHandler(stringDestinationUrl, nil)
                    }
                    
                }
        }
    }
    
    func downloadFromRemoteToSend(userId:String, fileNm:String, path:String, fileId:String, completionHandler: @escaping (String?, NSError?) -> ()){
        var stringUrl = "https://araise.iptime.org/namespace/ifs/home/gs-\(userId)/\(path)/\(fileNm)"
        stringUrl = stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        let user = App.defaults.userId
        let password = "1234"
        let credentialData = "gs-\(user):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString()
        let headers = [
            "Authorization": "Basic \(base64Credentials)"
        ]
        var saveFileNm = ""
        //        if(fileNm.contains(" ")){
        //            saveFileNm = fileNm.split(separator: " ").map(String.init).joined(separator: "-")
        //        }
        saveFileNm = fileNm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print("stringUrl : \(stringUrl)")
        let downloadUrl:URL = URL(string: stringUrl)!
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent("\(saveFileNm)")
            return (documentsURL, [.removePreviousFile])
        }
        
        Alamofire.download(downloadUrl, method: .get, headers:headers, to: destination)
            .downloadProgress(closure: { (progress) in
                print("download progress : \(progress.fractionCompleted)")
                //                 completionHandler(progress.fractionCompleted, nil)
            })
            .response { response in
                print("response : \(response)")
                if response.destinationURL != nil {
                    let stringDestinationUrl = response.destinationURL?.absoluteString
                    print(stringDestinationUrl)
                    completionHandler(stringDestinationUrl, nil)
                }
        }
    }
    
    func remoteDownloadRequest(fromUserId:String, fromDevUuid:String, fromOsCd:String, fromFoldr:String, fromFileNm:String, fromFileId:String){
        
        let urlString = App.URL.server+"reqFileDown.do"
        var comnd = "RALI"
        switch fromOsCd {
        case "W":
            comnd = "RWLI"
        case "A":
            comnd = "RALI"
        default:
            comnd = "RILI"
            break
        }
        let paramas:[String : Any] = ["fromUserId":fromUserId,"fromDevUuid":fromDevUuid,"fromOsCd":fromOsCd,"fromFoldr":fromFoldr,"fromFileNm":fromFileNm,"fromFileId":fromFileId,"toDevUuid":Util.getUuid(),"toOsCd":"I","toFoldr":"/Mobile","toFileNm":fromFileNm,"comndOsCd":"I","comndDevUuid":App.defaults.userId,"comnd":comnd]
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
                                print("remoteDownloadRequest : \(message)")
                               
                                
                                break
                            case .failure(let error):
                                
                                print(error.localizedDescription)
                            }
        }
    }
    
    
    
    
    
    func deleteNasFile(parameters:[String:Any], completionHandler: @escaping (NSDictionary?, NSError?) -> ()){
        Alamofire.request(App.URL.server+"nasFileDel.do"
            , method: .post
            , parameters:parameters
            , encoding : JSONEncoding.default
            , headers: jsonHeader
            ).responseJSON { response in
                switch response.result {
                case .success(let value):
                    completionHandler(value as? NSDictionary, nil)
                    
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    completionHandler(nil, error as NSError)
                    break
                }
        }
    }
   
    
    
    
    ///NAS 폴더 다운로드 시작
    
    
    
    func downloadFolderFromNas(foldrId:Int, foldrWholePathNm:String, userId:String, devUuid:String, deviceName:String, dwldFoldrNm:String){
        NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
        selectedUserId = userId
        selectedDevUuid = devUuid
        selectedDeviceName = deviceName
        rootFolderId = foldrId
        rootFoldrWholePathNm = foldrWholePathNm
        folderIdsToDownLoad.removeAll()
        folderPathToDownLoad.removeAll()
        fileArrayToDownload.removeAll()
        foldersToDownLoad.removeAll()
        folderIdsToUp.removeAll()
        print("call from downloadFolderFromNas")
        print("foldrWholePathNm : \(foldrWholePathNm), dwldFoldrNm: \(dwldFoldrNm)")
        folderIdsToDownLoad.append(foldrId)
        folderPathToDownLoad.append(foldrWholePathNm)
        folderIdsToUp.append(foldrId)
        
        getFolderIdsToDownload(foldrId: foldrId, foldrWholePathNm: foldrWholePathNm, userId:userId, devUuid:selectedDevUuid,deviceName:deviceName, dwldFoldrNm:dwldFoldrNm)
//        callGetFolderIdsToDownload(getArray: folderIdsToDownLoad, userId:userId, devUuid:selectedDevUuid,deviceName:deviceName, dwldFoldrNm:dwldFoldrNm)
    }
    
    func callGetFolderIdsToDownload(getArray:[Int], userId:String, devUuid:String, deviceName:String, dwldFoldrNm:String) {
        
        for id in getArray {
            self.getFolderIdsToDownload(foldrId: id, foldrWholePathNm: rootFoldrWholePathNm, userId:userId, devUuid:selectedDevUuid,deviceName:deviceName, dwldFoldrNm:dwldFoldrNm)
            return
        }
        
    }
    
    func getFolderIdsToDownload(foldrId:Int, foldrWholePathNm:String, userId:String, devUuid:String, deviceName:String, dwldFoldrNm:String) {
        var foldrLevel = 0
        var param = ["userId": userId, "devUuid":devUuid, "foldrId":String(foldrId),"sortBy":""]
        print("param : \(param)")
        GetListFromServer().getMobileFoldrLIst(devUuid:devUuid, userId:userId, deviceName: deviceName) { responseObject, error in
//        GetListFromServer().showInsideFoldrList(params: param, deviceName: deviceName) { responseObject, error in
            let json = JSON(responseObject!)
            if(json["listData"].exists()){
                let serverList:[AnyObject] = json["listData"].arrayObject as! [AnyObject]
//                print("download serverList :\(serverList)")
                var tempArray:[App.FolderStruct] = []
                if (serverList.count > 0){
                    for list in serverList {
                        
                        let folderPath = list["foldrWholePathNm"] as? String ?? "nil"
                        let foldrId = list["foldrId"] as? Int ?? 0
                        if(folderPath.contains(foldrWholePathNm)){
                                print("list : \(list)")
                            self.folderIdsToDownLoad.append(foldrId)
                            self.folderPathToDownLoad.append(folderPath)
                        }

                    }
                }
                
                self.printFolderPath(dwldFoldrNm:dwldFoldrNm)
            }
        }
    }
        
 
    func printFolderPath(dwldFoldrNm:String){
        print("folderPathToDownLoad: \(folderPathToDownLoad.count)")
        print("folderIdsToDownLoad: \(folderIdsToDownLoad.count)")
        print("printFolderPath called")
        let saveRootFoldrArray = folderPathToDownLoad[0].components(separatedBy: "/")
        upFoldersToDelete = ""
        for (index, name) in saveRootFoldrArray.enumerated() {
            if(0 < index && index < saveRootFoldrArray.count - 1){
                upFoldersToDelete += "/\(saveRootFoldrArray[index])"
            }
        }
        print("upFoldersToDelete : \(upFoldersToDelete)")
        var localPathArray:[URL] = []
        for name in folderPathToDownLoad {
            let fullName = name.replacingOccurrences(of: upFoldersToDelete, with: "")
            print("fullName : \(fullName)")
//            let fullNameArr = fullName.components(separatedBy: "/")
//            var folderName = ""
//            for (index, name) in fullNameArr.enumerated() {
//                print("name : \(name), index : \(index)")
//                let startIndex = fullNameArr.index(of: dwldFoldrNm)
//                if(startIndex! < index && index < fullNameArr.count ){
//                    folderName += "/\(fullNameArr[index])"
//                }
//            }
//            print("folderName : \(folderName)")
            let createdPath:URL = self.createLocalFolder(folderName: fullName)!
            localPathArray.append(createdPath)
        }

        getFilesFromFolder()
        
        
    }
    func createLocalFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = documentDirectory.appendingPathComponent(folderName)
            if !fileManager.fileExists(atPath: filePath.path) {
                do {
                    try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error.localizedDescription)
                    
                    return nil
                }
            }
            
            return filePath
        } else {
            return nil
        }
    }
    
    func getFilesFromFolder(){
        print("folderIdsToDownLoad.count:  \(folderIdsToDownLoad.count)")
        if(folderIdsToDownLoad.count > 0){
            let lastIndex = folderIdsToDownLoad.count - 1
            print("lastIndex : \(lastIndex)")
            if(lastIndex > -1){
                let stringFolderId = String(folderIdsToDownLoad[lastIndex])
                getFileListToDownload(userId: userId, devUuid: selectedDevUuid, foldrId: stringFolderId, lastIndex:lastIndex)
                
            }
            return
        }
        self.downloadFile()
        print("file download start : \(fileArrayToDownload.count)")
        
        
    }
    
    func getFileListToDownload(userId: String, devUuid: String, foldrId: String, lastIndex:Int){
        let param:[String : Any] = ["userId": selectedUserId, "devUuid":selectedDevUuid, "foldrId":foldrId,"page":1,"sortBy":""]
        print("param : \(param)")
        print("count : \(self.folderIdsToDownLoad.count), lastIndex: \(lastIndex)")
        GetListFromServer().getFileList(params: param){ responseObject, error in
            let json = JSON(responseObject!)
            //            let message = responseObject?.object(forKey: "message")
            if(json["listData"].exists()){
                let listData = json["listData"]
                print("getFileListToDownloadlistData : \(listData)")
                let serverList:[AnyObject] = json["listData"].arrayObject! as [AnyObject]
                for list in serverList{
                    let folder = App.FolderStruct(data: list as AnyObject)
                    self.fileArrayToDownload.append(folder)
                   
                }
                
                self.folderIdsToDownLoad.remove(at: lastIndex)
                self.getFilesFromFolder()
                return
            }
            
        }
    }
    
    func downloadFile(){
        print("fileArrayToDownload : \(fileArrayToDownload.count)")
        for file in fileArrayToDownload {
            print("download file : \(file)")
        }
        if(fileArrayToDownload.count > 0){
            let index = fileArrayToDownload.count - 1
            if(index > -1){
                let downFileName = fileArrayToDownload[index].fileNm
                let downPath = fileArrayToDownload[index].foldrWholePathNm
                let downId = String(fileArrayToDownload[index].fileId)
                callDownloadFromNasFolder(name: downFileName, path: downPath, fileId: downId, index:index)
                return
            }

        }
        self.finishDownload()
    }
    
    
    
    
    func callDownloadFromNasFolder(name:String, path:String, fileId:String, index:Int){
        print("upFoldersToDelete : \(upFoldersToDelete)")
        downloadFromNasFolder(userId:userId, fileNm:name, path:path, fileId:fileId){ responseObject, error in
            if let success = responseObject {
                print(success)
                if(success == "success"){
                }
            }
            self.fileArrayToDownload.remove(at: index)
            self.downloadFile()
        }
    }
    
    func finishDownload(){
        SyncLocalFilleToNas().sync(view: "ContextMenuWork", getFoldrId: "")         
        print("download finish")
        NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
        
        let messageDict = ["message":"폴더 다운로드를 성공하였습니다"]
        NotificationCenter.default.post(name: Notification.Name("showAlert"), object: self, userInfo: messageDict)
    }
    
    //nas 폴더 다운로드 끝
    
    func removeNasFolder(parameters:[String:Any], completionHandler: @escaping (NSDictionary?, NSError?) -> ()){
        Alamofire.request(App.URL.server+"nasFoldrDel.do"
            , method: .post
            , parameters:parameters
            , encoding : JSONEncoding.default
            , headers: jsonHeader
            ).responseJSON { response in
                switch response.result {
                case .success(let value):
                    completionHandler(value as? NSDictionary, nil)
                    
                    break
                case .failure(let error):
                    NSLog(error.localizedDescription)
                    completionHandler(nil, error as NSError)
                    break
                }
        }
    }
   
    // NAS 폴더 업로드 From Local 시작
    
   
    func createNasFolder(parameters:[String:Any], completionHandler: @escaping (NSDictionary?, NSError?) -> ()){
        Alamofire.request(App.URL.server+"nasFoldrCret.do"
            , method: .post
            , parameters:parameters
            , encoding : JSONEncoding.default
            , headers: jsonHeader
            ).responseJSON { response in
                switch response.result {
                case .success(let value):
                    completionHandler(value as? NSDictionary, nil)
                    
                    break
                case .failure(let error):
                    NSLog(error.localizedDescription)
                    completionHandler(nil, error as NSError)
                    break
                }
        }
    }
    
    
    
}
