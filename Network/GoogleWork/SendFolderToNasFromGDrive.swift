//
//  SendFolderToNasFromGDrive.swift
//  KT
//
//  Created by 이다한 on 2018. 4. 3..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GoogleSignIn
import Alamofire
import SwiftyJSON

class SendFolderToNasFromGDrive {
    var printGoogleFolderPathStarted = false
    var accessToken = ""
    var newFoldrWholePathNm = ""
    var oldFoldrWholePathNm = ""
    var newPath = ""
    var style = ""
    var toSavePathParent = ""
    var containerViewController:ContainerViewController?
    var nasSendController:NasSendController?
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
    var googleFolderIdsToDownLoad:[String] = []
    var folderPathToDownLoad:[String] = []
    var driveFileArray:[App.DriveFileStruct] = []
    var rootFolder = ""
    var gDriveMultiCheckedfolderArray:[App.DriveFileStruct] = []
    var orginalFoldrId = ""
    
    func downloadFolderFromGDrive(foldrId:String, getAccessToken: String, fileId:String, downloadRootFolderName:String, parent:NasSendController, gDriveMultiCheckedfolderArray:[App.DriveFileStruct]){
        
        accessToken = getAccessToken
        print("oldFoldrWholePathNm : \(oldFoldrWholePathNm)")
        
        nasSendController = parent
        googleFolderIdsToDownLoad.removeAll()
        folderPathToDownLoad.removeAll()
        driveFileArray.removeAll()
        gdriveFolderIdDict.removeAll()
        orginalFoldrId = foldrId
        print("call from downloadFolderFromNas")
        self.gDriveMultiCheckedfolderArray = gDriveMultiCheckedfolderArray
        let currentFolderPath = "\(downloadRootFolderName)"
        
        self.folderPathToDownLoad.append(currentFolderPath)
        gdriveFolderIdDict.updateValue(foldrId, forKey: currentFolderPath)
        getGDriveFolderIdsToDownload(foldrId: foldrId, currentFolderPath:currentFolderPath)
        
    }
    func getGDriveFolderIdsToDownload(foldrId:String, currentFolderPath:String) {
        print("get folders")
        googleFolderIdsToDownLoad.append(foldrId)
        print("folderIdsToDownLoad : \(googleFolderIdsToDownLoad)")
        var url = "https://www.googleapis.com/drive/v3/files?q='\(foldrId)' in parents and mimeType='application/vnd.google-apps.folder'&trashed=false&access_token=\(accessToken)" + App.URL.gDriveFileOption // 0eun
        url = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
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
                                                    let newFolderPath:String = currentFolderPath.precomposedStringWithCanonicalMapping
                                                    let newName:String = fileStruct.name.precomposedStringWithCanonicalMapping
                                                    let editCurrentFolderPath = "\(newFolderPath)/\(newName)"
                                                    self.folderPathToDownLoad.append(editCurrentFolderPath)
                                                    self.gdriveFolderIdDict.updateValue(fileStruct.fileId, forKey: editCurrentFolderPath)
                                                    print("second return called")
                                                    self.folderChildrenCheck(foldrId: fileStruct.fileId) {
                                                        response in
                                                        if( response > 0){
                                                            self.getGDriveFolderIdsToDownload(foldrId: fileStruct.fileId, currentFolderPath: editCurrentFolderPath)
                                                            return
                                                        } else {
                                                            let fileDict = ["fileId":foldrId]
                                                            NotificationCenter.default.post(name: Notification.Name("completeFileProcess"), object: self, userInfo:fileDict)
                                                        }
                                                    }
                                                    
                                                }
                                            }
                                        } else {
                                            print("json : \(json)")
                                            self.printGoogleFolderPath()
                                        }
                                        
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
        
        for (index, name) in folderPathToDownLoad.enumerated() {
            
            print("folderName : /tmp/\(name)")
            let gDriveFolderName = "tmp/\(name)"
            if index == 0 {
                rootFolder = "/Mobile/tmp/\(name)"
            }
            let createdPath:URL = GoogleWork().createLocalFolder(folderName: gDriveFolderName)!
            localPathArray.append(createdPath)
        }
        print("rootFolder : \(rootFolder)")
        print("localPathArray : \(localPathArray)")
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
        GoogleWork().getFiles(accessToken: accessToken, root: foldrId){ responseObject, error in
            let json = JSON(responseObject!)
            
            if let serverList:[AnyObject] = json["files"].arrayObject as [AnyObject]? {
                for file in serverList {
                    //                    print("file : \(file)")
                    if file["trashed"] as? Int == 0 && file["starred"] as? Int == 0 && file["shared"] as? Int == 0 && file["mimeType"] as? String != Util.getGoogleMimeType(etsionNm: "folder") && file["fileExtension"] as? String != "nil" {
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
                        return
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
        
        let newPathToSave:String = pathToSave.precomposedStringWithCanonicalMapping
        let newName:String = name.precomposedStringWithCanonicalMapping
        let newFullPathToSave = "\(newPathToSave)/\(newName)"
        print("fullPathToSave : \(fullPathToSave), newFullPathToSave: \(newFullPathToSave)")
        //downloadGdriveFileSend 는 파일 다운로드
        GoogleWork().downloadGDriveFileToSendToNas(fileId: fileId, mimeType: mimeType, name: fullPathToSave, startByte: 0, endByte: 10204) { responseObject, error in
            if let fileUrl = responseObject {
                var newDriveFiles = getDriveFileArray
                newDriveFiles.remove(at: index)
                self.downloadFileFromGDriveFolder(getDriveFileArray: newDriveFiles)
                
            }
        }
        
    }
    
    func finishGDriveFolderDownload(){
        //        if let syncOngoing:Bool = UserDefaults.standard.bool(forKey: "syncOngoing"), syncOngoing == true {
        //            print("aleady Syncing")
        //
        //        } else {
        //            SyncLocalFilleToNas().callSyncFomGdriveToNasSendFolder(view: "NasSendController", parent: nasSendController!, rootFolder: rootFolder)
        //        }
        
        
        print("download finish")
        let fileDict = ["fileId":orginalFoldrId]
        NotificationCenter.default.post(name: Notification.Name("completeFileProcess"), object: self, userInfo:fileDict)
        if(gDriveMultiCheckedfolderArray.count > 0){
            
            let lastIndex = gDriveMultiCheckedfolderArray.count - 1
            gDriveMultiCheckedfolderArray.remove(at: lastIndex)
        }
        nasSendController?.gDriveMultiCheckedfolderArray = gDriveMultiCheckedfolderArray
        nasSendController?.startMultiGdriveToNas()
        
    }
    
    //GdriveFolder다운로드 끝
}

