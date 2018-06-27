//

//  GoogleWork.swift
//  KT
//
//  Created by 이다한 on 2018. 3. 18..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GoogleSignIn
import Alamofire
import SwiftyJSON

class GoogleWork{
    var chunkSize:Double = 102400000000
    var printGoogleFolderPathStarted = false
    var accessToken = ""
    var newFoldrWholePathNm = ""
    var oldFoldrWholePathNm = ""
    var newPath = ""
    var style = ""
    var toSavePathParent = ""
    var containerViewController:ContainerViewController?
    var nasSendController:NasSendController?
    var homeDeviceCollectionVc:HomeDeviceCollectionVC?
    var homeViewController:HomeViewController?
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
    var folderIdsToDownLoad:[String] = []
    var googleFolderIdsToDownLoad:[String] = []
    var folderPathToDownLoad:[String] = []
    var fileArrayToDownload:[App.FolderStruct] = []
    var userId = UserDefaults.standard.string(forKey: "userId") as? String ?? "nil"
    var uuid = Util.getUuid()
    var selectedDevUuid = ""
    var selectedUserId = ""
    var selectedDeviceName = ""
    var driveFileArray:[App.DriveFileStruct] = []
    var request: Alamofire.Request?
    private var resumeData: Data?
    
    func googleSignInCheck(name:String, path:String, fileDict:[String:String]){
        if GIDSignIn.sharedInstance().hasAuthInKeychain() == true {
            GIDSignIn.sharedInstance().signInSilently()
            print("sign in silently")
            
            NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
            
        } else {
            print("need login")
            NotificationCenter.default.post(name: Notification.Name("googleSignInAlertShow"), object: self)
        }
    }
    
