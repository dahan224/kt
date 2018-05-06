//
//  SyncLocalFilleToNas.swift
//  KT
//
//  Created by 이다한 on 2018. 3. 7..
//  Copyright © 2018년 이다한. All rights reserved.
//



import UIKit
import SwiftyJSON
import Alamofire

class SyncLocalFilleToNas {
    
    var localFolderArray:[App.Folders] = []
    var tempLocalDirectoryArray:[URL] = []
    var folderPathArray = [String]()
    var folderArrayToCreate:[[String:Any]] = []
    var folderArrayToUpdate:[[String:Any]] = []
    var folderArrayToDelete:[[String:Any]] = []
    
    
    var localFileArray:[App.LocalFiles] = []
    var serverFileArray:[[String:Any]] = []
    var fileArrayToCreate:[[String:Any]] = []
    var fileArrayToUpdate:[[String:Any]] = []
    var fileArrayToDelete:[[String:Any]] = []
    var FileParameterArrayForUpload:[[String:Any]] = []
    
    var folderSyncFinished = false
    var fileSyncFinished = false
    var loginCookie = UserDefaults.standard.string(forKey: "cookie")!
    var loginToken = UserDefaults.standard.string(forKey: "token")!
    var userId = App.defaults.userId
    var uuId = Util.getUuid()
    var requestView = ""
    var currentFolderId = ""
    var nasSendFolderSelectVC:NasSendFolderSelectVC?
    var containerViewController:ContainerViewController?
    var nasSendController:NasSendController?
    var getRootFolder = ""
    func callSyncFomGdriveToNasSendFolder(view:String, parent:NasSendController, rootFolder:String){
        requestView = view
        nasSendController = parent
        getRootFolder = rootFolder
        getFileList()
    }
    
    func callSyncFomNasSend(view:String, parent:NasSendFolderSelectVC){
        requestView = view
        nasSendFolderSelectVC = parent
     
        getFileList()
    }
    
    func callSyncToDownloadFronGDriveToSendToNas(view:String, parent:NasSendController){
        requestView = view
        nasSendController = parent
        getFileList()
    }
    
    
    func sync(view:String, getFoldrId:String){
        currentFolderId = getFoldrId
        requestView = view
        if(requestView == "home"){
//            NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
        }
        getFileList()
    }
    
    var jsonHeader:[String:String] = [
        "Content-Type": "application/json",
        "X-Auth-Token": UserDefaults.standard.string(forKey: "token")!,
        "Cookie": UserDefaults.standard.string(forKey: "cookie")!
    ]
    
