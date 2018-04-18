//
//  SendFolderToGdriveFromNAS.swift
//  KT
//
//  Created by 이다한 on 2018. 4. 9..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GoogleSignIn
import Alamofire
import SwiftyJSON

class SendFolderToGdriveFromNAS{
    var accessToken = ""
    var newFoldrWholePathNm = ""
    var oldFoldrWholePathNm = ""
    var upFoldersToDelete = ""
    var newPath = ""
    var style = ""
    var toSavePathParent = ""
    var nasSendFolderSelectVC:NasSendFolderSelectVC?
    var multiCheckedfolderArray:[App.FolderStruct] = []
    var gdriveFolderIdDict:[String:String] = [:]
    var forSaveFolderId = ""
    var loginCookie = UserDefaults.standard.string(forKey: "cookie") ?? "nil"
    var loginToken = UserDefaults.standard.string(forKey: "token") ?? "nil"
    var jsonHeader:[String:String] = [
        "Content-Type": "application/json",
        "X-Auth-Token": UserDefaults.standard.string(forKey: "token")!,
        "Cookie": UserDefaults.standard.string(forKey: "cookie")!
    ]
    var folderIdsToDownLoad:[Int] = []
    var googleFolderIdsToDownLoad:[String] = []
    var folderPathToDownLoad:[String] = []
    var fileArrayToDownload:[App.FolderStruct] = []
    var userId = UserDefaults.standard.string(forKey: "userId") as? String ?? "nil"
    var uuid = Util.getUuid()
    var selectedDevUuid = ""
    var selectedUserId = ""
    var selectedDeviceName = ""
    var driveFileArray:[App.DriveFileStruct] = []
    
    
   
    //다운로드 from nas to google drive 시작
    
