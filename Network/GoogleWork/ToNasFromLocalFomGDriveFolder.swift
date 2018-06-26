//
//  ToNasFromLocalFomGDriveFolder.swift
//  KT
//
//  Created by 이다한 on 2018. 4. 4..
//  Copyright © 2018년 이다한. All rights reserved.
//


import UIKit
import SwiftyJSON
import Alamofire

class ToNasFromLocalFomGDriveFolder {
    
    var toUserId = ""
    var newFoldrWholePathNm = ""
    var oldFoldrWholePathNm = ""
    var oldFoldrWholePathNmForEachFolder = ""
    var newPath = ""
    var style = ""
    var nasSendController:NasSendController?
    var containerViewController:ContainerViewController?
    var multiCheckedfolderArray:[App.DriveFileStruct] = []
    var loginCookie = UserDefaults.standard.string(forKey: "cookie") ?? "nil"
    var loginToken = UserDefaults.standard.string(forKey: "token") ?? "nil"
    var jsonHeader:[String:String] = [
        "Content-Type": "application/json",
        "X-Auth-Token": UserDefaults.standard.string(forKey: "token")!,
        "Cookie": UserDefaults.standard.string(forKey: "cookie")!
    ]
    var folderLastName:String = ""
    var toOsCd = ""
    func readyCreatFolders(getToUserId:String, getNewFoldrWholePathNm:String, getOldFoldrWholePathNm:String, getMultiArray : [App.DriveFileStruct], parent:NasSendController, containerViewController:ContainerViewController, toOsCd:String){
        
        
        let folders:[App.Folders] = FileUtil().getFolderList()
        var foldersToCreate:[String] = []
        toUserId = getToUserId
        newFoldrWholePathNm = getNewFoldrWholePathNm
        oldFoldrWholePathNm = getOldFoldrWholePathNm
        oldFoldrWholePathNmForEachFolder = ""
        self.toOsCd = toOsCd
        multiCheckedfolderArray = getMultiArray
        nasSendController = parent
        if multiCheckedfolderArray.count > 0 {
            let lastIndex = multiCheckedfolderArray.count - 1
            self.containerViewController = containerViewController
            let folderLastName:String = multiCheckedfolderArray[lastIndex].name
            let mimeType = multiCheckedfolderArray[lastIndex].mimeType
            if mimeType.contains("folder") {
                oldFoldrWholePathNmForEachFolder = getOldFoldrWholePathNm+"/\(folderLastName)"
                oldFoldrWholePathNmForEachFolder = oldFoldrWholePathNmForEachFolder.precomposedStringWithCanonicalMapping
                for folder in folders{
                    if folder.foldrWholePathNm == oldFoldrWholePathNmForEachFolder || folder.foldrWholePathNm.contains("\(oldFoldrWholePathNmForEachFolder)/") {
                        print(folder.foldrWholePathNm)
                        var path = folder.foldrWholePathNm
                        print("local path : \(path)")
                        path = path.replacingOccurrences(of: "/Mobile/tmp", with: newFoldrWholePathNm)
                        let newPath = path.precomposedStringWithCanonicalMapping
                        print("path to update : \(newPath)")
                        foldersToCreate.append(newPath)
                    }
                }
                createFolders(foldersToCreate: foldersToCreate)
            } else {
                // 파일일 경우
                oldFoldrWholePathNmForEachFolder = getOldFoldrWholePathNm
                initForUploadFile()
            }
            
        } else {
            let pathForRemove:String = FileUtil().getFilePath(fileNm: "tmp", amdDate: "amdDate")
            if(pathForRemove.isEmpty){
                //
            } else {
                FileUtil().removeFile(path: pathForRemove)
                let syncOngoing:Bool = UserDefaults.standard.bool(forKey: "syncOngoing")
                if syncOngoing == true {
                    print("aleady Syncing")
                    
                } else {
                    SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
                }
            }
            
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: nil, message: "NAS로 내보내기 성공", preferredStyle: .alert)
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
    
    
    func createFolders(foldersToCreate:[String]) {
        if(foldersToCreate.count > 0){
            let index = foldersToCreate.count - 1
            if(index > -1){
                let param = ["userId":toUserId, "foldrWholePathNm":foldersToCreate[index]]
                callCreateNasFolder(param:param, index: index, foldersToCreate:foldersToCreate)
                return
            }
        }
        print("createFile")
        initForUploadFiles()
    }
    
    func callCreateNasFolder(param:[String:Any], index:Int, foldersToCreate:[String]){
        
        ContextMenuWork().createNasFolder(parameters: param, toOsCd: toOsCd){ responseObject, error in
            let json = JSON(responseObject as Any)
            let message = responseObject?.object(forKey: "message")
            print("\(String(describing: message)), \(String(describing: json["statusCode"].int))")
            if let statusCode = json["statusCode"].int, statusCode == 100 {
                
            } else {
                print(error?.localizedDescription as Any)
            }
            var newFolders = foldersToCreate
            newFolders.remove(at: index)
            self.createFolders(foldersToCreate: newFolders)
        }
    }
    
    
    func initForUploadFiles(){
        var files:[App.Files] = []
        var fileToUpload:[String] = []
        
        GetListFromServer().getMobileFileLIst(devUuid: Util.getUuid(), userId:App.defaults.userId, deviceName:"sdf"){ responseObject, error in
            let json = JSON(responseObject!)
            if(json["listData"].exists()){
                let serverList:[AnyObject] = json["listData"].arrayObject! as [AnyObject]
                for serverFile in serverList{
                    
                    let serverFileNm = serverFile["fileNm"] as? String ?? "nil"
                    let serverFilePath = serverFile["foldrWholePathNm"] as? String ?? "nil"
                    let serverFileAmdDate = serverFile["amdDate"] as? String ?? "nil"
                    print("serverFilePath : \(serverFilePath), oldFoldrWholePathNm : \(self.oldFoldrWholePathNm)")
                    if  serverFilePath.contains(self.oldFoldrWholePathNmForEachFolder)  {
                        print("file path to update : \(serverFilePath), fileName : \(serverFileNm), amdDate : \(serverFileAmdDate)")
                        let newServerFilePath = serverFilePath.precomposedStringWithCanonicalMapping
                        fileToUpload.append(newServerFilePath)
                        let uploadFile:App.Files = App.Files(data: serverFile)
                        files.append(uploadFile)
                    }
                    
                }
                self.uploadFile(files: files)
            }
            
        }
    }
    func initForUploadFile(){
        var files:[App.Files] = []
        var fileToUpload:[String] = []
        
        GetListFromServer().getMobileFileLIst(devUuid: Util.getUuid(), userId:App.defaults.userId, deviceName:"sdf"){ responseObject, error in
            let json = JSON(responseObject!)
            if(json["listData"].exists()){
                let serverList:[AnyObject] = json["listData"].arrayObject! as [AnyObject]
                for serverFile in serverList{
                    
                    let serverFileNm = serverFile["fileNm"] as? String ?? "nil"
                    let serverFilePath = serverFile["foldrWholePathNm"] as? String ?? "nil"
                    let serverFileAmdDate = serverFile["amdDate"] as? String ?? "nil"
                    print("serverFilePath : \(serverFilePath), oldFoldrWholePathNm : \(self.oldFoldrWholePathNm)")
                    if  serverFilePath == self.oldFoldrWholePathNmForEachFolder{
                        print("file path to update : \(serverFilePath), fileName : \(serverFileNm), amdDate : \(serverFileAmdDate)")
                        let newServerFilePath = serverFilePath.precomposedStringWithCanonicalMapping
                        fileToUpload.append(newServerFilePath)
                        serverFile
                        let uploadFile:App.Files = App.Files(data: serverFile)
                        files.append(uploadFile)
                    }
                    
                }
                self.uploadFile(files: files)
            }
            
        }
    }
    func uploadFile(files:[App.Files]){
        print("uploadFile :\(files)")
        if(files.count > 0){
            let index = files.count - 1
            if(index > -1){
                var originalFileName = "\(files[index].fileNm)"
                let amdDate = files[index].amdDate
                let originalFileId = files[index].fileId
                var toOsCd = "G"
                if(toUserId != App.defaults.userId){
                    toOsCd = "S"
                }
                
                var pathToUpdate = files[index].foldrWholePathNm
                
                pathToUpdate = pathToUpdate.replacingOccurrences(of: "/Mobile/tmp", with: newFoldrWholePathNm)
                print("uploadFile originalFileName: \(originalFileName), newFoldrWholePathNm: \(newFoldrWholePathNm), pathToUpdate : \(pathToUpdate)")
                originalFileName = originalFileName.precomposedStringWithCanonicalMapping
                if let fileUrl:URL = FileUtil().getFileUrl(fileNm: originalFileName, amdDate: amdDate) {
                    sendToNasFromLocal(url: fileUrl, name: originalFileName, toOsCd:toOsCd, originalFileId:originalFileId, files:files,newFoldrWholePathNm:pathToUpdate, originalFolderPath:files[index].foldrWholePathNm)
                }
                
                
                return
            }
            return
        }
        print("upload Files finish multiCheckedfolderArray : \(multiCheckedfolderArray.count)")
        if(multiCheckedfolderArray.count > 0){
            print("completeFileProcess called")
            let lastIndex = multiCheckedfolderArray.count - 1
            let fileId = self.multiCheckedfolderArray[lastIndex].fileId
            let fileDict = ["fileId":fileId]
            NotificationCenter.default.post(name: Notification.Name("completeFileProcess"), object: self, userInfo:fileDict)
            multiCheckedfolderArray.remove(at: lastIndex)
            readyCreatFolders(getToUserId: self.toUserId, getNewFoldrWholePathNm: self.newFoldrWholePathNm, getOldFoldrWholePathNm: self.oldFoldrWholePathNm, getMultiArray: self.multiCheckedfolderArray, parent: nasSendController!, containerViewController: containerViewController!, toOsCd: self.toOsCd)
//            nasSendController?.gDriveMultiCheckedfolderArray = multiCheckedfolderArray
//            nasSendController?.startMultiGdriveToNas()
        } else {
            let pathForRemove:String = FileUtil().getFilePath(fileNm: "tmp", amdDate: "amdDate")
            if(pathForRemove.isEmpty){
                //
            } else {
                FileUtil().removeFile(path: pathForRemove)
                let syncOngoing:Bool = UserDefaults.standard.bool(forKey: "syncOngoing")
                if syncOngoing == true {
                    print("aleady Syncing")
                    
                } else {
                    SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
                }
            }
            
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: nil, message: "NAS로 내보내기 성공", preferredStyle: .alert)
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
    
    func sendToNasFromLocal(url:URL, name:String, toOsCd:String, originalFileId:Int, files:[App.Files], newFoldrWholePathNm:String, originalFolderPath:String){
        let newName = name.precomposedStringWithCanonicalMapping
        let userId = toUserId
        let password:String = UserDefaults.standard.string(forKey: "userPassword")!
        
        let credentialData = "\(App.nasFoldrFrontNm)\(App.defaults.userId):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
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
        print("stringUrl : \(stringUrl)" )
        print("newName : \(newName)")
        
        
        if let fileUrl:URL = FileUtil().getFileUrlWithFoldr(fileNm: newName, foldrWholePathNm: originalFolderPath, amdDate: "") {
            let filePath = fileUrl.path
            let fileExtension = fileUrl.pathExtension
            print("fileExtension : \(fileExtension)")
            print("file path : \(filePath)")
            var fileSize = 0.0
            do {
                let attribute = try FileManager.default.attributesOfItem(atPath: url.path)
                if let size = attribute[FileAttributeKey.size] as? NSNumber {
                    fileSize =  size.doubleValue / 1000000.0
                }
            } catch {
                print("Error: \(error)")
            }
            print("FILE Yes AVAILABLE")
            print("stream upload, fileSize : \(fileSize)")
            
            let stream:InputStream = InputStream(url: url)!
            
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
                            self.notifyNasUploadFinish(name: newName, toOsCd:toOsCd, originalFileId:originalFileId, files:files, newFoldrWholePathNm:newFoldrWholePathNm)
                        }
                    }
                    upload.uploadProgress { progress in
                        
                        print(progress.fractionCompleted)
                    }
                    break
                case .failure(let encodingError):
                    print(encodingError.localizedDescription)
                    DispatchQueue.main.async {
                        self.containerViewController?.finishLoading()
                    }
                    
                    
                    break
                }
            })
        } else {
            print("error")
            let alertController = UIAlertController(title: nil, message: "파일을 찾을 수가 없습니다.", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel) {
                UIAlertAction in
            }
            alertController.addAction(yesAction)
            self.containerViewController?.present(alertController, animated: true)
        }
     
    }
    
    
    
    func notifyNasUploadFinish(name:String, toOsCd:String, originalFileId:Int, files:[App.Files], newFoldrWholePathNm:String){
        let urlString = App.URL.hostIpServer+"nasUpldCmplt.do"
        let paramas:[String : Any] = ["userId":toUserId,"fileId":originalFileId,"toFoldr":newFoldrWholePathNm,"toFileNm":name,"toOsCd":toOsCd]
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
                                var newFiles = files
                                if newFiles.count > 0 {
                                    newFiles.remove(at: newFiles.count - 1)
                                }
                                self.uploadFile(files: newFiles)
                                break
                            case .failure(let error):
                                
                                print(error.localizedDescription)
                            }
        }
    }
    
}

