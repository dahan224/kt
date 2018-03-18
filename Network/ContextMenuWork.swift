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
    var folderIdsToDownLoad:[Int] = []
    var folderPathToDownLoad:[String] = []
    var fileArrayToDownload:[App.FolderStruct] = []
    
    var userId = UserDefaults.standard.string(forKey: "userId") as? String ?? "nil"
    var uuid = Util.getUuid()
    var selectedDevUuid = ""
    var selectedUserId = ""
    var selectedDeviceName = ""
    
      
    func login(userId:String, password:String, completionHandler: @escaping (NSDictionary?, NSError?) -> ()){
        var params:[String:Any] = [String:Any]()
        params = ["userId":userId,"password":password]
        Alamofire.request(App.URL.server+"login.do"
            , method: .post
            , parameters:params
            , encoding : URLEncoding.default
            , headers: App.Headrs.jsonHeader
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
            , headers: App.Headrs.jsonHeader
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
        request.setValue(App.defaults.loginToken, forHTTPHeaderField: "X-Auth-Token")
        request.setValue(App.defaults.loginCookie, forHTTPHeaderField: "Cookie")
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
            , headers: App.Headrs.jsonHeader
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
            , headers: App.Headrs.jsonHeader
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
        let fullNameArr = path.components(separatedBy: "/")
        var folderName = ""
        for (index, name) in fullNameArr.enumerated() {
            print("name : \(name), index : \(index)")
            if(1 < index && index < fullNameArr.count ){
                folderName += "/\(fullNameArr[index])"
            }
        }
        let downloadUrl:URL = URL(string: stringUrl)!
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent("\(folderName)/\(saveFileNm)")
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
    
    func deleteNasFile(parameters:[String:Any], completionHandler: @escaping (NSDictionary?, NSError?) -> ()){
        Alamofire.request(App.URL.server+"nasFileDel.do"
            , method: .post
            , parameters:parameters
            , encoding : JSONEncoding.default
            , headers: App.Headrs.jsonHeader
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
    
    
    func downloadFolderFromNas(foldrId:Int, foldrWholePathNm:String, userId:String, devUuid:String, deviceName:String){
        selectedUserId = userId
        selectedDevUuid = devUuid
        selectedDeviceName = deviceName
        
        folderIdsToDownLoad.removeAll()
        folderPathToDownLoad.removeAll()
        fileArrayToDownload.removeAll()
        getFolderIdsToDownload(foldrId: foldrId, foldrWholePathNm: foldrWholePathNm, userId:userId, devUuid:selectedDevUuid,deviceName:deviceName)
    }
    
    
    
    func getFolderIdsToDownload(foldrId:Int, foldrWholePathNm:String, userId:String, devUuid:String, deviceName:String) {
        print("get folders")
        folderIdsToDownLoad.append(foldrId)
        folderPathToDownLoad.append(foldrWholePathNm)
        
        var param = ["userId": userId, "devUuid":devUuid, "foldrId":String(foldrId),"sortBy":""]
        print("param : \(param)")
        GetListFromServer().showInsideFoldrList(params: param, deviceName:selectedDeviceName) { responseObject, error in
            let json = JSON(responseObject!)
            if(json["listData"].exists()){
                let serverList:[AnyObject] = json["listData"].arrayObject as! [AnyObject]
                print("download serverList :\(serverList)")
                if (serverList.count > 0){
                    for list in serverList{
                        let folder = App.FolderStruct(data: list as AnyObject)
                        
                        if (self.folderIdsToDownLoad.contains(folder.foldrId)){
                            return
                        } else {
                            print("folder : \(folder.foldrId)")
                            self.folderIdsToDownLoad.append(folder.foldrId)
                            self.folderPathToDownLoad.append(folder.foldrWholePathNm)
                            let foldrLevel = list["foldrLevel"] as? Int ?? 0
                            if(foldrLevel > 0){
                                self.getFolderIdsToDownload(foldrId: folder.foldrId, foldrWholePathNm: folder.foldrWholePathNm, userId: self.selectedUserId, devUuid: self.selectedDevUuid, deviceName: self.selectedDeviceName)
                                return
                            }
                        }
                    }
                }
                self.printFolderPath()
            }
        }
        
    }
    
    func printFolderPath(){
        print("folderPathToDownLoad: \(folderPathToDownLoad)")
        print("folderIdsToDownLoad: \(folderIdsToDownLoad)")
        var localPathArray:[URL] = []
        for name in folderPathToDownLoad {
            let fullNameArr = name.components(separatedBy: "/")
            var folderName = ""
            for (index, name) in fullNameArr.enumerated() {
                print("name : \(name), index : \(index)")
                if(1 < index && index < fullNameArr.count ){
                    folderName += "/\(fullNameArr[index])"
                }
            }
            print("folderName : \(folderName)")
            let createdPath:URL = self.createLocalFolder(folderName: folderName)!
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
        
        if(folderIdsToDownLoad.count > 0){
            let index = folderIdsToDownLoad.count - 1
            if(index > -1){
                let stringFolderId = String(folderIdsToDownLoad[index])
                getFileListToDownload(userId: userId, devUuid: selectedDevUuid, foldrId: stringFolderId, index:index)
                return
            }
        }
        self.downloadFile()
        
    }
    
    func getFileListToDownload(userId: String, devUuid: String, foldrId: String, index:Int){
        let param:[String : Any] = ["userId": selectedUserId, "devUuid":selectedDevUuid, "foldrId":foldrId,"page":1,"sortBy":""]
        print("param : \(param)")
        GetListFromServer().getFileList(params: param){ responseObject, error in
            let json = JSON(responseObject!)
            //            let message = responseObject?.object(forKey: "message")
            if(json["listData"].exists()){
                let listData = json["listData"]
                //                print("getFileListToDownloadlistData : \(listData)")
                let serverList:[AnyObject] = json["listData"].arrayObject! as [AnyObject]
                for list in serverList{
                    let folder = App.FolderStruct(data: list as AnyObject)
                    self.fileArrayToDownload.append(folder)
                }
            }
            self.folderIdsToDownLoad.remove(at: index)
            self.getFilesFromFolder()
        }
        
        
    }
    
    func downloadFile(){
        print("fileArrayToDownload : \(fileArrayToDownload)")
        for file in fileArrayToDownload{
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
        ContextMenuWork().downloadFromNasFolder(userId:userId, fileNm:name, path:path, fileId:fileId){ responseObject, error in
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
        SyncLocalFilleToNas().sync()
         
        print("download finish")
    }
    
    
    func removeNasFolder(parameters:[String:Any], completionHandler: @escaping (NSDictionary?, NSError?) -> ()){
        Alamofire.request(App.URL.server+"nasFoldrDel.do"
            , method: .post
            , parameters:parameters
            , encoding : JSONEncoding.default
            , headers: App.Headrs.jsonHeader
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
            , headers: App.Headrs.jsonHeader
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
