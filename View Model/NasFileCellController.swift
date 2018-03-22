//
//  NasFileCellController.swift
//  KT
//
//  Created by 이다한 on 2018. 3. 12..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit

class NasFileCellController {
    var dv:HomeDeviceCollectionVC?
    var hv:HomeViewController?
    var cv:UICollectionView?
    func getCell(indexPathRow:Int, folderArray:[App.FolderStruct], multiCheckListState:HomeDeviceCollectionVC.multiCheckListEnum, collectionView:UICollectionView, parentView:HomeDeviceCollectionVC, deviceName:String) -> NasFileListCell {
        let indexPath = IndexPath(row: indexPathRow, section: 0)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NasFileListCell", for: indexPath) as! NasFileListCell
        
        if(folderArray[indexPath.row].foldrNm == "..."){
            cell.btnOption.isHidden = true
        }
        let imageString = Util.getFileImageString(fileExtension: folderArray[indexPath.row].etsionNm)
        
        cell.ivSub.image = UIImage(named: imageString)
        cell.optionSHowCheck = 0
        cell.optionHide()
        cell.lblMain.text = folderArray[indexPath.row].fileNm
        cell.lblSub.text = folderArray[indexPath.row].amdDate
        
        
        cell.btnOption.isHidden = false
        cell.btnShow.tag = indexPath.row
        cell.btnShow.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionNasFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnAction.tag = indexPath.row
        cell.btnAction.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionNasFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnDwnld.tag = indexPath.row
        cell.btnDwnld.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionNasFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnNas.tag = indexPath.row
        cell.btnNas.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionNasFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnGDrive.tag = indexPath.row
        cell.btnGDrive.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionNasFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionNasFileShowClicked(sender:)), for: .touchUpInside)
        return cell
    }

    
    func nasContextMenuCalled(cell:NasFileListCell, indexPath:IndexPath, sender:UIButton, folderArray:[App.FolderStruct], deviceName:String, parentView:String, deviceView:HomeDeviceCollectionVC, userId:String, fromOsCd:String, currentDevUuid:String, selectedDevUserId:String, currentFolderId:String){
        dv = deviceView
        let fileNm = folderArray[indexPath.row].fileNm
        let etsionNm = folderArray[indexPath.row].etsionNm
        let foldrWholePathNm = folderArray[indexPath.row].foldrWholePathNm
        let fileId = String(folderArray[indexPath.row].fileId)
        let foldrId = String(folderArray[indexPath.row].foldrId)
        let amdDate = folderArray[indexPath.row].amdDate
        dv?.showNasFileOption(tag: sender.tag)
        switch sender {
        case cell.btnShow:
            let fileIdDict = ["fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":deviceName]
            NotificationCenter.default.post(name: Notification.Name("getFileIdFromBtnShow"), object: self, userInfo: fileIdDict)
            
            
            break
        case cell.btnDwnld:
            
            dv?.downloadFromNas(name: fileNm, path: foldrWholePathNm, fileId:fileId)
            
        case cell.btnNas:
                let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"toStorage":"nas","fromUserId":userId, "fromOsCd":fromOsCd,"fromDevUuid":currentDevUuid]
                
                NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
                dv?.showNasFileOption(tag: sender.tag)                    
            break
            
        case cell.btnGDrive:
            
//            dv?.googleSignInCheck(name: fileNm, path: foldrWholePathNm)
            
            break
            
        case cell.btnDelete:
            let alertController = UIAlertController(title: nil, message: "해당 파일을 삭제 하시겠습니까?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                //Do you Success button Stuff here
                let params = ["userId":userId,"devUuid":currentDevUuid,"fileId":fileId,"fileNm":fileNm,"foldrWholePathNm": foldrWholePathNm]
                self.dv?.deleteNasFile(param: params, foldrId: foldrId)
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
    
    func nasFileContextMenuCalledFromGrid(indexPath:IndexPath, fileId:String, foldrWholePathNm:String, deviceName:String, parentView:String, deviceView:HomeViewController, userId:String, fromOsCd:String, currentDevUuid:String, currentFolderId:String, folderArray:[App.FolderStruct], intFolderArrayIndexPathRow:Int){
        let fileNm = folderArray[intFolderArrayIndexPathRow].fileNm
        //        let etsionNm = folderArray[intFolderArrayIndexPathRow].etsionNm
        let amdDate = folderArray[intFolderArrayIndexPathRow].amdDate
        let foldrWholePathNm = folderArray[intFolderArrayIndexPathRow].foldrWholePathNm
        let fileId = String(folderArray[intFolderArrayIndexPathRow].fileId)
        let foldrId = String(folderArray[intFolderArrayIndexPathRow].foldrId)
        hv = deviceView
        switch indexPath.row {
            case 0 :
                //파일 상세보기
                let fileIdDict = ["fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":deviceName]
                NotificationCenter.default.post(name: Notification.Name("getFileIdFromBtnShow"), object: self, userInfo: fileIdDict)
                NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
                break
            case 1:
                
                //다운로드
                hv?.downloadFromNas(name: fileNm, path: foldrWholePathNm, fileId:fileId)
                break
            
            case 2:
                
                // nas로 보내기
                let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"toStorage":"nas","fromUserId":userId, "fromOsCd":fromOsCd,"fromDevUuid":currentDevUuid]
                
                NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
                
                let fileIdDict = ["fileId":"0"]
                NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self, userInfo: fileIdDict)
                break
            case 3:
                //gdrive로 보내기
                
                break
            case 4:
                
                // 삭제
                let alertController = UIAlertController(title: nil, message: "해당 파일을 삭제 하시겠습니까?", preferredStyle: .alert)
                let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    //Do you Success button Stuff here
                    let params = ["userId":userId,"devUuid":currentDevUuid,"fileId":fileId,"fileNm":fileNm,"foldrWholePathNm": foldrWholePathNm]
                    self.hv?.deleteNasFile(param: params, foldrId: foldrId)
                }
                let noAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel)
                alertController.addAction(yesAction)
                alertController.addAction(noAction)
                hv?.present(alertController, animated: true)
                
            break
            
            default :
            
            break
            }
        
    }
  
}


