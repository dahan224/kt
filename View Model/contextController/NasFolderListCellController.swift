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
    var cv:UICollectionView?
    func getCell(indexPathRow:Int, folderArray:[App.FolderStruct], multiCheckListState:HomeDeviceCollectionVC.multiCheckListEnum, collectionView:UICollectionView, parentView:HomeDeviceCollectionVC) -> NasFolderListCell {
        let indexPath = IndexPath(row: indexPathRow, section: 0)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NasFolderListCell", for: indexPath) as! NasFolderListCell        
        if(folderArray[indexPath.row].foldrNm == ".."){
            cell.btnOption.isHidden = true
        }
        
        cell.ivSub.image = UIImage(named: "ico_folder")
        cell.optionSHowCheck = 0
        cell.optionHide()
        cell.lblMain.text = folderArray[indexPath.row].foldrNm
        cell.lblSub.text = folderArray[indexPath.row].amdDate
    
        if multiCheckListState == .active {
            if folderArray[indexPathRow].checked {
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
            }
            
            
        }
        return cell
    }
    
    func NasFolderContextMenuCalled(cell:NasFolderListCell, indexPath:IndexPath, sender:UIButton, folderArray:[App.FolderStruct], deviceName:String, parentView:String, deviceView:HomeDeviceCollectionVC, userId:String, fromOsCd:String, currentDevUuid:String, selectedDevUserId:String, currentFolderId:String, containerView:ContainerViewController){
        dv = deviceView
        let fileNm = folderArray[indexPath.row].fileNm
//        let etsionNm = folderArray[indexPath.row].etsionNm
        let amdDate = folderArray[indexPath.row].amdDate
        let foldrWholePathNm = folderArray[indexPath.row].foldrWholePathNm
        let fileId = String(folderArray[indexPath.row].fileId)
        let foldrId = folderArray[indexPath.row].foldrId
        let upFoldrId = folderArray[indexPath.row].upFoldrId
        let foldrNm = folderArray[indexPath.row].foldrNm
//        let devNm = folderArray[indexPath.row].devNm
        let fromOsCd = folderArray[indexPath.row].osCd
//        let fromDevUuid = folderArray[indexPath.row].devUuid
        let devUserId = folderArray[indexPath.row].userId
        
//        print("foldrId : \(foldrId), devUserId : \(devUserId)")
        
        switch sender {
        case cell.btnDwnld:
            
            self.dv?.hideSelectedOptions(tag: sender.tag)
//
            let alertController = UIAlertController(title: nil, message: "해당 폴더를 다운로드 하시겠습니까?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                ContextMenuWork().downloadFolderFromNas(foldrId: foldrId, foldrWholePathNm: foldrWholePathNm, userId:devUserId, devUuid:currentDevUuid, deviceName:deviceName, dwldFoldrNm:foldrNm)

                }
            let noAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel)
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            dv?.present(alertController, animated: true)
            break
        case cell.btnNas:
            self.dv?.hideSelectedOptions(tag: sender.tag)
            
            let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"toStorage":"nas","fromUserId":devUserId, "fromOsCd":fromOsCd,"fromDevUuid":currentDevUuid,"fromFoldrId":String(foldrId),"etsionNm":""]
            
            
            print("fileDict : \(fileDict)")
            NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
            
            
            
        case cell.btnGDrive:
            self.dv?.hideSelectedOptions(tag: sender.tag)
       
            print("folderId:\(foldrId)")
            let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"toStorage":"googleDrive","fromUserId":userId, "fromOsCd":fromOsCd,"fromDevUuid":currentDevUuid,"fromFoldrId":String(foldrId), "fromDevNm":deviceName,"etsionNm":""]
            
            print("fileDict : \(fileDict)")
            
            //                deviceView.googleSignInCheck(name: fileNm, path: foldrWholePathNm, fileDict: fileDict)
            containerView.googleSignInCheck(name: fileNm, path: foldrWholePathNm, fileDict: fileDict)
            
            break
        case cell.btnDelete:
            self.dv?.hideSelectedOptions(tag: sender.tag)
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
