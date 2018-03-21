//
//  RemoteFileListCellController.swift
//  KT
//
//  Created by 이다한 on 2018. 3. 14..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RemoteFileListCellController {
    
    var dv:HomeDeviceCollectionVC?
    var hv:HomeViewController?
    var viewController = ""
    var jsonHeader:[String:String] = [
        "Content-Type": "application/json",
        "X-Auth-Token": UserDefaults.standard.string(forKey: "token")!,
        "Cookie": UserDefaults.standard.string(forKey: "cookie")!
    ]
    
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
    
    func remoteFileContextMenuCalled(cell:RemoteFileListCell, indexPath:IndexPath, sender:UIButton, folderArray:[App.FolderStruct], deviceName:String, parentView:String, deviceView:HomeDeviceCollectionVC, userId:String, fromOsCd:String, currentDevUuid:String, selectedDevUserId:String, currentFolderId:String){
        dv = deviceView
        viewController = "deviceView"
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
            dv?.showRemoteFileOption(tag: sender.tag)
            break
        case cell.btnDwnld:
            let remoteDownLoadToNas = false
            UserDefaults.standard.setValue(remoteDownLoadToNas, forKey: "remoteDownLoadToNas")
            UserDefaults.standard.synchronize()

            print("folder : \(folderArray[indexPath.row])")
            print("fileId: \(fileId) , fromUserId : \(selectedDevUserId), fromDevUuid : \(currentDevUuid), fromFoldr : \(foldrWholePathNm)")
            remoteDownloadRequest(fromUserId: selectedDevUserId, fromDevUuid: currentDevUuid, fromOsCd: fromOsCd, fromFoldr: foldrWholePathNm, fromFileNm: fileNm, fromFileId: fileId)
            dv?.showRemoteFileOption(tag: sender.tag)
            break
            
        case cell.btnNas:
            
           
            let remoteDownLoadToNas = true
            UserDefaults.standard.setValue(remoteDownLoadToNas, forKey: "remoteDownLoadToNas")
            UserDefaults.standard.synchronize()

//            remoteDownloadRequestToNas(fromUserId: selectedDevUserId, fromDevUuid: currentDevUuid, fromOsCd: fromOsCd, fromFoldr: currentDevUuid, fromFileNm: fileNm, fromFileId: fileId)
            let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"toStorage":"nas","fromUserId":userId, "fromOsCd":fromOsCd,"fromDevUuid":currentDevUuid]            
            print("fileDict : \(fileDict)")
            NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
            break
            
       
        default:
            break
        }
    }
    
   
    
    func remoteFileContextMenuCalledFromGrid(indexPath:IndexPath, fileId:String, foldrWholePathNm:String, deviceName:String, parentView:String, deviceView:HomeViewController, userId:String, fromOsCd:String, currentDevUuid:String, currentFolderId:String, folderArray:[App.FolderStruct], intFolderArrayIndexPathRow:Int){
        let fileNm = folderArray[intFolderArrayIndexPathRow].fileNm
        //        let etsionNm = folderArray[intFolderArrayIndexPathRow].etsionNm
        let amdDate = folderArray[intFolderArrayIndexPathRow].amdDate
        let foldrWholePathNm = folderArray[intFolderArrayIndexPathRow].foldrWholePathNm
        let fileId = String(folderArray[intFolderArrayIndexPathRow].fileId)
        let foldrId = String(folderArray[intFolderArrayIndexPathRow].foldrId)
        hv = deviceView
        viewController = "homeView"
        switch indexPath.row {
        case 0 :
            //파일 상세보기
            let fileIdDict = ["fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":deviceName]
            NotificationCenter.default.post(name: Notification.Name("getFileIdFromBtnShow"), object: self, userInfo: fileIdDict)
            
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
            break
        case 1:
            
            //다운로드
            let remoteDownLoadToNas = false
            UserDefaults.standard.setValue(remoteDownLoadToNas, forKey: "remoteDownLoadToNas")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
            print("folder : \(folderArray[indexPath.row])")
            print("fileId: \(fileId) , fromUserId : \(userId), fromDevUuid : \(currentDevUuid), fromFoldr : \(foldrWholePathNm)")
            remoteDownloadRequest(fromUserId: userId, fromDevUuid: currentDevUuid, fromOsCd: fromOsCd, fromFoldr: foldrWholePathNm, fromFileNm: fileNm, fromFileId: fileId)
            break
            
        case 2:
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
            let remoteDownLoadToNas = true
            UserDefaults.standard.setValue(remoteDownLoadToNas, forKey: "remoteDownLoadToNas")
            UserDefaults.standard.synchronize()
            
            //            remoteDownloadRequestToNas(fromUserId: selectedDevUserId, fromDevUuid: currentDevUuid, fromOsCd: fromOsCd, fromFoldr: currentDevUuid, fromFileNm: fileNm, fromFileId: fileId)
            let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"toStorage":"nas","fromUserId":userId, "fromOsCd":fromOsCd,"fromDevUuid":currentDevUuid]
            print("fileDict : \(fileDict)")
            NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
            break
            
        default :
            
            break
        }
        
    }
    
    
    
    
    func remoteDownloadRequest(fromUserId:String, fromDevUuid:String, fromOsCd:String, fromFoldr:String, fromFileNm:String, fromFileId:String){
        
        let urlString = App.URL.server+"reqFileDown.do"
        var comnd = "RALI"
        switch fromOsCd {
        case "W":
            comnd = "RWLI"
        case "A":
            comnd = "RALI"
        default:
            comnd = "RILI"
            break
        }
        let paramas:[String : Any] = ["fromUserId":fromUserId,"fromDevUuid":fromDevUuid,"fromOsCd":fromOsCd,"fromFoldr":fromFoldr,"fromFileNm":fromFileNm,"fromFileId":fromFileId,"toDevUuid":Util.getUuid(),"toOsCd":"I","toFoldr":"/Mobile","toFileNm":fromFileNm,"comndOsCd":"I","comndDevUuid":App.defaults.userId,"comnd":comnd]
        print("notifyNasUploadFinish param : \(paramas)")
        Alamofire.request(urlString,
                          method: .post,
                          parameters: paramas,
                          encoding : JSONEncoding.default,
                          headers: jsonHeader).responseJSON { response in
                            switch response.result {
                            case .success(let JSON):

                                print(response.result.value)
                                let responseData = JSON as! NSDictionary
                                let message = responseData.object(forKey: "message")
                                print("remoteDownloadRequest : \(message)")                         
                                DispatchQueue.main.async {
                                    let alertController = UIAlertController(title: nil, message: "\(message!)", preferredStyle: .alert)
                                    let yesAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                                        UIAlertAction in
                                        
                                    }
                                    alertController.addAction(yesAction)
                                    if self.viewController == "deviceView" {
                                    self.dv?.present(alertController, animated: true, completion: nil)
                                    } else {
                                        self.hv?.present(alertController, animated: true, completion: nil)
                                    }
                                    
                                }
                            
                                break
                            case .failure(let error):

                                print(error.localizedDescription)
                            }
        }
    }
    
  
}
