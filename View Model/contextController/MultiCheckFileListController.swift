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
    var homeViewController:HomeViewController?
    var nasSendFolderSelectVC:NasSendFolderSelectVC?
    var selectedUserId = ""
    var selectedDevUuid = ""
    var selectedDeviceName = ""
    var selectedDevFoldrId = ""
    var fromOsCd = ""
    var fromDevUuid = ""
    var fromUserId = ""
    var toUserId = ""
    var toDevUuid = ""
    var toOsCd = ""
    var toFoldr = ""
    var fromFoldr = ""
    var folderIdsToDownLoad:[Int] = []
    var folderPathToDownLoad:[String] = []
    var fileArrayToDownload:[App.FolderStruct] = []
    
    func btnMultiCheckClicked(sender:UIButton, getHomeViewController:HomeViewController, parent:HomeDeviceCollectionVC){
        homeViewController = getHomeViewController
        dv = parent
        let buttonRow = sender.tag
        let indexPath = IndexPath(row: buttonRow, section: 0)
        //        print("superview : \(sender.superview?.superview)")
        if let cell = sender.superview as? NasFileListCell {
            if(cell.btnMultiChecked){
                cell.btnMultiChecked = false
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                cell.btnMultiChecked = true
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            }
            dv?.multiCheckedFolderArray(indexPath:indexPath, check:cell.btnMultiChecked)
        } else if let cell = sender.superview as? NasFolderListCell {
            if(cell.btnMultiChecked){
                cell.btnMultiChecked = false
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                cell.btnMultiChecked = true
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            }
            dv?.multiCheckedFolderArray(indexPath:indexPath, check:cell.btnMultiChecked)
        } else if let cell = sender.superview as? CollectionViewGridCell {
            if(cell.btnMultiChecked){
                cell.btnMultiChecked = false
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                cell.btnMultiChecked = true
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            }
            dv?.multiCheckedFolderArray(indexPath:indexPath, check:cell.btnMultiChecked)
        } else if let cell = sender.superview as? RemoteFileListCell {
            if(cell.btnMultiChecked){
                cell.btnMultiChecked = false
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                cell.btnMultiChecked = true
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            }
            dv?.multiCheckedFolderArray(indexPath:indexPath, check:cell.btnMultiChecked)
        } else if let cell = sender.superview as? LocalFileListCell {
            if(cell.btnMultiChecked){
                cell.btnMultiChecked = false
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                cell.btnMultiChecked = true
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            }
            dv?.multiCheckedFolderArray(indexPath:indexPath, check:cell.btnMultiChecked)
        } else if let cell = sender.superview as? LocalFolderListCell {
            if(cell.btnMultiChecked){
                cell.btnMultiChecked = false
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                cell.btnMultiChecked = true
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            }
            dv?.multiCheckedFolderArray(indexPath:indexPath, check:cell.btnMultiChecked)
        } else if let cell = sender.superview as? GDriveFolderListCell {
            if(cell.btnMultiChecked){
                cell.btnMultiChecked = false
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                cell.btnMultiChecked = true
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            }
            dv?.multiCheckedFolderArray(indexPath:indexPath, check:cell.btnMultiChecked)
        } else if let cell = sender.superview as? GDriveFileListCell {
            if(cell.btnMultiChecked){
                cell.btnMultiChecked = false
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                cell.btnMultiChecked = true
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            }
            dv?.multiCheckedFolderArray(indexPath:indexPath, check:cell.btnMultiChecked)
        }
    }
    
    func cellMultiCheckClicked(indexPath:IndexPath, parent:HomeDeviceCollectionVC, deviceCollectionView:UICollectionView){
        dv = parent
        
        if let cell = deviceCollectionView.cellForItem(at: indexPath) as? NasFileListCell {
            if(cell.btnMultiChecked){
                cell.btnMultiChecked = false
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                cell.btnMultiChecked = true
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            }
            dv?.multiCheckedFolderArray(indexPath:indexPath, check:cell.btnMultiChecked)
        } else if let cell = deviceCollectionView.cellForItem(at: indexPath) as? NasFolderListCell {
            if(cell.btnMultiChecked){
                cell.btnMultiChecked = false
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                cell.btnMultiChecked = true
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            }
            dv?.multiCheckedFolderArray(indexPath:indexPath, check:cell.btnMultiChecked)
        } else if let cell = deviceCollectionView.cellForItem(at: indexPath) as? CollectionViewGridCell {
            if(cell.btnMultiChecked){
                cell.btnMultiChecked = false
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                cell.btnMultiChecked = true
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            }
            dv?.multiCheckedFolderArray(indexPath:indexPath, check:cell.btnMultiChecked)
        } else if let cell = deviceCollectionView.cellForItem(at: indexPath) as? RemoteFileListCell {
            if(cell.btnMultiChecked){
                cell.btnMultiChecked = false
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                cell.btnMultiChecked = true
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            }
            dv?.multiCheckedFolderArray(indexPath:indexPath, check:cell.btnMultiChecked)
        } else if let cell = deviceCollectionView.cellForItem(at: indexPath) as? LocalFileListCell {
            if(cell.btnMultiChecked){
                cell.btnMultiChecked = false
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                cell.btnMultiChecked = true
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            }
            dv?.multiCheckedFolderArray(indexPath:indexPath, check:cell.btnMultiChecked)
        } else if let cell = deviceCollectionView.cellForItem(at: indexPath) as? LocalFolderListCell {
            if(cell.btnMultiChecked){
                cell.btnMultiChecked = false
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                cell.btnMultiChecked = true
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            }
            dv?.multiCheckedFolderArray(indexPath:indexPath, check:cell.btnMultiChecked)
        } else if let cell = deviceCollectionView.cellForItem(at: indexPath) as? GDriveFileListCell {
            if(cell.btnMultiChecked){
                cell.btnMultiChecked = false
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                cell.btnMultiChecked = true
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            }
            dv?.multiCheckedFolderArray(indexPath:indexPath, check:cell.btnMultiChecked)
        } else if let cell = deviceCollectionView.cellForItem(at: indexPath) as? GDriveFolderListCell {
            if(cell.btnMultiChecked){
                cell.btnMultiChecked = false
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                cell.btnMultiChecked = true
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            }
            dv?.multiCheckedFolderArray(indexPath:indexPath, check:cell.btnMultiChecked)
        }
    }
    
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
        
        SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: nil, message: "다운로드를 성공하였습니다.", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel){
                UIAlertAction in
                NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)                  
                
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
    
    //멀티 다운로드 끝
    //멀티 nas는 NasSendFolderSelectVC에서
    
    //멀티 nas 삭제 시작
    
    func callMultiDelete(getFolderArray:[App.FolderStruct], parent:HomeDeviceCollectionVC, fromUserId:String, devUuid:String, deviceName:String, devFoldrId:String){
        dv = parent
        selectedDevUuid = devUuid
        selectedDeviceName = deviceName
        selectedUserId = fromUserId
        multiCheckedfolderArray = getFolderArray
        selectedDevFoldrId = devFoldrId
        
        if (multiCheckedfolderArray.count > 0){
            let index = getFolderArray.count - 1
            let fileNm = getFolderArray[index].fileNm
            let foldrWholePathNm = getFolderArray[index].foldrWholePathNm
            let fileId = String(getFolderArray[index].fileId)
            let foldrId = String(getFolderArray[index].foldrId)
            let etsionNm = getFolderArray[index].etsionNm
            
            if(etsionNm == "nil"){
                let param:[String:Any] = ["userId":selectedUserId, "foldrId":foldrId, "foldrWholePathNm":foldrWholePathNm]
                self.deleteNasFolder(param: param)
            } else {
                let params = ["userId":selectedUserId,"devUuid":selectedDevUuid,"fileId":fileId,"fileNm":fileNm,"foldrWholePathNm": foldrWholePathNm]
                self.deleteNasFile(param: params, foldrId: foldrId)
                
            }
            return
        }
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: nil, message: "파일 삭제가 완료 되었습니다.", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel){
                UIAlertAction in
                NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
//                NotificationCenter.default.post(name: Notification.Name("btnMulticlicked"), object: self, userInfo: nil)
                let fileDict = ["foldrId":self.selectedDevFoldrId]
                print("delete filedict : \(fileDict)")
                NotificationCenter.default.post(name: Notification.Name("refreshInsideList"), object: self, userInfo: fileDict)
                
            }
            
            alertController.addAction(yesAction)
            parent.present(alertController, animated: true)
        }
        
    }
    
    
    func deleteNasFile(param:[String:Any], foldrId:String){
        print(param)
        ContextMenuWork().deleteNasFile(parameters:param){ responseObject, error in
            if let obj = responseObject {
                print(obj)
                let json = JSON(obj)
                let message = obj.object(forKey: "message")
                print("\(message), \(json["statusCode"].int)")
                if let statusCode = json["statusCode"].int, statusCode == 100 {
                 
                    let lastIndex = self.multiCheckedfolderArray.count - 1
                    self.multiCheckedfolderArray.remove(at: lastIndex)
                    self.callMultiDelete(getFolderArray: self.multiCheckedfolderArray, parent: self.dv!, fromUserId: self.selectedUserId, devUuid: self.selectedDevUuid, deviceName: self.selectedDeviceName, devFoldrId: self.selectedDevFoldrId)
                }
        
            }
            return
        }
    }
    func deleteNasFolder(param:[String:Any]){
        ContextMenuWork().removeNasFolder(parameters:param){ responseObject, error in
            if let obj = responseObject {
                print(obj)
                let json = JSON(obj)
                let message = obj.object(forKey: "message")
                print("\(String(describing: message)), \(String(describing: json["statusCode"].int))")
                if let statusCode = json["statusCode"].int, statusCode == 100 {
                    
                    let lastIndex = self.multiCheckedfolderArray.count - 1
                    self.multiCheckedfolderArray.remove(at: lastIndex)
                    self.callMultiDelete(getFolderArray: self.multiCheckedfolderArray, parent: self.dv!, fromUserId: self.selectedUserId, devUuid: self.selectedDevUuid, deviceName: self.selectedDeviceName, devFoldrId: self.selectedDevFoldrId)
                }
            }
            return
        }
    }
    
    // 멀티 파일 리모트 다운로드
    
    
    func remoteMultiDownloadRequest(getFolderArray:[App.FolderStruct], parent:HomeDeviceCollectionVC, fromUserId:String, devUuid:String, deviceName:String, devFoldrId:String,fromOsCd:String){
        
        dv = parent
        selectedDevUuid = devUuid
        selectedDeviceName = deviceName
        selectedUserId = fromUserId
        multiCheckedfolderArray = getFolderArray
        selectedDevFoldrId = devFoldrId
        self.fromOsCd = fromOsCd
        
        if (multiCheckedfolderArray.count > 0){
            let index = getFolderArray.count - 1
            let fileNm = getFolderArray[index].fileNm
            let foldrWholePathNm = getFolderArray[index].foldrWholePathNm
            let fileId = String(getFolderArray[index].fileId)
            let foldrId = String(getFolderArray[index].foldrId)
            let etsionNm = getFolderArray[index].etsionNm
            
            remoteDownloadRequest(fromUserId: selectedUserId, fromDevUuid: selectedDevUuid, fromOsCd: fromOsCd, fromFoldr: foldrWholePathNm, fromFileNm: fileNm, fromFileId: fileId)
            return
        }
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: nil, message: "리퀘스트 요청이 완료 되었습니다.", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel){
                UIAlertAction in
                NotificationCenter.default.post(name: Notification.Name("btnMulticlicked"), object: self, userInfo: nil)
                let fileDict = ["foldrId":self.selectedDevFoldrId]
                print("delete filedict : \(fileDict)")
                
                let fileIdDict = ["fileId":"0"]
                NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self, userInfo: fileIdDict)
            }
            
            alertController.addAction(yesAction)
            parent.present(alertController, animated: true)
        }
    }
    
    
    func remoteDownloadRequest(fromUserId:String, fromDevUuid:String, fromOsCd:String, fromFoldr:String, fromFileNm:String, fromFileId:String){
        var jsonHeader:[String:String] = [
            "Content-Type": "application/json",
            "X-Auth-Token": UserDefaults.standard.string(forKey: "token")!,
            "Cookie": UserDefaults.standard.string(forKey: "cookie")!
        ]
        
        let urlString = App.URL.server+"reqFileDown.do"
        var comnd = "R\(fromOsCd)LI"
        let paramas:[String : Any] = ["fromUserId":fromUserId,"fromDevUuid":fromDevUuid,"fromOsCd":fromOsCd,"fromFoldr":fromFoldr,"fromFileNm":fromFileNm,"fromFileId":fromFileId,"toDevUuid":Util.getUuid(),"toOsCd":"I","toFoldr":"/Mobile","toFileNm":fromFileNm,"comndOsCd":"I","comndDevUuid":App.defaults.userId,"comnd":comnd]
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
                                print("remoteDownloadRequest : \(message)")
                                
                                let lastIndex = self.multiCheckedfolderArray.count - 1
                                self.multiCheckedfolderArray.remove(at: lastIndex)
                                self.remoteMultiDownloadRequest(getFolderArray: self.multiCheckedfolderArray, parent: self.dv!, fromUserId: self.selectedUserId, devUuid: self.selectedDevUuid, deviceName: self.selectedDeviceName, devFoldrId: self.selectedDevFoldrId, fromOsCd: self.fromOsCd)
                                break
                            case .failure(let error):
                                
                                print(error.localizedDescription)
                            }
        }
    }
    
    func remoteMultiDownloadRequestToSend(getFolderArray:[App.FolderStruct], parent:NasSendFolderSelectVC, fromUserId:String, fromDevUuid:String, deviceName:String, devFoldrId:String,fromOsCd:String, toUserId:String, toOsCd:String, toDevUuid: String, toFoldr:String, fromFoldr:String){
        
        parent.activityIndicator.startAnimating()
        self.fromDevUuid = fromDevUuid
        self.fromUserId = fromUserId
        self.toUserId = toUserId
        self.toOsCd = toOsCd
        self.toDevUuid = toDevUuid
        selectedDeviceName = deviceName
        selectedUserId = fromUserId
        multiCheckedfolderArray = getFolderArray
        selectedDevFoldrId = devFoldrId
        self.fromOsCd = fromOsCd
        self.toFoldr = toFoldr
        self.fromFoldr = fromFoldr
        nasSendFolderSelectVC = parent
        print("request count : \(multiCheckedfolderArray.count)")
        if (multiCheckedfolderArray.count > 0){
            let index = getFolderArray.count - 1
            let fileNm = getFolderArray[index].fileNm
            let foldrWholePathNm = getFolderArray[index].foldrWholePathNm
            let fileId = String(getFolderArray[index].fileId)
            let foldrId = String(getFolderArray[index].foldrId)
            let etsionNm = getFolderArray[index].etsionNm
            
            remoteDownloadRequestToSend(fromUserId: fromUserId, fromDevUuid: fromDevUuid, fromOsCd: fromOsCd, fromFoldr: fromFoldr, fromFileNm: fileNm, fromFileId: fileId)
            return
        }
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: nil, message: "리퀘스트 요청이 완료 되었습니다.", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel){
                UIAlertAction in
                
                NotificationCenter.default.post(name: Notification.Name("btnMulticlicked"), object: self, userInfo: nil)
                let fileIdDict = ["fileId":"0"]
                NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self, userInfo: fileIdDict)
                Util().dismissFromLeft(vc: parent)
            }
            
            alertController.addAction(yesAction)
            parent.present(alertController, animated: true)
        }
    }
    
    func remoteDownloadRequestToSend(fromUserId:String, fromDevUuid:String, fromOsCd:String, fromFoldr:String, fromFileNm:String, fromFileId:String){
        var jsonHeader:[String:String] = [
            "Content-Type": "application/json",
            "X-Auth-Token": UserDefaults.standard.string(forKey: "token")!,
            "Cookie": UserDefaults.standard.string(forKey: "cookie")!
        ]
        
        let urlString = App.URL.server+"reqFileDown.do"
        var comnd = "R\(fromOsCd)L\(toOsCd)"
        //        var comnd = "R\(fromOsCd)L"
        
        print("comnd : \(comnd)")
        
        var finalFromUserId = fromUserId
//        var paramas:[String : Any] = ["fromUserId":finalFromUserId,"fromDevUuid":fromDevUuid,"fromOsCd":fromOsCd,"fromFoldr":fromFoldr,"fromFileNm":fromFileNm,"fromFileId":fromFileId,"toDevUuid":toDevUuid,"toOsCd":toOsCd,"toFoldr":toFoldr,"toFileNm":fromFileNm,"comndOsCd":"I","comndDevUuid":Util.getUuid(),"comnd":comnd]
//        if(toOsCd == "S") {
          var paramas = ["fromUserId":fromUserId,"fromDevUuid":fromDevUuid,"fromOsCd":fromOsCd,"fromFoldr":fromFoldr,"fromFileNm":fromFileNm,"fromFileId":fromFileId,"toUserId":toUserId,"toDevUuid":toDevUuid,"toOsCd":toOsCd,"toFoldr":toFoldr,"toFileNm":fromFileNm,"comndOsCd":"I","comndDevUuid":Util.getUuid(),"comnd":comnd]
//        }
        
        print("paramas : \(paramas)")
//        var comnd = "RALI"
//        switch fromOsCd {
//        case "W":
//            comnd = "RWLI"
//        case "A":
//            comnd = "RALI"
//        default:
//            comnd = "RILI"
//            break
//        }
//        let paramas:[String : Any] = ["fromUserId":fromUserId,"fromDevUuid":fromDevUuid,"fromOsCd":fromOsCd,"fromFoldr":fromFoldr,"fromFileNm":fromFileNm,"fromFileId":fromFileId,"toDevUuid":Util.getUuid(),"toOsCd":"I","toFoldr":"/Mobile","toFileNm":fromFileNm,"comndOsCd":"I","comndDevUuid":App.defaults.userId,"comnd":comnd]

        Alamofire.request(urlString,
                          method: .post,
                          parameters: paramas,
                          encoding : JSONEncoding.default,
                          headers: jsonHeader).responseJSON { response in
                            switch response.result {
                            case .success(let responseObject):
//                                print(response.result.value)
                                let responseData = responseObject as! NSDictionary
                                let message = responseData.object(forKey: "message")
//                                print("remoteDownloadRequest : \(message)")
                                let json = JSON(responseObject)
                                let data = json["data"]
                                let queId = String(describing: data["queId"])
                                print("json : \(json)")
                                print("remoteDownloadRequest : \(message), queId: \(queId), data: \(data)")
                                let lastIndex = self.multiCheckedfolderArray.count - 1
                                self.multiCheckedfolderArray.remove(at: lastIndex)
                                self.remoteMultiDownloadRequestToSend(getFolderArray: self.multiCheckedfolderArray, parent: self.nasSendFolderSelectVC!, fromUserId: self.fromUserId, fromDevUuid: self.fromDevUuid, deviceName: self.selectedDeviceName, devFoldrId: self.selectedDevFoldrId, fromOsCd: self.fromOsCd, toUserId: self.toUserId, toOsCd: self.toOsCd, toDevUuid: self.toDevUuid, toFoldr: self.toFoldr, fromFoldr: self.fromFoldr)
                                break
                              
                            case .failure(let error):
                                
                                print(error.localizedDescription)
                            }
        }
    }
    
   
    
    // local 삭제 시작
    func callMultiLocalDelete(getFolderArray:[App.FolderStruct], parent:HomeDeviceCollectionVC, fromUserId:String, devUuid:String, deviceName:String, devFoldrId:String){
        dv = parent
        selectedDevUuid = devUuid
        selectedDeviceName = deviceName
        selectedUserId = fromUserId
        multiCheckedfolderArray = getFolderArray
        selectedDevFoldrId = devFoldrId
        
        if (multiCheckedfolderArray.count > 0){
            let index = getFolderArray.count - 1
            let fileNm = getFolderArray[index].fileNm
            let foldrWholePathNm = getFolderArray[index].foldrWholePathNm
            let fileId = String(getFolderArray[index].fileId)
            let foldrId = String(getFolderArray[index].foldrId)
            let etsionNm = getFolderArray[index].etsionNm
            let amdDate = getFolderArray[index].amdDate
            
            if(etsionNm == "nil"){
                let foldrNmArray = foldrWholePathNm.components(separatedBy: "/")
                let foldrNm:String = foldrNmArray[foldrNmArray.count - 1]
                print("foldrWholePathNm, :\(foldrWholePathNm), foldrNm : \(foldrNm), foldrNmArray:\(foldrNmArray)")
                let pathForRemove:String = FileUtil().getFilePath(fileNm: foldrNm, amdDate: amdDate)
                print("pathForRemove : \(pathForRemove)")
                self.removeFile(path: pathForRemove)
            } else {
                let pathForRemove:String = FileUtil().getFilePath(fileNm: fileNm, amdDate: amdDate)
                print("pathForRemove : \(pathForRemove)")
                self.removeFile(path: pathForRemove)
                
                
            }
            return
        }
        DispatchQueue.main.async {
            SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
            let alertController = UIAlertController(title: nil, message: "멀티 파일 삭제가 완료 되었습니다.", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel){
                UIAlertAction in
                NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
                let fileDict = ["foldrId":self.selectedDevFoldrId]
                print("delete filedict : \(fileDict)")
                NotificationCenter.default.post(name: Notification.Name("refreshInsideList"), object: self, userInfo: fileDict)
                
            }
            
            alertController.addAction(yesAction)
            parent.present(alertController, animated: true)
        }
        
    }
    func removeFile(path:String){
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: path)
            let lastIndex = self.multiCheckedfolderArray.count - 1
            self.multiCheckedfolderArray.remove(at: lastIndex)
            self.callMultiLocalDelete(getFolderArray: self.multiCheckedfolderArray, parent: self.dv!, fromUserId: self.selectedUserId, devUuid: self.selectedDevUuid, deviceName: self.selectedDeviceName, devFoldrId: self.selectedDevFoldrId)
            
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    

}
    
    


