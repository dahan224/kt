//
//  RemoteFileListCellController.swift
//  KT
//
//  Created by 이다한 on 2018. 3. 14..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit

class RemoteFileListCellController {
    
    func getCell(indexPathRow:Int, folderArray:[App.FolderStruct], multiCheckListState:HomeDeviceCollectionVC.multiCheckListEnum, collectionView:UICollectionView, parentView:HomeDeviceCollectionVC) -> RemoteFileListCell {
        let indexPath = IndexPath(row: indexPathRow, section: 0)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RemoteFileListCell", for: indexPath) as! RemoteFileListCell
        
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
        let imageString = Util.getFileImageString(fileExtension: folderArray[indexPath.row].etsionNm)
        
        cell.ivSub.image = UIImage(named: imageString)
        cell.optionSHowCheck = 0
        cell.optionHide()
        cell.lblMain.text = folderArray[indexPath.row].fileNm
        cell.lblSub.text = folderArray[indexPath.row].amdDate
//        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(cellSwipeToLeft(sender:)))
//        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
//        cell.btnOption.addGestureRecognizer(swipeLeft)
        cell.btnOption.tag = indexPath.row
        cell.btnOption.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnRemoteFileOptionClicked(sender:)), for: .touchUpInside)
        
//        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(cellSwipeToLeft(sender:)))
//        rightSwipe.direction = UISwipeGestureRecognizerDirection.right
//        cell.btnOptionRed.addGestureRecognizer(rightSwipe)
        cell.btnOptionRed.tag = indexPath.row
        cell.btnOptionRed.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnRemoteFileOptionClicked(sender:)), for: .touchUpInside)
        
        
        cell.btnOption.isHidden = false
        cell.btnShow.tag = indexPath.row
        cell.btnShow.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionRemoteFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnAction.tag = indexPath.row
        cell.btnAction.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionRemoteFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnDwnld.tag = indexPath.row
        cell.btnDwnld.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionRemoteFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnNas.tag = indexPath.row
        cell.btnNas.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionRemoteFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnGDrive.tag = indexPath.row
        cell.btnGDrive.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionRemoteFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionRemoteFileShowClicked(sender:)), for: .touchUpInside)
        return cell
    }
    
    func remoteFileContextMenuCalled(cell:RemoteFileListCell, indexPath:IndexPath, sender:UIButton, folderArray:[App.FolderStruct], deviceName:String, parentView:String, deviceView:HomeDeviceCollectionVC, userId:String, fromOsCd:String, currentDevUuid:String, currentFolderId:String){
        let fileNm = folderArray[indexPath.row].fileNm
        let etsionNm = folderArray[indexPath.row].etsionNm
        let amdDate = folderArray[indexPath.row].amdDate
        let foldrWholePathNm = folderArray[indexPath.row].foldrWholePathNm
        let fileId = String(folderArray[indexPath.row].fileId)
        var btn = "show"
        switch sender {
        case cell.btnShow:
            btn = "show"
            print("fileId: \(fileId)")
            let fileIdDict = ["fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":deviceName]
            NotificationCenter.default.post(name: Notification.Name("getFileIdFromBtnShow"), object: self, userInfo: fileIdDict)
            break
        case cell.btnDwnld:
            
//            HomeDeviceCollectionVC().downloadFromNas(name: fileNm, path: foldrWholePathNm, fileId:fileId)
            ContextMenuWork().downloadFromNas(userId:userId, fileNm:fileNm, path:foldrWholePathNm, fileId:fileId){ responseObject, error in
                if let success = responseObject {
                    print(success)
                    if(success == "success"){
                        SyncLocalFilleToNas().sync()
                        DispatchQueue.main.async {
                            let alertController = UIAlertController(title: nil, message: "파일 다운로드를 성공하였습니다.", preferredStyle: .alert)
                            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel)
                            alertController.addAction(yesAction)
                            deviceView.present(alertController, animated: true)
                        }
                    }
                }
                return
            }
            print("btnActino called")
            break
            
        case cell.btnNas:
            
            let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"state":"local","fromUserId":userId, "fromOsCd":fromOsCd]
            print("fileDict : \(fileDict)")
            NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
            if parentView == "device" {
                deviceView.showLocalFileOption(tag: sender.tag)
            }
            
            break
            
       
        default:
            break
        }
    }
    
    
  
}
