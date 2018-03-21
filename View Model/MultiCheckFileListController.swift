//
//  MultiCheckFileListController.swift
//  KT
//
//  Created by 이다한 on 2018. 3. 21..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MultiCheckFileListController {
    
    var multiCheckedfolderArray:[App.FolderStruct] = []
    var dv:HomeDeviceCollectionVC?
    var selectedUserId = ""
    var selectedDevUuid = ""
    var selectedDeviceName = ""
    var folderIdsToDownLoad:[Int] = []
    var folderPathToDownLoad:[String] = []
    var fileArrayToDownload:[App.FolderStruct] = []
    
    
    func callDwonLoad(getFolderArray:[App.FolderStruct], parent:HomeDeviceCollectionVC, devUuid:String, deviceName:String){
        dv = parent
        selectedDevUuid = devUuid
        selectedDeviceName = deviceName
        multiCheckedfolderArray = getFolderArray
        
        if (multiCheckedfolderArray.count > 0){
            
            let index = getFolderArray.count - 1
            let name = getFolderArray[index].fileNm
            let foldrWholePathNm = getFolderArray[index].foldrWholePathNm
            let fileId = String(getFolderArray[index].fileId)
            let userId = getFolderArray[index].userId
            let foldrId = getFolderArray[index].foldrId
            let etsionNm = getFolderArray[index].etsionNm
            selectedUserId = userId
            if(etsionNm == "nil"){
                downloadFolderFromNas(foldrId: foldrId, foldrWholePathNm: foldrWholePathNm, userId: userId, devUuid: devUuid, deviceName: deviceName)
            } else {
                downloadFromNas(name: name, path: foldrWholePathNm, fileId: fileId, userId:userId, getFolderArray:getFolderArray)
            }            
            return
        }
        
        SyncLocalFilleToNas().sync()
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: nil, message: "다운로드를 성공하였습니다.", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel){
                UIAlertAction in
                NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
                NotificationCenter.default.post(name: Notification.Name("btnMulticlicked"), object: self, userInfo: nil)
            }
            
            alertController.addAction(yesAction)
            parent.present(alertController, animated: true)
        }
        
    }
    func downloadFromNas(name:String, path:String, fileId:String, userId:String,getFolderArray:[App.FolderStruct]){
        
        ContextMenuWork().downloadFromNas(userId:userId, fileNm:name, path:path, fileId:fileId){ responseObject, error in
            if let success = responseObject {
                print(success)
                if(success == "success"){
                    var newArray = getFolderArray
                    self.multiCheckedfolderArray.remove(at: self.multiCheckedfolderArray.count - 1)
                    self.callDwonLoad(getFolderArray: self.multiCheckedfolderArray, parent: self.dv!, devUuid: self.selectedDevUuid, deviceName: self.selectedDeviceName)
                    
                } else {
                    NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
                }
            }
            
            return
        }
    }
   
    
    func downloadFolderFromNas(foldrId:Int, foldrWholePathNm:String, userId:String, devUuid:String, deviceName:String){
        selectedUserId = userId
        selectedDevUuid = devUuid
        selectedDeviceName = deviceName
        
        folderIdsToDownLoad.removeAll()
        folderPathToDownLoad.removeAll()
        fileArrayToDownload.removeAll()
        print("call from downloadFolderFromNas")
        getFolderIdsToDownload(foldrId: foldrId, foldrWholePathNm: foldrWholePathNm, userId:userId, devUuid:selectedDevUuid,deviceName:deviceName)
    }
    
    
    
    func getFolderIdsToDownload(foldrId:Int, foldrWholePathNm:String, userId:String, devUuid:String, deviceName:String) {
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
                print("download serverList :\(serverList)")
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
        print("folderIdsToDownLoad.count:  \(folderIdsToDownLoad.count)")
        if(folderIdsToDownLoad.count > 0){
            let index = folderIdsToDownLoad.count - 1
            if(index > -1){
                let stringFolderId = String(folderIdsToDownLoad[index])
                getFileListToDownload(userId: selectedUserId, devUuid: selectedDevUuid, foldrId: stringFolderId, index:index)
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
                let downId = String(fileArrayToDownload[index].fileId)
                callDownloadFromNasFolder(name: downFileName, path: downPath, fileId: downId, index:index)
                return
            }
            
        }
        self.finishDownload()
    }
    
    
    
    
    func callDownloadFromNasFolder(name:String, path:String, fileId:String, index:Int){
        ContextMenuWork().downloadFromNasFolder(userId:selectedUserId, fileNm:name, path:path, fileId:fileId){ responseObject, error in
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
       
        self.multiCheckedfolderArray.remove(at: self.multiCheckedfolderArray.count - 1)
        self.callDwonLoad(getFolderArray: self.multiCheckedfolderArray, parent: self.dv!, devUuid: self.selectedDevUuid, deviceName: self.selectedDeviceName)
        
       
    }
    
    //다운로드 끝 
    
    
}