    func downloadFolderFromNas(foldrId:Int, foldrWholePathNm:String, userId:String, devUuid:String, deviceName:String, getAccessToken: String, getNewFoldrWholePathNm: String,  getGdriveFolderIdToSave: String, getOldFoldrWholePathNm: String,  getMultiArray: [App.FolderStruct], fileId:String, parent:NasSendFolderSelectVC){
        
        
        selectedUserId = userId
        selectedDevUuid = devUuid
        selectedDeviceName = deviceName
        toSavePathParent = getGdriveFolderIdToSave
        accessToken = getAccessToken
        newFoldrWholePathNm = getNewFoldrWholePathNm
        oldFoldrWholePathNm = getOldFoldrWholePathNm
        print("oldFoldrWholePathNm : \(oldFoldrWholePathNm), newFoldrWholePathNm : \(newFoldrWholePathNm), selectedDeviceName:\(selectedDeviceName)")
        
        multiCheckedfolderArray = getMultiArray
        nasSendFolderSelectVC = parent
        folderIdsToDownLoad.removeAll()
        folderPathToDownLoad.removeAll()
        fileArrayToDownload.removeAll()
        if(nasSendFolderSelectVC?.indicatorAnimating)!{
        } else {
            NotificationCenter.default.post(name: Notification.Name("NasSendFolderSelectVCToggleIndicator"), object: self, userInfo: nil)
        }
        
        print("call from downloadFolderFromNas")
        getFolderIdsToDownload(foldrId: foldrId, foldrWholePathNm: foldrWholePathNm, userId:userId, devUuid:selectedDevUuid,deviceName:selectedDeviceName)
    }
    
    
    func getFolderIdsToDownload(foldrId:Int, foldrWholePathNm:String, userId:String, devUuid:String, deviceName:String) {
        let param = ["userId": userId, "devUuid":devUuid, "foldrId":String(foldrId),"sortBy":""]
        print("param : \(param)")
        GetListFromServer().getMobileFoldrLIst(devUuid:devUuid, userId:userId, deviceName: deviceName) { responseObject, error in
            let json = JSON(responseObject!)
            if(json["listData"].exists()){
                let serverList:[AnyObject] = json["listData"].arrayObject! as [AnyObject]
                if (serverList.count > 0){
                    for list in serverList {
                        
                        let folderPath = list["foldrWholePathNm"] as? String ?? "nil"
                        let foldrId = list["foldrId"] as? Int ?? 0
                        if(folderPath.contains(self.oldFoldrWholePathNm)){
                            print("list : \(list)")
                            self.folderIdsToDownLoad.append(foldrId)
                            self.folderPathToDownLoad.append(folderPath)
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
        upFoldersToDelete = ""
        let saveRootFoldrArray = folderPathToDownLoad[0].components(separatedBy: "/")
        for (index, name) in saveRootFoldrArray.enumerated() {
            if(0 < index && index < saveRootFoldrArray.count - 1){
                upFoldersToDelete += "/\(saveRootFoldrArray[index])"
            }
        }
        print("upFoldersToDelete : \(upFoldersToDelete)")
        for name in folderPathToDownLoad {
            var fullName = "tmp\(name)"
            fullName = fullName.replacingOccurrences(of: upFoldersToDelete, with: "")
            print("fullName : \(fullName)")
            let createdPath:URL = self.createLocalFolder(folderName: fullName)!
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
            let index = folderIdsToDownLoad.count - 1
            if(index > -1){
                let stringFolderId = String(folderIdsToDownLoad[index])
                getFileListToDownload(userId: userId, devUuid: selectedDevUuid, foldrId: stringFolderId, index:index)
                return
            }
        }
        self.downloadFile()
        print("file download start")
        
    }
    
    func getFileListToDownload(userId: String, devUuid: String, foldrId: String, index:Int){
        let param:[String : Any] = ["userId": selectedUserId, "devUuid":selectedDevUuid, "foldrId":foldrId,"page":1,"sortBy":""]
        print("param : \(param)")
        GetListFromServer().getFileList(params: param){ responseObject, error in
            let json = JSON(responseObject!)
            //            let message = responseObject?.object(forKey: "message")
            if(json["listData"].exists()){
//                let listData = json["listData"]
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
                print("downPath : \(downPath)")
                let downId = String(fileArrayToDownload[index].fileId)
                callDownloadFromNasFolder(name: downFileName, path: downPath, fileId: downId, index:index)
                return
            }
            
        }
        self.finishDownload()
    }
    
    
    
    
    func callDownloadFromNasFolder(name:String, path:String, fileId:String, index:Int){
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
    
    func downloadFromNasFolder(userId:String, fileNm:String, path:String, fileId:String, completionHandler: @escaping (String?, NSError?) -> ()){
        var stringUrl = "https://araise.iptime.org/namespace/ifs/home/gs-\(userId)/\(userId)-gs\(path)/\(fileNm)"
        stringUrl = stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        let user = userId
        let password:String = UserDefaults.standard.string(forKey: "userPassword")!
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
       
        print("save path : tmp\(editPath)/\(saveFileNm)")
        let downloadUrl:URL = URL(string: stringUrl)!
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent("tmp\(editPath)/\(saveFileNm)")
            return (documentsURL, [.removePreviousFile])
        }
        
        Alamofire.download(downloadUrl, method: .get, headers:headers, to: destination)
            .downloadProgress(closure: { (progress) in
//                print("download progress : \(progress.fractionCompleted)")
                //                 completionHandler(progress.fractionCoprintmpleted, nil)
            })
            .response { response in
//                print("response : \(response)")
                if response.destinationURL != nil {
                    print(response.destinationURL!)
                    if let path = response.destinationURL?.path{
                        completionHandler("success", nil)
                    }
                    
                }
        }
    }
    func finishDownload(){
        
        print("download finish, toSavePathParent: \(toSavePathParent)")
        
        readyCreatFolders(getAccessToken: accessToken, getNewFoldrWholePathNm: newFoldrWholePathNm, getOldFoldrWholePathNm: oldFoldrWholePathNm,  getMultiArray: multiCheckedfolderArray, fileId: toSavePathParent, parent: nasSendFolderSelectVC!)
    }
    
    
    
    
    func sendToDriveFromLocal(name:String, parentFileId:String, fileURL:URL, completionHandler: @escaping (NSDictionary?, NSError?) -> ()){
        var fileSize:Double = 0
        do {
            let attribute = try FileManager.default.attributesOfItem(atPath: (fileURL.path))
            if let size = attribute[FileAttributeKey.size] as? NSNumber {
                fileSize = size.doubleValue
                print("fileSzie : \(fileSize)")
            }
        } catch {
            print("Error: \(error)")
        }
        let fileExtension = fileURL.pathExtension
        let googleMimeType:String = Util.getGoogleMimeType(etsionNm: fileExtension)
        print("fileExtension : \(fileExtension), googleMimeType : \(googleMimeType)")
        let stringUrl = "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart"
        let headers = [
            "Authorization": "Bearer \(accessToken)",
            "Content-type": "multipart/related; boundary=foo_bar_baz",
            "Content-Length": "\(fileSize)"
        ]
        var addParents = ""
        if (parentFileId.isEmpty){
            
        } else {
            addParents = ",'parents' : [ '\(parentFileId)' ]"
        }
        do {
            let data = try Data(contentsOf: fileURL as URL)
            Alamofire.upload(multipartFormData: { multipartFormData in
                multipartFormData.append("{'name':'\(name)'\(addParents) }".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName :"foo_bar_baz", mimeType: "application/json; charset=UTF-8")
                
                multipartFormData.append(data, withName: "foo_bar_baz", fileName: name, mimeType: googleMimeType)
                
            }, usingThreshold: UInt64.init(), to: stringUrl, method: .post, headers: headers,
               encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        //                        print("response:: \(response)")
                        completionHandler(response as? NSDictionary, nil)
                    }
                    break
                case .failure(let encodingError):
                    print(encodingError.localizedDescription)
                    break
                }
            })
        } catch {
            print("Unable to load data: \(error)")
        }
        
    }
    
    func createFolderInGdrive(name:String, fileId:String,  completionHandler: @escaping (NSDictionary?, NSError?) -> ()){
        let googleMimeType:String = Util.getGoogleMimeType(etsionNm: "folder")
        print("googleMimeType : \(googleMimeType)")
        var stringUrl = "https://www.googleapis.com/drive/v2/files"
        stringUrl = stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        var request = URLRequest(url: try! (stringUrl).asURL())
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let values:[String:Any] = [
            "title":"\(name)",
            "mimeType": "application/vnd.google-apps.folder",
            "parents": [
                [
                    "id":"\(fileId)"
                ]
            ]
        ]
        request.httpBody = try! JSONSerialization.data(withJSONObject: values)
        Alamofire.request(request).responseJSON { response in
            
            switch response.result {
            case .success(let value):
                //                    print("value : \(value)")
                //                    print("request body: \(request.httpBody)")
                completionHandler(value as? NSDictionary, nil)
                
                break
            case .failure(let error):
                NSLog(error.localizedDescription)
                completionHandler(nil, error as NSError)
                break
            }
        }
        
    }
    
    ////폴더 gdrive upload 시작
    
    func readyCreatFolders(getAccessToken:String, getNewFoldrWholePathNm:String, getOldFoldrWholePathNm:String, getMultiArray : [App.FolderStruct], fileId: String, parent:NasSendFolderSelectVC){
        if(parent.indicatorAnimating) {
            
        } else {
            NotificationCenter.default.post(name: Notification.Name("NasSendFolderSelectVCToggleIndicator"), object: self, userInfo: nil)
        }
        
        let folders:[App.Folders] = FileUtil().getFolderList()
        //        print("folders : \(folders)")
        var foldersToCreate:[String] = []
        accessToken = getAccessToken
        newFoldrWholePathNm = getNewFoldrWholePathNm
        oldFoldrWholePathNm = getOldFoldrWholePathNm
        print("oldFoldrWholePathNm : \(oldFoldrWholePathNm)")
        let oldFolderRoot = oldFoldrWholePathNm.components(separatedBy: "/")[1]
        print("oldFolderRoot : \(oldFolderRoot)")
        oldFoldrWholePathNm = oldFoldrWholePathNm.replacingOccurrences(of: upFoldersToDelete, with: "/tmp")
        print("oldFoldrWholePathNm : \(oldFoldrWholePathNm), newFoldrWholePathNm: \(newFoldrWholePathNm)")
        multiCheckedfolderArray = getMultiArray
        nasSendFolderSelectVC = parent
        gdriveFolderIdDict.removeAll()
        for folder in folders{
            print("folder.foldrWholePathNm : \(folder.foldrWholePathNm) , oldFoldrWholePathNm : \(oldFoldrWholePathNm)")
            if folder.foldrWholePathNm.contains(oldFoldrWholePathNm) {
                print(folder.foldrWholePathNm)
                var path = folder.foldrWholePathNm
                print("local path : \(path)")
                path = path.replacingOccurrences(of: "/Mobile/tmp", with: newFoldrWholePathNm)
                
                foldersToCreate.append(path)
            }
        }
        
        foldersToCreate.reverse()
        print("path to update : \(foldersToCreate)")
        gdriveFolderIdDict.updateValue(toSavePathParent, forKey: "\(newFoldrWholePathNm)/")
        print("toSavePathParent : \(toSavePathParent)")
        print("gdriveFolderIdDict : \(gdriveFolderIdDict)")
        createFolders(foldersToCreate: foldersToCreate)
    }
    
    func createFolders(foldersToCreate:[String]) {
        if(foldersToCreate.count > 0){
            let index = foldersToCreate.count - 1
            if(index > -1){
                print("gdriveFolderIdDict : \(gdriveFolderIdDict)")
                let folderPathArray = foldersToCreate[index].components(separatedBy: "/")
                let foldername = folderPathArray[folderPathArray.count - 2]
                print("foldername : \(foldername)")
                var parentFolder = ""
                for (index, path) in folderPathArray.enumerated() {
                    if( index < folderPathArray.count - 2){
                        parentFolder += "\(folderPathArray[index])/"
                    }
                }
                print("parentFolder : \(parentFolder)")
                for foldrIdStruct in gdriveFolderIdDict {
                    if(parentFolder == foldrIdStruct.key) {
                        print("parentFolderId : \(foldrIdStruct.value)")
                        let parentFolderId = foldrIdStruct.value
                        let param = ["accessToken":accessToken, "foldrWholePathNm":foldersToCreate[index]]
                        callCreateGoogleDriveFolder(name:foldername, index: index, foldersToCreate:foldersToCreate, parentFolderId:parentFolderId)
                    }
                }
                return
            }
        }
        print("initcreateFile")
        initForUploadFiles()
    }
    func callCreateGoogleDriveFolder(name:String, index:Int, foldersToCreate:[String], parentFolderId:String){
        createFolderInGdrive(name: name, fileId: parentFolderId) { responseObject, error in
            //            print("responseObject : \(responseObject)")
            let json = JSON(responseObject as Any)
            if let id = responseObject?.object(forKey: "id") as? String {
                self.forSaveFolderId = id
                print("created file Id : \(id)")
                var newFolders = foldersToCreate
                self.gdriveFolderIdDict.updateValue(id, forKey: newFolders[index])
                newFolders.remove(at: index)
                
                self.createFolders(foldersToCreate: newFolders)
                
            }
            
        }
        
    }
    
    func initForUploadFiles(){
        var files:[App.LocalFiles] = []
        let localFiles = FileUtil().getFileLIst()
        for file in localFiles {
            let localFileNm = file.fileNm
            let localFilePath = file.savedPath
            let localFileAmdDate = file.amdDate
            print("file path: \(localFilePath), oldFoldrWholePathNm : \(self.oldFoldrWholePathNm), fileName : \(localFileNm), amdDate : \(localFileAmdDate), ")
            if  localFilePath.contains(self.oldFoldrWholePathNm) {
                files.append(file)
            }

        }
        print("files to upload count : \(files.count), files : \(files)")
        self.uploadFile(files: files)

//        GetListFromServer().getMobileFileLIst(devUuid: Util.getUuid(), userId:App.defaults.userId, deviceName:"sdf"){ responseObject, error in
//            let json = JSON(responseObject!)
//            if(json["listData"].exists()){
//                let serverList:[AnyObject] = json["listData"].arrayObject! as [AnyObject]
//                for serverFile in serverList{
//                    let serverFileNm = serverFile["fileNm"] as? String ?? "nil"
//                    let serverFilePath = serverFile["foldrWholePathNm"] as? String ?? "nil"
//                    let serverFileAmdDate = serverFile["amdDate"] as? String ?? "nil"
//                    print("file path to update : \(serverFilePath), oldFoldrWholePathNm : \(self.oldFoldrWholePathNm), fileName : \(serverFileNm), amdDate : \(serverFileAmdDate), ")
//                    if  serverFilePath.contains(self.oldFoldrWholePathNm) {
//
//                        fileToUpload.append(serverFilePath)
//                        let uploadFile:App.Files = App.Files(data: serverFile)
//                        files.append(uploadFile)
//                    }
//
//                }
//                print("files to upload count : \(files.count)")
//                self.uploadFile(files: files)
//            }
//
//        }
    }
    
    func uploadFile(files:[App.LocalFiles]){
        print("uploadFile :\(uploadFile)")
        if(files.count > 0){
            let index = files.count - 1
            if(index > -1){
                let originalFileName = "\(files[index].fileNm).\(files[index].etsionNm)"
                let amdDate = files[index].amdDate
                let savedPath = files[index].savedPath
                let folderPath = files[index].foldrWholePathNm
                let folderPathArray = folderPath.components(separatedBy: "/")
                let foldername = folderPathArray[folderPathArray.count - 1]
                print("foldername : \(foldername)")
                var parentFolder = ""
                parentFolder = folderPath.replacingOccurrences(of: "/Mobile/tmp", with: newFoldrWholePathNm)
                parentFolder += "/"
                print("parentFolder : \(parentFolder), gdriveFolderIdDict : \(gdriveFolderIdDict)")
                for foldrIdStruct in gdriveFolderIdDict {
                    if(parentFolder == foldrIdStruct.key) {
                        print("parentFolderId : \(foldrIdStruct.value)")
                        let parentFolderId = foldrIdStruct.value
                        if let fileUrl:URL = FileUtil().getFileUrlFromPath(filePath:savedPath) {
                            sendToDriveFromLocal(name: originalFileName, parentFileId: parentFolderId, fileURL: fileUrl) { responseObject, error in
                                let json = JSON(responseObject as? NSDictionary)
                                var newFiles = files
                                newFiles.remove(at: newFiles.count - 1)
                                self.uploadFile(files: newFiles)
                            }
                        }
                    }
                }
                return
            }
        }
        print("upload Files finish")
        if(multiCheckedfolderArray.count > 0){
            
            let lastIndex = multiCheckedfolderArray.count - 1
            multiCheckedfolderArray.remove(at: lastIndex)
            nasSendFolderSelectVC?.multiCheckedfolderArray = multiCheckedfolderArray
            nasSendFolderSelectVC?.startMultiLocalToGdrive()
            
        } else {
            let pathForRemove:String = FileUtil().getFilePath(fileNm: "tmp", amdDate: "amdDate")
            print("pathForRemove : \(pathForRemove)")
            if(pathForRemove.isEmpty){
                
            } else {
                FileUtil().removeFile(path: pathForRemove)
            }
            nasSendFolderSelectVC?.NasSendFolderSelectVCAlert(title: "업로드에 성공하였습니다.")
            NotificationCenter.default.post(name: Notification.Name("NasSendFolderSelectVCToggleIndicator"), object: self, userInfo: nil)
            
        }
    }
    
    
    func downloadFromNasToSend(userId:String, fileNm:String, path:String, completionHandler: @escaping (String?, NSError?) -> ()){
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = documentDirectory.appendingPathComponent("tmp")
            if !fileManager.fileExists(atPath: filePath.path) {
                do {
                    try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error.localizedDescription)
                }
            }
        } 
        var stringUrl = "https://araise.iptime.org/namespace/ifs/home/gs-\(userId)/\(userId)-gs\(path)/\(fileNm)"
        stringUrl = stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        let user = userId
        let password:String = UserDefaults.standard.string(forKey: "userPassword")!
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
            documentsURL.appendPathComponent("tmp/\(saveFileNm)")
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
    
}

