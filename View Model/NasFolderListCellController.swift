//
//  NasFolderListCellController.swift
//  KT
//
//  Created by 이다한 on 2018. 3. 16..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import SwiftyJSON

class NasFolderListCellController {
    var dv:HomeDeviceCollectionVC?
    
    func getCell(indexPathRow:Int, folderArray:[App.FolderStruct], multiCheckListState:HomeDeviceCollectionVC.multiCheckListEnum, collectionView:UICollectionView, parentView:HomeDeviceCollectionVC) -> NasFolderListCell {
        let indexPath = IndexPath(row: indexPathRow, section: 0)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NasFolderListCell", for: indexPath) as! NasFolderListCell
        
        if (multiCheckListState == .active){
            cell.btnMultiCheck.isHidden = false
            cell.btnMultiCheck.tag = indexPath.row
            cell.btnMultiCheck.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnMultiCheckClicked(sender:)), for: .touchUpInside)
            cell.btnOption.isHidden = true
            
        } else {
            cell.btnOption.isHidden = false
            cell.btnMultiCheck.isHidden = true
        }
        if(folderArray[indexPath.row].foldrNm == "..."){
            cell.btnOption.isHidden = true
        }
        
        cell.ivSub.image = UIImage(named: "ico_folder")
        cell.optionSHowCheck = 0
        cell.optionHide()
        cell.lblMain.text = folderArray[indexPath.row].foldrNm
        cell.lblSub.text = folderArray[indexPath.row].amdDate
    
        cell.btnOption.isHidden = false
        cell.btnShow.tag = indexPath.row
        cell.btnShow.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionNasFolderShowClicked(sender:)), for: .touchUpInside)
        cell.btnDwnld.tag = indexPath.row
        cell.btnDwnld.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionNasFolderShowClicked(sender:)), for: .touchUpInside)
        cell.btnNas.tag = indexPath.row
        cell.btnNas.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionNasFolderShowClicked(sender:)), for: .touchUpInside)
        cell.btnGDrive.tag = indexPath.row
        cell.btnGDrive.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionNasFolderShowClicked(sender:)), for: .touchUpInside)
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionNasFolderShowClicked(sender:)), for: .touchUpInside)
        return cell
    }
    
    func NasFolderContextMenuCalled(cell:NasFolderListCell, indexPath:IndexPath, sender:UIButton, folderArray:[App.FolderStruct], deviceName:String, parentView:String, deviceView:HomeDeviceCollectionVC, userId:String, fromOsCd:String, currentDevUuid:String, selectedDevUserId:String, currentFolderId:String){
        dv = deviceView
        let fileNm = folderArray[indexPath.row].fileNm
        let etsionNm = folderArray[indexPath.row].etsionNm
        let amdDate = folderArray[indexPath.row].amdDate
        let foldrWholePathNm = folderArray[indexPath.row].foldrWholePathNm
        let fileId = String(folderArray[indexPath.row].fileId)
        let foldrId = folderArray[indexPath.row].foldrId
        let upFoldrId = folderArray[indexPath.row].upFoldrId
        self.dv?.showNasFolderOption(tag: sender.tag)
        switch sender {
        case cell.btnDwnld:
            let alertController = UIAlertController(title: nil, message: "해당 폴더를 다운로드 하시겠습니까?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                ContextMenuWork().downloadFolderFromNas(foldrId: foldrId, foldrWholePathNm: foldrWholePathNm, userId:userId, devUuid:currentDevUuid, deviceName:deviceName)
                
                }
            let noAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel)
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            dv?.present(alertController, animated: true)
            break
        case cell.btnNas:
            let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"toStorage":"nas","fromUserId":userId, "fromOsCd":fromOsCd,"fromDevUuid":currentDevUuid,"fromFoldrId":String(foldrId)]
            
            print("fileDict : \(fileDict)")
            NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
            
            
            
        case cell.btnGDrive:
            
//            self.googleSignInCheck(name: fileNm, path: foldrWholePathNm)
//            showOptionMenu(sender: sender, style: 0)
            break
        case cell.btnDelete:
            let alertController = UIAlertController(title: nil, message: "해당 폴더를 삭제 하시겠습니까?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                
                let param:[String:Any] = ["userId":userId, "foldrId":foldrId, "foldrWholePathNm":foldrWholePathNm]
                ContextMenuWork().removeNasFolder(parameters:param){ responseObject, error in
                    if let obj = responseObject {
                        print(obj)
                        let json = JSON(obj)
                        let message = obj.object(forKey: "message")
                        print("\(String(describing: message)), \(String(describing: json["statusCode"].int))")
                        if let statusCode = json["statusCode"].int, statusCode == 100 {
                            DispatchQueue.main.async {
                                self.dv?.showNasFolderOption(tag: sender.tag)
                                print("upFoldrId : \(upFoldrId)")
                                self.dv?.showInsideList(userId: userId, devUuid: currentDevUuid, foldrId: String(upFoldrId), deviceName: deviceName)
                                let alertController = UIAlertController(title: nil, message: "폴더 삭제가 완료 되었습니다.", preferredStyle: .alert)
                                let yesAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                                    UIAlertAction in
                                    
                                    
                                }
                                alertController.addAction(yesAction)
                                self.dv?.present(alertController, animated: true)
                            }
                        }
                    }
                    
                    
                    return
                }
                
                
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
