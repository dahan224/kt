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
    var containerViewController:ContainerViewController?
    var selectedUserId = ""
    var selectedDevUuid = ""
    var selectedDeviceName = ""
    var selectedDevFoldrId = ""
    var selectedDevUserId = ""
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
    var upFoldersToDelete = ""
    var newFolderArray:[App.FolderStruct] = []
    
    func btnMultiCheckClicked(sender:UIButton, parent:HomeDeviceCollectionVC, folderArray:[App.FolderStruct]){
//        homeViewController = getHomeViewController
        dv = parent
        newFolderArray = folderArray
        let buttonRow = sender.tag
        let indexPath = IndexPath(row: buttonRow, section: 0)
        
        print("btnMultiCheckClicked indexpath row : \(indexPath.row)")
        //        print("superview : \(sender.superview?.superview)")
        if newFolderArray.count > indexPath.row {
            if let cell = sender.superview as? NasFileListCell {
                if(folderArray[indexPath.row].checked){
                    cell.btnMultiChecked = false
                    newFolderArray[sender.tag].checked = false
                    cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
                } else {
                    cell.btnMultiChecked = true
                    newFolderArray[sender.tag].checked = true
                    cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
                }
                dv?.multiCheckedFolderArrayGrid(indexPath:indexPath, check:newFolderArray[indexPath.row].checked, getFolderArray:newFolderArray)
            } else if let cell = sender.superview as? NasFolderListCell {
                if(folderArray[indexPath.row].checked){
                    cell.btnMultiChecked = false
                    newFolderArray[sender.tag].checked = false
                    cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
                } else {
                    cell.btnMultiChecked = true
                    newFolderArray[sender.tag].checked = true
                    cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
                }
                dv?.multiCheckedFolderArrayGrid(indexPath:indexPath, check:newFolderArray[indexPath.row].checked, getFolderArray:newFolderArray)
            } else if let cell = sender.superview as? CollectionViewGridCell {
                if(folderArray[indexPath.row].checked){
                    cell.btnMultiChecked = false
                    newFolderArray[sender.tag].checked = false
                    cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
                } else {
                    cell.btnMultiChecked = true
                    newFolderArray[sender.tag].checked = true
                    cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
                }
                dv?.multiCheckedFolderArrayGrid(indexPath:indexPath, check:newFolderArray[indexPath.row].checked, getFolderArray:newFolderArray)
            } else if let cell = sender.superview as? RemoteFileListCell {
                if(folderArray[indexPath.row].checked){
                    cell.btnMultiChecked = false
                    newFolderArray[sender.tag].checked = false
                    cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
                } else {
                    cell.btnMultiChecked = true
                    newFolderArray[sender.tag].checked = true
                    cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
                }
                dv?.multiCheckedFolderArrayGrid(indexPath:indexPath, check:newFolderArray[indexPath.row].checked, getFolderArray:newFolderArray)
            } else if let cell = sender.superview as? LocalFileListCell {
                if(folderArray[indexPath.row].checked){
                    cell.btnMultiChecked = false
                    newFolderArray[sender.tag].checked = false
                    cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
                } else {
                    cell.btnMultiChecked = true
                    newFolderArray[sender.tag].checked = true
                    cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
                }
                dv?.multiCheckedFolderArrayGrid(indexPath:indexPath, check:newFolderArray[indexPath.row].checked, getFolderArray:newFolderArray)
            } else if let cell = sender.superview as? LocalFolderListCell {
                if(folderArray[indexPath.row].checked){
                    cell.btnMultiChecked = false
                    newFolderArray[sender.tag].checked = false
                    cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
                } else {
                    cell.btnMultiChecked = true
                    newFolderArray[sender.tag].checked = true
                    cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
                }
                dv?.multiCheckedFolderArrayGrid(indexPath:indexPath, check:newFolderArray[indexPath.row].checked, getFolderArray:newFolderArray)
            } else if let cell = sender.superview as? GDriveFolderListCell {
                if(folderArray[indexPath.row].checked){
                    cell.btnMultiChecked = false
                    newFolderArray[sender.tag].checked = false
                    cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
                } else {
                    cell.btnMultiChecked = true
                    newFolderArray[sender.tag].checked = true
                    cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
                }
                dv?.multiCheckedFolderArrayGrid(indexPath:indexPath, check:newFolderArray[indexPath.row].checked, getFolderArray:newFolderArray)
            } else if let cell = sender.superview as? GDriveFileListCell {
                if(folderArray[indexPath.row].checked){
                    cell.btnMultiChecked = false
                    newFolderArray[sender.tag].checked = false
                    cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
                } else {
                    cell.btnMultiChecked = true
                    newFolderArray[sender.tag].checked = true
                    cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
                }
                dv?.multiCheckedFolderArrayGrid(indexPath:indexPath, check:newFolderArray[indexPath.row].checked, getFolderArray:newFolderArray)
            }
        }
        
    }
    
    
    
    func callDwonLoad(getFolderArray:[App.FolderStruct], parent:HomeDeviceCollectionVC, devUuid:String, deviceName:String, devUserId:String){
        dv = parent
        selectedDevUuid = devUuid
        selectedDeviceName = deviceName
        selectedDevUserId = devUserId
        multiCheckedfolderArray = getFolderArray
        
        
        if (multiCheckedfolderArray.count > 0){
            
            let index = getFolderArray.count - 1
            let name = getFolderArray[index].fileNm
            let foldrWholePathNm = getFolderArray[index].foldrWholePathNm
            let fileId = String(getFolderArray[index].fileId)
            let userId = getFolderArray[index].userId
            let foldrId = getFolderArray[index].foldrId
            let etsionNm = getFolderArray[index].etsionNm
            let foldrNm = getFolderArray[index].foldrNm
            selectedUserId = userId
            if(etsionNm == "nil"){
                downloadFolderFromNas(foldrId: foldrId, foldrWholePathNm: foldrWholePathNm, userId: selectedDevUserId, devUuid: devUuid, deviceName: deviceName, dwldFoldrNm:foldrNm)
            } else {
                downloadFromNas(name: name, path: foldrWholePathNm, fileId: fileId, userId:selectedDevUserId, getFolderArray:getFolderArray)
            }            
            return
        }
        if let syncOngoing:Bool = UserDefaults.standard.bool(forKey: "syncOngoing"), syncOngoing == true {
            print("aleady Syncing")
        } else {
            SyncLocalFilleToNas().sync(view: "ContextMenuWork", getFoldrId: "")
        }
        
//
//        SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
        /*
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: nil, message: "다운로드를 성공하였습니다.", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel){
                UIAlertAction in
                NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)                  
                
            }
            
            alertController.addAction(yesAction)
            parent.present(alertController, animated: true)
        }*/
        
    }
    func downloadFromNas(name:String, path:String, fileId:String, userId:String,getFolderArray:[App.FolderStruct]){
        
        ContextMenuWork().downloadFromNas(userId:userId, fileNm:name, path:path, fileId:fileId){ responseObject, error in
            if let success = responseObject {
                print(success)
                if(success == "success"){
                    var newArray = getFolderArray
                    self.multiCheckedfolderArray.remove(at: self.multiCheckedfolderArray.count - 1)
                    
                    let fileDict = ["fileId":fileId]
                    NotificationCenter.default.post(name: Notification.Name("completeFileProcess"), object: self, userInfo:fileDict)
                    
                    self.callDwonLoad(getFolderArray: self.multiCheckedfolderArray, parent: self.dv!, devUuid: self.selectedDevUuid, deviceName: self.selectedDeviceName, devUserId: self.selectedDevUserId)
                    
                } else {
                    NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
                }
            }
            
            return
        }
    }
   
    
    func downloadFolderFromNas(foldrId:Int, foldrWholePathNm:String, userId:String, devUuid:String, deviceName:String, dwldFoldrNm:String){
        selectedUserId = userId
        selectedDevUuid = devUuid
        selectedDeviceName = deviceName
        
        folderIdsToDownLoad.removeAll()
        folderPathToDownLoad.removeAll()
        fileArrayToDownload.removeAll()
        print("call from downloadFolderFromNas")
//        getFolderIdsToDownload(foldrId: foldrId, foldrWholePathNm: foldrWholePathNm, userId:userId, devUuid:selectedDevUuid,deviceName:deviceName)
        getFolderIdsToDownload(foldrId: foldrId, foldrWholePathNm: foldrWholePathNm, userId:userId, devUuid:selectedDevUuid,deviceName:deviceName, dwldFoldrNm:dwldFoldrNm)
    }
    
    
    
    func getFolderIdsToDownload(foldrId:Int, foldrWholePathNm:String, userId:String, devUuid:String, deviceName:String, dwldFoldrNm:String) {
        var foldrLevel = 0
        var param = ["userId": userId, "devUuid":devUuid, "foldrId":String(foldrId),"sortBy":""]
        print("param : \(param)")
        GetListFromServer().getMobileFoldrLIst(devUuid:devUuid, userId:userId, deviceName: deviceName) { responseObject, error in
            //        GetListFromServer().showInsideFoldrList(params: param, deviceName: deviceName) { responseObject, error in
            let json = JSON(responseObject!)
            if(json["listData"].exists()){
                let serverList:[AnyObject] = json["listData"].arrayObject as! [AnyObject]
                //                print("download serverList :\(serverList)")
                var tempArray:[App.FolderStruct] = []
                if (serverList.count > 0){
                    for list in serverList {
                        
                        let folderPath = list["foldrWholePathNm"] as? String ?? "nil"
                        let foldrId = list["foldrId"] as? Int ?? 0
                        if(folderPath.contains(foldrWholePathNm)){
                            print("list : \(list)")
                            self.folderIdsToDownLoad.append(foldrId)
                            self.folderPathToDownLoad.append(folderPath)
                        }
                        
                    }
                }
                
                self.printFolderPath(dwldFoldrNm:dwldFoldrNm)
            }
        }
    }
    func printFolderPath(dwldFoldrNm:String){
        print("folderPathToDownLoad: \(folderPathToDownLoad.count)")
        print("folderIdsToDownLoad: \(folderIdsToDownLoad.count)")
        print("printFolderPath called")
        let saveRootFoldrArray = folderPathToDownLoad[0].components(separatedBy: "/")
        upFoldersToDelete = ""
        for (index, name) in saveRootFoldrArray.enumerated() {
            if(0 < index && index < saveRootFoldrArray.count - 1){
                upFoldersToDelete += "/\(saveRootFoldrArray[index])"
            }
        }
        print("upFoldersToDelete : \(upFoldersToDelete)")
        for name in folderPathToDownLoad {
            let fullName = name.replacingOccurrences(of: upFoldersToDelete, with: "")
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
                    var folder = App.FolderStruct(data: list as AnyObject)
                    folder.userId = userId
                    folder.devUuid = devUuid
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
        downloadFromNasFolder(userId:selectedUserId, fileNm:name, path:path, fileId:fileId){ responseObject, error in
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
        var stringUrl = "\(App.URL.nasServer)\(App.nasFoldrFrontNm)\(userId)/\(userId)-gs\(path)/\(fileNm)"
        stringUrl = stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        let user:String = App.defaults.userId
        let password:String = UserDefaults.standard.string(forKey: "userPassword")!
        let credentialData = "\(App.nasFoldrFrontNm)\(user):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString()
        let headers = [
            "Authorization": "Basic \(base64Credentials)"
        ]
        print("stringUrl : \(stringUrl)")
        let fullPath = path
        
        let editPath = fullPath.replacingOccurrences(of: upFoldersToDelete, with: "")
        print("file save folder : \(editPath), upFoldersToDelete: \(upFoldersToDelete)")
        let downloadUrl:URL = URL(string: stringUrl)!
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent("\(editPath)/\(fileNm)")
            return (documentsURL, [.removePreviousFile])
        }
        
        Alamofire.download(downloadUrl, method: .get, headers:headers, to: destination)
            .downloadProgress(closure: { (progress) in
                print("download progress : \(progress.fractionCompleted)")
                //                 completionHandler(progress.fractionCoprintmpleted, nil)
            })
            .response { response in
                print("response : \(response)")
                if response.destinationURL != nil {
                    print(response.destinationURL!)
                    if let path = response.destinationURL?.path{
                        let path2 = "/private\(path)"
                        
                        //                        DbHelper().localFileToSqlite(id: fileId, path: path2)
                        print("path2 : \(path2)" )
                        print("saved fileId : \(UserDefaults.standard.string(forKey: path2)), fileId : \(fileId)")
                        completionHandler("success", nil)
                    }
                    
                }
        }
    }
    
    func finishDownload(){
        let foldrId:String = "\(multiCheckedfolderArray[self.multiCheckedfolderArray.count - 1].foldrId)"
        let fileDict = ["fileId":foldrId]
        NotificationCenter.default.post(name: Notification.Name("completeFileProcess"), object: self, userInfo:fileDict)
        self.multiCheckedfolderArray.remove(at: self.multiCheckedfolderArray.count - 1)
        self.callDwonLoad(getFolderArray: self.multiCheckedfolderArray, parent: self.dv!, devUuid: self.selectedDevUuid, deviceName: self.selectedDeviceName, devUserId: selectedDevUserId)
        
       
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
//                NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
//                NotificationCenter.default.post(name: Notification.Name("btnMulticlicked"), object: self, userInfo: nil)
                
//                print("delete filedict : \(fileDict)")
                let fileDict = ["foldrId":self.selectedDevFoldrId]
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
            let nasSynchYn = getFolderArray[index].nasSynchYn
            print("nasSynchYn : \(nasSynchYn)")
            if nasSynchYn == "Y" {
                remoteDownload(fromUserId: selectedUserId, fromDevUuid: selectedDevUuid, fromOsCd: fromOsCd, fromFoldr: foldrWholePathNm, fromFileNm: fileNm, fromFileId: fileId)
            } else {
                
                remoteDownloadRequest(fromUserId: selectedUserId, fromDevUuid: selectedDevUuid, fromOsCd: fromOsCd, fromFoldr: foldrWholePathNm, fromFileNm: fileNm, fromFileId: fileId)
            }
            
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
        
        let urlString = App.URL.hostIpServer+"reqFileDown.do"
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
    
    
    func remoteDownload(fromUserId:String, fromDevUuid:String, fromOsCd:String, fromFoldr:String, fromFileNm:String, fromFileId:String){
        print("remoteDownload called")
        var jsonHeader:[String:String] = [
            "Content-Type": "application/json",
            "X-Auth-Token": UserDefaults.standard.string(forKey: "token")!,
            "Cookie": UserDefaults.standard.string(forKey: "cookie")!
        ]
        
        let urlString = App.URL.hostIpServer+"reqFileDown.do"
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
                                
                                let lastIndex = self.multiCheckedfolderArray.count - 1
                                self.multiCheckedfolderArray.remove(at: lastIndex)
                                self.remoteMultiDownloadRequest(getFolderArray: self.multiCheckedfolderArray, parent: self.dv!, fromUserId: self.selectedUserId, devUuid: self.selectedDevUuid, deviceName: self.selectedDeviceName, devFoldrId: self.selectedDevFoldrId, fromOsCd: self.fromOsCd)
                                
                                break
                            case .failure(let error):
                                
                                print(error.localizedDescription)
                            }
        }
    }
    
    
    func remoteMultiDownloadRequestToSend(getFolderArray:[App.FolderStruct], parent:ContainerViewController, fromUserId:String, fromDevUuid:String, deviceName:String, devFoldrId:String,fromOsCd:String, toUserId:String, toOsCd:String, toDevUuid: String, toFoldr:String, fromFoldr:String){
        
        
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
        self.containerViewController = parent
        print("request count : \(multiCheckedfolderArray.count)")
        if (multiCheckedfolderArray.count > 0){
            let index = getFolderArray.count - 1
            let fileNm = getFolderArray[index].fileNm
            let foldrWholePathNm = getFolderArray[index].foldrWholePathNm
            let fileId = String(getFolderArray[index].fileId)
            let foldrId = String(getFolderArray[index].foldrId)
            let etsionNm = getFolderArray[index].etsionNm
            let nasSynchYn = getFolderArray[index].nasSynchYn
            print("nasSynchYn : \(nasSynchYn)")           
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
                  self.containerViewController?.finishLoading()
            }
            
            alertController.addAction(yesAction)
            self.containerViewController?.present(alertController, animated: true)
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
        let paramas = ["fromUserId":fromUserId,"fromDevUuid":fromDevUuid,"fromOsCd":fromOsCd,"fromFoldr":fromFoldr,"fromFileNm":fromFileNm,"fromFileId":fromFileId,"toUserId":toUserId,"toDevUuid":toDevUuid,"toOsCd":toOsCd,"toFoldr":toFoldr,"toFileNm":fromFileNm,"comndOsCd":"I","comndDevUuid":Util.getUuid(),"comnd":comnd]
        
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
                                    print("remoteDownloadRequest : \(String(describing: message)), queId: \(queId), data: \(data)")
                                    let lastIndex = self.multiCheckedfolderArray.count - 1
                                    self.multiCheckedfolderArray.remove(at: lastIndex)
                                    self.remoteMultiDownloadRequestToSend(getFolderArray: self.multiCheckedfolderArray, parent: self.containerViewController!, fromUserId: self.fromUserId, fromDevUuid: self.fromDevUuid, deviceName: self.selectedDeviceName, devFoldrId: self.selectedDevFoldrId, fromOsCd: self.fromOsCd, toUserId: self.toUserId, toOsCd: self.toOsCd, toDevUuid: self.toDevUuid, toFoldr: self.toFoldr, fromFoldr: self.fromFoldr)
                                } else {
                                    let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                                    let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel){
                                        UIAlertAction in
                                        
                                        NotificationCenter.default.post(name: Notification.Name("btnMulticlicked"), object: self, userInfo: nil)
                                        let fileIdDict = ["fileId":"0"]
                                        NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self, userInfo: fileIdDict)
                                        self.containerViewController?.finishLoading()
                                    }
                                    
                                    alertController.addAction(yesAction)
                                    self.containerViewController?.present(alertController, animated: true)
                                }
                                
                            case .failure(let error):
                                print(error.localizedDescription)
                                let alertController = UIAlertController(title: nil, message: "요청처리에 실패하였습니다.", preferredStyle: .alert)
                                let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel){
                                    UIAlertAction in
                                    
                                    NotificationCenter.default.post(name: Notification.Name("btnMulticlicked"), object: self, userInfo: nil)
                                    let fileIdDict = ["fileId":"0"]
                                    NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self, userInfo: fileIdDict)
                                    self.containerViewController?.finishLoading()
                                }
                                
                                alertController.addAction(yesAction)
                                self.containerViewController?.present(alertController, animated: true)
                            }
        }
    }
    
    
    // local 삭제 시작
    func callMultiLocalDelete(getFolderArray:[App.FolderStruct], parent:HomeDeviceCollectionVC, fromUserId:String, devUuid:String, deviceName:String, devFoldrId:String, containerViewController:ContainerViewController){
        dv = parent
        selectedDevUuid = devUuid
        selectedDeviceName = deviceName
        selectedUserId = fromUserId
        multiCheckedfolderArray = getFolderArray
        selectedDevFoldrId = devFoldrId
        self.containerViewController = containerViewController
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
            if let syncOngoing:Bool = UserDefaults.standard.bool(forKey: "syncOngoing"), syncOngoing == true {
                print("aleady Syncing")
                
            } else {
                SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
                
            }
            
            let alertController = UIAlertController(title: nil, message: "멀티 파일 삭제가 완료 되었습니다.", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel){
                UIAlertAction in
                containerViewController.finishLoading()
//                NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
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
            self.callMultiLocalDelete(getFolderArray: self.multiCheckedfolderArray, parent: self.dv!, fromUserId: self.selectedUserId, devUuid: self.selectedDevUuid, deviceName: self.selectedDeviceName, devFoldrId: self.selectedDevFoldrId, containerViewController:self.containerViewController!)
            
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    

}
    
    