    func sysncFoldrInfo() {
        print("syncFolerInfo Called")
        folderArrayToCreate.removeAll()
        //모바일 폴더 동기화 리스트
        Alamofire.request(App.URL.server+"mobileFoldrList.json"
            , method: .post
            , parameters:["userId":userId, "devUuid":uuId as Any]
            , encoding : JSONEncoding.default
            , headers: jsonHeader
            ).responseJSON { response in
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if let statusCode = json["statusCode"].int, statusCode == 100 {
                        let serverList:[AnyObject] = json["listData"].arrayObject! as [AnyObject]
                        if(json["listData"].exists()){
                            if(serverList.count < 1){
//                                print(serverList.count)
                                for (_, folder) in self.localFolderArray.enumerated() {
                                    let parameter = folder.getParameter
//                                    print("parameter : \(parameter)")
                                    self.folderArrayToCreate.append(parameter)
                                }
                            } else {
//                                print("jsonlistData: \(json["listData"])")
                                var serverFolderPathArray:[String] = []
                                var localFolderPathArray:[String] = []
                                for serverFolder in serverList{
                                    let serverFolderPath = "\(serverFolder["foldrWholePathNm"] as! String)"
                                    serverFolderPathArray.append(serverFolderPath)
                                }
                                for localFolder in self.localFolderArray {
                                    let localFolderPath = "\(localFolder.foldrWholePathNm)"
                                    print("localFolderPath : \(localFolderPath)")
                                    if(!serverFolderPathArray.contains(localFolderPath)){
                                        self.folderArrayToCreate.append(localFolder.getParameter)
                                    }
                                }
                                for localFolder in self.localFolderArray {
                                   let localFolderPath = "\(localFolder.foldrWholePathNm)"
                                    localFolderPathArray.append(localFolderPath)
                                }
                                print("localFolderPathArray : \(localFolderPathArray)")
                                
                                for serverFolder in serverList{
                                    let serverFolderPath = "\(serverFolder["foldrWholePathNm"] as! String)"
                                    print("serverFolderPath : \(serverFolderPath)")
                                    if(!localFolderPathArray.contains(serverFolderPath)){
                                        let deleteFolder = App.Folders(data: serverFolder)
                                        let deleteFolderParameter = App.FoldersToEdit(folder:deleteFolder, cmd:"D").getParameter
                                        self.folderArrayToDelete.append(deleteFolderParameter)
                                    }
                                    
                                }
                            }
                            if(self.folderArrayToDelete.count > 0){
                                self.deleteFolderListToServer(parameters: self.folderArrayToDelete)
                                print("deletefolder : \(self.folderArrayToDelete)")
                            } else {
                                if(self.folderArrayToCreate.count > 0){
                                    print("createfolder : \(self.folderArrayToCreate)")
                                    self.createFolderListToServer(parameters: self.folderArrayToCreate)
                                } else {
                                    self.sysncFileInfo()
                                }

                            }
                            
                            self.folderSyncFinished = true
                           
                        }
                    }
                    break
                case .failure(let error):
                    NSLog(error.localizedDescription)
                    
                    break
                }
        }
        
    }
    
    func sysncFileInfo() {
        print("syncFileInfo called ????")
        FileParameterArrayForUpload.removeAll()
        fileArrayToUpdate.removeAll()
        fileArrayToDelete.removeAll()
        fileArrayToCreate.removeAll()
        
        GetListFromServer().getMobileFileLIst(devUuid: uuId, userId:App.defaults.userId, deviceName:"sdf"){ responseObject, error in
            let json = JSON(responseObject!)
            if(json["listData"].exists()){
                let serverList:[AnyObject] = json["listData"].arrayObject! as [AnyObject]
                print("nasfileList :\(serverList)")
                var serverFilePathArray:[String] = []
                for serverFile in serverList{
//                    print("server : \(serverFile)")
                    let serverFileNm = serverFile["fileNm"] as? String ?? "nil"
                    let serverFilePath = serverFile["foldrWholePathNm"] as? String ?? "nil"
                    var foldrWholePathNm = "\(serverFilePath)/\(serverFileNm)"
                    print("server foldrWholePathNm : \(foldrWholePathNm)")
                    serverFilePathArray.append(foldrWholePathNm)
                }
                
                print("serverFilePathArray : \(serverFilePathArray)")
                var localFilePathArray:[String] = []
                if(self.localFileArray.count > 0){
                    for localFile in self.localFileArray {
                        let localFilePath = "\(localFile.foldrWholePathNm)/\(localFile.fileNm).\(localFile.etsionNm)"
                        localFilePathArray.append(localFilePath)
                    }
                }
                print("localFilePathArray : \(localFilePathArray)")
                
                for serverFile in serverList{
                    let serverFileNm = serverFile["fileNm"] as? String ?? "nil"
                    let serverFilePath = serverFile["foldrWholePathNm"] as? String ?? "nil"
                    let serverFileAmdDate = serverFile["amdDate"] as? String ?? "nil"
                    var foldrWholePathNm = "\(serverFilePath)/\(serverFileNm)"
                    if !localFilePathArray.contains(foldrWholePathNm) {
                        let deleteFile = App.Files(data: serverFile)
                        let deleteFileParameter = App.FilesToEdit(file:deleteFile, cmd:"D").getDeleteParameter
                        self.fileArrayToDelete.append(deleteFileParameter)
                    } else {
                        print("server")
                    }
                }
                for localFile in self.localFileArray {
                    let localFilePath = "\(localFile.foldrWholePathNm)/\(localFile.fileNm).\(localFile.etsionNm)"
                    if(!serverFilePathArray.contains(localFilePath)){
                        self.fileArrayToCreate.append(localFile.getParameter)
                    }
                }
                
                if(self.fileArrayToDelete.count > 0){
                    print("fileArrayToDelete : \(self.fileArrayToDelete)" )
                    self.deleteFileListToServer(parameters: self.fileArrayToDelete)
                } else {
                    if(self.fileArrayToCreate.count>0){
                        print("create filelist : \(self.fileArrayToCreate)")
                        self.createFileListToServer(parameters: self.fileArrayToCreate)
                    } else {
                        let defaults = UserDefaults.standard
                        defaults.set(false, forKey: "syncOngoing")
                        defaults.synchronize()
                        
                        if(self.requestView == "home"){
//                            NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
                            let fileDict = ["foldrId":self.currentFolderId]
                            NotificationCenter.default.post(name: Notification.Name("refreshInsideList"), object: self, userInfo:fileDict)
                        } else if(self.requestView == "NasSendFolderSelectVC"){
                            self.nasSendFolderSelectVC?.notifiedSyncFinish(rootFolder:self.getRootFolder)
                        } else if(self.requestView == "NasSendController"){
                            self.nasSendController?.notifiedSyncFinish(rootFolder:self.getRootFolder)
                        }
                    }
                }
                
            } else {
                if(self.fileArrayToCreate.count>0){
                    print("create filelist : \(self.fileArrayToCreate)")
                    self.createFileListToServer(parameters: self.fileArrayToCreate)
                } else {
                    let defaults = UserDefaults.standard
                    defaults.set(false, forKey: "syncOngoing")
                    defaults.synchronize()
                    
                    if(self.requestView == "home"){
//                        NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
                        let fileDict = ["foldrId":self.currentFolderId]
                        NotificationCenter.default.post(name: Notification.Name("refreshInsideList"), object: self, userInfo:fileDict)
                    } else if (self.requestView == "NasSendFolderSelectVC"){
                        self.nasSendFolderSelectVC?.notifiedSyncFinish(rootFolder:self.getRootFolder)
                    } else if(self.requestView == "NasSendController"){
                        self.nasSendController?.notifiedSyncFinish(rootFolder:self.getRootFolder)
                    }
                }
               
            }
    
        }
    }

    func getFileList(){
       
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "syncOngoing")
        defaults.synchronize()
        localFileArray.removeAll()
        localFolderArray.removeAll()
        folderPathArray.removeAll()
        let today = Date()
         let folder = App.Folders(cmd : "C", userId : userId, devUuid : uuId, foldrNm : "Mobile", foldrWholePathNm: "/Mobile", cretDate : Util.date(text: today), amdDate : Util.date(text: today))
        localFolderArray.append(folder)
        localFileArray = FileUtil().getFileLIst()
        print("localFileArray : \(localFileArray)")
        let folders:[App.Folders] = FileUtil().getFolderList()
        for folder in folders {
            localFolderArray.append(folder)
        }
         self.sysncFoldrInfo()
    }
    
    
    func createFolderListToServer(parameters:[[String: Any]]){
        var request = URLRequest(url: try! (App.URL.server+"mobileFoldrMetaInfoList.do").asURL())
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(self.loginToken, forHTTPHeaderField: "X-Auth-Token")
        request.setValue(self.loginCookie, forHTTPHeaderField: "Cookie")
        let values = parameters
        request.httpBody = try! JSONSerialization.data(withJSONObject: values)
        Alamofire.request(request).responseJSON { response in
            //                print("httpBody : \(response.request?.httpBody)")
            switch response.result {
            case .success(let value):
                _ = JSON(value)
                let responseData = value as! NSDictionary
                let message = responseData.object(forKey: "message")
//                print("createFolderListToServer : \(message)")
                self.sysncFileInfo()
                
                break
            case .failure(let error):
                NSLog(error.localizedDescription)
                break
            }
        }
    }
    
    
    func deleteFolderListToServer(parameters:[[String: Any]]){
        var request = URLRequest(url: try! (App.URL.server+"mobileFoldrMetaInfoList.do").asURL())
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(self.loginToken, forHTTPHeaderField: "X-Auth-Token")
        request.setValue(self.loginCookie, forHTTPHeaderField: "Cookie")
        let values = parameters
        request.httpBody = try! JSONSerialization.data(withJSONObject: values)
        Alamofire.request(request).responseJSON { response in
            //                print("httpBody : \(response.request?.httpBody)")
            switch response.result {
            case .success(let value):
                _ = JSON(value)
                let responseData = value as! NSDictionary
                let message = responseData.object(forKey: "message")
//                   print("deleteFolderListToServer : \(message)")
                if(self.folderArrayToCreate.count > 0){
//                    print("createfolder : \(self.folderArrayToCreate)")
                    self.createFolderListToServer(parameters: self.folderArrayToCreate)
                } else {
                        self.sysncFileInfo()
                }
                
                break
            case .failure(let error):
                NSLog(error.localizedDescription)
                break
            }
        }
    }
    
    func deleteFileListToServer(parameters:[[String:Any]]){
        var request = URLRequest(url: try! (App.URL.server+"mobileFileMetaInfoList.do").asURL())
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(self.loginToken, forHTTPHeaderField: "X-Auth-Token")
        request.setValue(self.loginCookie, forHTTPHeaderField: "Cookie")
        let values = parameters
        request.httpBody = try! JSONSerialization.data(withJSONObject: values)
        Alamofire.request(request).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                //                                let json = JSON(value)
//                print("deleteFileListToServer : \(response.result)")
                let responseData = value as! NSDictionary
                let message = responseData.object(forKey: "message")
                print(" deleteFileListToServer message : \(message)")
                if(self.fileArrayToCreate.count>0){
//                    print("create filelist : \(self.fileArrayToCreate)")
                    self.createFileListToServer(parameters: self.fileArrayToCreate)
                } else {
                    let defaults = UserDefaults.standard
                    defaults.set(false, forKey: "syncOngoing")
                    defaults.synchronize()
                    
                }
                
                break
            case .failure(let error):
                NSLog(error.localizedDescription)
                
                break
            }
        }
    }
    
    
    func createFileListToServer(parameters:[[String:Any]]){
        var request = URLRequest(url: try! (App.URL.server+"mobileFileMetaInfoList.do").asURL())
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(self.loginToken, forHTTPHeaderField: "X-Auth-Token")
        request.setValue(self.loginCookie, forHTTPHeaderField: "Cookie")
        let values = parameters
        request.httpBody = try! JSONSerialization.data(withJSONObject: values)
        Alamofire.request(request).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                //                                let json = JSON(value)
//                print("createFileServer : \(response.result)")
                let defaults = UserDefaults.standard
                defaults.set(false, forKey: "syncOngoing")
                defaults.synchronize()
                
                let responseData = value as! NSDictionary
                let message = responseData.object(forKey: "message")
                print(" createFileListToServer message : \(String(describing: message))")
                if(self.requestView == "home"){
//                    NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
                    let fileDict = ["foldrId":self.currentFolderId]
                    NotificationCenter.default.post(name: Notification.Name("refreshInsideList"), object: self, userInfo:fileDict)
                }  else if (self.requestView == "NasSendFolderSelectVC"){
                    self.nasSendFolderSelectVC?.notifiedSyncFinish(rootFolder:self.getRootFolder)
                } else if(self.requestView == "NasSendController"){
                    self.nasSendController?.notifiedSyncFinish(rootFolder:self.getRootFolder)
                }
                break
            case .failure(let error):
                NSLog(error.localizedDescription)
                
                break
            }
        }
    }
}

