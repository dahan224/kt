//
//  LocalFolderListCellController.swift
//  KT
//
//  Created by 이다한 on 2018. 3. 16..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class LocalFolderListCellController {
    var dv:HomeDeviceCollectionVC?
    
    func getCell(indexPathRow:Int, folderArray:[App.FolderStruct], multiCheckListState:HomeDeviceCollectionVC.multiCheckListEnum, collectionView:UICollectionView, parentView:HomeDeviceCollectionVC) -> LocalFolderListCell {
        let indexPath = IndexPath(row: indexPathRow, section: 0)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LocalFolderListCell", for: indexPath) as! LocalFolderListCell
    
        if(folderArray[indexPath.row].foldrNm == ".."){
            cell.btnOption.isHidden = true
        }
        
        cell.ivSub.image = UIImage(named: "ico_folder")
        cell.optionSHowCheck = 0
        cell.optionHide()
        cell.lblMain.text = folderArray[indexPath.row].foldrNm
        cell.lblSub.text = folderArray[indexPath.row].amdDate
        
        
        
        cell.btnOption.isHidden = false
        cell.btnNas.tag = indexPath.row
        cell.btnNas.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionLocalFolderShowClicked(sender:)), for: .touchUpInside)
        cell.btnGDrive.tag = indexPath.row
        cell.btnGDrive.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionLocalFolderShowClicked(sender:)), for: .touchUpInside)
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionLocalFolderShowClicked(sender:)), for: .touchUpInside)
        return cell
    }
    
    func LocalFolderContextMenuCalled(cell:LocalFolderListCell, indexPath:IndexPath, sender:UIButton, folderArray:[App.FolderStruct], deviceName:String, parentView:String, deviceView:HomeDeviceCollectionVC, userId:String, fromOsCd:String, currentDevUuid:String, selectedDevUserId:String, currentFolderId:String, containerView:ContainerViewController){
        dv = deviceView
        let fileNm = folderArray[indexPath.row].fileNm
        let etsionNm = folderArray[indexPath.row].etsionNm
        let amdDate = folderArray[indexPath.row].amdDate
        let foldrWholePathNm = folderArray[indexPath.row].foldrWholePathNm
        let fileId = String(folderArray[indexPath.row].fileId)
        let foldrId = folderArray[indexPath.row].foldrId
        let upFoldrId = folderArray[indexPath.row].upFoldrId
        switch sender {
        case cell.btnNas:
            print(deviceName)
            dv?.hideSelectedOptions(tag: sender.tag)
            let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"toStorage":"nas","fromUserId":userId, "fromOsCd":fromOsCd,"fromDevUuid":currentDevUuid,"fromFoldrId":String(foldrId)]
            
            print("fileDict : \(fileDict)")
            NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
            
            
            
            
        case cell.btnGDrive:
            dv?.hideSelectedOptions(tag: sender.tag)
             let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"fromDevUuid":currentDevUuid, "toStorage":"googleDrive","fromUserId":userId, "fromOsCd":fromOsCd,"fromFoldrId":String(foldrId)]
            print("fileDict : \(fileDict)")
            
            containerView.googleSignInSegueState = .loginForSend
            containerView.googleSignInCheck(name: fileNm, path: foldrWholePathNm, fileDict: fileDict)
            break
        case cell.btnDelete:
            dv?.hideSelectedOptions(tag: sender.tag)
            let alertController = UIAlertController(title: nil, message: "해당 폴더를 삭제 하시겠습니까?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                let foldrNmArray = foldrWholePathNm.components(separatedBy: "/")
                let foldrNm:String = foldrNmArray[foldrNmArray.count - 1]
                print("foldrWholePathNm, :\(foldrWholePathNm), foldrNm : \(foldrNm), foldrNmArray:\(foldrNmArray)")
                print("fileId : \(fileId), foldrId : \(foldrId), currentFolderId : \(currentFolderId)")
//                let pathForRemove:String = FileUtil().getFilePath(fileNm: foldrNm, amdDate: amdDate)
//                    print("pathForRemove : \(pathForRemove)")
                let pathForRemove:String = FileUtil().getFolderPathWithFoldr(fileNm: foldrNm, foldrWholePathNm:foldrWholePathNm, amdDate: amdDate)
                FileUtil().removeFile(path: pathForRemove)

                SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    let alertController = UIAlertController(title: nil, message: "파일 삭제가 완료 되였습니다.", preferredStyle: .alert)
                    let yesAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        let fileDict = ["foldrId":currentFolderId]
                        print("delete filedict : \(fileDict)")
                        NotificationCenter.default.post(name: Notification.Name("refreshInsideList"), object: self, userInfo: fileDict)


                    }
                    alertController.addAction(yesAction)
                    self.dv?.present(alertController, animated: true)
                })

                
                
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
    
    
  
}
