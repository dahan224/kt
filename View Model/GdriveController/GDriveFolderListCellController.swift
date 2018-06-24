//
//  GDriveFolderListCellController.swift
//  KT
//
//  Created by 김영은 on 2018. 3. 21..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class GDriveFolderListCellController {
    
    var dv:HomeDeviceCollectionVC?
    
    func getCell(indexPathRow:Int, folderArray:[App.DriveFileStruct], multiCheckListState:HomeDeviceCollectionVC.multiCheckListEnum, collectionView:UICollectionView, parentView:HomeDeviceCollectionVC) -> GDriveFolderListCell {
        let indexPath = IndexPath(row: indexPathRow, section: 0)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GDriveFolderListCell", for: indexPath) as! GDriveFolderListCell
        
       if(folderArray[indexPath.row].name == ".."){
            cell.btnOption.isHidden = true
        }
        
        cell.ivSub.image = UIImage(named: "ico_folder")
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
    
    func GdriveFolderContextMenuCalled(cell:GDriveFolderListCell, indexPath:IndexPath, sender:UIButton, folderArray:[App.DriveFileStruct], deviceName:String, parentView:String, deviceView:HomeDeviceCollectionVC, userId:String, fromOsCd:String, currentDevUuid:String, selectedDevUserId:String, currentFolderId:String, containerViewController:ContainerViewController){
        dv = deviceView
        let fileNm = folderArray[indexPath.row].name
        let etsionNm = folderArray[indexPath.row].fileExtension
        let amdDate = folderArray[indexPath.row].createdTime
        let foldrWholePathNm = folderArray[indexPath.row].foldrWholePath
        let fileId = String(folderArray[indexPath.row].fileId)
        let foldrId = folderArray[indexPath.row].fileId
        let upFoldrId = folderArray[indexPath.row].fileId
        let mimeType = folderArray[indexPath.row].mimeType
        switch sender {
        case cell.btnDwnld:
            dv?.hideSelectedOptions(tag: sender.tag)
            let alertController = UIAlertController(title: nil, message: "해당 폴더를 다운로드 하시겠습니까?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                    let accessToken = UserDefaults.standard.string(forKey: "googleAccessToken")!
                    let downloadRootFolderName = fileNm
                    print("downloadRootFolderName : \(downloadRootFolderName), foldrWholePathNm : \(foldrWholePathNm)")
                    containerViewController.showIndicator()
                    GoogleWork().downloadFolderFromGDrive(foldrId: foldrId, getAccessToken: accessToken, fileId: fileId, downloadRootFolderName:downloadRootFolderName, containerViewController:containerViewController)
                
            }
            let noAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel)
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            dv?.present(alertController, animated: true)
            break
        case cell.btnNas:
            dv?.hideSelectedOptions(tag: sender.tag)
            print(deviceName)
            
            let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"toStorage":"nas","fromUserId":userId, "fromOsCd":"gDrive","fromDevUuid":currentDevUuid, "fromFoldrId":String(foldrId),"etsionNm":"", "mimeType":mimeType]
            print("fileDict : \(fileDict)")
            
            NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
            break
        case cell.btnDelete:
            dv?.hideSelectedOptions(tag: sender.tag)
            containerViewController.showIndicator()
            if parentView == "device" {
                let alertController = UIAlertController(title: nil, message: "해당 폴더를 삭제 하시겠습니까?", preferredStyle: .alert)
                let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    GoogleWork().deleteGDriveFile(fileId: fileId)
                    containerViewController.showIndicator()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        if(currentFolderId == "root" || currentFolderId.isEmpty){
                            let accessToken = UserDefaults.standard.string(forKey: "googleAccessToken")!
                            containerViewController.getFiles(accessToken: accessToken, root: "root")
                            
                        } else {
                            
                            deviceView.showInsideListGDrive(userId: userId, devUuid: currentDevUuid, foldrId: currentFolderId, deviceName: deviceName)
                            
                        }
                        let alertController = UIAlertController(title: nil, message: "파일 삭제가 완료 되였습니다.", preferredStyle: .alert)
                        let yesAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                            UIAlertAction in
                            containerViewController.finishLoading()
                            
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
