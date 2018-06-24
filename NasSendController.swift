//
//  NasSendController.swift
//  KT
//
//  Created by 이다한 on 2018. 5. 2..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class NasSendController {
    var storageState = NasSendFolderSelectVC.toStorageKind.nas
    var containerViewController:ContainerViewController?
    var jsonHeader:[String:String] = [
        "Content-Type": "application/json",
        "X-Auth-Token": UserDefaults.standard.string(forKey: "token")!,
        "Cookie": UserDefaults.standard.string(forKey: "cookie")!
    ]
    var toOsCd = ""
    var toUserId = ""
    var originalFileName = ""
    var originalFileId = ""
    var amdDate = ""
    var oldFoldrWholePathNm = ""
    var newFoldrWholePathNm = ""
    var multiCheckedfolderArray:[App.FolderStruct] = []
    var etsionNm:String = ""
    var driveFileArray:[App.DriveFileStruct] = []
    var checkedButtonRow:Int = 0
    var driveFolderNameArray:[String] = []
    var driveFolderIdArray:[String] = []
    var fromOsCd:String = ""
    var fromDevUuid:String = ""
    var accessToken:String = ""
    var googleDriveFileIdPath:String = ""
    var deviceName:String = ""
    var fromUserId:String = ""
    var currentDevUuId:String = ""
    var newFoldrId:String = ""
    
    var fromFoldrId:String = ""
    var mimeType:String = ""
    var gDriveMultiCheckedfolderArray:[App.DriveFileStruct] = []
    var listState = NasSendFolderSelectVC.listEnum.deviceRoot
    
    
    func handleNasSend(getToOsCd:String, getToUserId:String, getOriginalFileName:String, getAmdDate:String, getOriginalFileId:String, oldFoldrWholePathNm:String, newFoldrWholePathNm:String, multiCheckedfolderArray:[App.FolderStruct], etsionNm:String, storageState:NasSendFolderSelectVC.toStorageKind, listState:NasSendFolderSelectVC.listEnum, driveFileArray:[App.DriveFileStruct], checkedButtonRow:Int, driveFolderNameArray:[String], driveFolderIdArray:[String], fromOsCd:String, fromDevUuid:String, accessToken:String, googleDriveFileIdPath:String, deviceName:String, fromUserId:String, containerViewController:ContainerViewController, currentDevUuId:String, newFoldrId:String, fromFoldrId:String, mimeType:String, gDriveMultiCheckedfolderArray:[App.DriveFileStruct]){
        self.toOsCd = getToOsCd
        self.toUserId = getToUserId
        self.originalFileName = getOriginalFileName
        self.amdDate = getAmdDate
        self.originalFileId = getOriginalFileId
        self.oldFoldrWholePathNm = oldFoldrWholePathNm
        self.newFoldrWholePathNm = newFoldrWholePathNm
        self.multiCheckedfolderArray = multiCheckedfolderArray
        self.etsionNm = etsionNm
        self.checkedButtonRow = checkedButtonRow
        self.driveFileArray = driveFileArray
        self.driveFolderNameArray = driveFolderNameArray
        self.driveFolderIdArray =  driveFolderIdArray
        self.fromOsCd = fromOsCd
        self.fromDevUuid = fromDevUuid
        self.accessToken = accessToken
        self.googleDriveFileIdPath = googleDriveFileIdPath
        self.deviceName = deviceName
        self.fromUserId = fromUserId
        self.currentDevUuId = currentDevUuId
        self.newFoldrId = newFoldrId
        self.fromFoldrId = fromFoldrId
        self.mimeType = mimeType
        self.containerViewController = containerViewController
        self.storageState = storageState
        self.gDriveMultiCheckedfolderArray = gDriveMultiCheckedfolderArray
        self.listState = listState
        
        switch storageState {
        case .nas:
            print("etsionNm : \(etsionNm), filename : \(getOriginalFileName), fromDevUuid:\(fromDevUuid)")
            
            if(fromDevUuid == Util.getUuid()){
                //local > nas
                if(!etsionNm.isEmpty || getOriginalFileName != "nil"){
                    
                    let fileUrl:URL = FileUtil().getFileUrlWithFoldr(fileNm: getOriginalFileName, foldrWholePathNm: "/Mobile", amdDate: getAmdDate)!
                    sendToNasFromLocal(url: fileUrl, name: getOriginalFileName, toOsCd:getToOsCd, fileId: getOriginalFileId, toUserId:getToUserId, newFoldrWholePathNm:newFoldrWholePathNm)
                } else {
                    // local 폴더 업로드 to nas
                    print("upload path : \(newFoldrWholePathNm), oldFoldrWholePathNm: \(oldFoldrWholePathNm)")
                    
                    ToNasFromLocalFolder().readyCreatFolders(getToUserId:getToUserId, getNewFoldrWholePathNm:newFoldrWholePathNm, getOldFoldrWholePathNm:oldFoldrWholePathNm, getMultiArray:multiCheckedfolderArray, parent: containerViewController, toOsCd: self.toOsCd)
                    containerViewController.showIndicator()
                    
                }
            } else if (fromOsCd == "S" || fromOsCd == "G"){
                // nas to nas
                var booCheck1 = (fromOsCd != "G")
                var booCheck2 = (fromOsCd != "S")
                var booCheck3 = (booCheck1 || booCheck2)
                print("fromOsCd:\(fromOsCd), booCheck1:\(booCheck1), booCheck2:\(booCheck2), booCheck3:\(booCheck3)")
                print("etsionNm : \(etsionNm)")
                // nas to nas or share nas
                if(!etsionNm.isEmpty){
                    // nas 보내기 파일
                    if(fromOsCd == "G"){
                        print("deviceName : \(deviceName)")
                        // nas -> nas 또는 share nas
                        if(getToUserId != UserDefaults.standard.string(forKey: "userId")){
                            let param = ["userId":fromUserId,"toUserId":getToUserId,"devUuid":currentDevUuId,"fileId":getOriginalFileId,"fileNm":getOriginalFileName, "foldrId":newFoldrId,"foldrWholePathNm":newFoldrWholePathNm,"oldfoldrWholePathNm":oldFoldrWholePathNm,"osCd":"G","toOsCd":"S"]
                            print("from g to s param : \(param)")
                            self.sendNasToShareNas(params: param)
                        } else {
                            let param = ["userId":getToUserId, "devUuid": currentDevUuId,"fileId":getOriginalFileId,"fileNm":getOriginalFileName,"foldrId":newFoldrId,"foldrWholePathNm":newFoldrWholePathNm,"oldfoldrWholePathNm":oldFoldrWholePathNm]
                            print("from g to g param : \(param), \(deviceName)")
                            self.sendNasToNas(params: param)
                        }
                    } else if (fromOsCd == "S") {
                        if(getToUserId != UserDefaults.standard.string(forKey: "userId")){
                            let param = ["userId":fromUserId,"toUserId":getToUserId,"devUuid":currentDevUuId,"fileId":getOriginalFileId,"fileNm":getOriginalFileName, "foldrId":newFoldrId,"foldrWholePathNm":newFoldrWholePathNm,"oldfoldrWholePathNm":oldFoldrWholePathNm,"osCd":fromOsCd,"toOsCd":getToOsCd]
                            print("param : \(param)")
                            //shared to shared
                            self.sendNasToShareNas(params: param)
                        } else {
                            let param =                                ["userId":fromUserId,"toUserId":getToUserId,"devUuid":currentDevUuId,"fileId":getOriginalFileId,"fileNm":getOriginalFileName, "foldrId":newFoldrId,"foldrWholePathNm":newFoldrWholePathNm,"oldfoldrWholePathNm":oldFoldrWholePathNm,"osCd":fromOsCd,"toOsCd":getToOsCd]
                            print("param : \(param) to G")
                            self.sendNasToShareNas(params: param)
                        }
                    }
                } else {
                    // nas 보내기 폴더
                    
                    let param = ["userId":fromUserId,"toUserId":getToUserId, "foldrId":fromFoldrId,"foldrWholePathNm":newFoldrWholePathNm,"oldfoldrWholePathNm":oldFoldrWholePathNm,"osCd":fromOsCd,"toOsCd":getToOsCd]
                    if(fromOsCd == "S" || getToOsCd == "S"){
                        print("copyShareNasFolder param : \(param)")
                        self.copyShareNasFolder(params: param)
                    } else {
                        print("fromOsCd: \(fromOsCd), toOsCd :  \(getToOsCd)")
                        print("copyNasFolder param : \(param)")
                        self.copyNasFolder(params: param)
                    }
                    
                }
                
            }  else if fromOsCd == "gDrive" {
                //gdrive to nas
                print("gdrive to nas")
                
                //                print("mimetype : \(self.mimeType)")
                if(!self.mimeType.contains("folder") && !self.mimeType.isEmpty){
                    print("download from gdrive 파일")
                    containerViewController.showIndicator()
                    GoogleWork().downloadGDriveFileToSendToNas(fileId: getOriginalFileId, mimeType: self.mimeType, name: getOriginalFileName, startByte: 0, endByte: 10240) { responseObject, error in
                        if let fileUrl = responseObject {
                            //                            print("fileUrl : \(fileUrl), name : \(getOriginalFileName), toOsCd : \(getToOsCd), fileId : \(self.originalFileId)")
                            if(!fileUrl.absoluteString.isEmpty){
                                //                                print("download end")
                                //sync -> get file id > upload to nas from local
                                //                                print("sync start")
                                //                                DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                                SyncLocalFilleToNas().callSyncToDownloadFronGDriveToSendToNas(view: "NasSendController", parent: self)
                                //
                                //                                })
                            }
                        }
                        return
                    }
                } else {
                    print("accessToken :\(accessToken)")
                    containerViewController.showIndicator()
                    SendFolderToNasFromGDrive().downloadFolderFromGDrive(foldrId: getOriginalFileId, getAccessToken: accessToken, fileId: getOriginalFileId, downloadRootFolderName:getOriginalFileName, parent:self, gDriveMultiCheckedfolderArray:gDriveMultiCheckedfolderArray)
                    
                }
            } else {
                
                // remote to nas
                print("remote to nas , oldFoldrWholePathNm : \(oldFoldrWholePathNm)")
                remoteDownloadRequest(fromUserId: fromUserId, fromDevUuid: fromDevUuid, fromOsCd: fromOsCd, fromFoldr: oldFoldrWholePathNm, fromFileNm: getOriginalFileName, fromFileId: originalFileId)
                
                
            }
            
            break
        case .googleDrive :
            var checkedFolderId = "root"
            var checkedFolderName = "root"
            var finalNewFoldrWholePathNm = "root"
            if listState == .deviceSelect {
                
            } else {
                print("listState : \(listState), index : \(checkedButtonRow)")
                checkedFolderId = driveFileArray[checkedButtonRow].fileId
                checkedFolderName = driveFileArray[checkedButtonRow].name
                finalNewFoldrWholePathNm = ""
                for (index, file) in driveFolderNameArray.enumerated() {
                    if(index < driveFolderNameArray.count){
                        finalNewFoldrWholePathNm += "\(driveFolderNameArray[index])/"
                    }
                }
                finalNewFoldrWholePathNm += "\(checkedFolderName)"
            }
            //            print("driveFolderIdArray: \(driveFolderIdArray), checkedFolderId : \(checkedFolderId)")
            //            print("driveFolderNameArray: \(driveFolderNameArray), checkedFolderName : \(checkedFolderName)")
            if(fromDevUuid == Util.getUuid()){
                if(!etsionNm.isEmpty){
                    let fileURL:URL = FileUtil().getFileUrl(fileNm: getOriginalFileName, amdDate: getAmdDate)!
                    sendToDriveFromLocal(name: getOriginalFileName, path: oldFoldrWholePathNm, fileId: checkedFolderId, fileURL:fileURL)
                    
                    
                } else {
                    print("upload folder from local to gDrive, newFoldrWholePathNm: \(finalNewFoldrWholePathNm)")
                    
                    print("\(driveFolderNameArray)")
                    containerViewController.showIndicator()
                    GoogleWork().readyCreatFolders(getAccessToken: accessToken, getNewFoldrWholePathNm: finalNewFoldrWholePathNm, getOldFoldrWholePathNm: oldFoldrWholePathNm,  getMultiArray: multiCheckedfolderArray, fileId: checkedFolderId, parent: containerViewController, nasSendController: self)
                    
                    
                }
                
                
            } else if fromOsCd == "gDrive" {
                //gdrive to gdrive
                print("gdrive to gdrive")
                //                parent.activityIndicator.startAnimating()
                print("fileId : \(getOriginalFileId), name : \(getOriginalFileName), googleDriveFileIdPath : \(googleDriveFileIdPath)")
                print("mimeType : \(mimeType)")
                
                GoogleWork().copyGdriveFile(name: getOriginalFileName, fileId: getOriginalFileId, parents: googleDriveFileIdPath) { responseObject, error in
                    if let fileUrl = responseObject {
                        DispatchQueue.main.async {
                            let alertController = UIAlertController(title: nil, message: "파일 복사에 성공했습니다.", preferredStyle: .alert)
                            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                                UIAlertAction in
                                //Do you Success button Stuff here
                                self.containerViewController?.finishLoading()
                                
                            }
                            alertController.addAction(yesAction)
                            self.containerViewController?.present(alertController, animated: true)
                            
                        }
                        
                    }
                    
                    return
                }
                
            } else {
                // nasd to gdrive
                
                //                print("etsionNm : \(etsionNm)")
                if(!etsionNm.isEmpty){
                    // from nas to gdrive file
                    //                    print("downloadFromNasToDriveFile")
                    downloadFromNasToDrive(name: getOriginalFileName, path: oldFoldrWholePathNm, fileId: checkedFolderId, fromUserId: fromUserId, accessToken: accessToken)
                } else {
                    // from nas to gdrive folder
                    let inFoldrId:Int = Int(fromFoldrId) ?? 0
                    //                    print("deviceName : \(deviceName), newFoldrWholePathNm: \(newFoldrWholePathNm)")
                    //                    print("driveFolderIdArray: \(driveFolderIdArray), checkedFolderId : \(checkedFolderId)")
                    //                    print("driveFolderNameArray: \(driveFolderNameArray), checkedFolderName : \(checkedFolderName)")
                    //                    print("foldrId: \(inFoldrId), foldrWholePathNm: \(oldFoldrWholePathNm), userId:\(fromUserId), devUuid:\(fromDevUuid), deviceName:\(deviceName), getAccessToken: \(accessToken), getNewFoldrWholePathNm: \(newFoldrWholePathNm), getGdriveFolderIdToSave: \(checkedFolderId), getOldFoldrWholePathNm: \(oldFoldrWholePathNm),  getMultiArray: \(multiCheckedfolderArray), fileId: \(googleDriveFileIdPath), storageState: .googleDrive")
                    var getArray = multiCheckedfolderArray
                    getArray.removeAll()
                    
                    SendFolderToGdriveFromNAS().downloadFolderFromNas(foldrId: inFoldrId, foldrWholePathNm: oldFoldrWholePathNm, userId:fromUserId, devUuid:fromDevUuid, deviceName:deviceName, getAccessToken: accessToken, getNewFoldrWholePathNm: newFoldrWholePathNm, getGdriveFolderIdToSave: checkedFolderId, getOldFoldrWholePathNm: oldFoldrWholePathNm,  getMultiArray: getArray, fileId: googleDriveFileIdPath, containerViewController:containerViewController, storageState: .googleDrive, nasSendController:self)
                    containerViewController.showIndicator()
                }
                
            }
            break
            
        case .nas_multi:
            print("multi ans to nas")
            print("multiCheckedfolderArray : \(multiCheckedfolderArray)")
            startMultiSendToNas()
            
            break
        case .nas_gdrive_multi:
            print("multi nas to gdrive")
            //multicheck call download - > start
            startMultiNasToGdrive()
            break
            
        case .gdrive_nas_multi:
            print("multi gDrive to nas")
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
            startMultiGdriveToNas()
            containerViewController.showIndicator()
            break
        case .remote_nas_multi:
            print("multi remote to nas")
            print("multiCheckedfolderArray : \(multiCheckedfolderArray), oldFoldrWholePathNm : \(oldFoldrWholePathNm)")
            MultiCheckFileListController().remoteMultiDownloadRequestToSend(getFolderArray: multiCheckedfolderArray, parent: containerViewController, fromUserId:fromUserId, fromDevUuid: fromDevUuid, deviceName: deviceName, devFoldrId:fromFoldrId, fromOsCd:fromOsCd, toUserId:toUserId, toOsCd:toOsCd, toDevUuid: currentDevUuId, toFoldr:newFoldrWholePathNm, fromFoldr:oldFoldrWholePathNm)
            containerViewController.showIndicator()
            break
        case .local_nas_multi:
            print("multi local to nas")
            startMultiSendToNas()
            containerViewController.showIndicator()
            break
        case .local_gdrive_multi:
            print("multi local to gdrive")
            startMultiLocalToGdrive()
            break
        case .search_nas_multi:
            print("multi search to nas")
            
            startMultiSendToNas()
            containerViewController.showIndicator()
            break
        case .multi_nas_multi:
            print("multi lately file to nas")
            
            startMultiSendToNas()
            containerViewController.showIndicator()
            break
        default:
            break
        }
        
    }
    
    
    func startMultiSendToNas(){
        if(multiCheckedfolderArray.count > 0){
            let index = multiCheckedfolderArray.count - 1
            let originalFileId = String(multiCheckedfolderArray[index].fileId)
            let fromFoldrId = String(multiCheckedfolderArray[index].foldrId)
            let originalFileName = multiCheckedfolderArray[index].fileNm
            let oldFoldrWholePathNm = multiCheckedfolderArray[index].foldrWholePathNm
            let etsionNm = multiCheckedfolderArray[index].etsionNm
            let devUuid = multiCheckedfolderArray[index].devUuid
            let fromOsCd = multiCheckedfolderArray[index].osCd
            let fromUserId = multiCheckedfolderArray[index].userId
            let fromDevUuid = multiCheckedfolderArray[index].devUuid
            print("fromOsCd : \(fromOsCd), fromUserId : \(fromUserId), fromDevUuid : \(fromDevUuid), oldFoldrWholePathNm : \(oldFoldrWholePathNm)")
            
            if(etsionNm != "nil"){
                // nas 보내기 파일
                if(fromOsCd == "G"){
                    print("deviceName : \(deviceName)")
                    // nas -> nas 또는 share nas
                    if(toUserId != UserDefaults.standard.string(forKey: "userId")){
                        let param = ["userId":fromUserId,"toUserId":toUserId,"devUuid":currentDevUuId,"fileId":originalFileId,"fileNm":originalFileName, "foldrId":newFoldrId,"foldrWholePathNm":newFoldrWholePathNm,"oldfoldrWholePathNm":oldFoldrWholePathNm,"osCd":"G","toOsCd":"S"]
                        print("from g to s param : \(param)")
                        self.sendNasToShareNas(params: param)
                    } else {
                        let param = ["userId":toUserId, "devUuid": currentDevUuId,"fileId":originalFileId,"fileNm":originalFileName,"foldrId":newFoldrId,"foldrWholePathNm":newFoldrWholePathNm,"oldfoldrWholePathNm":oldFoldrWholePathNm]
                        print("from g to g param : \(param), \(deviceName)")
                        self.sendNasToNas(params: param)
                    }
                } else if (fromOsCd == "S") {
                    if(toUserId != UserDefaults.standard.string(forKey: "userId")){
                        let param = ["userId":fromUserId,"toUserId":toUserId,"devUuid":currentDevUuId,"fileId":originalFileId,"fileNm":originalFileName, "foldrId":newFoldrId,"foldrWholePathNm":newFoldrWholePathNm,"oldfoldrWholePathNm":oldFoldrWholePathNm,"osCd":fromOsCd,"toOsCd":toOsCd]
                        print("param : \(param)")
                        //shared to shared
                        self.sendNasToShareNas(params: param)
                    } else {
                        let param =                                ["userId":fromUserId,"toUserId":toUserId,"devUuid":currentDevUuId,"fileId":originalFileId,"fileNm":originalFileName, "foldrId":newFoldrId,"foldrWholePathNm":newFoldrWholePathNm,"oldfoldrWholePathNm":oldFoldrWholePathNm,"osCd":fromOsCd,"toOsCd":toOsCd]
                        print("param : \(param) to G")
                        self.sendNasToShareNas(params: param)
                    }
                } else if devUuid == Util.getUuid() {
                    print("from my device to nas")
                    let fileUrl:URL = FileUtil().getFileUrlWithFoldr(fileNm: originalFileName, foldrWholePathNm: oldFoldrWholePathNm, amdDate: self.amdDate)!
                    sendToNasFromLocal(url: fileUrl, name: originalFileName, toOsCd:toOsCd, fileId: originalFileId, toUserId: toUserId, newFoldrWholePathNm: newFoldrWholePathNm)
                } else {
                    print("from remote to nas")
                    remoteDownloadRequestToSend(fromUserId: fromUserId, fromDevUuid: fromDevUuid, fromOsCd: fromOsCd, fromFoldr: oldFoldrWholePathNm, fromFileNm: originalFileName, fromFileId: originalFileId)
                }
            } else {
                // nas 보내기 폴더
                
                let param = ["userId":fromUserId,"toUserId":toUserId, "foldrId":fromFoldrId,"foldrWholePathNm":newFoldrWholePathNm,"oldfoldrWholePathNm":oldFoldrWholePathNm,"osCd":fromOsCd,"toOsCd":toOsCd]
                if((fromOsCd == "S" && toOsCd == "G") || (toOsCd == "S" && fromOsCd == "G")){
                    print("copyShareNasFolder param : \(param)")
                    self.copyShareNasFolder(params: param)
                } else if devUuid != Util.getUuid() {
                    print("fromOsCd: \(fromOsCd), toOsCd :  \(toOsCd)")
                    print("copyNasFolder param : \(param)")
                    self.copyNasFolder(params: param)
                } else {
                    print("local to nas folder")
                    ToNasFromLocalFolder().readyCreatFoldersFromNasSendController(getToUserId:toUserId, getNewFoldrWholePathNm:newFoldrWholePathNm, getOldFoldrWholePathNm:oldFoldrWholePathNm, getMultiArray:multiCheckedfolderArray, nasSendController:self, toOsCd: toOsCd)
                }
                
            }
            return
        }
        //        print("count : \(multiCheckedfolderArray.count)")
        containerViewController?.inActiveMultiCheck()
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
    
    func startMultiGdriveToNas(){
        print("gDriveMultiCheckedfolderArray : \(gDriveMultiCheckedfolderArray.count)")
        if(gDriveMultiCheckedfolderArray.count > 0){
            
            let index = gDriveMultiCheckedfolderArray.count - 1
            let originalFileId = String(gDriveMultiCheckedfolderArray[index].fileId)
            let fromFoldrId = String(gDriveMultiCheckedfolderArray[index].fileId)
            originalFileName = gDriveMultiCheckedfolderArray[index].name
            let oldFoldrWholePathNm = gDriveMultiCheckedfolderArray[index].foldrWholePath
            let mimeType = gDriveMultiCheckedfolderArray[index].mimeType
            print("mimeType : \(mimeType)")
            if(mimeType != Util.getGoogleMimeType(etsionNm: "folder")){
                
                GoogleWork().downloadGDriveFileToSendToNas(fileId: originalFileId, mimeType: mimeType, name: originalFileName, startByte: 0, endByte: 10240) { responseObject, error in
                    if let fileUrl = responseObject {
                        if(!fileUrl.absoluteString.isEmpty){
                            print("download end")
                            //sync -> get file id > upload to nas from local
                            if(self.gDriveMultiCheckedfolderArray.count > 0){
                                let lastIndex = self.gDriveMultiCheckedfolderArray.count - 1
                                let fileId = self.gDriveMultiCheckedfolderArray[lastIndex].fileId
                                let fileDict = ["fileId":fileId]
                                NotificationCenter.default.post(name: Notification.Name("completeFileProcess"), object: self, userInfo:fileDict)
                                self.gDriveMultiCheckedfolderArray.remove(at: lastIndex)
                            }
                            self.startMultiGdriveToNas()
                        }
                    }
                }
                return
            } else {
                SendFolderToNasFromGDrive().downloadFolderFromGDrive(foldrId: originalFileId, getAccessToken: accessToken, fileId: originalFileId, downloadRootFolderName:originalFileName, parent:self, gDriveMultiCheckedfolderArray:gDriveMultiCheckedfolderArray)
                return
            }
        }
        print("start upload file")
        
        containerViewController?.inActiveMultiCheck()
        if let syncOngoing:Bool = UserDefaults.standard.bool(forKey: "syncOngoing"), syncOngoing == true {
            print("aleady Syncing")
        } else {
            
            SyncLocalFilleToNas().callSyncFomGdriveToNasSendFolder(view: "NasSendController", parent: self, rootFolder: "/Mobile/tmp")
        }
        
    }
    
    
    
    func startMultiLocalToGdrive(){
        if(multiCheckedfolderArray.count > 0){
            let index = multiCheckedfolderArray.count - 1
            let originalFileId = String(multiCheckedfolderArray[index].fileId)
            let fromFoldrId = String(multiCheckedfolderArray[index].foldrId)
            let originalFileName = multiCheckedfolderArray[index].fileNm
            let oldFoldrWholePathNm = multiCheckedfolderArray[index].foldrWholePathNm
            let etsionNm = multiCheckedfolderArray[index].etsionNm
            let amdDate = multiCheckedfolderArray[index].amdDate
            
            var checkedFolderId = "root"
            var checkedFolderName = "root"
            var finalNewFoldrWholePathNm = "root"
            if listState == .deviceSelect {
            } else {
                print("listState : \(listState), index : \(checkedButtonRow)")
                checkedFolderId = driveFileArray[checkedButtonRow].fileId
                checkedFolderName = driveFileArray[checkedButtonRow].name
                finalNewFoldrWholePathNm = ""
                for (index, file) in driveFolderNameArray.enumerated() {
                    if(index < driveFolderNameArray.count){
                        finalNewFoldrWholePathNm += "\(driveFolderNameArray[index])/"
                    }
                }
                finalNewFoldrWholePathNm += "\(checkedFolderName)"
            }
            print("etsionNm  : \(etsionNm)")
            if(etsionNm != "nil"){
                print("originalFileName : \(originalFileName)")
                let fileURL:URL = FileUtil().getFileUrl(fileNm: originalFileName, amdDate: amdDate)!
                sendToDriveFromLocal(name: originalFileName, path: oldFoldrWholePathNm, fileId: checkedFolderId, fileURL:fileURL)
                return
            } else {
                print("upload folder from local to gDrive, newFoldrWholePathNm: \(finalNewFoldrWholePathNm)")
                print("\(driveFolderNameArray)")
                GoogleWork().readyCreatFolders(getAccessToken: accessToken, getNewFoldrWholePathNm: finalNewFoldrWholePathNm, getOldFoldrWholePathNm: oldFoldrWholePathNm,  getMultiArray: multiCheckedfolderArray, fileId: checkedFolderId, parent: containerViewController!, nasSendController:self)
                
                return
            }
            
        }
        
        containerViewController?.inActiveMultiCheck()
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: nil, message: "업로드에 성공 하였습니다.", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                //Do you Success button Stuff here
                self.containerViewController?.finishLoading()
                
            }
            alertController.addAction(yesAction)
            self.containerViewController?.present(alertController, animated: true)
            
        }
        
    }
    
    func startMultiNasToGdrive(){
        if(multiCheckedfolderArray.count > 0){
            let index = multiCheckedfolderArray.count - 1
            let originalFileId = String(multiCheckedfolderArray[index].fileId)
            let fromFoldrId = String(multiCheckedfolderArray[index].foldrId)
            let originalFileName = multiCheckedfolderArray[index].fileNm
            let oldFoldrWholePathNm = multiCheckedfolderArray[index].foldrWholePathNm
            let etsionNm = multiCheckedfolderArray[index].etsionNm
            let amdDate = multiCheckedfolderArray[index].amdDate
            
            print("originalFileName : \(originalFileName), etsionNm: \(etsionNm)")
            var checkedFolderId = "root"
            var checkedFolderName = "root"
            var finalNewFoldrWholePathNm = "root"
            if listState == .deviceSelect {
                
            } else {
                print("listState : \(listState), index : \(checkedButtonRow)")
                checkedFolderId = driveFileArray[checkedButtonRow].fileId
                checkedFolderName = driveFileArray[checkedButtonRow].name
                for (index, file) in driveFolderNameArray.enumerated() {
                    if(index < driveFolderNameArray.count){
                        finalNewFoldrWholePathNm += "/\(driveFolderNameArray[index])"
                    }
                }
                finalNewFoldrWholePathNm += "/\(checkedFolderName)"
            }
            print("driveFolderIdArray: \(driveFolderIdArray), checkedFolderId : \(checkedFolderId)")
            print("driveFolderNameArray: \(driveFolderNameArray), checkedFolderName : \(checkedFolderName)")
            print("etsionNm : \(etsionNm)")
            
            if(!etsionNm.isEmpty && etsionNm != "nil"){
                // from nas to gdrive
                print("downloadFromNasToDriveFile")
                downloadFromNasToDrive(name: originalFileName, path: oldFoldrWholePathNm, fileId: checkedFolderId, fromUserId: fromUserId, accessToken: accessToken)
                return
            } else {
                // from nas to gdrive folder
                let inFoldrId = Int(fromFoldrId) ?? 0
                
                SendFolderToGdriveFromNAS().downloadFolderFromNas(foldrId: inFoldrId, foldrWholePathNm: oldFoldrWholePathNm, userId:fromUserId, devUuid:fromDevUuid, deviceName:deviceName, getAccessToken: accessToken, getNewFoldrWholePathNm: newFoldrWholePathNm, getGdriveFolderIdToSave: checkedFolderId, getOldFoldrWholePathNm: oldFoldrWholePathNm,  getMultiArray: multiCheckedfolderArray, fileId: googleDriveFileIdPath, containerViewController:containerViewController!, storageState: storageState, nasSendController:self)
                return
                
            }
            
        } else {
            let pathForRemove:String = FileUtil().getFilePath(fileNm: "tmp", amdDate: "amdDate")
            print("pathForRemove : \(pathForRemove)")
            if(pathForRemove.isEmpty){
                
            } else {
                FileUtil().removeFile(path: pathForRemove)
                if let syncOngoing:Bool = UserDefaults.standard.bool(forKey: "syncOngoing"), syncOngoing == true {
                } else {
                    SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
                }
            }
        }
        containerViewController?.inActiveMultiCheck()
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: nil, message: "GDrive로 내보내기 성공", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                //Do you Success button Stuff here
                self.containerViewController?.finishLoading()
                
            }
            alertController.addAction(yesAction)
            self.containerViewController?.present(alertController, animated: true)
            
        }
        
        
    }
    
    
    
    
    func sendToNasFromLocal(url:URL, name:String, toOsCd:String, fileId:String, toUserId:String, newFoldrWholePathNm:String){
        containerViewController?.showIndicator()
        let userId:String = toUserId
        let password:String = UserDefaults.standard.string(forKey: "userPassword")!
        let loginUserId = UserDefaults.standard.string(forKey: "userId")
        print("loginUserId : \(String(describing: loginUserId!))")
        let credentialData = "\(App.nasFoldrFrontNm)\(String(describing: loginUserId!)):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        let decodedData = Data(base64Encoded: base64Credentials)!
        let decodedString = String(data: decodedData, encoding: .utf8)!
        print("decodedString : \(decodedString)")
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
        
        let filePath = url.path
        let fileExtension = url.pathExtension
        print("fileExtension : \(fileExtension)")
        print("file path : \(filePath)")
        
        
        print("fileId : \(fileId)")
        do {
            //            let data = try Data(contentsOf: url)
            //            print("data : \(data)")
            //            let data = NSData.dataWithContentsOfMappedFile(filePath)
            if FileManager.default.fileExists(atPath: url.path) {
                var fileSize = 0.0
                do {
                    let attribute = try FileManager.default.attributesOfItem(atPath: filePath)
                    if let size = attribute[FileAttributeKey.size] as? NSNumber {
                        fileSize =  size.doubleValue / 1000000.0
                    }
                } catch {
                    print("Error: \(error)")
                }
                print("FILE Yes AVAILABLE")
                print("stream upload, fileSize : \(fileSize)")
                
                let stream:InputStream = InputStream(url: url)!
                let newName = name.precomposedStringWithCanonicalMapping
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
                                self.notifyNasUploadFinish(name: newName, toOsCd:toOsCd, fileId:fileId, toUserId:toUserId, newFoldrWholePathNm:newFoldrWholePathNm)
                            }
                        }
                        upload.uploadProgress { progress in
                            
                            print(progress.fractionCompleted)
                        }
                        break
                    case .failure(let encodingError):
                        print(encodingError.localizedDescription)
                        
                        break
                    }
                })
            } else {
                print("FILE NOT AVAILABLE")
            }
        } catch {
            print("Unable to load data: \(error)")
            
        }
        
        
        
        
    }
    
    func notifyNasUploadFinish(name:String, toOsCd:String, fileId:String, toUserId:String, newFoldrWholePathNm:String){
        let urlString = App.URL.hostIpServer+"nasUpldCmplt.do"
        
        
        let paramas:[String : Any] = ["userId":toUserId,"fileId":fileId,"toFoldr":newFoldrWholePathNm,"toFileNm":name,"toOsCd":toOsCd]
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
                                print("notifyNasUploadFinish storage : \(self.storageState), fromOsCd: \(self.fromOsCd)")
                                if(self.storageState == .remote_nas_multi) {
                                    //                                    self.countRemoteDownloadFinished()
                                } else if self.storageState == .local_nas_multi {
                                    
                                    let fileId:String = "\(self.multiCheckedfolderArray[self.multiCheckedfolderArray.count - 1].fileId)"
                                    let fileDict = ["fileId":fileId]
                                    NotificationCenter.default.post(name: Notification.Name("completeFileProcess"), object: self, userInfo:fileDict)
                                    let lastIndex = self.multiCheckedfolderArray.count - 1
                                    self.multiCheckedfolderArray.remove(at: lastIndex)
                                    self.startMultiSendToNas()
                                    
                                } else if self.storageState == .multi_nas_multi {
                                    ////
                                    let lastIndex = self.multiCheckedfolderArray.count - 1
                                    self.multiCheckedfolderArray.remove(at: lastIndex)
                                    self.startMultiSendToNas()
                                    
                                } else if self.storageState == .gdrive_nas_multi {
                                    let lastIndex = self.gDriveMultiCheckedfolderArray.count - 1
                                    self.gDriveMultiCheckedfolderArray.remove(at: lastIndex)
                                    self.startMultiGdriveToNas()
                                } else if self.storageState == .search_nas_multi {
                                    let lastIndex = self.multiCheckedfolderArray.count - 1
                                    self.multiCheckedfolderArray.remove(at: lastIndex)
                                    self.startMultiSendToNas()
                                } else {
                                    // 보내기용 다운 파일 삭제
                                    if(self.storageState == .nas && self.fromOsCd != "S" && self.fromOsCd != "G" && self.fromOsCd == "gDrive") {
                                        let pathForRemove:String = FileUtil().getFilePath(fileNm: "tmp", amdDate: "amdDate")
                                        print("pathForRemove : \(pathForRemove)")
                                        if(pathForRemove.isEmpty){
                                            
                                        } else {
                                            FileUtil().removeFile(path: pathForRemove)
                                            if let syncOngoing:Bool = UserDefaults.standard.bool(forKey: "syncOngoing"), syncOngoing == true {
                                                print("aleady Syncing")
                                                
                                            } else {
                                                SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
                                            }
                                            
                                            
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
                                
                                break
                            case .failure(let error):
                                
                                print(error.localizedDescription)
                            }
        }
    }
    
    func sendToDriveFromLocal(name:String, path:String, fileId:String, fileURL:URL){
        let googleEmail = UserDefaults.standard.string(forKey: "googleEmail")
        let accessToken:String = self.accessToken
        
        containerViewController?.showIndicator()
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
        if (fileId.isEmpty){
            
        } else {
            addParents = ",'parents' : [ '\(fileId)' ]"
        }
        do {
            do {
                let attribute = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                if let size = attribute[FileAttributeKey.size] as? NSNumber {
                    fileSize =  size.doubleValue / 1000000.0
                }
            } catch {
                print("Error: \(error)")
            }
            
            let edited = name.replacingOccurrences(of: "'", with: "\\'")
            let encoded = name.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
            print("sendToDriveFromLocal encoded : \(encoded), edited : \(edited)")
            
            //            let encodedName:String = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
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
                        print("response:: \(response)")
                        if (self.storageState == .local_gdrive_multi){
                            if(self.multiCheckedfolderArray.count > 0) {
                                let statusCode = (response.response?.statusCode)! //example : 200
                                if(statusCode == 200) {
                                    let fileId:String = "\(self.multiCheckedfolderArray[self.multiCheckedfolderArray.count - 1].fileId)"
                                    let fileDict = ["fileId":fileId]
                                    NotificationCenter.default.post(name: Notification.Name("completeFileProcess"), object: self, userInfo:fileDict)
                                    
                                    let lastIndex = self.multiCheckedfolderArray.count - 1
                                    self.multiCheckedfolderArray.remove(at: lastIndex)
                                    self.startMultiLocalToGdrive()
                                } else {
                                    //multi 에러 표시
                                    let lastIndex = self.multiCheckedfolderArray.count - 1
                                    self.multiCheckedfolderArray.remove(at: lastIndex)
                                    self.startMultiLocalToGdrive()
                                }
                            } else {
                                self.startMultiLocalToGdrive()
                            }
                            
                        } else {
                            let statusCode = (response.response?.statusCode)! //example : 200
                            if(statusCode == 200) {
                                print("업로드 성공")
                                let alertController = UIAlertController(title: nil, message: "파일 업로드에 성공 하였습니다.", preferredStyle: .alert)
                                let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel)  {
                                    UIAlertAction in
                                    self.containerViewController?.finishLoading()
                                    
                                }
                                alertController.addAction(yesAction)
                                self.containerViewController?.present(alertController, animated: true)
                            } else {
                                let alertController = UIAlertController(title: nil, message: "파일 업로드에 실패 하였습니다.\n 잠시 후 재시도 부탁 드립니다.", preferredStyle: .alert)
                                let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel)  {
                                    UIAlertAction in
                                    self.containerViewController?.finishLoading()
                                    
                                }
                                alertController.addAction(yesAction)
                                self.containerViewController?.present(alertController, animated: true)
                            }
                        }
                        
                    }
                    upload.uploadProgress { progress in
                        
                        print(progress.fractionCompleted)
                    }
                    break
                case .failure(let encodingError):
                    print(encodingError.localizedDescription)
                    self.containerViewController?.finishLoading()
                    if(self.multiCheckedfolderArray.count > 0) {
                        //멀티 프로세스 fail 처리
                        let lastIndex = self.multiCheckedfolderArray.count - 1
                        self.multiCheckedfolderArray.remove(at: lastIndex)
                        self.startMultiLocalToGdrive()
                    }
                    
                    break
                }
            })
        } catch {
            print("Unable to load data: \(error)")
        }
        
    }
    
    func sendNasToShareNas(params:[String:Any]){
        containerViewController?.showIndicator()
        ContextMenuWork().fromNasToStorage(parameters: params){ responseObject, error in
            let json = JSON(responseObject)
            let message = json["message"].string
            print("\(String(describing: message)), \(String(describing: json["statusCode"].int))")
            if let statusCode = json["statusCode"].int, statusCode == 100 {
                if(self.storageState == .nas){
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: nil, message: "NAS로 내보내기 성공", preferredStyle: .alert)
                        let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel)  {
                            UIAlertAction in
                            self.containerViewController?.finishLoading()
                            
                        }
                        alertController.addAction(yesAction)
                        self.containerViewController?.present(alertController, animated: true)
                        
                    }
                    
                } else if(self.storageState == .nas_multi) {
                    let fileId:String = "\(self.multiCheckedfolderArray[self.multiCheckedfolderArray.count - 1].fileId)"
                    let fileDict = ["fileId":fileId]
                    NotificationCenter.default.post(name: Notification.Name("completeFileProcess"), object: self, userInfo:fileDict)
                    
                    let lastIndex = self.multiCheckedfolderArray.count - 1
                    self.multiCheckedfolderArray.remove(at: lastIndex)
                    self.startMultiSendToNas()
                } else if (self.storageState == .multi_nas_multi){
                    let lastIndex = self.multiCheckedfolderArray.count - 1
                    self.multiCheckedfolderArray.remove(at: lastIndex)
                    self.startMultiSendToNas()
                } else if self.storageState == .search_nas_multi {
                    let lastIndex = self.multiCheckedfolderArray.count - 1
                    self.multiCheckedfolderArray.remove(at: lastIndex)
                    self.startMultiSendToNas()
                }
                
            } else {
                print(error?.localizedDescription as Any)
                
                if self.storageState == .nas_multi {
                    NotificationCenter.default.post(name: Notification.Name("failFileProcess"), object: self, userInfo:nil)
                }
                
                let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel)  {
                    UIAlertAction in
                    self.containerViewController?.finishLoading()
                    
                }
                alertController.addAction(yesAction)
                self.containerViewController?.present(alertController, animated: true)
            }
            
            return
        }
    }
    
    
    
    func sendNasToNas(params:[String:Any]){
        containerViewController?.showIndicator()
        ContextMenuWork().fromNasToNas(parameters: params){ responseObject, error in
            if error == nil {
                if let obj = responseObject {
                    let json = JSON(obj)
                    let message = json["message"].string
                    if let statusCode = json["statusCode"].int, statusCode == 100 {
                        if(self.storageState == .nas){
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
                        }  else if (self.storageState == .nas_multi) {
                            let lastIndex = self.multiCheckedfolderArray.count - 1
                            let fileId:String = "\(self.multiCheckedfolderArray[lastIndex].fileId)"
                            let fileDict = ["fileId":fileId]
                            NotificationCenter.default.post(name: Notification.Name("completeFileProcess"), object: self, userInfo:fileDict)
                            
                            self.multiCheckedfolderArray.remove(at: lastIndex)
                            self.startMultiSendToNas()
                        }  else if (self.storageState == .multi_nas_multi){
                            
                            let lastIndex = self.multiCheckedfolderArray.count - 1
                            let fileId:String = "\(self.multiCheckedfolderArray[lastIndex].fileId)"
                            let fileDict = ["fileId":fileId]
                            NotificationCenter.default.post(name: Notification.Name("completeFileProcess"), object: self, userInfo:fileDict)
                            
                            self.multiCheckedfolderArray.remove(at: lastIndex)
                            self.startMultiSendToNas()
                            
                        } else if self.storageState == .search_nas_multi {
                            let lastIndex = self.multiCheckedfolderArray.count - 1
                            self.multiCheckedfolderArray.remove(at: lastIndex)
                            self.startMultiSendToNas()
                        }
                        
                    } else {
                        
                        if self.storageState == .multi_nas_multi || self.storageState == .nas_multi {
                            NotificationCenter.default.post(name: Notification.Name("failFileProcess"), object: self, userInfo:nil)
                        } else {
                            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                                UIAlertAction in
                                
                                self.containerViewController?.finishLoading()
                            }
                            alertController.addAction(yesAction)
                            self.containerViewController?.present(alertController, animated: true)
                        }
                        
                        
                    }
                }
            } else {
                if self.storageState == .multi_nas_multi || self.storageState == .nas_multi {
                    NotificationCenter.default.post(name: Notification.Name("failFileProcess"), object: self, userInfo:nil)
                } else {
                    
                    self.containerViewController?.showErrorAlert()
                }
                
                
            }
            
            return
        }
    }
    
    func copyNasFolder(params:[String:Any]){
        containerViewController?.showIndicator()
        ContextMenuWork().copyNasFolder(parameters: params){ responseObject, error in
            let json = JSON(responseObject)
            let message = responseObject?.object(forKey: "message") as? String
            //            print("\(message), \(String(describing: json["statusCode"].int))")
            if let statusCode = json["statusCode"].int, statusCode == 100 {
                if(self.storageState == .nas){
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                        let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                            UIAlertAction in
                            //Do you Success button Stuff here
                            self.containerViewController?.finishLoading()
                        }
                        alertController.addAction(yesAction)
                        self.containerViewController?.present(alertController, animated: true)
                    }
                } else if(self.storageState == .nas_multi) {
                    let foldrId:String = "\(self.multiCheckedfolderArray[self.multiCheckedfolderArray.count - 1].foldrId)"
                    let fileDict = ["fileId":foldrId]
                    NotificationCenter.default.post(name: Notification.Name("completeFileProcess"), object: self, userInfo:fileDict)
                    let lastIndex = self.multiCheckedfolderArray.count - 1
                    self.multiCheckedfolderArray.remove(at: lastIndex)
                    self.startMultiSendToNas()
                }
                
            } else {
                print(error?.localizedDescription as Any)
                self.containerViewController?.showErrorAlert()
            }
            
            return
        }
    }
    
    func copyShareNasFolder(params:[String:Any]){
        containerViewController?.showIndicator()
        print(params)
        ContextMenuWork().copyShareNasFolder(parameters: params){ responseObject, error in
            let json = JSON(responseObject)
            let message = responseObject?.object(forKey: "message") as? String
            print("\(message), \(String(describing: json["statusCode"].int))")
            if let statusCode = json["statusCode"].int, statusCode == 100 {
                
                if(self.storageState == .nas){
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                        let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                            UIAlertAction in
                            //Do you Success button Stuff here
                            self.containerViewController?.finishLoading()
                        }
                        alertController.addAction(yesAction)
                        self.containerViewController?.present(alertController, animated: true)
                        
                    }
                } else if(self.storageState == .nas_multi) {
                    let lastIndex = self.multiCheckedfolderArray.count - 1
                    let foldrId = self.multiCheckedfolderArray[lastIndex].foldrId
                    let fileDict = ["fileId":"\(foldrId)"]
                    NotificationCenter.default.post(name: Notification.Name("completeFileProcess"), object: self, userInfo:fileDict)
                    self.multiCheckedfolderArray.remove(at: lastIndex)
                    self.startMultiSendToNas()
                }
                
            } else {
                // 0516 - NAS 폴더 이동에 실패하였습니다 alert +  multi의 경우 multiCheckedfolderArry all remove 후 progress창 닫을 것
                if self.storageState == .nas_multi {
                    NotificationCenter.default.post(name: Notification.Name("failFileProcess"), object: self, userInfo:nil)
                }
                let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    //Do you Success button Stuff here
                    self.containerViewController?.finishLoading()
                }
                alertController.addAction(yesAction)
                self.containerViewController?.present(alertController, animated: true)
                print(error?.localizedDescription as Any)
            }
            
            return
        }
        
    }
    
    
    
    func downloadFromNasToDrive(name:String, path:String, fileId:String, fromUserId:String, accessToken:String){
        containerViewController?.showIndicator()
        SendFolderToGdriveFromNAS().downloadFromNasToSend(userId:fromUserId, fileNm:name, path:path){ responseObject, error in
            if let success = responseObject {
                if(success.isEmpty){
                } else {
                    print("localUrl : \(success)")
                    let fileURL:URL = URL(string: success)!
                    let fileExtension = fileURL.pathExtension
                    let googleMimeType:String = Util.getGoogleMimeType(etsionNm: fileExtension)
                    
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
                    let stringUrl = "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart"
                    let headers = [
                        "Authorization": "Bearer \(accessToken)",
                        "Content-type": "multipart/related; boundary=foo_bar_baz",
                        "Content-Length": "\(fileSize)"
                    ]
                    var addParents = ""
                    if (fileId.isEmpty){
                        
                    } else {
                        addParents = ",'parents' : [ '\(fileId)' ]"
                    }
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
                        multipartFormData.append(stream, withLength: UInt64(fileSize), name: "foo_bar_baz", fileName: newName, mimeType: googleMimeType)
                        
                    }, usingThreshold: UInt64.init(), to: stringUrl, method: .post, headers: headers,
                       encodingCompletion: { encodingResult in
                        switch encodingResult {
                        case .success(let upload, _, _):
                            upload.responseJSON { response in
                                print("response:: \(response)")
                                let pathForRemove:String = FileUtil().getFilePath(fileNm: "tmp", amdDate: "amdDate")
                                print("pathForRemove : \(pathForRemove)")
                                if(pathForRemove.isEmpty){
                                    
                                } else {
                                    FileUtil().removeFile(path: pathForRemove)
                                }
                                if (self.storageState == .nas_gdrive_multi){
                                    if(self.multiCheckedfolderArray.count > 0) {
                                        let fileId:String = "\(self.multiCheckedfolderArray[self.multiCheckedfolderArray.count - 1].fileId)"
                                        let fileDict = ["fileId":fileId]
                                        NotificationCenter.default.post(name: Notification.Name("completeFileProcess"), object: self, userInfo:fileDict)
                                        
                                        let lastIndex = self.multiCheckedfolderArray.count - 1
                                        self.multiCheckedfolderArray.remove(at: lastIndex)
                                    }
                                    self.startMultiNasToGdrive()
                                    //
                                } else {
                                    let alertController = UIAlertController(title: nil, message: "파일 업로드에 성공 하였습니다.", preferredStyle: .alert)
                                    let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                                        UIAlertAction in
                                        //Do you Success button Stuff here
                                        self.containerViewController?.finishLoading()
                                    }
                                    alertController.addAction(yesAction)
                                    self.containerViewController?.present(alertController, animated: true)
                                }
                                
                            }
                            break
                        case .failure(let encodingError):
                            print(encodingError.localizedDescription)
                            self.containerViewController?.finishLoading()
                            if (self.storageState == .nas_gdrive_multi){
                                if(self.multiCheckedfolderArray.count > 0) {
                                    let fileId:String = "\(self.multiCheckedfolderArray[self.multiCheckedfolderArray.count - 1].fileId)"
                                    let fileDict = ["fileId":fileId]
                                    NotificationCenter.default.post(name: Notification.Name("failFileProcess"), object: self, userInfo:fileDict)
                                    
                                    let lastIndex = self.multiCheckedfolderArray.count - 1
                                    self.multiCheckedfolderArray.remove(at: lastIndex)
                                }
                                self.startMultiNasToGdrive()
                                //
                            }
                            break
                        }
                    })
                    
                    
                }
                
            }
            return
        }
    }
    
    func notifiedSyncFinish(rootFolder:String){
        
        //gdrive to nas
        //        print("notifiedSyncFinish called rootFolder: \(rootFolder)")
        if rootFolder.isEmpty {
            let loginUserId = UserDefaults.standard.string(forKey: "userId")
            GetListFromServer().getMobileFileLIst(devUuid: Util.getUuid(), userId:loginUserId!, deviceName:"sdf"){ responseObject, error in
                let json = JSON(responseObject!)
                if(json["listData"].exists()){
                    let serverList:[AnyObject] = json["listData"].arrayObject! as [AnyObject]
                    print("serverList : \(serverList)")
                    for serverFile in serverList{
                        let serverFileNm = serverFile["fileNm"] as? String ?? "nil"
                        let serverFilePath = serverFile["foldrWholePathNm"] as? String ?? "nil"
                        let serverFileAmdDate = serverFile["amdDate"] as? String ?? "nil"
                        //                        print("serverFileNm : \(serverFileNm), , originalFileName : \(self.originalFileName), serverFilePath : \(serverFilePath)")
                        if(rootFolder.isEmpty){
                            if(serverFileNm == self.originalFileName && serverFilePath == "/Mobile/tmp"){
                                print("fromFoldrId : \(self.fromFoldrId), originalFileName:\(self.originalFileName)")
                                if(self.fromFoldrId.isEmpty){
                                    //파일 업로드 to nas
                                    if self.storageState == .gdrive_nas_multi {
                                        if(serverFilePath == "/Mobile/tmp"){
                                            let getFileID = serverFile["fileId"] as? Int ?? 0
                                            //                                            print("getFileID : \(getFileID)")
                                            //                                        let fileUrl:URL = FileUtil().getFileUrl(fileNm: self.originalFileName, amdDate: self.amdDate)!
                                            let fileUrl:URL = FileUtil().getFileUrlWithFoldr(fileNm: self.originalFileName, foldrWholePathNm: "/Mobile/tmp", amdDate: self.amdDate)!
                                            
                                            
                                            self.sendToNasFromLocal(url: fileUrl, name: self.originalFileName, toOsCd:self.toOsCd, fileId: String(getFileID), toUserId: self.toUserId, newFoldrWholePathNm: self.newFoldrWholePathNm)
                                            break
                                        }
                                        
                                    } else {
                                        let getFileID = serverFile["fileId"] as? Int ?? 0
                                        //                                      let fileUrl:URL = FileUtil().getFileUrl(fileNm: self.originalFileName, amdDate: self.amdDate)!
                                        let filePath:String = FileUtil().getFilePathWithFoldr(fileNm: self.originalFileName, foldrWholePathNm: "/Mobile/tmp", amdDate: self.amdDate)
                                        
                                        
                                        if(FileManager.default.fileExists(atPath: filePath)){
                                            let fileUrl:URL = FileUtil().getFileUrlWithFoldr(fileNm: self.originalFileName, foldrWholePathNm: "/Mobile/tmp", amdDate: self.amdDate)!
                                            print("getFileID : \(getFileID), self.originalFileName: \(self.originalFileName), self.toOsCd: \(self.toOsCd)")
                                            print("fileUrl : \(fileUrl)")
                                            
                                            self.sendToNasFromLocal(url: fileUrl, name: self.originalFileName, toOsCd:self.toOsCd, fileId: String(getFileID), toUserId: self.toUserId, newFoldrWholePathNm: self.newFoldrWholePathNm)
                                            break
                                        }
                                        
                                    }
                                    
                                    
                                }
                            }
                        }
                        
                    }
                } else {
                    print("no file")
                }
                
            }
        } else {
            //get folder Id
            print("폴더 업로드 시작")
            print("start upload folder to nas")
            print("newFoldrWholePathNm : \(newFoldrWholePathNm)  rootFolder : \(rootFolder), fromOsCd : \(fromOsCd)")
            if(self.storageState == .gdrive_nas_multi || self.fromOsCd == "gDrive"){
                ToNasFromLocalFomGDriveFolder().readyCreatFolders(getToUserId:self.toUserId, getNewFoldrWholePathNm:self.newFoldrWholePathNm, getOldFoldrWholePathNm:rootFolder, getMultiArray:self.gDriveMultiCheckedfolderArray, parent:self, containerViewController:containerViewController!, toOsCd: toOsCd)
                self.containerViewController?.showIndicator()
            } else {
                print("ToNasFromLocalFolder().readyCreatFoldersFromNasSendControlle")
                ToNasFromLocalFolder().readyCreatFoldersFromNasSendController(getToUserId:toUserId, getNewFoldrWholePathNm:newFoldrWholePathNm, getOldFoldrWholePathNm:rootFolder, getMultiArray:multiCheckedfolderArray, nasSendController:self, toOsCd: toOsCd)
                self.containerViewController?.showIndicator()
                
            }
            
        }
        
    }
    //
    func remoteDownloadRequest(fromUserId:String, fromDevUuid:String, fromOsCd:String, fromFoldr:String, fromFileNm:String, fromFileId:String){
        containerViewController?.showIndicator()
        let urlString = App.URL.hostIpServer+"reqFileDown.do"
        let comnd = "R\(fromOsCd)L\(toOsCd)"
        print("comnd : \(comnd)")
        
        let paramas = ["fromUserId":fromUserId,"fromDevUuid":fromDevUuid,"fromOsCd":fromOsCd,"fromFoldr":oldFoldrWholePathNm,"fromFileNm":fromFileNm,"fromFileId":fromFileId,"toUserId":toUserId,"toDevUuid":currentDevUuId,"toOsCd":toOsCd,"toFoldr":newFoldrWholePathNm,"toFileNm":fromFileNm,"comndOsCd":"I","comndDevUuid":Util.getUuid(),"comnd":comnd]
        
        
        print("param : \(paramas)")
        Alamofire.request(urlString,
                          method: .post,
                          parameters: paramas,
                          encoding : JSONEncoding.default,
                          headers: jsonHeader).responseJSON { response in
                            switch response.result {
                            case .success(let responseObject):
                                print(response.result.value)
                                
                                let json = JSON(responseObject)
                                let message = json["message"].string
                                let statusCode = json["statusCode"].int
                                
                                if statusCode == 100 {
                                    let data = json["data"]
                                    let queId = String(describing: data["queId"])
                                    
                                    print("json : \(json)")
                                    print("remoteDownloadRequest : \(message), queId: \(queId), data: \(data)")
                                    
                                    if self.storageState == .multi_nas_multi {
                                        let lastIndex = self.multiCheckedfolderArray.count - 1
                                        self.multiCheckedfolderArray.remove(at: lastIndex)
                                        self.startMultiSendToNas()
                                    } else if self.storageState == .search_nas_multi {
                                        let lastIndex = self.multiCheckedfolderArray.count - 1
                                        self.multiCheckedfolderArray.remove(at: lastIndex)
                                        self.startMultiSendToNas()
                                    } else {
                                        DispatchQueue.main.async {
                                            let alertController = UIAlertController(title: nil, message: "NAS 보내기 요청 성공", preferredStyle: .alert)
                                            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                                                UIAlertAction in
                                                //Do you Success button Stuff here
                                                self.containerViewController?.finishLoading()
                                            }
                                            alertController.addAction(yesAction)
                                            self.containerViewController?.present(alertController, animated: true)
                                        }
                                    }
                                } else {
                                    let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                                    let yesAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                                        UIAlertAction in
                                        
                                        self.containerViewController?.finishLoading()
                                    }
                                    alertController.addAction(yesAction)
                                    self.containerViewController?.present(alertController, animated: true)
                                }
                                break
                            case .failure(let error):
                                print(error.localizedDescription)
                                let alertController = UIAlertController(title: nil, message: "요청처리에 실패하였습니다.", preferredStyle: .alert)
                                let yesAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                                    UIAlertAction in
                                    
                                    self.containerViewController?.finishLoading()
                                }
                                alertController.addAction(yesAction)
                                self.containerViewController?.present(alertController, animated: true)
                            }
        }
    }
    
    func remoteDownloadRequestToSend(fromUserId:String, fromDevUuid:String, fromOsCd:String, fromFoldr:String, fromFileNm:String, fromFileId:String){
        let jsonHeader:[String:String] = [
            "Content-Type": "application/json",
            "X-Auth-Token": UserDefaults.standard.string(forKey: "token")!,
            "Cookie": UserDefaults.standard.string(forKey: "cookie")!
        ]
        
        let urlString = App.URL.hostIpServer+"reqFileDown.do"
        let comnd = "R\(fromOsCd)L\(toOsCd)"
        print("comnd : \(comnd)")
        
        let paramas = ["fromUserId":fromUserId,"fromDevUuid":fromDevUuid,"fromOsCd":fromOsCd,"fromFoldr":fromFoldr,"fromFileNm":fromFileNm,"fromFileId":fromFileId,"toUserId":toUserId,"toDevUuid":currentDevUuId,"toOsCd":toOsCd,"toFoldr":newFoldrWholePathNm,"toFileNm":fromFileNm,"comndOsCd":"I","comndDevUuid":Util.getUuid(),"comnd":comnd]
        print("paramas : \(paramas)")
        Alamofire.request(urlString,
                          method: .post,
                          parameters: paramas,
                          encoding : JSONEncoding.default,
                          headers: jsonHeader).responseJSON { response in
                            switch response.result {
                            case .success(let responseObject):
                                let json = JSON(responseObject)
                                let message = json["message"].string
                                let statusCode = json["statusCode"].int
                                
                                if statusCode == 100 {
                                    let data = json["data"]
                                    let queId = String(describing: data["queId"])
                                    
                                    print("json : \(json)")
                                    print("remoteDownloadRequest : \(message), queId: \(queId), data: \(data)")
                                    
                                    let lastIndex = self.multiCheckedfolderArray.count - 1
                                    self.multiCheckedfolderArray.remove(at: lastIndex)
                                    self.startMultiSendToNas()
                                } else {
                                    let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                                    let yesAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                                        UIAlertAction in
                                        
                                        self.containerViewController?.finishLoading()
                                    }
                                    alertController.addAction(yesAction)
                                    self.containerViewController?.present(alertController, animated: true)
                                }
                            case .failure(let error):
                                print(error.localizedDescription)
                                let alertController = UIAlertController(title: nil, message: "요청처리에 실패하였습니다.", preferredStyle: .alert)
                                let yesAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                                    UIAlertAction in
                                    
                                    self.containerViewController?.finishLoading()
                                }
                                alertController.addAction(yesAction)
                                self.containerViewController?.present(alertController, animated: true)
                            }
        }
    }
    
    
    
}
