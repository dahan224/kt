//
//  ToNasFromLocalFolder.swift
//  KT
//
//  Created by 이다한 on 2018. 3. 18..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ToNasFromLocalFolder {
    
    var toUserId = ""
    var newFoldrWholePathNm = ""
    var oldFoldrWholePathNm = ""
    var newFolderNm = ""
    var newPath = ""
    var style = ""
    var nasSendFolderSelectVC:NasSendFolderSelectVC?
    var multiCheckedfolderArray:[App.FolderStruct] = []
    var loginCookie = UserDefaults.standard.string(forKey: "cookie") ?? "nil"
    var loginToken = UserDefaults.standard.string(forKey: "token") ?? "nil"
    var jsonHeader:[String:String] = [
        "Content-Type": "application/json",
        "X-Auth-Token": UserDefaults.standard.string(forKey: "token")!,
        "Cookie": UserDefaults.standard.string(forKey: "cookie")!
    ]
    func readyCreatFolders(getToUserId:String, getNewFoldrWholePathNm:String, getOldFoldrWholePathNm:String, getMultiArray : [App.FolderStruct], parent:NasSendFolderSelectVC){
        NotificationCenter.default.post(name: Notification.Name("NasSendFolderSelectVCToggleIndicator"), object: self, userInfo: nil)
        let folders:[App.Folders] = FileUtil().getFolderList()
        var foldersToCreate:[String] = []
        toUserId = getToUserId
        newFoldrWholePathNm = getNewFoldrWholePathNm
        oldFoldrWholePathNm = getOldFoldrWholePathNm
        let oldFoldrWholePathNmArray = oldFoldrWholePathNm.components(separatedBy: "/")
        newFolderNm = oldFoldrWholePathNmArray[oldFoldrWholePathNmArray.count - 1]
        multiCheckedfolderArray = getMultiArray
        nasSendFolderSelectVC = parent
        for folder in folders{
            if folder.foldrWholePathNm == oldFoldrWholePathNm || folder.foldrWholePathNm.contains("\(oldFoldrWholePathNm)/") {
                print(folder.foldrWholePathNm)
                var path = folder.foldrWholePathNm
                print("local path : \(path)")
                path = path.replacingOccurrences(of: oldFoldrWholePathNm, with: "\(newFoldrWholePathNm)/\(newFolderNm)")
                print("path to update : \(path)")
                foldersToCreate.append(path)
            }
        }
        print("newFolderNm : \(newFolderNm)")
        createFolders(foldersToCreate: foldersToCreate)
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
        
        ContextMenuWork().createNasFolder(parameters: param){ responseObject, error in
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
        print("uploadFile :\(uploadFile)")
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
//                pathToUpdate = pathToUpdate.replacingOccurrences(of: "/Mobile", with: newFoldrWholePathNm)
                pathToUpdate = pathToUpdate.replacingOccurrences(of: oldFoldrWholePathNm, with: "\(newFoldrWholePathNm)/\(newFolderNm)")
                print("uploadFile originalFileName: \(originalFileName), newFoldrWholePathNm: \(newFoldrWholePathNm), pathToUpdate : \(pathToUpdate)")
                if let fileUrl:URL = FileUtil().getFileUrl(fileNm: originalFileName, amdDate: amdDate) {
                    sendToNasFromLocal(url: fileUrl, name: originalFileName, toOsCd:toOsCd, originalFileId:originalFileId, files:files,newFoldrWholePathNm:pathToUpdate)
                }
                
                
                return
            }
        }
        print("upload Files finish")
        if(multiCheckedfolderArray.count > 0){
            let lastIndex = multiCheckedfolderArray.count - 1
            multiCheckedfolderArray.remove(at: lastIndex)
            nasSendFolderSelectVC?.multiCheckedfolderArray = multiCheckedfolderArray
            nasSendFolderSelectVC?.startMultiLocalToNas()
            
        } else {
            NotificationCenter.default.post(name: Notification.Name("NasSendFolderSelectVCToggleIndicator"), object: self, userInfo: nil)
//            NotificationCenter.default.post(name: Notification.Name("NasSendFolderSelectVCAlert"), object: self, userInfo: nil)
            nasSendFolderSelectVC?.NasSendFolderSelectVCAlert(title: "NAS로 내보내기 성공")
        }
        
        
    }
    
    func sendToNasFromLocal(url:URL, name:String, toOsCd:String, originalFileId:Int, files:[App.Files], newFoldrWholePathNm:String){
        
        let userId = toUserId
        let password:String = UserDefaults.standard.string(forKey: "userPassword")!
        
        let credentialData = "gs-\(App.defaults.userId):\(password)".data(using: String.Encoding.utf8)!
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
        var stringUrl = "https://araise.iptime.org/namespace/ifs/home/gs-\(userId)/\(userId)-gs\(newFoldrWholePathNm)/\(name)?overwrite=true"
        stringUrl =  stringUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print("stringUrl : \(stringUrl)" )
        
        let filePath = url.path
        let fileExtension = url.pathExtension
        print("fileExtension : \(fileExtension)")
        print("file path : \(filePath)")
        
        Alamofire.upload(url, to: stringUrl, method: .put, headers: headers)
            .uploadProgress { progress in // main queue by default
//                print("Upload Progress: \(progress.fractionCompleted)")
                
            }
            .downloadProgress { progress in // main queue by default
//                print("Download Progress: \(progress.fractionCompleted)")
            }
            .responseString { response in
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response)")
                if let alamoError = response.result.error {
                    let alamoCode = alamoError._code
                    let statusCode = (response.response?.statusCode) ?? 0
                } else { //no errors
                    let statusCode = (response.response?.statusCode)! //example : 200
                    self.notifyNasUploadFinish(name: name, toOsCd:toOsCd, originalFileId:originalFileId, files:files, newFoldrWholePathNm:newFoldrWholePathNm)
                    
                }
        }
    }
    
    
    
    func notifyNasUploadFinish(name:String, toOsCd:String, originalFileId:Int, files:[App.Files], newFoldrWholePathNm:String){
        let urlString = App.URL.server+"nasUpldCmplt.do"
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
                                newFiles.remove(at: newFiles.count - 1)
                                self.uploadFile(files: newFiles)
                                break
                            case .failure(let error):
                                
                                print(error.localizedDescription)
                            }
        }
    }
    
}
