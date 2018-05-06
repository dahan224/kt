//
//  LocalFileListCellController.swift
//  KT
//
//  Created by 이다한 on 2018. 3. 17..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit

class LocalFileListCellController:UIViewController{
    var dv:HomeDeviceCollectionVC?
    
    
    func getCell(indexPathRow:Int, folderArray:[App.FolderStruct], multiCheckListState:HomeDeviceCollectionVC.multiCheckListEnum, collectionView:UICollectionView, parentView:HomeDeviceCollectionVC, viewState:HomeViewController.viewStateEnum) -> LocalFileListCell {
        let indexPath = IndexPath(row: indexPathRow, section: 0)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LocalFileListCell", for: indexPath) as! LocalFileListCell
    
        if(folderArray[indexPath.row].foldrNm == ".."){
            cell.btnOption.isHidden = true
        }
        
        let imageString = Util.getFileImageString(fileExtension: folderArray[indexPath.row].etsionNm)
        cell.ivSub.image = UIImage(named: imageString)
        cell.optionSHowCheck = 0
        cell.optionHide()
        cell.lblMain.text = folderArray[indexPath.row].fileNm
        cell.lblSub.text = folderArray[indexPath.row].amdDate
        if(viewState == .search){
            cell.lblDevice.isHidden = false
            cell.lblDevice.text = folderArray[indexPath.row].devNm
        } else {
            cell.lblDevice.isHidden = false
            let size = FileUtil().covertFileSize(getSize: folderArray[indexPath.row].fileSize)
            cell.lblDevice.text = size
        }
        
//        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(cellLocalFileSwipeToLeft(sender:)))
//        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
//        cell.btnOption.addGestureRecognizer(swipeLeft)
       
        cell.btnOption.isHidden = false
        cell.btnShow.tag = indexPath.row
        cell.btnShow.addTarget(self, action: #selector(parentView.optionLocalFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnAction.tag = indexPath.row
        cell.btnAction.addTarget(self, action: #selector(parentView.optionLocalFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnNas.tag = indexPath.row
        cell.btnNas.addTarget(self, action: #selector(parentView.optionLocalFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnGDrive.tag = indexPath.row
        cell.btnGDrive.addTarget(self, action: #selector(parentView.optionLocalFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(parentView.optionLocalFileShowClicked(sender:)), for: .touchUpInside)
        return cell
    }
    func localContextMenuCalled(cell:LocalFileListCell, indexPath:IndexPath, sender:UIButton, folderArray:[App.FolderStruct], parentView:String, deviceView:HomeDeviceCollectionVC, userId:String, currentFolderId:String, viewState:HomeViewController.viewStateEnum, containerView:ContainerViewController, deviceName:String){
        dv = deviceView
        let fileNm = folderArray[indexPath.row].fileNm
        let etsionNm = folderArray[indexPath.row].etsionNm
        let amdDate = folderArray[indexPath.row].amdDate
        let foldrWholePathNm = folderArray[indexPath.row].foldrWholePathNm
        let fileId = String(folderArray[indexPath.row].fileId)
        let foldrId = folderArray[indexPath.row].foldrId
        let devNm = folderArray[indexPath.row].devNm
        let fromOsCd = folderArray[indexPath.row].osCd
        let fromDevUuid = folderArray[indexPath.row].devUuid
        switch sender {
        case cell.btnShow:
            print("fileId: \(fileId)")
            self.dv?.hideSelectedOptions(tag: sender.tag)
            
            let fileIdDict = ["fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":devNm]
            NotificationCenter.default.post(name: Notification.Name("getFileIdFromBtnShow"), object: self, userInfo: fileIdDict)
            
            break
        case cell.btnAction:
            self.dv?.hideSelectedOptions(tag: sender.tag)
            let url:URL = FileUtil().getFileUrl(fileNm: fileNm, amdDate: amdDate)!
            let urlDict = ["url":url]
            NotificationCenter.default.post(name: Notification.Name("openDocument"), object: self, userInfo: urlDict)
            
            print("btnActino called")
            break
            
        case cell.btnNas:
            self.dv?.hideSelectedOptions(tag: sender.tag)
            let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"toStorage":"nas","fromUserId":userId, "fromOsCd":fromOsCd,"fromDevUuid":fromDevUuid,"etsionNm":etsionNm]
            
            print("fileDict : \(fileDict)")
            
            NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
           
            
            break
            
        case cell.btnGDrive:
//            if parentView == "device" {
                self.dv?.hideSelectedOptions(tag: sender.tag)
                
                
                let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"fromDevUuid":fromDevUuid, "toStorage":"googleDrive","fromUserId":userId, "fromOsCd":fromOsCd,"etsionNm":etsionNm]
                
                print("fileDict : \(fileDict)")
                
//                deviceView.googleSignInCheck(name: fileNm, path: foldrWholePathNm, fileDict: fileDict)
                containerView.googleSignInCheck(name: fileNm, path: foldrWholePathNm, fileDict: fileDict)
//            }
            break
        case cell.btnDelete:
//            if parentView == "device" {
            self.dv?.hideSelectedOptions(tag: sender.tag)
//            }
            let alertController = UIAlertController(title: nil, message: "해당 파일을 삭제 하시겠습니까?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
                
                print("fileNm : \(fileNm)")
                if let pathForRemove:String = FileUtil().getFilePathWithFoldr(fileNm: fileNm, foldrWholePathNm:foldrWholePathNm, amdDate: amdDate)
                {
                    print("pathForRemove : \(pathForRemove)")
                    self.removeFile(path: pathForRemove)
                    if let syncOngoing:Bool = UserDefaults.standard.bool(forKey: "syncOngoing"), syncOngoing == true {
                        print("aleady Syncing")
                        
                    } else {
                        SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        let alertController = UIAlertController(title: nil, message: "파일 삭제가 완료 되였습니다.", preferredStyle: .alert)
                        let yesAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                            UIAlertAction in
                            if(viewState == .search){
                                deviceView.refreshSearchList()
                                NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
                            } else {
                                let fileDict = ["foldrId":String(foldrId)]
                                print("delete filedict : \(fileDict)")
                                NotificationCenter.default.post(name: Notification.Name("refreshInsideList"), object: self, userInfo: fileDict)
                                NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
                                
                            }
                            
                            
                        }
                        alertController.addAction(yesAction)
                        deviceView.present(alertController, animated: true)
                    })
                }
               
                
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
    
    
    func localContextMenuCalledFromGrid(indexPath:IndexPath, fileId:String, foldrWholePathNm:String, deviceName:String, parentView:String, deviceView:HomeViewController, userId:String, fromOsCd:String, currentFolderId:String, folderArray:[App.FolderStruct], intFolderArrayIndexPathRow:Int, containerView:ContainerViewController){
        let fileNm = folderArray[intFolderArrayIndexPathRow].fileNm
        let etsionNm = folderArray[intFolderArrayIndexPathRow].etsionNm
        let amdDate = folderArray[intFolderArrayIndexPathRow].amdDate
        let foldrWholePathNm = folderArray[intFolderArrayIndexPathRow].foldrWholePathNm
        let fileId = String(folderArray[intFolderArrayIndexPathRow].fileId)
        let foldrId = folderArray[intFolderArrayIndexPathRow].foldrId
        let fromOsCd = folderArray[intFolderArrayIndexPathRow].osCd
        let devNm = folderArray[intFolderArrayIndexPathRow].devNm
        let fromDevUuid = folderArray[intFolderArrayIndexPathRow].devUuid
        
        switch indexPath.row {
        case 0:
//            print("fileId: \(fileId)")
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
            let fileIdDict = ["fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":devNm]
            NotificationCenter.default.post(name: Notification.Name("getFileIdFromBtnShow"), object: self, userInfo: fileIdDict)
            break
        case 1:
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
            let url:URL = FileUtil().getFileUrl(fileNm: fileNm, amdDate: amdDate)!
            let urlDict = ["url":url]
            NotificationCenter.default.post(name: Notification.Name("openDocument"), object: self, userInfo: urlDict)
            
            print("btnActino called")
//            print("btnActino called")
            break
            
        case 2:
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
            let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"toStorage":"nas","fromUserId":userId, "fromOsCd":fromOsCd,"fromDevUuid":fromDevUuid,"etsionNm":etsionNm]
            print("fileDict : \(fileDict)")
            NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
            
            break
        case 3:
            let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"fromDevUuid":fromDevUuid, "toStorage":"googleDrive","fromUserId":userId, "fromOsCd":fromOsCd,"etsionNm":etsionNm]
//            print("fileDict : \(fileDict)")
//            GoogleWork().googleSignInCheck(name: fileNm, path: foldrWholePathNm, fileDict: fileDict)
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
            containerView.googleSignInCheck(name: fileNm, path: foldrWholePathNm, fileDict: fileDict)
            break
            
        case 4:
            let alertController = UIAlertController(title: nil, message: "해당 파일을 삭제 하시겠습니까?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
                print("foldrWholePathNm : \(foldrWholePathNm)")
                let pathForRemove:String = FileUtil().getFilePathWithFoldr(fileNm: fileNm, foldrWholePathNm:foldrWholePathNm, amdDate: amdDate)
                print("pathForRemove : \(pathForRemove)")
                self.removeFile(path: pathForRemove)
                if let syncOngoing:Bool = UserDefaults.standard.bool(forKey: "syncOngoing"), syncOngoing == true {
                    print("aleady Syncing")
                    
                } else {
                    SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
                }
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
    
    
    func removeFile(path:String){
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: path)
            
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    
}
