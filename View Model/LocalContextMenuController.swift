//
//  LocalContextMenuController.swift
//  KT
//
//  Created by 이다한 on 2018. 3. 14..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GoogleSignIn


class LocalContextMenuController {
    var documentController : UIDocumentInteractionController!
    
    func localContextMenuCalled(cell:LocalFileListCell, indexPath:IndexPath, sender:UIButton, folderArray:[App.FolderStruct], deviceName:String, parentView:String, deviceView:HomeDeviceCollectionVC, userId:String, fromOsCd:String, currentDevUuid:String, currentFolderId:String){
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
        case cell.btnAction:
            
            let url:URL = FileUtil().getFileUrl(fileNm: fileNm, amdDate: amdDate)
            documentController = UIDocumentInteractionController(url: url)
            documentController.presentOptionsMenu(from: CGRect.zero, in: deviceView.view, animated: true)
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
            
        case cell.btnGDrive:
            if parentView == "device" {
                deviceView.googleSignInCheck(name: fileNm, path: foldrWholePathNm)
                deviceView.showLocalFileOption(tag: sender.tag)
            }
            break
        case cell.btnDelete:
            let alertController = UIAlertController(title: nil, message: "해당 파일을 삭제 하시겠습니까?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                let pathForRemove:String = FileUtil().getFilePath(fileNm: fileNm, amdDate: amdDate)
                print("pathForRemove : \(pathForRemove)")
                self.removeFile(path: pathForRemove)
                SyncLocalFilleToNas().sync()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    let alertController = UIAlertController(title: nil, message: "파일 삭제가 완료 되였습니다.", preferredStyle: .alert)
                    let yesAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        
                        deviceView.showInsideList(userId: userId, devUuid: currentDevUuid, foldrId: currentFolderId, deviceName: deviceName)
                        
                    }
                    alertController.addAction(yesAction)
                    deviceView.present(alertController, animated: true)
                })
                
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
    
    
    func localContextMenuCalledFromGrid(indexPath:IndexPath, fileId:String, foldrWholePathNm:String, deviceName:String, parentView:String, deviceView:HomeViewController, userId:String, fromOsCd:String, currentDevUuid:String, currentFolderId:String, folderArray:[App.FolderStruct], intFolderArrayIndexPathRow:Int){
        let fileNm = folderArray[intFolderArrayIndexPathRow].fileNm
        let etsionNm = folderArray[intFolderArrayIndexPathRow].etsionNm
        let amdDate = folderArray[intFolderArrayIndexPathRow].amdDate
        let foldrWholePathNm = folderArray[intFolderArrayIndexPathRow].foldrWholePathNm
        let fileId = String(folderArray[intFolderArrayIndexPathRow].fileId)
        
        switch indexPath.row {
            case 0:
                print("fileId: \(fileId)")
                let fileIdDict = ["fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":deviceName]
                NotificationCenter.default.post(name: Notification.Name("getFileIdFromBtnShow"), object: self, userInfo: fileIdDict)
                break
            case 1:
                let url:URL = FileUtil().getFileUrl(fileNm: fileNm, amdDate: amdDate)
                documentController = UIDocumentInteractionController(url: url)
                documentController.presentOptionsMenu(from: CGRect.zero, in: deviceView.view, animated: true)
                print("btnActino called")
                break
            
            case 2:
                let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"state":"local","fromUserId":userId, "fromOsCd":fromOsCd]
                print("fileDict : \(fileDict)")
                NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
                break
            case 3:
                deviceView.googleSignInCheck(name: fileNm, path: foldrWholePathNm)
                
                break
        
            case 4:
                let alertController = UIAlertController(title: nil, message: "해당 파일을 삭제 하시겠습니까?", preferredStyle: .alert)
                let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    let pathForRemove:String = FileUtil().getFilePath(fileNm: fileNm, amdDate: amdDate)
                    print("pathForRemove : \(pathForRemove)")
                    self.removeFile(path: pathForRemove)
                    SyncLocalFilleToNas().sync()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        let alertController = UIAlertController(title: nil, message: "파일 삭제가 완료 되였습니다.", preferredStyle: .alert)
                        let yesAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                            UIAlertAction in
                            var alertView:HomeDeviceCollectionVC = HomeDeviceCollectionVC()
                            alertView.showInsideList(userId: userId, devUuid: currentDevUuid, foldrId: currentFolderId, deviceName: deviceName)
                            
                        }
                        alertController.addAction(yesAction)
                        deviceView.present(alertController, animated: true)
                    })
                    
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


//원래 코드

//func localContextMenuCalled(cell:LocalFileListCell, indexPath:IndexPath, sender:UIButton){
//    fileNm = folderArray[indexPath.row].fileNm
//    let etsionNm = folderArray[indexPath.row].etsionNm
//    let amdDate = folderArray[indexPath.row].amdDate
//    foldrWholePathNm = folderArray[indexPath.row].foldrWholePathNm
//    fileId = String(folderArray[indexPath.row].fileId)
//    var btn = "show"
//    switch sender {
//    case cell.btnShow:
//        btn = "show"
//        var fileId:String = ""
//        var foldrWholePathNm:String = ""
//        if(mainContentState == .oneViewList){
//            fileId = "\(folderArray[indexPath.row].fileId)"
//            foldrWholePathNm = "\(folderArray[indexPath.row].foldrWholePathNm)"
//        }
//        print("fileId: \(fileId)")
//        let fileIdDict = ["fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":deviceName]
//        NotificationCenter.default.post(name: Notification.Name("getFileIdFromBtnShow"), object: self, userInfo: fileIdDict)
//        break
//    case cell.btnAction:
//
//        let url:URL = FileUtil().getFileUrl(fileNm: fileNm, amdDate: amdDate)
//        documentController = UIDocumentInteractionController(url: url)
//        documentController.presentOptionsMenu(from: CGRect.zero, in: self.view, animated: true)
//        print("btnActino called")
//        break
//
//    case cell.btnNas:
//
//        let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"state":"local","fromUserId":userId, "fromOsCd":fromOsCd]
//        print("fileDict : \(fileDict)")
//        NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
//        showLocalFileOption(tag: sender.tag)
//        break
//
//    case cell.btnGDrive:
//        self.googleSignInCheck(name: fileNm, path: foldrWholePathNm)
//        showLocalFileOption(tag: sender.tag)
//        break
//    case cell.btnDelete:
//        let alertController = UIAlertController(title: nil, message: "해당 파일을 삭제 하시겠습니까?", preferredStyle: .alert)
//        let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
//            UIAlertAction in
//            let pathForRemove:String = FileUtil().getFilePath(fileNm: self.fileNm, amdDate: amdDate)
//            self.removeFile(path: pathForRemove)
//            SyncLocalFilleToNas().sync()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
//                let alertController = UIAlertController(title: nil, message: "파일 삭제가 완료 되였습니다.", preferredStyle: .alert)
//                let yesAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
//                    UIAlertAction in
//
//                    self.showInsideList(userId: self.userId, devUuid: self.currentDevUuid, foldrId: self.currentFolderId, deviceName: self.deviceName)
//
//                }
//                alertController.addAction(yesAction)
//                self.present(alertController, animated: true)
//            })
//
//        }
//        let noAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel)
//        alertController.addAction(yesAction)
//        alertController.addAction(noAction)
//        self.present(alertController, animated: true)
//        break
//    default:
//        break
//    }
//}

