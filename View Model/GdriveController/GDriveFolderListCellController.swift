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
        cell.lblSub.text = folderArray[indexPath.row].createdTime
        
        
        
        cell.btnOption.isHidden = false
        cell.btnDwnld.tag = indexPath.row
        cell.btnDwnld.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionGDriveFolderShowClicked(sender:)), for: .touchUpInside)
        cell.btnNas.tag = indexPath.row
        cell.btnNas.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionGDriveFolderShowClicked(sender:)), for: .touchUpInside)
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionGDriveFolderShowClicked(sender:)), for: .touchUpInside)
        return cell
    }
    
    func GdriveFolderContextMenuCalled(cell:GDriveFolderListCell, indexPath:IndexPath, sender:UIButton, folderArray:[App.DriveFileStruct], deviceName:String, parentView:String, deviceView:HomeDeviceCollectionVC, userId:String, fromOsCd:String, currentDevUuid:String, selectedDevUserId:String, currentFolderId:String){
        dv = deviceView
        let fileNm = folderArray[indexPath.row].name
        let etsionNm = folderArray[indexPath.row].fileExtension
        let amdDate = folderArray[indexPath.row].createdTime
        let foldrWholePathNm = folderArray[indexPath.row].foldrWholePath
        let fileId = String(folderArray[indexPath.row].fileId)
        let foldrId = folderArray[indexPath.row].fileId
        let upFoldrId = folderArray[indexPath.row].fileId
        switch sender {
        case cell.btnDwnld:
            dv?.hideSelectedOptions(tag: sender.tag)
            let alertController = UIAlertController(title: nil, message: "해당 폴더를 다운로드 하시겠습니까?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                if let googleEmail = UserDefaults.standard.string(forKey: "googleEmail"){
                    let accessToken = DbHelper().getAccessToken(email: googleEmail)
                    let downloadRootFolderName = fileNm
                    print("downloadRootFolderName : \(downloadRootFolderName), foldrWholePathNm : \(foldrWholePathNm)")
                    GoogleWork().downloadFolderFromGDrive(foldrId: foldrId, getAccessToken: accessToken, fileId: fileId, downloadRootFolderName:downloadRootFolderName)
                }
                
            }
            let noAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel)
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            dv?.present(alertController, animated: true)
            break
        case cell.btnNas:
            dv?.hideSelectedOptions(tag: sender.tag)
            print(deviceName)
            
            let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"toStorage":"nas","fromUserId":userId, "fromOsCd":"gDrive","fromDevUuid":currentDevUuid, "fromFoldrId":String(foldrId)]
            print("fileDict : \(fileDict)")
            
            NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
            break
        case cell.btnDelete:
            dv?.hideSelectedOptions(tag: sender.tag)
            let alertController = UIAlertController(title: nil, message: "해당 폴더를 삭제 하시겠습니까?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                let foldrNmArray = foldrWholePathNm.components(separatedBy: "/")
                let foldrNm:String = foldrNmArray[foldrNmArray.count - 1]
                print("foldrWholePathNm, :\(foldrWholePathNm), foldrNm : \(foldrNm), foldrNmArray:\(foldrNmArray)")
                let pathForRemove:String = FileUtil().getFilePath(fileNm: foldrNm, amdDate: amdDate)
                print("pathForRemove : \(pathForRemove)")
                self.removeFile(path: pathForRemove)
                SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    let alertController = UIAlertController(title: nil, message: "파일 삭제가 완료 되였습니다.", preferredStyle: .alert)
                    let yesAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        let fileDict = ["foldrId":String(foldrId)]
                        print("delete filedict : \(fileDict)")
                        NotificationCenter.default.post(name: Notification.Name("refreshInsideList"), object: self, userInfo: fileDict)
                        
                        
                    }
                    alertController.addAction(yesAction)
                    self.dv?.present(alertController, animated: true)
                })
                //
                
                
            }
            let noAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel)
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            dv?.present(alertController, animated: true)
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
