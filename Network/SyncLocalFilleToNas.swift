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
        
        GetListFromServer().getFoldrList(devUuid: uuId, userId:App.defaults.userId, deviceName:"sdf"){ responseObject, error in
            let json = JSON(responseObject!)
            if(json["listData"].exists()){
                let serverList:[AnyObject] = json["listData"].arrayObject! as [AnyObject]
//                print("nasfolderList :\(serverList)")
                for rootFolder in serverList{
                    let foldrId = rootFolder["foldrId"] as? Int ?? 0
                    let stringFoldrId = String(foldrId)
                    let froldrNm = rootFolder["foldrNm"] as? String ?? "nil"
                    let stringFroldrNm = String(froldrNm)
                    self.showInsideList(userId: App.defaults.userId, devUuid: self.uuId, foldrId: stringFoldrId, deviceName:"sdf")
                }
            }
            
        }
    }
    
    func showInsideList(userId: String, devUuid: String, foldrId: String, deviceName:String){
        var param = ["userId": userId, "devUuid":devUuid, "foldrId":foldrId,"sortBy":"kind"]
        GetListFromServer().showInsideFoldrList(params: param, deviceName:deviceName){ responseObject, error in
            let json = JSON(responseObject!)
            if(json["listData"].exists()){
                let serverList:[AnyObject] = json["listData"].arrayObject as! [AnyObject]
//                print("showInsideList :\(serverList)")
                for list in serverList{
                    let folder = App.FolderStruct(data: list as AnyObject)
                }
                self.getFileListFromServer(userId: userId, devUuid: devUuid, foldrId: foldrId)
            }
            
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
//                                let message = responseData.object(forKey: "message")
//                                print("showFolderInfo json : \(json)")
                                if(json["listData"].exists()){
                                    let serverList:[AnyObject] = json["listData"].arrayObject as! [AnyObject]
//                                    print("syncfileLIst : \(serverList)")
                                    
                                    var serverFilePathArray:[String] = []
                                    
                                    
                                    for serverFile in serverList{
                                        print("server : \(serverFile)")
                                        let serverFileNm = serverFile["fileNm"] as? String ?? "nil"
                                        let serverFilePath = serverFile["foldrWholePathNm"] as? String ?? "nil"
                                        if let pathNmArray = URLComponents(string: serverFilePath)?.path.components(separatedBy: "/") {
                                            var foldrWholePathNm = "/Mobile"
                                            for (index, path) in pathNmArray.enumerated() {
                                                if(1 < index && index < pathNmArray.count){
                                                    foldrWholePathNm += "/\(pathNmArray[index])"
                                                }
                                            }
                                            foldrWholePathNm += "/\(serverFileNm)"
                                            print("server foldrWholePathNm : \(foldrWholePathNm)")
                                            serverFilePathArray.append(foldrWholePathNm)
                                        }
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
                                        var foldrWholePathNm = "/Mobile"
                                        if let pathNmArray = URLComponents(string: foldrWholePathNm)?.path.components(separatedBy: "/") {
                                            for (index, path) in pathNmArray.enumerated() {
                                                if(2 < index && index < pathNmArray.count){
                                                    foldrWholePathNm += "/\(pathNmArray[index])"
                                                }                                                
                                            }
                                            foldrWholePathNm += "/\(serverFileNm)"
                                            
                                        }
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
                                        } else {
                                            
                                        }
                                    }
                                    
                                    if(self.fileArrayToDelete.count > 0){
                                        print("fileArrayToDelete : \(self.fileArrayToDelete)" )
                                        self.deleteFileListToServer(parameters: self.fileArrayToDelete)
                                    } else {
                                        if(self.fileArrayToCreate.count>0){
                                            print("create filelist : \(self.fileArrayToCreate)")
                                            self.createFileListToServer(parameters: self.fileArrayToCreate)
                                        }
                                    }
                                } else {
                                    if(self.fileArrayToCreate.count>0){
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
//        localFileArray = FileUtil().getFileList()

        let today = Date()
        
        let subDirs = documentsURL.subDirectories
        let folder = App.Folders(cmd : "C", userId : userId, devUuid : uuId, foldrNm : "Mobile", foldrWholePathNm: "/Mobile", cretDate : Util.date(text: today), amdDate : Util.date(text: today))
        localFolderArray.append(folder)
//         print("subDirs : \(subDirs)")
//        getSubDirectories(subDirs: subDirs, foldrWholePath: "/Mobile")

        getFolderList(foldrWholePath: "/Mobile")
//        print("localFolderArray : \(localFolderArray)" )
//        print("localFileArray : \(localFileArray)" )
        
         self.sysncFoldrInfo()
    }
    
    func getFolderList(foldrWholePath:String) {
            let documentsDirectory =  try? FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileEnumerator = FileManager.default.enumerator(at: documentsDirectory!, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions())
            while let file = fileEnumerator?.nextObject() as? URL {
                let fileSavedPath = file.path
                do {
                    let attribute = try FileManager.default.attributesOfItem(atPath: fileSavedPath)
                    let fileName:String = (NSURL(fileURLWithPath: file.lastPathComponent).deletingPathExtension?.lastPathComponent)!
                    let fileExtension = file.pathExtension
                    let folderCreateDate: Date = attribute[FileAttributeKey.creationDate] as! Date
                    let modifiedDate: Date = attribute[FileAttributeKey.modificationDate] as! Date
                    let decodedFileName:String = fileName.removingPercentEncoding!
                  
                    let fileCreateDate: Date = attribute[FileAttributeKey.creationDate] as! Date
                    
                    if(fileExtension.isEmpty){
                        var foldrWholePathNm = "/Mobile"
//                        if let folderNmArray = URLComponents(string: fileSavedPath)?.path.components(separatedBy: "/") {
                        if let folderNmArray = URLComponents(string: fileSavedPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)?.path.components(separatedBy: "/") {
                            
                            let documentIndex = folderNmArray.index(of: "Documents")
                            for (index, path) in folderNmArray.enumerated() {
                                if(documentIndex! < index && index < folderNmArray.count){
                                    foldrWholePathNm += "/\(folderNmArray[index])"
                                }
                            }
                        }
                        
                        let folder = App.Folders(cmd : "C", userId : userId, devUuid : uuId, foldrNm : fileName, foldrWholePathNm: foldrWholePathNm, cretDate : Util.date(text: folderCreateDate), amdDate : Util.date(text: modifiedDate))
                        localFolderArray.append(folder)
                    } else {
                        var foldrWholePathNm = "/Mobile"
                        if let folderNmArray = URLComponents(string: fileSavedPath)?.path.components(separatedBy: "/") {
                            let documentIndex = folderNmArray.index(of: "Documents")
                            let folderNm = folderNmArray[(folderNmArray.count) - 2]
                            let pathLastIndex = (folderNmArray.count) - 1
                            for (index, path) in folderNmArray.enumerated() {
                                if(documentIndex! < index && index < pathLastIndex){
                                    foldrWholePathNm += "/\(folderNmArray[index])"
                                }
                            }
                            
                            if let size = attribute[FileAttributeKey.size] as? NSNumber {
                                if(!fileExtension.isEmpty){
                                    let files = App.LocalFiles(cmd:"C",userId:App.defaults.userId,devUuid:Util.getUuid(),fileNm:decodedFileName,etsionNm:fileExtension,fileSize:size.stringValue,cretDate:Util.date(text: fileCreateDate),amdDate:Util.date(text: modifiedDate), foldrWholePathNm: foldrWholePathNm, savedPath: fileSavedPath)
                                    
                                    localFileArray.append(files)
                                }
                            }
                        }
                    }
                } catch {
                    
                }
        
            }
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

