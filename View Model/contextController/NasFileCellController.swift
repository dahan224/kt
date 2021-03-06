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
    var downloadBtnClicked = false
    func getCell(indexPathRow:Int, folderArray:[App.FolderStruct], multiCheckListState:HomeDeviceCollectionVC.multiCheckListEnum, collectionView:UICollectionView, parentView:HomeDeviceCollectionVC, deviceName:String, viewState:HomeViewController.viewStateEnum) -> NasFileListCell {
        let indexPath = IndexPath(row: indexPathRow, section: 0)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NasFileListCell", for: indexPath) as! NasFileListCell
        
        if(folderArray[indexPath.row].foldrNm == ".."){
            cell.btnOption.isHidden = true
        }
        let imageString = Util.getFileImageString(fileExtension: folderArray[indexPath.row].etsionNm)
        let fileThumbYn = folderArray[indexPath.row].fileThumbYn
        if fileThumbYn == "Y" {
            
        } else {
            
        }
        
        
        cell.ivSub.image = UIImage(named: imageString)
        cell.optionSHowCheck = 0
        cell.optionHide()
        cell.lblMain.text = folderArray[indexPath.row].fileNm
        cell.lblSub.text = folderArray[indexPath.row].amdDate
        if(viewState == .search || viewState == .lately){
            cell.lblDevice.isHidden = false
            cell.lblDevice.text = folderArray[indexPath.row].devNm
        } else {
            cell.lblDevice.isHidden = false
            let size = FileUtil().covertFileSize(getSize: folderArray[indexPath.row].fileSize)
            cell.lblDevice.text = size
        }
  
        if multiCheckListState == .active {
            if folderArray[indexPathRow].checked {
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
            }
        
            
        }
        

        return cell
    }

    
    func nasContextMenuCalled(cell:NasFileListCell, indexPath:IndexPath, sender:UIButton, folderArray:[App.FolderStruct], deviceName:String, parentView:String, deviceView:HomeDeviceCollectionVC, userId:String, currentFolderId:String, containerView:ContainerViewController){
        dv = deviceView
         let fileNm = folderArray[indexPath.row].fileNm
        let etsionNm = folderArray[indexPath.row].etsionNm
        let foldrWholePathNm = folderArray[indexPath.row].foldrWholePathNm
        let fileId = String(folderArray[indexPath.row].fileId)
        let foldrId = String(folderArray[indexPath.row].foldrId)
        let amdDate = folderArray[indexPath.row].amdDate
        let devNm = folderArray[indexPath.row].devNm
        let fromOsCd = folderArray[indexPath.row].osCd
        let fromDevUuid = folderArray[indexPath.row].devUuid
        let fileThumbYn = folderArray[indexPath.row].fileThumbYn
        let devUserId = folderArray[indexPath.row].userId
        print("devUserId : \(devUserId)")
        switch sender {
        case cell.btnShow:
//            dv?.showNasFileOption(tag: sender.tag)
            dv?.hideSelectedOptions(tag: sender.tag)
            print("nas btnShow clicked")
//            let fileIdDict = ["fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":devNm]
            let fileIdDict = ["fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":devNm, "fileThumbYn":fileThumbYn]
            NotificationCenter.default.post(name: Notification.Name("getFileIdFromBtnShow"), object: self, userInfo: fileIdDict)
            
            
            break
        case cell.btnDwnld:
            
            dv?.hideSelectedOptions(tag: sender.tag)
         
//            let alertController = UIAlertController(title: nil, message: "해당 파일을 다운로드 하시겠습니까?", preferredStyle: .alert)
//            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
//                UIAlertAction in
                //Do you Success button Stuff here
            self.dv?.downloadFromNas(name: fileNm, path: foldrWholePathNm, fileId:fileId, devUserId:devUserId)
//            }
//            let noAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel)
//            alertController.addAction(yesAction)
//            alertController.addAction(noAction)
//            dv?.present(alertController, animated: true)
            
            
        case cell.btnNas:
            dv?.hideSelectedOptions(tag: sender.tag)
            let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"toStorage":"nas","fromUserId":userId, "fromOsCd":fromOsCd,"fromDevUuid":fromDevUuid,"etsionNm":etsionNm]
//            print("fileDict : \(fileDict)")
            NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
            
            break
            
        case cell.btnGDrive:
            dv?.hideSelectedOptions(tag: sender.tag)
//            dv?.googleSignInCheck(name: fileNm, path: foldrWholePathNm)
            let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"fromDevUuid":fromDevUuid, "toStorage":"googleDrive","fromUserId":userId, "fromOsCd":fromOsCd,"etsionNm":etsionNm]
            print("fileDict : \(fileDict)")
            
            //                deviceView.googleSignInCheck(name: fileNm, path: foldrWholePathNm, fileDict: fileDict)
            
            containerView.googleSignInCheck(name: fileNm, path: foldrWholePathNm, fileDict: fileDict)
            
            break
            
        case cell.btnDelete:
            dv?.hideSelectedOptions(tag: sender.tag)
            let alertController = UIAlertController(title: nil, message: "해당 파일을 삭제 하시겠습니까?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                //Do you Success button Stuff here
                let params = ["userId":userId,"devUuid":fromDevUuid,"fileId":fileId,"fileNm":fileNm,"foldrWholePathNm": foldrWholePathNm]
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
    
    func nasFileContextMenuCalledFromGrid(indexPath:IndexPath, fileId:String, foldrWholePathNm:String, deviceName:String, parentView:String, deviceView:HomeViewController, userId:String, fromOsCd:String, currentFolderId:String, folderArray:[App.FolderStruct], intFolderArrayIndexPathRow:Int, containerView:ContainerViewController){
        let fileNm = folderArray[intFolderArrayIndexPathRow].fileNm
        let etsionNm = folderArray[intFolderArrayIndexPathRow].etsionNm
        let amdDate = folderArray[intFolderArrayIndexPathRow].amdDate
        let foldrWholePathNm = folderArray[intFolderArrayIndexPathRow].foldrWholePathNm
        let fileId = String(folderArray[intFolderArrayIndexPathRow].fileId)
        let foldrId = String(folderArray[intFolderArrayIndexPathRow].foldrId)
        let devNm = folderArray[intFolderArrayIndexPathRow].devNm
        let fromOsCd = folderArray[intFolderArrayIndexPathRow].osCd
        let fromDevUuid = folderArray[intFolderArrayIndexPathRow].devUuid
        let fileThumbYn = folderArray[intFolderArrayIndexPathRow].fileThumbYn
        
        hv = deviceView
        switch indexPath.row {
            case 0 :
                //파일 상세보기
                NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
                let fileIdDict = ["fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":devNm, "fileThumbYn":fileThumbYn]
                NotificationCenter.default.post(name: Notification.Name("getFileIdFromBtnShow"), object: self, userInfo: fileIdDict)
                
                break
            case 1:
                
                //다운로드
                NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
                hv?.downloadFromNas(name: fileNm, path: foldrWholePathNm, fileId:fileId)
                break
            
            case 2:
                
                // nas로 보내기
                let fileIdDict = ["fileId":"0"]
                NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self, userInfo: fileIdDict)
                
                let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"toStorage":"nas","fromUserId":userId, "fromOsCd":fromOsCd,"fromDevUuid":fromDevUuid,"etsionNm":etsionNm]
                
                print("fileDict : \(fileDict)")
                NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)

                
                
                break
            case 3:
                //gdrive로 보내기
                let fileIdDict = ["fileId":"0"]
                NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self, userInfo: fileIdDict)
                
                let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"fromDevUuid":fromDevUuid, "toStorage":"googleDrive","fromUserId":userId, "fromOsCd":fromOsCd,"etsionNm":etsionNm]
                print("fileDict : \(fileDict)")
                
                containerView.googleSignInCheck(name: fileNm, path: foldrWholePathNm, fileDict: fileDict)
                
                break
            case 4:
                
                // 삭제
                let alertController = UIAlertController(title: nil, message: "해당 파일을 삭제 하시겠습니까?", preferredStyle: .alert)
                let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    //Do you Success button Stuff here
                    let params = ["userId":userId,"devUuid":fromDevUuid,"fileId":fileId,"fileNm":fileNm,"foldrWholePathNm": foldrWholePathNm]
                    
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
    func nasFileContextMenuCalledFromLatelyGrid(indexPath:IndexPath, fileId:String, foldrWholePathNm:String, deviceName:String, parentView:String, deviceView:LatelyUpdatedFileViewController, userId:String, fromOsCd:String, currentFolderId:String, folderArray:[App.FolderStruct], intFolderArrayIndexPathRow:Int, containerView:ContainerViewController){
        let fileNm = folderArray[intFolderArrayIndexPathRow].fileNm
        let etsionNm = folderArray[intFolderArrayIndexPathRow].etsionNm
        let amdDate = folderArray[intFolderArrayIndexPathRow].amdDate
        let foldrWholePathNm = folderArray[intFolderArrayIndexPathRow].foldrWholePathNm
        let fileId = String(folderArray[intFolderArrayIndexPathRow].fileId)
        let foldrId = String(folderArray[intFolderArrayIndexPathRow].foldrId)
        let devNm = folderArray[intFolderArrayIndexPathRow].devNm
        let fromOsCd = folderArray[intFolderArrayIndexPathRow].osCd
        let fromDevUuid = folderArray[intFolderArrayIndexPathRow].devUuid
        let fileThumbYn = folderArray[intFolderArrayIndexPathRow].fileThumbYn
        
        switch indexPath.row {
        case 0 :
            //파일 상세보기
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
            let fileIdDict = ["fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":devNm, "fileThumbYn":fileThumbYn]
            NotificationCenter.default.post(name: Notification.Name("getFileIdFromBtnShow"), object: self, userInfo: fileIdDict)
            
            break
        case 1:
            
            //다운로드
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
            deviceView.downloadFromNas(name: fileNm, path: foldrWholePathNm, fileId:fileId)
            break
            
        case 2:
            
            // nas로 보내기
            let fileIdDict = ["fileId":"0"]
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self, userInfo: fileIdDict)
            
            let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"toStorage":"nas","fromUserId":userId, "fromOsCd":fromOsCd,"fromDevUuid":fromDevUuid,"etsionNm":etsionNm]
            
            print("fileDict : \(fileDict)")
            NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
            
            
            
            break
        case 3:
            //gdrive로 보내기
            let fileIdDict = ["fileId":"0"]
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self, userInfo: fileIdDict)
            
            let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"fromDevUuid":fromDevUuid, "toStorage":"googleDrive","fromUserId":userId, "fromOsCd":fromOsCd,"etsionNm":etsionNm]
            print("fileDict : \(fileDict)")
            
            containerView.googleSignInCheck(name: fileNm, path: foldrWholePathNm, fileDict: fileDict)
            
            break
        case 4:
            
            // 삭제
            let alertController = UIAlertController(title: nil, message: "해당 파일을 삭제 하시겠습니까?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                //Do you Success button Stuff here
                let params = ["userId":userId,"devUuid":fromDevUuid,"fileId":fileId,"fileNm":fileNm,"foldrWholePathNm": foldrWholePathNm]
                
                deviceView.deleteNasFile(param: params, foldrId: foldrId)
                
            }
            let noAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel)
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            deviceView.present(alertController, animated: true)
            
            break
            
        default :
            
            break
        }
        
    }
    
    func nasContextMenuCalledFromLately(cell:NasFileListCell, indexPath:IndexPath, sender:UIButton, folderArray:[App.FolderStruct], deviceName:String, parentView:String, deviceView:LatelyUpdatedFileViewController, userId:String, currentFolderId:String, containerView:ContainerViewController){
        let fileNm = folderArray[indexPath.row].fileNm
        let etsionNm = folderArray[indexPath.row].etsionNm
        let foldrWholePathNm = folderArray[indexPath.row].foldrWholePathNm
        let fileId = String(folderArray[indexPath.row].fileId)
        let foldrId = String(folderArray[indexPath.row].foldrId)
        let amdDate = folderArray[indexPath.row].amdDate
        let devNm = folderArray[indexPath.row].devNm
        let fromOsCd = folderArray[indexPath.row].osCd
        let fromDevUuid = folderArray[indexPath.row].devUuid
        let fileThumbYn = folderArray[indexPath.row].fileThumbYn
        
        switch sender {
        case cell.btnShow:
            //            dv?.showNasFileOption(tag: sender.tag)
            dv?.hideSelectedOptions(tag: sender.tag)
            print("nas btnShow clicked")
            //            let fileIdDict = ["fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":devNm]
            let fileIdDict = ["fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":devNm, "fileThumbYn":fileThumbYn]
            NotificationCenter.default.post(name: Notification.Name("getFileIdFromBtnShow"), object: self, userInfo: fileIdDict)
            
            
            break
        case cell.btnDwnld:
            
            dv?.hideSelectedOptions(tag: sender.tag)
            deviceView.downloadFromNas(name: fileNm, path: foldrWholePathNm, fileId:fileId)
            
        case cell.btnNas:
            dv?.hideSelectedOptions(tag: sender.tag)
            let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"toStorage":"nas","fromUserId":userId, "fromOsCd":fromOsCd,"fromDevUuid":fromDevUuid,"etsionNm":etsionNm]
            //            print("fileDict : \(fileDict)")
            NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
            
            break
            
        case cell.btnGDrive:
            self.dv?.hideSelectedOptions(tag: sender.tag)
            //            dv?.googleSignInCheck(name: fileNm, path: foldrWholePathNm)
            let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"fromDevUuid":fromDevUuid, "toStorage":"googleDrive","fromUserId":userId, "fromOsCd":fromOsCd,"etsionNm":etsionNm]
            print("fileDict : \(fileDict)")
            
            //                deviceView.googleSignInCheck(name: fileNm, path: foldrWholePathNm, fileDict: fileDict)
            
            containerView.googleSignInCheck(name: fileNm, path: foldrWholePathNm, fileDict: fileDict)
            
            break
            
        case cell.btnDelete:
            dv?.hideSelectedOptions(tag: sender.tag)
            let alertController = UIAlertController(title: nil, message: "해당 파일을 삭제 하시겠습니까?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                //Do you Success button Stuff here
                let params = ["userId":userId,"devUuid":fromDevUuid,"fileId":fileId,"fileNm":fileNm,"foldrWholePathNm": foldrWholePathNm]
                deviceView.deleteNasFile(param: params, foldrId: foldrId)
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


