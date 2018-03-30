//
//  GDriveFileListCellController.swift
//  KT
//
//  Created by 김영은 on 2018. 3. 21..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit

class GDriveFileListCellController {
    var dv:HomeDeviceCollectionVC?
    
    
    func getCell(indexPathRow:Int, folderArray:[App.DriveFileStruct], multiCheckListState:HomeDeviceCollectionVC.multiCheckListEnum, collectionView:UICollectionView, parentView:HomeDeviceCollectionVC) -> GDriveFileListCell {
        
        let indexPath = IndexPath(row: indexPathRow, section: 0)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GDriveFileListCell", for: indexPath) as! GDriveFileListCell
        
        if (multiCheckListState == .active){
            cell.btnMultiCheck.isHidden = false
            cell.btnMultiCheck.tag = indexPath.row
            cell.btnMultiCheck.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnMultiCheckClicked(sender:)), for: .touchUpInside)
            cell.btnOption.isHidden = true
            
        } else {
            cell.btnOption.isHidden = false
            cell.btnMultiCheck.isHidden = true
        }
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
        cell.btnAction.tag = indexPath.row
        cell.btnAction.addTarget(self, action: #selector(parentView.optionGDriveFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnNas.tag = indexPath.row
        cell.btnNas.addTarget(self, action: #selector(parentView.optionGDriveFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnGDrive.tag = indexPath.row
        cell.btnGDrive.addTarget(self, action: #selector(parentView.optionGDriveFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(parentView.optionGDriveFileShowClicked(sender:)), for: .touchUpInside)
        return cell
    }
    
    func localContextMenuCalled(cell:GDriveFileListCell, indexPath:IndexPath, sender:UIButton, folderArray:[App.DriveFileStruct], deviceName:String, parentView:String, deviceView:HomeDeviceCollectionVC, userId:String, fromOsCd:String, currentDevUuid:String, currentFolderId:String){
        
        let fileNm = folderArray[indexPath.row].name
        let amdDate = folderArray[indexPath.row].createdTime
        let foldrWholePathNm = folderArray[indexPath.row].foldrWholePath
        let fileId = String(folderArray[indexPath.row].fileId)
        let mimeType = folderArray[indexPath.row].mimeType
        let fileExtension = folderArray[indexPath.row].fileExtension
        let size = folderArray[indexPath.row].size
        let createdTime = folderArray[indexPath.row].createdTime
        let modifiedTime = folderArray[indexPath.row].modifiedTime
        
        switch sender {
            case cell.btnShow:
                print("fileId: \(fileId)")
                let fileIdDict = ["fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":deviceName, "fileExtension":fileExtension,"size":String(size),"createdTime":createdTime,"modifiedTime":modifiedTime]
                NotificationCenter.default.post(name: Notification.Name("getFileIdFromBtnShow"), object: self, userInfo: fileIdDict)
            case cell.btnDwnld:
                if parentView == "device" {
                    deviceView.downloadGDriveFile(fileId: fileId, mimeType:mimeType, name:fileNm)
                }
            case cell.btnNas:
                let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"toStorage":"nas","fromUserId":userId, "fromOsCd":fromOsCd,"fromDevUuid":currentDevUuid]
                print("fileDict : \(fileDict)")
                
                NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
                if parentView == "device" {
                    deviceView.showLocalFileOption(tag: sender.tag)
                }
            case cell.btnGDrive:
                if parentView == "device" {
                    /*
                    let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"fromDevUuid":currentDevUuid, "toStorage":"googleDrive","fromUserId":userId, "fromOsCd":fromOsCd]
                    print("fileDict : \(fileDict)")
                    deviceView.googleSignInCheck(name: fileNm, path: foldrWholePathNm, fileDict: fileDict)
                    deviceView.showLocalFileOption(tag: sender.tag)*/
                }
            case cell.btnDelete:
                if parentView == "device" {
                    let alertController = UIAlertController(title: nil, message: "해당 파일을 삭제 하시겠습니까?", preferredStyle: .alert)
                    let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        deviceView.deleteGDriveFile(fileId: fileId)
                        SyncLocalFilleToNas().sync(view: "")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                            let alertController = UIAlertController(title: nil, message: "파일 삭제가 완료 되였습니다.", preferredStyle: .alert)
                            let yesAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                                UIAlertAction in
                                
                                deviceView.showInsideList(userId: userId, devUuid: currentDevUuid, foldrId: currentFolderId, deviceName: deviceName)
                                
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
    
    
    func localContextMenuCalledFromGrid(indexPath:IndexPath, fileId:String, foldrWholePathNm:String, deviceName:String, parentView:String, deviceView:HomeViewController, userId:String, fromOsCd:String, currentDevUuid:String, currentFolderId:String, folderArray:[App.DriveFileStruct], intFolderArrayIndexPathRow:Int){
        let fileNm = folderArray[intFolderArrayIndexPathRow].name
        let amdDate = folderArray[intFolderArrayIndexPathRow].name
        let foldrWholePathNm = folderArray[intFolderArrayIndexPathRow].name
        let fileId = String(folderArray[intFolderArrayIndexPathRow].fileId)
        let foldrId = folderArray[intFolderArrayIndexPathRow].fileId
        let mimeType = folderArray[intFolderArrayIndexPathRow].mimeType
        
        switch indexPath.row {
        case 0:
            let fileIdDict = ["fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":deviceName]
            NotificationCenter.default.post(name: Notification.Name("getFileIdFromBtnShow"), object: self, userInfo: fileIdDict)
            break
        case 1:
            if parentView == "device" {
                //deviceView.downloadGDriveFile(fileId: fileId, mimeType:mimeType, name:fileNm)
            }
        case 2:
            let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"fromDevUuid":currentDevUuid, "toStorage":"nas","fromUserId":userId, "fromOsCd":fromOsCd]
            print("fileDict : \(fileDict)")
            NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
            break
        case 3:
            let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"fromDevUuid":currentDevUuid, "toStorage":"googleDrive","fromUserId":userId, "fromOsCd":fromOsCd]
            //            print("fileDict : \(fileDict)")
            GoogleWork().googleSignInCheck(name: fileNm, path: foldrWholePathNm, fileDict: fileDict)
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
            break
            
        case 4:
            let alertController = UIAlertController(title: nil, message: "해당 파일을 삭제 하시겠습니까?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
                
                let pathForRemove:String = FileUtil().getFilePath(fileNm: fileNm, amdDate: amdDate)
                //self.removeFile(path: pathForRemove)
                SyncLocalFilleToNas().sync(view: "")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    let alertController = UIAlertController(title: nil, message: "파일 삭제가 완료 되였습니다.", preferredStyle: .alert)
                    let yesAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        let fileDict = ["foldrId":String(foldrId)]
                        print("delete filedict : \(fileDict)")
                        NotificationCenter.default.post(name: Notification.Name("refreshInsideList"), object: self, userInfo: fileDict)
                        
                        
                    }
                    alertController.addAction(yesAction)
                    deviceView.present(alertController, animated: true)
                })
                
            }
            let noAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel) {
                UIAlertAction in
                NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
            }
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            deviceView.present(alertController, animated: true)
            break
            
        default:
            break
        }
        
    }
    
}
