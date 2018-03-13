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
    var loginToken:String = App.defaults.loginToken
    var loginCookie:String = App.defaults.loginCookie
    var userId = App.defaults.userId
    var uuId = Util.getUuid()
    
    func sync(){
        getFileList()
    }
    
    
    
    func sysncFoldrInfo() {
        print("syncFolerInfo Called")
        folderArrayToCreate.removeAll()
        //모바일 폴더 동기화 리스트
        Alamofire.request(App.URL.server+"mobileFoldrList.json"
            , method: .post
            , parameters:["userId":userId, "devUuid":uuId as Any]
            , encoding : JSONEncoding.default
            , headers: App.Headrs.jsonHeader
            ).responseJSON { response in
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if let statusCode = json["statusCode"].int, statusCode == 100 {
                        let serverList:[AnyObject] = json["listData"].arrayObject! as [AnyObject]
                        if(json["listData"].exists()){
                            print()
                            if(serverList.count < 1){
//                                print(serverList.count)
                                for (_, folder) in self.localFolderArray.enumerated() {
                                    let parameter = folder.getParameter
                                    print("parameter : \(parameter)")
                                    self.folderArrayToCreate.append(parameter)
                                }
                            } else {
                                print("jsonlistData: \(json["listData"])")
                                
                                var serverFolderPathArray:[String] = []
                                
                                for serverFolder in serverList{
                                    print("serverFile[folderNm] : \(serverFolder["foldrNm"])")
                                    for localFolder in self.localFolderArray {
                                        let serverFolderPath = "\(serverFolder["foldrWholePathNm"] as! String))"
                                        let localFolderPath = "\(localFolder.foldrWholePathNm)"
                                        print("serverFolderPath : \(serverFolderPath), localFolderPath: \(localFolderPath)")
                                        if(serverFolderPath == localFolderPath){
                                        } else {
                                            self.folderArrayToCreate.append(localFolder.getParameter)
                                            print("folderArrayToCreate : \(self.folderArrayToCreate)")
                                        }
                                    }
                                }
//                                for localFileArray
//                                    if(!serverList.contains(where: {$0["foldrWholePathNm"] as! String == localFolder.foldrWholePathNm})){
//
//                                    } else if (!self.localFolderArray.contains(where: {$0.foldrWholePathNm == serverFolder["foldrWholePathNm"] as! String})) {
//                                        let deleteFolder = App.Folders(data: serverFolder)
//                                        let deleteFolderParameter = App.FoldersToEdit(folder:deleteFolder, cmd:"D").getParameter
//                                        self.folderArrayToDelete.append(deleteFolderParameter)
//                                        print("folderArrayToDelete : \(self.folderArrayToDelete)")
//                                    }
//
//                                }
                                print("sysncFoldrInfo : \(serverList)")
                            }
                            if(self.folderArrayToCreate.count > 0){
                                print("createfolder : \(self.folderArrayToCreate)")
                                self.createFolderListToServer(parameters: self.folderArrayToCreate)
                            }
                            if(self.folderArrayToUpdate.count > 0){
                                self.createFolderListToServer(parameters: self.folderArrayToUpdate)
                                print("updateefolder : \(self.folderArrayToDelete)")
                            }
                            if(self.folderArrayToDelete.count > 0){
                                self.createFolderListToServer(parameters: self.folderArrayToDelete)
                                print("deletefolder : \(self.folderArrayToDelete)")
                            }
                            self.folderSyncFinished = true
//                            self.sysncFileInfo()
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
        print("syncFileInfo called")
        FileParameterArrayForUpload.removeAll()
        fileArrayToUpdate.removeAll()
        fileArrayToDelete.removeAll()
        fileArrayToCreate.removeAll()
        
        GetListFromServer().getFoldrList(devUuid: uuId, userId:App.defaults.userId, deviceName:"sdf"){ responseObject, error in
            let json = JSON(responseObject!)
            if(json["listData"].exists()){
                let serverList:[AnyObject] = json["listData"].arrayObject! as [AnyObject]
                print("nasfolderList :\(serverList)")
                for rootFolder in serverList{
                    let foldrId = rootFolder["foldrId"] as? Int ?? 0
                    let stringFoldrId = String(foldrId)
                    let froldrNm = rootFolder["foldrNm"] as? String ?? "nil"
                    let stringFroldrNm = String(froldrNm)
                    self.showInsideList(userId: App.defaults.userId, devUuid: self.uuId, foldrId: stringFoldrId, deviceName:"sdf")
                }
            }
            return
        }
    }
    
    func showInsideList(userId: String, devUuid: String, foldrId: String, deviceName:String){
        var param = ["userId": userId, "devUuid":devUuid, "foldrId":foldrId,"sortBy":"kind"]
        GetListFromServer().showInsideFoldrList(params: param, deviceName:deviceName){ responseObject, error in
            let json = JSON(responseObject!)
            if(json["listData"].exists()){
                let serverList:[AnyObject] = json["listData"].arrayObject as! [AnyObject]
                print("showInsideList :\(serverList)")
                for list in serverList{
                    let folder = App.FolderStruct(data: list as AnyObject)
                }
                self.getFileListFromServer(userId: userId, devUuid: devUuid, foldrId: foldrId)
            }
            return
        }
        
    }
    func getFileListFromServer(userId: String, devUuid: String, foldrId: String){
        var param:[String : Any] = ["userId": userId, "devUuid":devUuid, "foldrId":foldrId,"page":1,"sortBy":"kind"]
        let urlString = App.URL.server+"listFile.json"
        Alamofire.request(urlString,
                          method: .post,
                          parameters: param,
                          encoding : JSONEncoding.default,
                          headers: App.Headrs.jsonHeader).responseJSON{ (response) in
                            switch response.result {
                            case .success(let value):
                                let json = JSON(value)
                                let responseData = value as! NSDictionary
                                let message = responseData.object(forKey: "message")
                                print("showFolderInfo json : \(json)")
                                if(json["listData"].exists()){
                                    let serverList:[AnyObject] = json["listData"].arrayObject as! [AnyObject]
                                    print("syncfileLIst : \(serverList)")
                                    
                                    var serverFileIdArray:[String] = []
                                    
                                    for serverFile in serverList{
                                        let serverFileId = serverFile["fileId"] as? Int ?? 0
                                        let stringServerFileId = String(serverFileId)
                                        serverFileIdArray.append(stringServerFileId)
                                    }
                                    var localFileIdArray:[String] = []
                                    if(self.localFileArray.count > 0){
                                        for localFile in self.localFileArray {
                                            let fileSavedPath = "\(localFile.savedPath)"
                                            print("fileSavedPath :\(fileSavedPath)" )
                                            let fileId = DbHelper().getLocalFileId(path: fileSavedPath)
                                            localFileIdArray.append(fileId)
                                        }
                                    }
//                                    print("serverFileIdArray : \(serverFileIdArray)")
//                                    print("localFileIdArray : \(localFileIdArray)")
                                    for serverFile in serverList{
                                        let serverFileId = serverFile["fileId"] as? Int ?? 0
                                        let stringServerFileId = String(serverFileId)
                                        if !localFileIdArray.contains(stringServerFileId) {
                                            let deleteFile = App.Files(data: serverFile)
                                            let deleteFileParameter = App.FilesToEdit(file:deleteFile, cmd:"D").getDeleteParameter
                                            self.fileArrayToDelete.append(deleteFileParameter)
                                        } else {
                                            
                                        }
                                    }
                                    for localFile in self.localFileArray {
                                        let fileSavedPath = "\(localFile.savedPath)"
                                        let fileId = DbHelper().getLocalFileId(path: fileSavedPath)
                                        if(!serverFileIdArray.contains(fileId)){
                                            self.fileArrayToCreate.append(localFile.getParameter)
                                            print("localFile.etsionNm : \(localFile.etsionNm)")
                                            print("fileArrayToCreate1 : \(self.fileArrayToCreate)")
                                        } else {
                                            
                                        }
                                    }
                                } else {
                                    if(self.localFileArray.count > 0 ){
                                        for localFile in self.localFileArray {
                                            self.fileArrayToCreate.append(localFile.getParameter)
                                            print("fileArrayToCreate2 : \(self.fileArrayToCreate.count)")
                                        }
                                    }
                                }
                               
                               
                                if(self.fileArrayToDelete.count > 0){
                                    print("delete call")
                                    print("fileArrayToDelete count : \(self.fileArrayToDelete.count), fileArrayToCreate.count : \(self.fileArrayToCreate.count)" )
                                    print("fileArrayToDelete : \(self.fileArrayToDelete)" )
                                    self.deleteFileListToServer(parameters: self.fileArrayToDelete)
                                } else {
                                    if(self.fileArrayToCreate.count>0){
                                        print("fileArrayToDelete count : \(self.fileArrayToDelete.count), fileArrayToCreate.count : \(self.fileArrayToCreate.count)" )
                                        print("create filelist : \(self.fileArrayToCreate)")
                                        self.createFileListToServer(parameters: self.fileArrayToCreate)
                                    }
                                }
                                break
                            case .failure(let error):
                                NSLog(error.localizedDescription)
                                break
                            default:
                                print(response)
                                break
                            }
                            
        }
    }
    func getFileList(){
        localFileArray.removeAll()
        localFolderArray.removeAll()
        folderPathArray.removeAll()
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        localFileArray = FileUtil().getFileList()
        for localFile in localFileArray{
            print("localFileetsionNm : \(localFile.etsionNm)")
        }
        
        let subDirs = documentsURL.subDirectories
        let folder = App.Folders(cmd : "C", userId : userId, devUuid : uuId, foldrNm : "", foldrWholePathNm: "/Mobile", cretDate : "", amdDate : "")
        localFolderArray.append(folder)
        
        getSubDirectories(subDirs: subDirs, foldrWholePath: "/Mobile")
        
        
    }
    
    func getSubDirectories(subDirs:[URL], foldrWholePath:String){
        if(subDirs.count > 0){
            for subDir in subDirs{
                do{
                    let attribute = try FileManager.default.attributesOfItem(atPath: subDir.path)
                    var folderName:String = (NSURL(fileURLWithPath: subDir.lastPathComponent).deletingPathExtension?.lastPathComponent)!
                    let folderCreateDate: Date = attribute[FileAttributeKey.creationDate] as! Date
                    let modifiedDate: Date = attribute[FileAttributeKey.modificationDate] as! Date
                    let foldrWholePathNm = "\(foldrWholePath)/\(folderName)"
                    let folder = App.Folders(cmd : "C", userId : userId, devUuid : uuId, foldrNm : folderName, foldrWholePathNm: foldrWholePathNm, cretDate : Util.date(text: folderCreateDate), amdDate : Util.date(text: modifiedDate))
                    
                    localFolderArray.append(folder)
                    
                    if(subDir.subDirectories.count > 0){
                        getSubDirectories(subDirs: subDir.subDirectories, foldrWholePath: foldrWholePathNm)
                        return
                    }
                    
                } catch {
                    print("Error: \(error)")
                }
            }
        }
        print("localFolderArray : \(localFolderArray)")
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
                print("createFolderListToServer : \(message)")
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
                print("deleteFileListToServer : \(response.result)")
                let responseData = value as! NSDictionary
                let message = responseData.object(forKey: "message")
//                print(" deleteFileListToServer message : \(message)")
                if(self.fileArrayToCreate.count>0){
//                    print("create filelist : \(self.fileArrayToCreate)")
                    self.createFileListToServer(parameters: self.fileArrayToCreate)
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
                print("createFileServer : \(response.result)")
                let responseData = value as! NSDictionary
                let message = responseData.object(forKey: "message")
                print(" createFileListToServer message : \(String(describing: message))")
                
                break
            case .failure(let error):
                NSLog(error.localizedDescription)
                
                break
            }
        }
    }
}

