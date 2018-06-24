//
//  RemoteFileListCellController.swift
//  KT
//
//  Created by 이다한 on 2018. 3. 14..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RemoteFileListCellController {
    
    var dv:HomeDeviceCollectionVC?
    var hv:HomeViewController?
    var latelyView:LatelyUpdatedFileViewController?
    var viewController = ""
    var jsonHeader:[String:String] = [
        "Content-Type": "application/json",
        "X-Auth-Token": UserDefaults.standard.string(forKey: "token")!,
        "Cookie": UserDefaults.standard.string(forKey: "cookie")!
    ]
    
    func getCell(indexPathRow:Int, folderArray:[App.FolderStruct], multiCheckListState:HomeDeviceCollectionVC.multiCheckListEnum, collectionView:UICollectionView, parentView:HomeDeviceCollectionVC, viewState:HomeViewController.viewStateEnum) -> RemoteFileListCell {
        let indexPath = IndexPath(row: indexPathRow, section: 0)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RemoteFileListCell", for: indexPath) as! RemoteFileListCell
        
        if(folderArray[indexPath.row].foldrNm == ".."){
            cell.btnOption.isHidden = true
        }
        let imageString = Util.getFileImageString(fileExtension: folderArray[indexPath.row].etsionNm)
        
        cell.ivSub.image = UIImage(named: imageString)
        cell.optionSHowCheck = 0
        cell.optionHide()
        cell.lblMain.text = folderArray[indexPath.row].fileNm
        cell.lblSub.text = folderArray[indexPath.row].amdDate
        
        if(viewState == .search || viewState == .lately){
            cell.lblDevice.isHidden = false
            cell.lblDevice.text = folderArray[indexPath.row].devNm
        } else {
            cell.lblDevice.isHidden = false
            let size = FileUtil().covertFileSize(getSize: folderArray[indexPath.row].fileSize)
            cell.lblDevice.text = size
        }
        
        if multiCheckListState == .active {
            if folderArray[indexPathRow].checked {
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
            }
            
            
        }
      
        return cell
    }
    
    func remoteFileContextMenuCalled(cell:RemoteFileListCell, indexPath:IndexPath, sender:UIButton, folderArray:[App.FolderStruct], deviceName:String, parentView:String, deviceView:HomeDeviceCollectionVC, userId:String, fromOsCd:String, currentDevUuid:String, selectedDevUserId:String, currentFolderId:String){
        dv = deviceView
        viewController = "deviceView"
        var fromDevUuid = currentDevUuid
        var finalFromOsCd = fromOsCd
        var fromUserId = selectedDevUserId
        if(folderArray[indexPath.row].devUuid != "nil"){
            fromDevUuid = folderArray[indexPath.row].devUuid
        }
        if(folderArray[indexPath.row].userId != "nil"){
            fromUserId = folderArray[indexPath.row].userId
        }
        if(folderArray[indexPath.row].osCd != "nil"){
            finalFromOsCd = folderArray[indexPath.row].osCd
        }
        let fileNm = folderArray[indexPath.row].fileNm
        let etsionNm = folderArray[indexPath.row].etsionNm
        let amdDate = folderArray[indexPath.row].amdDate
        let foldrWholePathNm = folderArray[indexPath.row].foldrWholePathNm
        let fileId = String(folderArray[indexPath.row].fileId)
        let devNm = folderArray[indexPath.row].devNm
        let nasSynchYn = folderArray[indexPath.row].nasSynchYn
        let fileThumbYn = folderArray[indexPath.row].fileThumbYn
        
        var btn = "show"
        switch sender {
        case cell.btnShow:
            btn = "show"
            dv?.hideSelectedOptions(tag: sender.tag)
//            let fileIdDict = ["fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":devNm]
            let fileIdDict = ["fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":devNm, "fileThumbYn":fileThumbYn]
            print("fileIdDict : \(fileIdDict)")
            NotificationCenter.default.post(name: Notification.Name("getFileIdFromBtnShow"), object: self, userInfo: fileIdDict)
            
            break
        case cell.btnDwnld:
            print("nasSynchYn : \(nasSynchYn)")
            dv?.hideSelectedOptions(tag: sender.tag)
            let remoteDownLoadStyle = "remoteDownLoad"
            UserDefaults.standard.setValue(remoteDownLoadStyle, forKey: "remoteDownLoadStyle")
            UserDefaults.standard.synchronize()

            
            print("folder : \(folderArray[indexPath.row])")
            print("fileId: \(fileId) , fromUserId : \(fromUserId), fromDevUuid : \(fromDevUuid), fromFoldr : \(foldrWholePathNm)")
            let alertController = UIAlertController(title: nil, message: "해당 파일을 다운로드 하시겠습니까?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                if nasSynchYn == "Y" {
                    let path = "\(fromDevUuid)/\(foldrWholePathNm)"
                    print("path : \(path)")
                    self.downloadFromRemote(userId: fromUserId, name: fileNm, path: path, fileId: fileId)
                    
                    
                } else {
                    self.remoteDownloadRequest(fromUserId: fromUserId, fromDevUuid: fromDevUuid, fromOsCd: finalFromOsCd, fromFoldr: foldrWholePathNm, fromFileNm: fileNm, fromFileId: fileId)
                }
                
                
            }
            let noAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel)
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            dv?.present(alertController, animated: true)
            break
            
        case cell.btnNas:
            
            dv?.hideSelectedOptions(tag: sender.tag)
            let remoteDownLoadStyle = "remoteDownLoadToNas"
            UserDefaults.standard.setValue(remoteDownLoadStyle, forKey: "remoteDownLoadStyle")
            UserDefaults.standard.synchronize()

