//
//  GDriveFileListCellController.swift
//  KT
//
//  Created by 김영은 on 2018. 3. 21..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit

class GDriveFileListCellController:UIViewController {
    var dv:HomeDeviceCollectionVC?
    
    
    func getCell(indexPathRow:Int, folderArray:[App.DriveFileStruct], multiCheckListState:HomeDeviceCollectionVC.multiCheckListEnum, collectionView:UICollectionView, parentView:HomeDeviceCollectionVC) -> GDriveFileListCell {
        
        let indexPath = IndexPath(row: indexPathRow, section: 0)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GDriveFileListCell", for: indexPath) as! GDriveFileListCell
        
       
        if(folderArray[indexPath.row].name == ".."){
            cell.btnOption.isHidden = true
        }
        
//        let imageString = Util.getFileImageString(fileExtension: folderArray[indexPath.row].mimeType)
//        let etsionFromMimeType = Util.getEtsionFromMimetype(mimeType: folderArray[indexPath.row].mimeType)
        let imageString = Util.getFileImageString(fileExtension: folderArray[indexPath.row].fileExtension)
        

        
        cell.lblDevice.isHidden = false
        let size = FileUtil().covertFileSize(getSize: folderArray[indexPath.row].size)
        cell.lblDevice.text = size
        
        cell.ivSub.image = UIImage(named: imageString)
        cell.optionSHowCheck = 0
        cell.optionHide()
        cell.lblMain.text = folderArray[indexPath.row].name
        cell.lblSub.text = folderArray[indexPath.row].modifiedTime.components(separatedBy: ".")[0].replacingOccurrences(of: "T", with: " ")
        
        if multiCheckListState == .active {
            if folderArray[indexPathRow].checked {
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
            }
        
        }
        
        return cell
    }
    
