//
//  GdriveMultiCheckController.swift
//  KT
//
//  Created by 이다한 on 2018. 4. 4..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GdriveMultiCheckController {
    var driveFileArray:[App.DriveFileStruct] = []
    var multiCheckedfolderArray: [App.DriveFileStruct] = []
    var homeViewController:HomeViewController?
    var homeDeviceCollectionVC:HomeDeviceCollectionVC?
    var flickState = HomeViewController.flickEnum.main
    var accessToken = ""
    var newFoldrWholePathNm = ""
    var oldFoldrWholePathNm = ""
    var newPath = ""
    var style = ""
    var toSavePathParent = ""
    var nasSendFolderSelectVC:NasSendFolderSelectVC?
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
    var rootFolder = ""
    
    
    func btnGoogleDriveMultiCheckClicked(sender:UIButton, getDriveArray:[App.DriveFileStruct], getHomeViewController:HomeViewController, getFlisckState:HomeViewController.flickEnum, parent:HomeDeviceCollectionVC){
        driveFileArray = getDriveArray
        homeViewController = getHomeViewController
        flickState = getFlisckState
        homeDeviceCollectionVC = parent
        
        let buttonRow = sender.tag
        let indexPath = IndexPath(row: buttonRow, section: 0)
        //        print("superview : \(sender.superview?.superview)")
        if let cell = sender.superview as? GDriveFolderListCell {
            if(cell.btnMultiChecked){
                cell.btnMultiChecked = false
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                cell.btnMultiChecked = true
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            }
            let checkedFile = getDriveArray[indexPath.row]
            print("checkedFile:\(checkedFile)")
            homeDeviceCollectionVC?.gDriveMultiCheckedFolderArray(indexPath:indexPath, check:cell.btnMultiChecked, checkedFile:checkedFile)
        } else if let cell = sender.superview as? GDriveFileListCell {
            if(cell.btnMultiChecked){
                cell.btnMultiChecked = false
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                cell.btnMultiChecked = true
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            }
            let checkedFile = getDriveArray[indexPath.row]
            print("checkedFile:\(checkedFile)")
            homeDeviceCollectionVC?.gDriveMultiCheckedFolderArray(indexPath:indexPath, check:cell.btnMultiChecked, checkedFile:checkedFile)
        }

    }
    
    func callDwonLoad(getFolderArray:[App.DriveFileStruct], parent:HomeDeviceCollectionVC){
        homeDeviceCollectionVC = parent
        multiCheckedfolderArray = getFolderArray
        
        if (multiCheckedfolderArray.count > 0){
            let index = getFolderArray.count - 1
            let name = getFolderArray[index].name
            let fileId = getFolderArray[index].fileId
            let mimeType = getFolderArray[index].mimeType
            if(mimeType == Util.getGoogleMimeType(etsionNm: "folder")){
                if let googleEmail = UserDefaults.standard.string(forKey: "googleEmail"){
//                    let accessToken = DbHelper().getAccessToken(email: googleEmail)
                    let accessToken = UserDefaults.standard.string(forKey: "googleAccessToken")!
                    let downloadRootFolderName = name
                    downloadFolderFromGDrive(foldrId: fileId, getAccessToken: accessToken, fileId: fileId, downloadRootFolderName:downloadRootFolderName)
                }
            } else {
//                let fullPathToSave = "\(pathToSave)/\(name)"
                GoogleWork().downloadGDriveFile(fileId: fileId, mimeType: mimeType, name: name) { responseObject, error in
                    if let fileUrl = responseObject {
                        var newArray = getFolderArray
                        self.multiCheckedfolderArray.remove(at: self.multiCheckedfolderArray.count - 1)
                        
                        let fileDict = ["fileId":fileId]
                        NotificationCenter.default.post(name: Notification.Name("completeFileProcess"), object: self, userInfo:fileDict)
                        
                        self.callDwonLoad(getFolderArray: self.multiCheckedfolderArray, parent: self.homeDeviceCollectionVC!)
                    }
                }
            }
            return
        }
        if let syncOngoing:Bool = UserDefaults.standard.bool(forKey: "syncOngoing"), syncOngoing == true {
            print("aleady Syncing")
            
        } else {
            SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
        }
        /*
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: nil, message: "다운로드를 성공하였습니다.", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel){
                UIAlertAction in
                NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
//                NotificationCenter.default.post(name: Notification.Name("btnMulticlicked"), object: self, userInfo: nil)
            }
            alertController.addAction(yesAction)
            parent.present(alertController, animated: true)
        }*/
        
    }

    func downloadFolderFromGDrive(foldrId:String, getAccessToken: String, fileId:String, downloadRootFolderName:String){
        NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
        accessToken = getAccessToken
        print("oldFoldrWholePathNm : \(oldFoldrWholePathNm)")
        
        googleFolderIdsToDownLoad.removeAll()
        folderPathToDownLoad.removeAll()
        driveFileArray.removeAll()
        gdriveFolderIdDict.removeAll()
        print("call from downloadFolderFromNas")
        
        let currentFolderPath = "/\(downloadRootFolderName)"
        self.folderPathToDownLoad.append(currentFolderPath)
        gdriveFolderIdDict.updateValue(foldrId, forKey: currentFolderPath)
        getGDriveFolderIdsToDownload(foldrId: foldrId, currentFolderPath:currentFolderPath)
    }
    func getGDriveFolderIdsToDownload(foldrId:String, currentFolderPath:String) {
        print("get folders")
        googleFolderIdsToDownLoad.append(foldrId)
        print("folderIdsToDownLoad : \(googleFolderIdsToDownLoad)")
        var url = "https://www.googleapis.com/drive/v3/files?q='\(foldrId)' in parents and mimeType='application/vnd.google-apps.folder'&access_token=\(accessToken)" + App.URL.gDriveFileOption // 0eun
        url = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        Alamofire.request(url,
                          method: .get,
                          encoding: JSONEncoding.default,
                          headers: nil).responseJSON { response in
                            switch response.result {
                            case .success(let value):
                                let json = JSON(value)
                                print("json : \(json)")
                                if(json["error"].exists()){
                                    print("error: \(json["error"])")
                                } else {
                                    if let serverList:[AnyObject] = json["files"].arrayObject as! [AnyObject] {
                                        if serverList.count > 0 {
                                            for file in serverList {
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
                                        self.printGoogleFolderPath()
                                    }
                                }
                                
                            case .failure(let error):
                                NSLog(error.localizedDescription)
                                
                            }
                            
        }
    }
    func folderChildrenCheck(foldrId:String, completion: @escaping (Int) -> Void){
        var url = "https://www.googleapis.com/drive/v3/files?q='\(foldrId)' in parents and mimeType='application/vnd.google-apps.folder'&access_token=\(accessToken)" + App.URL.gDriveFileOption // 0eun
        url = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        Alamofire.request(url,
                          method: .get,
                          encoding: JSONEncoding.default,
                          headers: nil).responseJSON { response in
                            switch response.result {
                            case .success(let value):
                                let json = JSON(value)
                                print("json : \(json)")
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
            let createdPath:URL = GoogleWork().createLocalFolder(folderName: name)!
            localPathArray.append(createdPath)
        }
        
        getFilesFromGoogleFolder()
        
    }
    func getFilesFromGoogleFolder(){
        print("folderIdsToDownLoad.count:  \(googleFolderIdsToDownLoad.count)")
        if(googleFolderIdsToDownLoad.count > 0){
            let index = googleFolderIdsToDownLoad.count - 1
            if(index > -1){
                let stringFolderId = googleFolderIdsToDownLoad[index]
                
                print("google folder stringFolderId: \(stringFolderId)")
                getGoogleFileListToDownload(foldrId: stringFolderId, index:index)
                return
            }
        }
        self.downloadFileFromGDriveFolder()
        print("file download start")
        
    }
    
    func getGoogleFileListToDownload(foldrId: String, index:Int){
        GoogleWork().getFiles(accessToken: accessToken, root: foldrId){ responseObject, error in
            let json = JSON(responseObject!)
            
            if let serverList:[AnyObject] = json["files"].arrayObject as! [AnyObject] {
                for file in serverList {
                    //                                            print("file : \(file)")
                    if file["trashed"] as? Int == 0 && file["starred"] as? Int == 0 && file["shared"] as? Int == 0 && file["mimeType"] as? String != Util.getGoogleMimeType(etsionNm: "folder"){
                        let fileStruct = App.DriveFileStruct(device: file, foldrWholePaths: ["Google"])
                        
                        self.driveFileArray.append(fileStruct)
                    }
                }
                //                print("driveFileArray : \(self.self.driveFileArray)")
                
            }
            self.googleFolderIdsToDownLoad.remove(at: index)
            self.getFilesFromGoogleFolder()
            
        }
    }
    func downloadFileFromGDriveFolder(){
        for file in driveFileArray {
            //            print("count : \(driveFileArray.count), download file : \(file)")
        }
        print("driveFileArray.count  :\(driveFileArray.count)")
        if(driveFileArray.count > 0){
            let index = driveFileArray.count - 1
            if(index > -1){
                let downFileName = driveFileArray[index].name
                let parentFolder = driveFileArray[index].parents
                let downId = String(driveFileArray[index].fileId)
                let mimeType = driveFileArray[index].mimeType
                print("parentFolder : \(parentFolder)")
                for foldrIdStruct in gdriveFolderIdDict {
                    print("key : \(foldrIdStruct.key), vlaue : \(foldrIdStruct.value)")
                    if(parentFolder == foldrIdStruct.value) {
                        print("parentFolderId : \(foldrIdStruct.key)")
                        let parentFolderPath = foldrIdStruct.key
                        callDownloadFromDriveFolder(fileId: downId, mimeType: mimeType, name: downFileName, pathToSave: parentFolderPath, index: index)
                    }
                }
                return
            }
        }
        self.finishGDriveFolderDownload()
        print("finish download")
        
    }
    func callDownloadFromDriveFolder(fileId:String, mimeType:String,name:String, pathToSave:String, index:Int){
        let fullPathToSave = "\(pathToSave)/\(name)"
        GoogleWork().downloadGDriveFile(fileId: fileId, mimeType: mimeType, name: fullPathToSave) { responseObject, error in
            if let fileUrl = responseObject {
                self.driveFileArray.remove(at: index)
                self.downloadFileFromGDriveFolder()
            }
        }
        
    }
    
    func finishGDriveFolderDownload(){
        let foldrId:String = multiCheckedfolderArray[self.multiCheckedfolderArray.count - 1].fileId
        let fileDict = ["fileId":foldrId]
        NotificationCenter.default.post(name: Notification.Name("completeFileProcess"), object: self, userInfo:fileDict)
        self.multiCheckedfolderArray.remove(at: self.multiCheckedfolderArray.count - 1)
        self.callDwonLoad(getFolderArray: self.multiCheckedfolderArray, parent: self.homeDeviceCollectionVC!)
    }
}