//            remoteDownloadRequestToNas(fromUserId: selectedDevUserId, fromDevUuid: currentDevUuid, fromOsCd: fromOsCd, fromFoldr: currentDevUuid, fromFileNm: fileNm, fromFileId: fileId)
            let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"toStorage":"nas","fromUserId":fromUserId, "fromOsCd":finalFromOsCd,"fromDevUuid":fromDevUuid]
            print("fileDict : \(fileDict)")
            NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
            break
            
       
        default:
            break
        }
    }
    
   
    
    func remoteFileContextMenuCalledFromGrid(indexPath:IndexPath, fileId:String, foldrWholePathNm:String, deviceName:String, parentView:String, deviceView:HomeViewController, userId:String, fromOsCd:String, currentDevUuid:String, currentFolderId:String, folderArray:[App.FolderStruct], intFolderArrayIndexPathRow:Int){
        let fileNm = folderArray[intFolderArrayIndexPathRow].fileNm
        //        let etsionNm = folderArray[intFolderArrayIndexPathRow].etsionNm
        let amdDate = folderArray[intFolderArrayIndexPathRow].amdDate
        let foldrWholePathNm = folderArray[intFolderArrayIndexPathRow].foldrWholePathNm
        let fileId = String(folderArray[intFolderArrayIndexPathRow].fileId)
        let foldrId = String(folderArray[intFolderArrayIndexPathRow].foldrId)
        let devNm = folderArray[intFolderArrayIndexPathRow].devNm
        let nasSynchYn = folderArray[intFolderArrayIndexPathRow].nasSynchYn
        var fromDevUuid = currentDevUuid
        var finalFromOsCd = fromOsCd
        var fromUserId = userId
        if(folderArray[intFolderArrayIndexPathRow].devUuid != "nil"){
            fromDevUuid = folderArray[indexPath.row].devUuid
        }
        if(folderArray[intFolderArrayIndexPathRow].userId != "nil"){
            fromUserId = folderArray[indexPath.row].userId
        }
        if(folderArray[intFolderArrayIndexPathRow].osCd != "nil"){
            finalFromOsCd = folderArray[indexPath.row].osCd
        }
        let fileThumbYn = folderArray[intFolderArrayIndexPathRow].fileThumbYn
        hv = deviceView
        viewController = "homeView"
        switch indexPath.row {
        case 0 :
            //파일 상세보기
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
            
//            let fileIdDict = ["fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":devNm]
            let fileIdDict = ["fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":devNm, "fileThumbYn":fileThumbYn]
            NotificationCenter.default.post(name: Notification.Name("getFileIdFromBtnShow"), object: self, userInfo: fileIdDict)
            
            
            break
        case 1:
            
            //다운로드
            let remoteDownLoadStyle = "remoteDownLoad"
            UserDefaults.standard.setValue(remoteDownLoadStyle, forKey: "remoteDownLoadStyle")
            UserDefaults.standard.synchronize()
            print("remoteDownLoad: \(String(describing: UserDefaults.standard.string(forKey: "remoteDownLoadStyle")))")
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
            print("folder : \(folderArray[indexPath.row])")
            print("fileId: \(fileId) , fromUserId : \(userId), fromDevUuid : \(currentDevUuid), fromFoldr : \(foldrWholePathNm), nasSynchYn: \(nasSynchYn)")
            let alertController = UIAlertController(title: nil, message: "해당 파일을 다운로드 하시겠습니까?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                if nasSynchYn == "Y" {
                    let path = "\(fromDevUuid)/\(foldrWholePathNm)"
                    print("path : \(path)")
                    self.downloadFromRemote(userId: fromUserId, name: fileNm, path: path, fileId: fileId)
                    
                    
                } else {
                    self.remoteDownloadRequest(fromUserId: fromUserId, fromDevUuid: fromDevUuid, fromOsCd: finalFromOsCd, fromFoldr: foldrWholePathNm, fromFileNm: fileNm, fromFileId: fileId)
                    
                }
                
                
            }
            let noAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel)
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            deviceView.present(alertController, animated: true)
            break
            
        case 2:
            
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
//            let remoteDownLoadToNas = true
            let remoteDownLoadStyle = "remoteDownLoadToNas"
            UserDefaults.standard.setValue(remoteDownLoadStyle, forKey: "remoteDownLoadStyle")
            UserDefaults.standard.synchronize()
            
            //            remoteDownloadRequestToNas(fromUserId: selectedDevUserId, fromDevUuid: currentDevUuid, fromOsCd: fromOsCd, fromFoldr: currentDevUuid, fromFileNm: fileNm, fromFileId: fileId)
            let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"toStorage":"nas","fromUserId":userId, "fromOsCd":fromOsCd,"fromDevUuid":currentDevUuid]
            print("fileDict : \(fileDict)")
            NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
            break
            
        default :
            
            break
        }
        
    }
    
    
    
    func remoteFileContextMenuCalledFromGridLately(indexPath:IndexPath, fileId:String, foldrWholePathNm:String, deviceName:String, parentView:String, deviceView:LatelyUpdatedFileViewController, userId:String, fromOsCd:String, currentDevUuid:String, currentFolderId:String, folderArray:[App.FolderStruct], intFolderArrayIndexPathRow:Int){
        let fileNm = folderArray[intFolderArrayIndexPathRow].fileNm
        //        let etsionNm = folderArray[intFolderArrayIndexPathRow].etsionNm
        let amdDate = folderArray[intFolderArrayIndexPathRow].amdDate
        let foldrWholePathNm = folderArray[intFolderArrayIndexPathRow].foldrWholePathNm
        let fileId = String(folderArray[intFolderArrayIndexPathRow].fileId)
        let foldrId = String(folderArray[intFolderArrayIndexPathRow].foldrId)
        let devNm = folderArray[intFolderArrayIndexPathRow].devNm
        let nasSynchYn = folderArray[intFolderArrayIndexPathRow].nasSynchYn
        var fromDevUuid = currentDevUuid
        var finalFromOsCd = fromOsCd
        var fromUserId = userId
        if(folderArray[intFolderArrayIndexPathRow].devUuid != "nil"){
            fromDevUuid = folderArray[indexPath.row].devUuid
        }
        if(folderArray[intFolderArrayIndexPathRow].userId != "nil"){
            fromUserId = folderArray[indexPath.row].userId
        }
        if(folderArray[intFolderArrayIndexPathRow].osCd != "nil"){
            finalFromOsCd = folderArray[indexPath.row].osCd
        }
        let fileThumbYn = folderArray[intFolderArrayIndexPathRow].fileThumbYn
        viewController = "latelyView"
        switch indexPath.row {
        case 0 :
            //파일 상세보기
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
            
            //            let fileIdDict = ["fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":devNm]
            let fileIdDict = ["fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":devNm, "fileThumbYn":fileThumbYn]
            NotificationCenter.default.post(name: Notification.Name("getFileIdFromBtnShow"), object: self, userInfo: fileIdDict)
            
            
            break
        case 1:
            
            //다운로드
            let remoteDownLoadStyle = "remoteDownLoad"
            UserDefaults.standard.setValue(remoteDownLoadStyle, forKey: "remoteDownLoadStyle")
            UserDefaults.standard.synchronize()
            print("remoteDownLoad: \(String(describing: UserDefaults.standard.string(forKey: "remoteDownLoadStyle")))")
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
            print("folder : \(folderArray[indexPath.row])")
            print("fileId: \(fileId) , fromUserId : \(userId), fromDevUuid : \(currentDevUuid), fromFoldr : \(foldrWholePathNm), nasSynchYn: \(nasSynchYn)")
            let alertController = UIAlertController(title: nil, message: "해당 파일을 다운로드 하시겠습니까?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                if nasSynchYn == "Y" {
                    let path = "\(fromDevUuid)/\(foldrWholePathNm)"
                    print("path : \(path)")
                    self.downloadFromRemote(userId: fromUserId, name: fileNm, path: path, fileId: fileId)
                    
                    
                } else {
                    self.remoteDownloadRequest(fromUserId: fromUserId, fromDevUuid: fromDevUuid, fromOsCd: finalFromOsCd, fromFoldr: foldrWholePathNm, fromFileNm: fileNm, fromFileId: fileId)
                    
                }
                
                
            }
            let noAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel)
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            deviceView.present(alertController, animated: true)
            break
            
        case 2:
            
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
            //            let remoteDownLoadToNas = true
            let remoteDownLoadStyle = "remoteDownLoadToNas"
            UserDefaults.standard.setValue(remoteDownLoadStyle, forKey: "remoteDownLoadStyle")
            UserDefaults.standard.synchronize()
            
            //            remoteDownloadRequestToNas(fromUserId: selectedDevUserId, fromDevUuid: currentDevUuid, fromOsCd: fromOsCd, fromFoldr: currentDevUuid, fromFileNm: fileNm, fromFileId: fileId)
            let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"toStorage":"nas","fromUserId":userId, "fromOsCd":fromOsCd,"fromDevUuid":currentDevUuid]
            print("fileDict : \(fileDict)")
            NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
            break
            
        default :
            
            break
        }
        
    }
    
    
    
    
    func remoteDownloadRequest(fromUserId:String, fromDevUuid:String, fromOsCd:String, fromFoldr:String, fromFileNm:String, fromFileId:String){
        print("remoteDownloadRequest called")
        
        let urlString = App.URL.hostIpServer+"reqFileDown.do"
        let comnd = "R\(fromOsCd)LI"
        let paramas:[String : Any] = ["fromUserId":fromUserId,"fromDevUuid":fromDevUuid,"fromOsCd":fromOsCd,"fromFoldr":fromFoldr,"fromFileNm":fromFileNm,"fromFileId":fromFileId,"toDevUuid":Util.getUuid(),"toOsCd":"I","toFoldr":"/Mobile","toFileNm":fromFileNm,"comndOsCd":"I","comndDevUuid":App.defaults.userId,"comnd":comnd]
        print("notifyNasUploadFinish param : \(paramas)")
        Alamofire.request(urlString,
                          method: .post,
                          parameters: paramas,
                          encoding : JSONEncoding.default,
                          headers: jsonHeader).responseJSON { response in
                            switch response.result {
                            case .success(let responseObject):
                                
                                let json = JSON(responseObject)
                                let message = json["message"].string
                                
                                DispatchQueue.main.async {
                                    let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                                    let yesAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                                        UIAlertAction in
                                        
                                    }
                                    alertController.addAction(yesAction)
                                    if self.viewController == "deviceView" {
                                        self.dv?.present(alertController, animated: true, completion: nil)
                                    } else if self.viewController == "homeView" {
                                        self.hv?.present(alertController, animated: true, completion: nil)
                                    } else {
                                        self.latelyView?.present(alertController, animated: true, completion: nil)
                                    }
                                    
                                }
                                
                            case .failure(let error):
                                print(error.localizedDescription)
                                let alertController = UIAlertController(title: nil, message: "요청처리에 실패하였습니다.", preferredStyle: .alert)
                                let yesAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.default)
                                alertController.addAction(yesAction)
                                if self.viewController == "deviceView" {
                                    self.dv?.present(alertController, animated: true, completion: nil)
                                } else if self.viewController == "homeView" {
                                    self.hv?.present(alertController, animated: true, completion: nil)
                                } else {
                                    self.latelyView?.present(alertController, animated: true, completion: nil)
                                }
                            }
        }
    }

    
    func downloadFromRemote(userId:String, name:String, path:String, fileId:String){
        ContextMenuWork().downloadFromRemote(userId:userId, fileNm:name, path:path, fileId:fileId){ responseObject, error in
            if let success = responseObject {
                print(success)
                if(success == "success"){
                    
                    if let syncOngoing:Bool = UserDefaults.standard.bool(forKey: "syncOngoing"), syncOngoing == true {
                        print("aleady Syncing")
                        
                    } else {
                        SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
                    }
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: nil, message: "파일 다운로드를 성공하였습니다.", preferredStyle: .alert)
                        //                        let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel)
                        let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                            UIAlertAction in
                            
                        }
                        alertController.addAction(yesAction)
                        print("download Success")
                        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
                        alertWindow.rootViewController = UIViewController()
                        alertWindow.windowLevel = UIWindowLevelAlert + 1;
                        alertWindow.makeKeyAndVisible()
                        alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
                    }
                }
            }
            return
        }
    }
}