    func getFiles(accessToken:String, root:String, completionHandler: @escaping (NSDictionary?, NSError?) -> Void){
        var url = "https://www.googleapis.com/drive/v3/files?q='\(root)' in parents and trashed=false&access_token=\(accessToken)" + App.URL.gDriveFileOption // 0eun
        url = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        Alamofire.request(url,
                          method: .get,
                          encoding: JSONEncoding.default,
                          headers: nil).responseJSON { response in
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
    
    
    func getFilesByName(accessToken:String, fileNm:String, completionHandler: @escaping (NSDictionary?, NSError?) -> Void){
        var url = "https://www.googleapis.com/drive/v3/files?q=name contains '\(fileNm)' and trashed=false&access_token=\(accessToken)" + App.URL.gDriveFileOption // 0eun
//        print("getFilesByName : \(url)")
        url = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        Alamofire.request(url,
                          method: .get,
                          encoding: JSONEncoding.default,
                          headers: nil).responseJSON { response in
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
//            let data = try Data(contentsOf: fileURL as URL)
            let attribute = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            do {
                let attribute = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                if let size = attribute[FileAttributeKey.size] as? NSNumber {
                    fileSize =  size.doubleValue / 1000000.0
                }
            } catch {
                print("Error: \(error)")
            }
            print("FILE Yes AVAILABLE")
            print("stream upload, fileSize : \(fileSize)")
            
            let edited = name.replacingOccurrences(of: "'", with: "\\'")
            let stream:InputStream = InputStream(url: fileURL)!
            let newName = edited.precomposedStringWithCanonicalMapping
            Alamofire.upload(multipartFormData: { multipartFormData in
                multipartFormData.append("{'name':'\(newName)'\(addParents) }".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName :"foo_bar_baz", mimeType: "application/json; charset=UTF-8")
                
//                multipartFormData.append(data, withName: "foo_bar_baz", fileName: name, mimeType: googleMimeType)
                multipartFormData.append(stream, withLength: UInt64(fileSize), name: "foo_bar_baz", fileName: newName, mimeType: googleMimeType)
                
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
                    completionHandler(nil, encodingError as NSError)
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
        var stringUrl = "https://www.googleapis.com//drive/v2/files"
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
    
    func readyCreatFolders(getAccessToken:String, getNewFoldrWholePathNm:String, getOldFoldrWholePathNm:String, getMultiArray : [App.FolderStruct], fileId: String, parent:ContainerViewController, nasSendController:NasSendController){
        
        let folders:[App.Folders] = FileUtil().getFolderList()
//        print("folders : \(folders)")
        var foldersToCreate:[String] = []
        accessToken = getAccessToken
        newFoldrWholePathNm = getNewFoldrWholePathNm
        oldFoldrWholePathNm = getOldFoldrWholePathNm
        print("oldFoldrWholePathNm : \(oldFoldrWholePathNm)")
        let oldFolderRoot = oldFoldrWholePathNm.components(separatedBy: "/")[1]
        print("oldFolderRoot : \(oldFolderRoot)")
        oldFoldrWholePathNm = oldFoldrWholePathNm.replacingOccurrences(of: "/\(oldFolderRoot)", with: "/Mobile")
        print("oldFoldrWholePathNm : \(oldFoldrWholePathNm), newFoldrWholePathNm: \(newFoldrWholePathNm)")
        multiCheckedfolderArray = getMultiArray
        containerViewController = parent
        self.nasSendController = nasSendController
        gdriveFolderIdDict.removeAll()
        for folder in folders{
            if folder.foldrWholePathNm == oldFoldrWholePathNm || folder.foldrWholePathNm.contains("\(oldFoldrWholePathNm)/") {
                print(folder.foldrWholePathNm)
                var path = folder.foldrWholePathNm
                print("local path : \(path)")
                path = "\(path.replacingOccurrences(of: "/Mobile", with: newFoldrWholePathNm))/"

                foldersToCreate.append(path)
            }
        }
        toSavePathParent = getNewFoldrWholePathNm
        foldersToCreate.reverse()
        print("path to update : \(foldersToCreate)")
        gdriveFolderIdDict.updateValue(fileId, forKey: "\(newFoldrWholePathNm)/")
        print("toSavePathParent : \(toSavePathParent)")
        print("gdriveFolderIdDict : \(gdriveFolderIdDict)")
        createFolders(foldersToCreate: foldersToCreate)
    }
    
    func createFolders(foldersToCreate:[String]) {
//        print("count : \(foldersToCreate.count)")
        if(foldersToCreate.count > 0){
            let index = foldersToCreate.count - 1
            if(index > -1){
                print("gdriveFolderIdDict : \(gdriveFolderIdDict)")
                let folderPathArray = foldersToCreate[index].components(separatedBy: "/")
                let foldername = folderPathArray[folderPathArray.count - 2]
                
                print("foldername : \(foldername), folderPathArray : \(folderPathArray)")
                var parentFolder = ""
                for (index, path) in folderPathArray.enumerated() {
                    if( index < folderPathArray.count - 2){
                        parentFolder += "\(folderPathArray[index])/"
                    }
                }
                print("parentFolder : \(parentFolder)")
                
                print("foldersToCreate : \(foldersToCreate)")
                
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
            
            if error == nil {
                if let id = responseObject?.object(forKey: "id") as? String {
                    self.forSaveFolderId = id
                    print("created file Id : \(id)")
                    var newFolders = foldersToCreate
                    print("newFolders : \(newFolders)")
                    self.gdriveFolderIdDict.updateValue(id, forKey: newFolders[index])
                    newFolders.remove(at: index)
                    
                    self.createFolders(foldersToCreate: newFolders)
                    
                }
            } else {
                
            }
            
            
        }
      
    }
    
    func initForUploadFiles(){
        var files:[App.Files] = []
        var fileToUpload:[String] = []
        let userId = UserDefaults.standard.string(forKey: "userId")!
        GetListFromServer().getMobileFileLIst(devUuid: Util.getUuid(), userId:userId, deviceName:"sdf"){ responseObject, error in
            let json = JSON(responseObject!)
            if(json["listData"].exists()){
                let serverList:[AnyObject] = json["listData"].arrayObject! as [AnyObject]
                for serverFile in serverList{
                    let serverFileNm = serverFile["fileNm"] as? String ?? "nil"
                    let serverFilePath = serverFile["foldrWholePathNm"] as? String ?? "nil"
                    let serverFileAmdDate = serverFile["amdDate"] as? String ?? "nil"
                    
                    if  serverFilePath.contains(self.oldFoldrWholePathNm) {
                        print("file path to update : \(serverFilePath), fileName : \(serverFileNm), amdDate : \(serverFileAmdDate)")
                        fileToUpload.append(serverFilePath)
                        let uploadFile:App.Files = App.Files(data: serverFile)
                        files.append(uploadFile)
                    }
                    
                }
                self.uploadFile(files: files)
            }
            
        }
    }
    
    func uploadFile(files:[App.Files]){
//        print("uploadFile :\(files)")
        if(files.count > 0){
            let index = files.count - 1
            if(index > -1){
                let originalFileName = "\(files[index].fileNm)"
                let amdDate = files[index].amdDate
//                let originalFileId = files[index].fileId
                var pathToUpdate = files[index].foldrWholePathNm
                pathToUpdate = pathToUpdate.replacingOccurrences(of: "/Mobile", with: newFoldrWholePathNm)
//                print("uploadFile originalFileName: \(originalFileName), newFoldrWholePathNm: \(newFoldrWholePathNm), pathToUpdate : \(pathToUpdate)")
                let folderPathArray = pathToUpdate.components(separatedBy: "/")
//                let foldername = folderPathArray[folderPathArray.count - 2]
//                print("foldername : \(foldername), folderPathArray : \(folderPathArray)")
                var parentFolder = ""
                for (index, _) in folderPathArray.enumerated() {
                    if( index < folderPathArray.count){
                        parentFolder += "\(folderPathArray[index])/"
                    }
                }
//                print("parentFolder : \(parentFolder)")
                
                for foldrIdStruct in gdriveFolderIdDict {
//                    print("foldrIdStruct : \(foldrIdStruct)")
                    if(parentFolder == foldrIdStruct.key) {
//                        print("parentFolderId : \(foldrIdStruct.value)")
                        let parentFolderId = foldrIdStruct.value
                        if let fileUrl:URL = FileUtil().getFileUrlWithFoldr(fileNm: originalFileName, foldrWholePathNm: files[index].foldrWholePathNm, amdDate: amdDate) {
                            sendToDriveFromLocal(name: originalFileName, parentFileId: parentFolderId, fileURL: fileUrl) { responseObject, error in
                                if error == nil {
//                                    let json = JSON(responseObject as? NSDictionary)
                                    var newFiles = files
                                    newFiles.remove(at: newFiles.count - 1)
                                    self.uploadFile(files: newFiles)
                                    
                                } else {
                                    
                                    //실패처리
                                    if(self.multiCheckedfolderArray.count > 0){
                                        let foldrId:String = "\(self.multiCheckedfolderArray[self.multiCheckedfolderArray.count - 1].foldrId)"
                                        let fileDict = ["fileId":foldrId]
                                        NotificationCenter.default.post(name: Notification.Name("failFileProcess"), object: self, userInfo:fileDict)
                                        
                                        let lastIndex = self.multiCheckedfolderArray.count - 1
                                        self.multiCheckedfolderArray.remove(at: lastIndex)
                                        self.nasSendController?.multiCheckedfolderArray = self.multiCheckedfolderArray
                                        self.nasSendController?.startMultiLocalToGdrive()
                                        
                                    } else {
                                        DispatchQueue.main.async {
                                            self.containerViewController?.showErrorAlert()
                                            
                                        }
                                    }
                                    return
                                    
                                    
                                }
                                
                                
                            }
                        }

                    }
                }
//                return
                
            }
        } else {
            print("upload Files finish")
            if(multiCheckedfolderArray.count > 0){
                let foldrId:String = "\(self.multiCheckedfolderArray[self.multiCheckedfolderArray.count - 1].foldrId)"
                let fileDict = ["fileId":foldrId]
                NotificationCenter.default.post(name: Notification.Name("completeFileProcess"), object: self, userInfo:fileDict)
                
                let lastIndex = multiCheckedfolderArray.count - 1
                multiCheckedfolderArray.remove(at: lastIndex)
                self.nasSendController?.multiCheckedfolderArray = multiCheckedfolderArray
                self.nasSendController?.startMultiLocalToGdrive()
                
            } else {
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: nil, message: "업로드에 성공하였습니다.", preferredStyle: .alert)
                    let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        //Do you Success button Stuff here
                        self.containerViewController?.finishLoading()
                    }
                    alertController.addAction(yesAction)
                    self.containerViewController?.present(alertController, animated: true)
                    
                }
            }
        }
      
    }
    
    
    //다운로드 from nas to google drive 시작
    
    func downloadFolderFromNas(foldrId:String, foldrWholePathNm:String, userId:String, devUuid:String, deviceName:String, getAccessToken: String, getNewFoldrWholePathNm: String,  getGdriveFolderIdToSave: String, getOldFoldrWholePathNm: String,  getMultiArray: [App.FolderStruct], fileId:String, parent:ContainerViewController){
        
        
        selectedUserId = userId
        selectedDevUuid = devUuid
        selectedDeviceName = deviceName
        toSavePathParent = getGdriveFolderIdToSave
        accessToken = getAccessToken
        newFoldrWholePathNm = getNewFoldrWholePathNm
        oldFoldrWholePathNm = getOldFoldrWholePathNm
        print("oldFoldrWholePathNm : \(oldFoldrWholePathNm), newFoldrWholePathNm : \(newFoldrWholePathNm)")
        
        multiCheckedfolderArray = getMultiArray        
        containerViewController = parent
        folderIdsToDownLoad.removeAll()
        folderPathToDownLoad.removeAll()
        fileArrayToDownload.removeAll()
//        if(nasSendFolderSelectVC?.indicatorAnimating)!{
//        } else {
//            NotificationCenter.default.post(name: Notification.Name("NasSendFolderSelectVCToggleIndicator"), object: self, userInfo: nil)
//        }
        print("call from downloadFolderFromNas")
        getFolderIdsToDownload(foldrId: foldrId, foldrWholePathNm: foldrWholePathNm, userId:userId, devUuid:selectedDevUuid,deviceName:deviceName)
    }
    
    
    
    func getFolderIdsToDownload(foldrId:String, foldrWholePathNm:String, userId:String, devUuid:String, deviceName:String) {
        print("get folders")
        folderIdsToDownLoad.append(foldrId)
        print("folderIdsToDownLoad : \(folderIdsToDownLoad)")
        folderPathToDownLoad.append(foldrWholePathNm)
        var foldrLevel = 0
        var param = ["userId": userId, "devUuid":devUuid, "foldrId":String(foldrId),"sortBy":""]
        print("param : \(param)")
        GetListFromServer().showInsideFoldrList(params: param, deviceName:selectedDeviceName) { responseObject, error in
            let json = JSON(responseObject!)
            if(json["listData"].exists()){
                let serverList:[AnyObject] = json["listData"].arrayObject as! [AnyObject]
//                print("download serverList :\(serverList)")
                if (serverList.count > 0){
                    for list in serverList{
                        let folder = App.FolderStruct(data: list as AnyObject)
                        
                        if (self.folderIdsToDownLoad.contains(folder.foldrId)){
                            print("first return called")
                            return
                        } else {
                            print("folder : \(folder.foldrId)")
                            self.folderIdsToDownLoad.append(folder.foldrId)
                            self.folderPathToDownLoad.append(folder.foldrWholePathNm)
                            foldrLevel = list["foldrLevel"] as? Int ?? 0
                            if(foldrLevel > 0){
                                print("second return called")
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
            var folderName = "/tmp"
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
                print("downPath : \(downPath)")
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

        print("download finish, toSavePathParent: \(toSavePathParent)")
        
        readyCreatFolders(getAccessToken: accessToken, getNewFoldrWholePathNm: newFoldrWholePathNm, getOldFoldrWholePathNm: oldFoldrWholePathNm,  getMultiArray: multiCheckedfolderArray, fileId: toSavePathParent, parent: containerViewController!, nasSendController: nasSendController!)
    }
    
    //nas 폴더 다운로드 끝
    
    func downloadGDriveFile(fileId:String, mimeType:String, name:String, startByte:Double, endByte:Double, completionHandler: @escaping (URL?, NSError?) -> ()){
        //        accessToken = UserDefaults.standard.string(forKey: "accessToken")!
        
        if let googleEmail = UserDefaults.standard.string(forKey: "googleEmail"){
//            accessToken = DbHelper().getAccessToken(email: googleEmail)
            accessToken = UserDefaults.standard.string(forKey: "googleAccessToken")!
            let getTokenTime:String = UserDefaults.standard.string(forKey: "googleLoginTime")!
            
            print("fileId : \(fileId), mimeType : \(mimeType), name:\(name)")
            let stringUrl = "https://www.googleapis.com/drive/v3/files/\(fileId)/?alt=media&access_token=\(accessToken)"
//            let stringUrl = "https://www.googleapis.com/drive/v2/files/\(fileId)?access_token=\(accessToken)"
            print("stringUrl : \(stringUrl)")
            
            let downloadUrl = URL(string: stringUrl)
            let newName = name.precomposedStringWithCanonicalMapping
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

                // the name of the file here I kept is yourFileName with appended extension
                documentsURL.appendPathComponent("\(newName)")
                return (documentsURL, [.removePreviousFile])
            }
          
            var newStartByte:Double = 0.0
            let headers = [
                "Authorization": "Bearer \(accessToken)",
                "Range": "bytes=\(startByte)-\(endByte)"
            ]
            
            //            Alamofire.download(request)
            Alamofire.download(downloadUrl!, method: .get, headers:headers, to: destination)
                .downloadProgress(closure: { (progress) in
                    
                    DispatchQueue.main.async {
                        print("gdrive download progress : \(progress.fractionCompleted)")
                    }
                })
                
                .response {response in
                    //                    print("response : \(response)")
                    let statusCode = response.response?.statusCode ?? 0//example : 200
//                    print("statusCode : \(statusCode)")
                    
                    if(statusCode == 200) {
                        print("???")
                        if response.destinationURL != nil {
                            DispatchQueue.main.async {
                                print(response.destinationURL!)
                                completionHandler(response.destinationURL, nil)
                            }
                            
                            
                        }
                        
                    } else if statusCode == 206 {
//                        print("content ragne :\(response.response?.allHeaderFields["content-range"])")
                        if let contentRange:String = response.response?.allHeaderFields["content-range"] as! String {
                            let totalSize = contentRange.split(separator: "/")[1]
                            let inTotalSize:Double = Double(totalSize)!
                            print("totalSize : \(totalSize)")
                            if endByte <= inTotalSize {
                                newStartByte = endByte
                                var newEndByte = endByte + self.chunkSize
                                if newEndByte > inTotalSize {
                                    newEndByte = inTotalSize
                                }
                                print("totalSize : \(totalSize), newStartByte : \(newStartByte), newEndByte : \(newEndByte)")
                                let headers = [
                                    "Authorization": "Bearer \(self.accessToken)",
                                    "Range": "bytes=\(newStartByte)-\(newEndByte)"
                                ]
                                self.request = Alamofire.download(downloadUrl!, method: .get, headers:headers, to: destination)
                            } else {
                                print("download finish")
                            }
                            
                        }
                        
                    } else {
                        DispatchQueue.main.async {
//                            print(response.destinationURL!)
                            completionHandler(nil, response.error as NSError?)
                        }
                    }
                    
            }
           
        }
    }
    func downloadGDriveFileToExcute(fileId:String, mimeType:String, name:String, startByte:Double, endByte:Double, completionHandler: @escaping (URL?, NSError?) -> ()){
            accessToken = UserDefaults.standard.string(forKey: "googleAccessToken")!
//            print("fileId : \(fileId), mimeType : \(mimeType), name:\(name)")
            let stringUrl = "https://www.googleapis.com/drive/v3/files/\(fileId)/?alt=media&access_token=\(accessToken)"
//            print("stringUrl : \(stringUrl)")
            
            let downloadUrl = URL(string: stringUrl)
            let newName = name.precomposedStringWithCanonicalMapping
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                documentsURL.appendPathComponent("AppPlay/\(newName)")
                return (documentsURL, [.removePreviousFile])
            }
            
            var newStartByte:Double = 0.0
            let request = URLRequest(url: try! (stringUrl).asURL())
//            URLCache.shared.removeCachedResponse(for: request)
        
            let headers = [
                "Authorization": "Bearer \(accessToken)",
                "Range": "bytes=\(startByte)-\(endByte)"
            ]
            
            //            Alamofire.download(request)
            Alamofire.download(downloadUrl!, method: .get, headers:headers, to: destination)
                .downloadProgress(closure: { (progress) in
                    
                    DispatchQueue.main.async {
                        print("gdrive download progress : \(progress.fractionCompleted)")
                    }
                })
                
                .response {response in
                    //                    print("response : \(response)")
                    let statusCode = response.response?.statusCode ?? 0//example : 200
                    //                    print("statusCode : \(statusCode)")
                    
                    if(statusCode == 200) {
                        print("???")
                        if response.destinationURL != nil {
                            DispatchQueue.main.async {
                                print(response.destinationURL!)
                                completionHandler(response.destinationURL, nil)
                            }
                            
                            
                        }
                        
                    } else if statusCode == 206 {
                        //                        print("content ragne :\(response.response?.allHeaderFields["content-range"])")
                        if let contentRange:String = response.response?.allHeaderFields["content-range"] as! String {
                            let totalSize = contentRange.split(separator: "/")[1]
                            let inTotalSize:Double = Double(totalSize)!
                            print("totalSize : \(totalSize)")
                            if endByte <= inTotalSize {
                                newStartByte = endByte
                                var newEndByte = endByte + self.chunkSize
                                if newEndByte > inTotalSize {
                                    newEndByte = inTotalSize
                                }
                                print("totalSize : \(totalSize), newStartByte : \(newStartByte), newEndByte : \(newEndByte)")
                                let headers = [
                                    "Authorization": "Bearer \(self.accessToken)",
                                    "Range": "bytes=\(newStartByte)-\(newEndByte)"
                                ]
                                self.request = Alamofire.download(downloadUrl!, method: .get, headers:headers, to: destination)
                            } else {
                                print("download finish")
                            }
                            
                        }
                        
                    } else {
                        DispatchQueue.main.async {
                            //                            print(response.destinationURL!)
                            completionHandler(nil, response.error as NSError?)
                        }
                    }
                    
            }
            
        
    }
    
    func downloadGDriveFileByChunk(fileId:String, mimeType:String, name:String, startByte:Double, endByte:Double, completionHandler: @escaping (URL?, NSError?) -> ()){
        //        accessToken = UserDefaults.standard.string(forKey: "accessToken")!
        
        if let googleEmail = UserDefaults.standard.string(forKey: "googleEmail"){
            //            accessToken = DbHelper().getAccessToken(email: googleEmail)
            accessToken = UserDefaults.standard.string(forKey: "googleAccessToken")!
            let getTokenTime:String = UserDefaults.standard.string(forKey: "googleLoginTime")!
            
            print("fileId : \(fileId), mimeType : \(mimeType), name:\(name)")
            let stringUrl = "https://www.googleapis.com/drive/v3/files/\(fileId)/?alt=media&access_token=\(accessToken)"
            //            let stringUrl = "https://www.googleapis.com/drive/v2/files/\(fileId)?access_token=\(accessToken)"
            print("stringUrl : \(stringUrl)")
            
            let downloadUrl = URL(string: stringUrl)
            let newName = name.precomposedStringWithCanonicalMapping
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                
                // the name of the file here I kept is yourFileName with appended extension
                documentsURL.appendPathComponent("\(newName)")
                return (documentsURL, [.removePreviousFile])
            }
            
            var newStartByte:Double = 0.0
            var request = URLRequest(url: try! (stringUrl).asURL())
//            URLCache.shared.removeCachedResponse(for: request)
       
            var headers = [
                "Authorization": "Bearer \(accessToken)",
                "Range": "bytes=\(startByte)-\(endByte)"
            ]
            
//            Alamofire.download(request)
            Alamofire.download(downloadUrl!, method: .get, headers:headers, to: destination)
                .downloadProgress(closure: { (progress) in
                    
                    DispatchQueue.main.async {
                        print("gdrive download progress : \(progress.fractionCompleted)")
                    }
                    
                    
//                     URLCache.shared.removeAllCachedResponses()
                    
                })
                
                .response {response in
                    //                    print("response : \(response)")
                    let statusCode = response.response?.statusCode ?? 0//example : 200
                    print("statusCode : \(statusCode)")
                    if(statusCode == 200) {
                        print("???")
                        if response.destinationURL != nil {
                            DispatchQueue.main.async {
                                print(response.destinationURL!)
                                completionHandler(response.destinationURL, nil)
                            }
                            
                            
                        }
                        
                    } else if statusCode == 206 {
                        print("content ragne :\(response.response?.allHeaderFields["content-range"])")
                        if let contentRange:String = response.response?.allHeaderFields["content-range"] as! String {
                            let totalSize = contentRange.split(separator: "/")[1]
                            let inTotalSize:Double = Double(totalSize)!
                            print("totalSize : \(totalSize)")
                            if endByte <= inTotalSize {
                                    newStartByte = endByte
                                var newEndByte = endByte + self.chunkSize
                                if newEndByte > inTotalSize {
                                    newEndByte = inTotalSize
                                }
                                print("totalSize : \(totalSize), newStartByte : \(newStartByte), newEndByte : \(newEndByte)")
                                var headers = [
                                    "Authorization": "Bearer \(self.accessToken)",
                                    "Range": "bytes=\(newStartByte)-\(newEndByte)"
                                ]
                                self.request = Alamofire.download(downloadUrl!, method: .get, headers:nil, to: destination)
                            } else {
                                print("download finish")
                            }
                            
                            
                        }
                    }
                    
            }
            
        }
    }
    
    

    func downloadGDriveFileToSendToNas(fileId:String, mimeType:String, name:String, startByte:Double, endByte:Double, completionHandler: @escaping (URL?, NSError?) -> ()){
        //        accessToken = UserDefaults.standard.string(forKey: "accessToken")!
        accessToken = UserDefaults.standard.string(forKey: "googleAccessToken")!
        let getTokenTime:String = UserDefaults.standard.string(forKey: "googleLoginTime")!
        
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
        if let googleEmail = UserDefaults.standard.string(forKey: "googleEmail"){
//            accessToken = DbHelper().getAccessToken(email: googleEmail)
//            print("fileId : \(fileId), mimeType : \(mimeType), name:\(name)")
            let stringUrl = "https://www.googleapis.com/drive/v3/files/\(fileId)/?alt=media&access_token=\(accessToken)"
//            print("stringUrl : \(stringUrl)")
            
            let downloadUrl = URL(string: stringUrl)
            let newName = name.precomposedStringWithCanonicalMapping
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                
                // the name of the file here I kept is yourFileName with appended extension
                documentsURL.appendPathComponent("tmp/\(newName)")
                return (documentsURL, [.removePreviousFile])
            }            
//            let urlRequest = URLRequest(url: downloadUrl!)
//            URLCache.shared.removeCachedResponse(for: urlRequest)
            print("file download from drive in GooglwWork swif")

            
            var newStartByte:Double = 0.0
            var headers = [
                "Authorization": "Bearer \(accessToken)",
                "Range": "bytes=\(startByte)-\(endByte)"
            ]
            
            request = Alamofire.download(downloadUrl!, method: .get, headers:headers, to: destination)
//            Alamofire.download(downloadUrl!, to: destination)
                .downloadProgress(closure: { (progress) in
                    DispatchQueue.main.async {
                        print("gdrive download progress : \(progress.fractionCompleted)")
                    }
                })
                .response {  response in
                    //                    print("response : \(response)")
                    let statusCode = (response.response?.statusCode)! //example : 200
//                    print("statusCode : \(statusCode), response : \(response)")
                    if(statusCode == 200) {
                        if response.destinationURL != nil {
                            DispatchQueue.main.async {
                                print(response.destinationURL!)
                                completionHandler(response.destinationURL, nil)
                            }
                        }
                    }  else if statusCode == 206 {
//                        print("content ragne :\(response.response?.allHeaderFields["content-range"])")
                        if let contentRange:String = response.response?.allHeaderFields["content-range"] as! String {
                            let totalSize = contentRange.split(separator: "/")[1]
                            let inTotalSize:Double = Double(totalSize)!
                            print("totalSize : \(totalSize)")
                            if endByte <= inTotalSize {
                                newStartByte = endByte
                                var newEndByte = endByte + self.chunkSize
                                if newEndByte > inTotalSize {
                                    newEndByte = inTotalSize
                                }
                                print("totalSize : \(totalSize), newStartByte : \(newStartByte), newEndByte : \(newEndByte)")
                                var headers = [
                                    "Authorization": "Bearer \(self.accessToken)",
                                    "Range": "bytes=\(newStartByte)-\(newEndByte)"
                                ]
                                self.request = Alamofire.download(downloadUrl!, method: .get, headers:nil, to: destination)
                            } else {
                                print("download finish")
                            }
                            
                            
                        }
                    }
                    
            }
            
            
        }
        
        
    }
    func copyGdriveFile(name:String, fileId:String, parents:String, completionHandler: @escaping (NSDictionary?, NSError?) -> ()){
        if let googleEmail = UserDefaults.standard.string(forKey: "googleEmail"){
//            accessToken = DbHelper().getAccessToken(email: googleEmail)
            accessToken = UserDefaults.standard.string(forKey: "googleAccessToken")!
            print("accessToken : \(accessToken)")
            var stringUrl = "https://www.googleapis.com/drive/v2/files/\(fileId)/copy"
            stringUrl = stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
            var request = URLRequest(url: try! (stringUrl).asURL())
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            let values:[String:Any] = [
                "parents": [
                    [
                        "id":"\(parents)"
                    ]
                ]
            ]
            request.httpBody = try! JSONSerialization.data(withJSONObject: values)
            Alamofire.request(request).responseJSON { response in
                
                switch response.result {
                case .success(let value):
                    print("value : \(value)")
                    print("request body: \(request.httpBody)")
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
    
    // 구글드라이브 파일 삭제
    func deleteGDriveFile(fileId:String) {
        if let googleEmail = UserDefaults.standard.string(forKey: "googleEmail"){
            
//            accessToken = DbHelper().getAccessToken(email: googleEmail)
            accessToken = UserDefaults.standard.string(forKey: "googleAccessToken")!
            let url = "https://www.googleapis.com/drive/v3/files/\(fileId)"
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + accessToken
            ]
            Alamofire.request(url,
                              method: .delete,
                              //parameters: {},
                encoding : JSONEncoding.default,
                headers:headers
                ).responseJSON{ (response) in
                    print(response)
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        if (json["code"].string != nil) {
                            print(json["code"])
                        } else {
                            print("파일을 삭제하였습니다.")
                        }
                    case .failure(let error):
                        print(error)
                    }
            }
        }
    }
    // 0eun - end
    
    
    // download folder from google drive
    
    func downloadFolderFromGDrive(foldrId:String, getAccessToken: String, fileId:String, downloadRootFolderName:String, containerViewController:ContainerViewController){
        
        selectedUserId = userId
        accessToken = getAccessToken
        print("oldFoldrWholePathNm : \(oldFoldrWholePathNm)")
        self.containerViewController = containerViewController
        googleFolderIdsToDownLoad.removeAll()
        folderPathToDownLoad.removeAll()
        fileArrayToDownload.removeAll()
        driveFileArray.removeAll()
        gdriveFolderIdDict.removeAll()
        print("call from downloadFolderFromGdrive")
        
        let currentFolderPath = "/\(downloadRootFolderName)"
        self.folderPathToDownLoad.append(currentFolderPath)
        gdriveFolderIdDict.updateValue(foldrId, forKey: currentFolderPath)
        getGDriveFolderIdsToDownload(foldrId: foldrId, currentFolderPath:currentFolderPath)
        
    }
    func getGDriveFolderIdsToDownload(foldrId:String, currentFolderPath:String) {
        print("get folders")
        googleFolderIdsToDownLoad.append(foldrId)
        print("folderIdsToDownLoad : \(googleFolderIdsToDownLoad)")
        var url = "https://www.googleapis.com/drive/v3/files?q='\(foldrId)' in parents&trashed=false&access_token=\(accessToken)" + App.URL.gDriveFileOption // 0eun
        
        url = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        print("url : \(url)")
        Alamofire.request(url,
                          method: .get,
                          encoding: JSONEncoding.default,
                          headers: nil).responseJSON { response in
                            switch response.result {
                            case .success(let value):
                                let json = JSON(value)
                                
                                if(json["error"].exists()){
                                    print("error: \(json["error"])")
                                } else {
                                    if let serverList:[AnyObject] = json["files"].arrayObject as [AnyObject]? {
                                        if serverList.count > 0 {
                                            for file in serverList {
                                                print("trashed : \(file["trashed"] as? Int ?? 0)")
                                                if let trashCheck = file["trashed"] as? Int, let sharedCheck = file["shared"] as? Int, let starredCheck = file["starred"] as? Int, trashCheck == 0 && sharedCheck == 0 && starredCheck == 0 {
                                                    let fileStruct = App.DriveFileStruct(device:file, foldrWholePaths:["sd"])
                                                    self.googleFolderIdsToDownLoad.append(fileStruct.fileId)
                                                    let editCurrentFolderPath = "\(currentFolderPath)/\(fileStruct.name)"
                                                    self.folderPathToDownLoad.append(editCurrentFolderPath)
                                                    self.gdriveFolderIdDict.updateValue(fileStruct.fileId, forKey: editCurrentFolderPath)
                                                    print("second return called")
                                                    self.folderChildrenCheck(foldrId: fileStruct.fileId) {
                                                        response in
                                                        if( response > 0){
                                                            self.getGDriveFolderIdsToDownload(foldrId: fileStruct.fileId, currentFolderPath: editCurrentFolderPath)
                                                            return
                                                        }
                                                    }

                                                }
                                            }
                                        } else {
                                            
                                        }
//                                        print("count : \(serverList.count)")
                                        print("json : \(json)")
                                        

                                    } else {
                                        print("no json file")
                                    }
                                }
                                
                            case .failure(let error):
                                NSLog(error.localizedDescription)
                                
                            }
                            
        }
    }
    func folderChildrenCheck(foldrId:String, completion: @escaping (Int) -> Void){
        var url = "https://www.googleapis.com/drive/v3/files?q='\(foldrId)' in parents and mimeType='application/vnd.google-apps.folder'&trashed=false&access_token=\(accessToken)" + App.URL.gDriveFileOption // 0eun
        url = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        Alamofire.request(url,
                          method: .get,
                          encoding: JSONEncoding.default,
                          headers: nil).responseJSON { response in
                            switch response.result {
                            case .success(let value):
                                let json = JSON(value)
                                print("json : \(json)")
                                print("files exist : \(json["files"][0].exists())")
                                print("files exist : \(json["files"][0]["name"].exists())")
                                let endLoop = json["files"][0]["name"].exists()
                                if (!endLoop) {
                                    self.printGoogleFolderPath()
                                }
                                if(json["error"].exists()){
                                    print("error: \(json["error"])")
                                    completion(0)
                                } else {
                                    if let serverList:[AnyObject] = json["files"].arrayObject as! [AnyObject] {
                                        if serverList.count > 0 {
                                            completion(serverList.count)
                                        }
                                        completion(0)
                                    }
                                }
                                
                            case .failure(let error):
                                NSLog(error.localizedDescription)
                                completion(0)
                            }
                            
        }
        
        
    }
    func printGoogleFolderPath(){
        print("folderPathToDownLoad: \(folderPathToDownLoad)")
        print("googleFolderIdsToDownLoad: \(googleFolderIdsToDownLoad)")
        print("gdriveFolderIdDict: \(gdriveFolderIdDict)")
        var localPathArray:[URL] = []
        for name in folderPathToDownLoad {
            
            print("folderName : \(name)")
            let createdPath:URL = self.createLocalFolder(folderName: name)!
            localPathArray.append(createdPath)
        }
        
        if !printGoogleFolderPathStarted {
            printGoogleFolderPathStarted = true
            getFilesFromGoogleFolder(getGoogleFolderIdsToDownload:googleFolderIdsToDownLoad)
        }
        
        
    }
    func getFilesFromGoogleFolder(getGoogleFolderIdsToDownload: [String]){
        
        print("folderIdsToDownLoad.count:  \(getGoogleFolderIdsToDownload.count)")
        if(getGoogleFolderIdsToDownload.count > 0){
            let index = getGoogleFolderIdsToDownload.count - 1
            print("index : \(index)")
            if(index > -1){
                let stringFolderId = getGoogleFolderIdsToDownload[index]
                
                print("google folder stringFolderId: \(stringFolderId)")
                getGoogleFileListToDownload(foldrId: stringFolderId, index:index, getGoogleFolderIdsToDownload:getGoogleFolderIdsToDownload)
                return
            }
        }
        self.downloadFileFromGDriveFolder(getDriveFileArray:driveFileArray)
        print("file download start")
        
    }
    
    func getGoogleFileListToDownload(foldrId: String, index:Int, getGoogleFolderIdsToDownload:[String]){
        getFiles(accessToken: accessToken, root: foldrId){ responseObject, error in
            let json = JSON(responseObject!)
            
            if let serverList:[AnyObject] = json["files"].arrayObject as [AnyObject]? {
                for file in serverList {
//                    print("file : \(file)")
                    if file["trashed"] as? Int == 0 && file["starred"] as? Int == 0 && file["shared"] as? Int == 0 && file["mimeType"] as? String != Util.getGoogleMimeType(etsionNm: "folder") && file["fileExtension"] as? String != "nil"{
                        let fileStruct = App.DriveFileStruct(device: file, foldrWholePaths: ["Google"])
                        
                        self.driveFileArray.append(fileStruct)
                    }
                }
//                print("driveFileArray : \(self.self.driveFileArray)")
                print("index : \(index), folderIdsToDownLoad.count:  \(getGoogleFolderIdsToDownload.count)")
                var newFolders = getGoogleFolderIdsToDownload
                newFolders.remove(at: index)
                self.getFilesFromGoogleFolder(getGoogleFolderIdsToDownload : newFolders)
            } else {
                
            }
            
            
        }
    }
    func downloadFileFromGDriveFolder(getDriveFileArray:[App.DriveFileStruct]){
        for file in driveFileArray {
//            print("count : \(driveFileArray.count), download file : \(file)")
        }
        print("driveFileArray.count  :\(getDriveFileArray.count)")
        if(getDriveFileArray.count > 0){
            let index = getDriveFileArray.count - 1
            if(index > -1){
                let downFileName = getDriveFileArray[index].name
                let parentFolder = getDriveFileArray[index].parents
                let downId = String(getDriveFileArray[index].fileId)
                let mimeType = getDriveFileArray[index].mimeType
                print("parentFolder : \(parentFolder)")
                for foldrIdStruct in gdriveFolderIdDict {
                    print("key : \(foldrIdStruct.key), vlaue : \(foldrIdStruct.value)")
                    if(parentFolder == foldrIdStruct.value) {
                        print("parentFolderId : \(foldrIdStruct.key)")
                        let parentFolderPath = foldrIdStruct.key
                        callDownloadFromDriveFolder(fileId: downId, mimeType: mimeType, name: downFileName, pathToSave: parentFolderPath, index: index, getDriveFileArray:getDriveFileArray)
                    }
                }
                return
            }
        }
        self.finishGDriveFolderDownload()
        print("finish download")
        
    }
    func callDownloadFromDriveFolder(fileId:String, mimeType:String,name:String, pathToSave:String, index:Int, getDriveFileArray:[App.DriveFileStruct]){
        let fullPathToSave = "\(pathToSave)/\(name)"
        print("fullPathToSave : \(fullPathToSave)")
        downloadGDriveFile(fileId: fileId, mimeType: mimeType, name: fullPathToSave, startByte: 0, endByte: 102400) { responseObject, error in
            if let fileUrl = responseObject {
                var newDriveFiles = getDriveFileArray
                newDriveFiles.remove(at: index)
                self.downloadFileFromGDriveFolder(getDriveFileArray: newDriveFiles)
            }
        }
        
    }
    
    func finishGDriveFolderDownload(){
        if let syncOngoing:Bool = UserDefaults.standard.bool(forKey: "syncOngoing"), syncOngoing == true {
            print("aleady Syncing")
            
        } else {
            SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
        }
        
        print("download finish")
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: nil, message: "폴더 다운로드를 성공하였습니다", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                //Do you Success button Stuff here
                self.containerViewController?.finishLoading()
            }
            alertController.addAction(yesAction)
            self.containerViewController?.present(alertController, animated: true)
            
        }
        return
    }
    
    //GdriveFolder다운로드 끝
}