    func ContextMenuCalled(cell:GDriveFileListCell, indexPath:IndexPath, sender:UIButton, folderArray:[App.DriveFileStruct], deviceName:String, parentView:String, deviceView:HomeDeviceCollectionVC, userId:String, fromOsCd:String, currentDevUuid:String, currentFolderId:String, containerView:ContainerViewController){
        
        let fileNm = folderArray[indexPath.row].name
        let amdDate = folderArray[indexPath.row].createdTime
        let foldrWholePathNm = folderArray[indexPath.row].foldrWholePath
        let fileId = folderArray[indexPath.row].fileId
        let mimeType = folderArray[indexPath.row].mimeType
        let fileExtension = folderArray[indexPath.row].fileExtension
        let size = folderArray[indexPath.row].size
        let createdTime = folderArray[indexPath.row].createdTime
        let modifiedTime = folderArray[indexPath.row].modifiedTime
        let thumbnailLink = folderArray[indexPath.row].thumbnailLink
//        print("currentFOlderId : \(currentFolderId)")
        switch sender {
            case cell.btnShow:
                deviceView.hideSelectedOptions(tag: sender.tag)
                print("fileId: \(fileId)")
                var fileThumbYn = "N"
                if thumbnailLink != "nil"{
                    fileThumbYn = "Y"
                }
                
                let fileIdDict = ["fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":deviceName, "fileExtension":fileExtension,"size":String(size),"createdTime":createdTime,"modifiedTime":modifiedTime, "fileThumbYn":fileThumbYn, "fromOsCd":"D","thumbnailLink":"\(thumbnailLink)"]
//                print("fileIdDict : \(fileIdDict), thumbnailLink : \(thumbnailLink)")
                NotificationCenter.default.post(name: Notification.Name("getFileIdFromBtnShow"), object: self, userInfo: fileIdDict)
            case cell.btnDwnld:
                
                containerView.showIndicator()
                deviceView.hideSelectedOptions(tag: sender.tag)
                
                if parentView == "device" {
                print("parentView : \(parentView)")
                    deviceView.downloadGDriveFile(fileId: fileId, mimeType:mimeType, name:fileNm)
                    
                }
            case cell.btnNas:
                deviceView.hideSelectedOptions(tag: sender.tag)
                let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"toStorage":"nas","fromUserId":userId, "fromOsCd":"gDrive","fromDevUuid":currentDevUuid, "mimeType":mimeType]
                print("fileDict : \(fileDict)")
                
                NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
            
            case cell.btnGDrive:
                deviceView.hideSelectedOptions(tag: sender.tag)
//                let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"fromDevUuid":currentDevUuid, "toStorage":"googleDrive","fromUserId":userId, "fromOsCd":fromOsCd]
                 let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"toStorage":"googleDrive","fromUserId":userId, "fromOsCd":"gDrive","fromDevUuid":currentDevUuid, mimeType:mimeType,]
                print("fileDict : \(fileDict)")
                NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
            
            
            case cell.btnDelete:
                deviceView.hideSelectedOptions(tag: sender.tag)
                containerView.showIndicator()
                if parentView == "device" {
                    let alertController = UIAlertController(title: nil, message: "해당 파일을 삭제 하시겠습니까?", preferredStyle: .alert)
                    let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        GoogleWork().deleteGDriveFile(fileId: fileId)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            if(currentFolderId == "root" || currentFolderId.isEmpty){
                                let accessToken = UserDefaults.standard.string(forKey: "googleAccessToken")!
                                containerView.getFiles(accessToken: accessToken, root: "root")
                            
                            } else {
                                deviceView.showInsideListGDrive(userId: userId, devUuid: currentDevUuid, foldrId: currentFolderId, deviceName: deviceName)
                                
                            }
                            let alertController = UIAlertController(title: nil, message: "파일 삭제가 완료 되였습니다.", preferredStyle: .alert)
                            let yesAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                                UIAlertAction in
                                containerView.finishLoading()
                               
                            }
                            alertController.addAction(yesAction)
                            deviceView.present(alertController, animated: true)
                        })
                        
                    }
                    let noAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel)
                    alertController.addAction(yesAction)
                    alertController.addAction(noAction)
                    deviceView.present(alertController, animated: true)
                }
            default:
                break
        }
    }
    
    
    func ContextMenuCalledFromGrid(indexPath:IndexPath, fileId:String, foldrWholePathNm:String, deviceName:String, parentView:String, deviceView:HomeViewController, userId:String, fromOsCd:String, currentDevUuid:String, currentFolderId:String, folderArray:[App.DriveFileStruct], intFolderArrayIndexPathRow:Int, containerView:ContainerViewController){
        let fileNm = folderArray[intFolderArrayIndexPathRow].name
        let amdDate = folderArray[intFolderArrayIndexPathRow].createdTime
        let foldrWholePathNm = folderArray[intFolderArrayIndexPathRow].foldrWholePath
        let fileId = folderArray[intFolderArrayIndexPathRow].fileId
        let mimeType = folderArray[intFolderArrayIndexPathRow].mimeType
        let fileExtension = folderArray[intFolderArrayIndexPathRow].fileExtension
        let size = folderArray[intFolderArrayIndexPathRow].size
        let createdTime = folderArray[intFolderArrayIndexPathRow].createdTime
        let modifiedTime = folderArray[intFolderArrayIndexPathRow].modifiedTime
        let thumbnailLink = folderArray[intFolderArrayIndexPathRow].thumbnailLink
        switch indexPath.row {
        case 0:
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
            var fileThumbYn = "N"
            if thumbnailLink != "nil"{
                fileThumbYn = "Y"
            }
            let fileIdDict = ["fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":deviceName, "fileExtension":fileExtension,"size":size,"createdTime":createdTime,"modifiedTime":modifiedTime,  "fileThumbYn":fileThumbYn, "fromOsCd":"D","thumbnailLink":"\(thumbnailLink)"]
            
            print("fileIdDict : \(fileIdDict)")
            NotificationCenter.default.post(name: Notification.Name("getFileIdFromBtnShow"), object: self, userInfo: fileIdDict)
            break
        case 1:
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
                //deviceView.downloadGDriveFile(fileId: fileId, mimeType:mimeType, name:fileNm)
                containerView.showIndicator()

            GoogleWork().downloadGDriveFile(fileId: fileId, mimeType: mimeType, name: fileNm, startByte: 0, endByte: 102400) { responseObject, error in
                if let responseUrl = responseObject {

                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: nil, message: "다운로드를 성공하였습니다.", preferredStyle: .alert)
                        let yesAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                            UIAlertAction in
                            containerView.finishLoading()
                            if let syncOngoing:Bool = UserDefaults.standard.bool(forKey: "syncOngoing"), syncOngoing == true {
                                print("aleady Syncing")
                                
                            } else {
                                SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
                            }
                        }
                        alertController.addAction(yesAction)
                        deviceView.present(alertController, animated: true)
                    }
                } else {
                    DispatchQueue.main.async {
                        containerView.finishLoading()
                    }
                }
            }
        
        case 2:
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
            let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"toStorage":"nas","fromUserId":userId, "fromOsCd":"gDrive","fromDevUuid":currentDevUuid, mimeType:mimeType,]
            print("fileDict : \(fileDict)")
            
            NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
            
            break
        case 3:
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
       
            let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"toStorage":"googleDrive","fromUserId":userId, "fromOsCd":"gDrive","fromDevUuid":currentDevUuid, mimeType:mimeType,]
            print("fileDict : \(fileDict)")
            NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
            
            break
            
        case 4:
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
            let alertController = UIAlertController(title: nil, message: "해당 파일을 삭제 하시겠습니까?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                GoogleWork().deleteGDriveFile(fileId: fileId)
                containerView.showIndicator()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    if(currentFolderId == "root" || currentFolderId.isEmpty){
                        let accessToken = UserDefaults.standard.string(forKey: "googleAccessToken")!
                        containerView.getFiles(accessToken: accessToken, root: "root")
                        
                    } else {
                        let fileDict = ["foldrId":currentFolderId]
                        NotificationCenter.default.post(name: Notification.Name("refreshInsideList"), object: self, userInfo:fileDict)
                        
                    }
                    let alertController = UIAlertController(title: nil, message: "파일 삭제가 완료 되였습니다.", preferredStyle: .alert)
                    let yesAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                       containerView.finishLoading()
                    }
                    alertController.addAction(yesAction)
                    deviceView.present(alertController, animated: true)
                })
                
            }
            let noAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel)
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            deviceView.present(alertController, animated: true)
            break
            
        default:
            break
        }
        
    }
    func ContextMenuCalledFromGridLately(indexPath:IndexPath, fileId:String, foldrWholePathNm:String, deviceName:String, parentView:String, deviceView:LatelyUpdatedFileViewController, userId:String, fromOsCd:String, currentDevUuid:String, currentFolderId:String, folderArray:[App.DriveFileStruct], intFolderArrayIndexPathRow:Int, containerView:ContainerViewController){
        let fileNm = folderArray[intFolderArrayIndexPathRow].name
        let amdDate = folderArray[intFolderArrayIndexPathRow].createdTime
        let foldrWholePathNm = folderArray[intFolderArrayIndexPathRow].foldrWholePath
        let fileId = folderArray[intFolderArrayIndexPathRow].fileId
        let mimeType = folderArray[intFolderArrayIndexPathRow].mimeType
        let fileExtension = folderArray[intFolderArrayIndexPathRow].fileExtension
        let size = folderArray[intFolderArrayIndexPathRow].size
        let createdTime = folderArray[intFolderArrayIndexPathRow].createdTime
        let modifiedTime = folderArray[intFolderArrayIndexPathRow].modifiedTime
        let thumbnailLink = folderArray[intFolderArrayIndexPathRow].thumbnailLink
        switch indexPath.row {
        case 0:
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
            var fileThumbYn = "N"
            if thumbnailLink != "nil"{
                fileThumbYn = "Y"
            }
            let fileIdDict = ["fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":deviceName, "fileExtension":fileExtension,"size":size,"createdTime":createdTime,"modifiedTime":modifiedTime,  "fileThumbYn":fileThumbYn, "fromOsCd":"D","thumbnailLink":"\(thumbnailLink)"]
            
            print("fileIdDict : \(fileIdDict)")
            NotificationCenter.default.post(name: Notification.Name("getFileIdFromBtnShow"), object: self, userInfo: fileIdDict)
            break
        case 1:
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
            //deviceView.downloadGDriveFile(fileId: fileId, mimeType:mimeType, name:fileNm)
            containerView.showIndicator()
            
            GoogleWork().downloadGDriveFile(fileId: fileId, mimeType: mimeType, name: fileNm, startByte: 0, endByte: 102400) { responseObject, error in
                if let responseUrl = responseObject {
                    
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: nil, message: "다운로드를 성공하였습니다.", preferredStyle: .alert)
                        let yesAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                            UIAlertAction in
                            containerView.finishLoading()
                            if let syncOngoing:Bool = UserDefaults.standard.bool(forKey: "syncOngoing"), syncOngoing == true {
                                print("aleady Syncing")
                                
                            } else {
                                SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
                            }
                        }
                        alertController.addAction(yesAction)
                        deviceView.present(alertController, animated: true)
                    }
                } else {
                    DispatchQueue.main.async {
                        containerView.finishLoading()
                    }
                }
            }
            
        case 2:
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
            let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"toStorage":"nas","fromUserId":userId, "fromOsCd":"gDrive","fromDevUuid":currentDevUuid, mimeType:mimeType,]
            print("fileDict : \(fileDict)")
            
            NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
            
            break
        case 3:
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
            
            let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"toStorage":"googleDrive","fromUserId":userId, "fromOsCd":"gDrive","fromDevUuid":currentDevUuid, mimeType:mimeType,]
            print("fileDict : \(fileDict)")
            NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
            
            break
            
        case 4:
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
            let alertController = UIAlertController(title: nil, message: "해당 파일을 삭제 하시겠습니까?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                GoogleWork().deleteGDriveFile(fileId: fileId)
                containerView.showIndicator()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    if(currentFolderId == "root" || currentFolderId.isEmpty){
                        if let googleEmail = UserDefaults.standard.string(forKey: "googleEmail"){
                            //                            var accessToken = DbHelper().getAccessToken(email: googleEmail)
                            var accessToken = UserDefaults.standard.string(forKey: "googleAccessToken")!
                            containerView.getFiles(accessToken: accessToken, root: "root")
                        }
                    } else {
                        let fileDict = ["foldrId":currentFolderId]
                        NotificationCenter.default.post(name: Notification.Name("refreshInsideList"), object: self, userInfo:fileDict)
                        
                    }
                    let alertController = UIAlertController(title: nil, message: "파일 삭제가 완료 되였습니다.", preferredStyle: .alert)
                    let yesAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        containerView.finishLoading()
                        
                    }
                    alertController.addAction(yesAction)
                    deviceView.present(alertController, animated: true)
                })
                
            }
            let noAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel)
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            deviceView.present(alertController, animated: true)
            break
            
        default:
            break
        }
        
    }
}
