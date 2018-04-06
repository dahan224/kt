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
        
        let imageString = Util.getFileImageString(fileExtension: folderArray[indexPath.row].mimeType)
        cell.ivSub.image = UIImage(named: imageString)
        cell.optionSHowCheck = 0
        cell.optionHide()
        cell.lblMain.text = folderArray[indexPath.row].name
        cell.lblSub.text = folderArray[indexPath.row].createdTime
        
        cell.btnOption.isHidden = false
        cell.btnShow.tag = indexPath.row
        cell.btnShow.addTarget(self, action: #selector(parentView.optionGDriveFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnDwnld.tag = indexPath.row
        cell.btnDwnld.addTarget(self, action: #selector(parentView.optionGDriveFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnNas.tag = indexPath.row
        cell.btnNas.addTarget(self, action: #selector(parentView.optionGDriveFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnGDrive.tag = indexPath.row
        cell.btnGDrive.addTarget(self, action: #selector(parentView.optionGDriveFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(parentView.optionGDriveFileShowClicked(sender:)), for: .touchUpInside)
        return cell
    }
    
    func localContextMenuCalled(cell:GDriveFileListCell, indexPath:IndexPath, sender:UIButton, folderArray:[App.DriveFileStruct], deviceName:String, parentView:String, deviceView:HomeDeviceCollectionVC, userId:String, fromOsCd:String, currentDevUuid:String, currentFolderId:String, containerView:ContainerViewController){
        
        let fileNm = folderArray[indexPath.row].name
        let amdDate = folderArray[indexPath.row].createdTime
        let foldrWholePathNm = folderArray[indexPath.row].foldrWholePath
        let fileId = folderArray[indexPath.row].fileId
        let mimeType = folderArray[indexPath.row].mimeType
        let fileExtension = folderArray[indexPath.row].fileExtension
        let size = folderArray[indexPath.row].size
        let createdTime = folderArray[indexPath.row].createdTime
        let modifiedTime = folderArray[indexPath.row].modifiedTime
        print("currentFOlderId : \(currentFolderId)")
        switch sender {
            case cell.btnShow:
                deviceView.showGDriveFileOption(tag: sender.tag)
                print("fileId: \(fileId)")
                let fileIdDict = ["fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":deviceName, "fileExtension":fileExtension,"size":String(size),"createdTime":createdTime,"modifiedTime":modifiedTime]
                NotificationCenter.default.post(name: Notification.Name("getFileIdFromBtnShow"), object: self, userInfo: fileIdDict)
            case cell.btnDwnld:
                deviceView.showGDriveFileOption(tag: sender.tag)
                
                if parentView == "device" {
                print("parentView : \(parentView)")
                    deviceView.downloadGDriveFile(fileId: fileId, mimeType:mimeType, name:fileNm)
                }
            case cell.btnNas:
                deviceView.showGDriveFileOption(tag: sender.tag)
                let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"toStorage":"nas","fromUserId":userId, "fromOsCd":"gDrive","fromDevUuid":currentDevUuid, mimeType:mimeType,]
                print("fileDict : \(fileDict)")
                
                NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
            
            case cell.btnGDrive:
                deviceView.showGDriveFileOption(tag: sender.tag)
//                let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"fromDevUuid":currentDevUuid, "toStorage":"googleDrive","fromUserId":userId, "fromOsCd":fromOsCd]
                 let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"toStorage":"googleDrive","fromUserId":userId, "fromOsCd":"gDrive","fromDevUuid":currentDevUuid, mimeType:mimeType,]
                print("fileDict : \(fileDict)")
                NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
            
            
            case cell.btnDelete:
                deviceView.showGDriveFileOption(tag: sender.tag)
                
                if parentView == "device" {
                    let alertController = UIAlertController(title: nil, message: "해당 파일을 삭제 하시겠습니까?", preferredStyle: .alert)
                    let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        GoogleWork().deleteGDriveFile(fileId: fileId)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            if(currentFolderId == "root" || currentFolderId.isEmpty){
                                if let googleEmail = UserDefaults.standard.string(forKey: "googleEmail"){
                                    var accessToken = DbHelper().getAccessToken(email: googleEmail)
                                    containerView.getFiles(accessToken: accessToken, root: "root")
                                }                                
                            } else {
                                deviceView.showInsideListGDrive(userId: userId, devUuid: currentDevUuid, foldrId: currentFolderId, deviceName: deviceName)
                                
                            }
                            let alertController = UIAlertController(title: nil, message: "파일 삭제가 완료 되였습니다.", preferredStyle: .alert)
                            let yesAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                                UIAlertAction in
                               
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
    
    
    func localContextMenuCalledFromGrid(indexPath:IndexPath, fileId:String, foldrWholePathNm:String, deviceName:String, parentView:String, deviceView:HomeViewController, userId:String, fromOsCd:String, currentDevUuid:String, currentFolderId:String, folderArray:[App.DriveFileStruct], intFolderArrayIndexPathRow:Int, containerView:ContainerViewController){
        let fileNm = folderArray[intFolderArrayIndexPathRow].name
        let amdDate = folderArray[intFolderArrayIndexPathRow].createdTime
        let foldrWholePathNm = folderArray[intFolderArrayIndexPathRow].foldrWholePath
        let fileId = folderArray[intFolderArrayIndexPathRow].fileId
        let mimeType = folderArray[intFolderArrayIndexPathRow].mimeType
        let fileExtension = folderArray[intFolderArrayIndexPathRow].fileExtension
        let size = folderArray[intFolderArrayIndexPathRow].size
        let createdTime = folderArray[intFolderArrayIndexPathRow].createdTime
        let modifiedTime = folderArray[intFolderArrayIndexPathRow].modifiedTime
        
        switch indexPath.row {
        case 0:
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
            let fileIdDict = ["fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":deviceName, "fileExtension":fileExtension,"size":size,"createdTime":createdTime,"modifiedTime":modifiedTime]
            print("fileIdDict : \(fileIdDict)")
            NotificationCenter.default.post(name: Notification.Name("getFileIdFromBtnShow"), object: self, userInfo: fileIdDict)
            break
        case 1:
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
                //deviceView.downloadGDriveFile(fileId: fileId, mimeType:mimeType, name:fileNm)
                deviceView.homeViewToggleIndicator()
                GoogleWork().downloadGDriveFile(fileId: fileId, mimeType: mimeType, name: fileNm) { responseObject, error in
                if let responseUrl = responseObject {
                   
                    let alertController = UIAlertController(title: nil, message: "다운로드를 성공하였습니다.", preferredStyle: .alert)
                    let yesAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        deviceView.homeViewToggleIndicator()
                        
                    }
                    alertController.addAction(yesAction)
                    deviceView.present(alertController, animated: true)
                    
                    
                } else {
                    deviceView.homeViewToggleIndicator()
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
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    if(currentFolderId == "root" || currentFolderId.isEmpty){
                        if let googleEmail = UserDefaults.standard.string(forKey: "googleEmail"){
                            var accessToken = DbHelper().getAccessToken(email: googleEmail)
                            containerView.getFiles(accessToken: accessToken, root: "root")
                        }
                    } else {
                        let fileDict = ["foldrId":currentFolderId]
                        NotificationCenter.default.post(name: Notification.Name("refreshInsideList"), object: self, userInfo:fileDict)
                        
                    }
                    let alertController = UIAlertController(title: nil, message: "파일 삭제가 완료 되였습니다.", preferredStyle: .alert)
                    let yesAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                       
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
