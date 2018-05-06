
//
//  SelectFilnishController.swift
//  KT
//
//  Created by 이다한 on 2018. 4. 6..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import GoogleSignIn


class SelectFilnishController {
    var toOsCd = ""
    var fromFoldrId = ""
    var etsionNm = ""
    var toUserId = ""
    var originalFileName = ""
    var originalFileId = ""
    var amdDate = ""
    
    var oldFoldrWholePathNm = ""
    func send(parent:NasSendFolderSelectVC, getToOsCd:String, getToUserId:String, getOriginalFileName:String, getAmdDate:String, getOriginalFileId:String, oldFoldrWholePathNm:String, newFoldrWholePathNm:String, multiCheckedfolderArray:[App.FolderStruct], etsionNm:String, storageState:NasSendFolderSelectVC.toStorageKind, listState:NasSendFolderSelectVC.listEnum, driveFileArray:[App.DriveFileStruct], checkedButtonRow:Int, driveFolderNameArray:[String], driveFolderIdArray:[String], fromOsCd:String, fromDevUuid:String, accessToken:String, googleDriveFileIdPath:String, deviceName:String, fromUserId:String){
        toOsCd = getToOsCd
        toUserId = getToUserId
        originalFileName = getOriginalFileName
        originalFileId = getOriginalFileId
        amdDate = getAmdDate
        self.oldFoldrWholePathNm = oldFoldrWholePathNm
        self.etsionNm = etsionNm
        switch storageState {
        case .nas:
            if(!etsionNm.isEmpty){
                toOsCd = "G"
                if(toUserId != UserDefaults.standard.string(forKey: "userId")){
                    toOsCd = "S"
                }
                parent.NasSendFolderSelectVCToggleIndicator()
                //                let fileUrl:URL = FileUtil().getFileUrl(fileNm: originalFileName, amdDate: amdDate)!
                let fileUrl:URL = FileUtil().getFileUrlWithFoldr(fileNm: originalFileName, foldrWholePathNm: "/Mobile", amdDate: self.amdDate)!
                parent.sendToNasFromLocal(url: fileUrl, name: originalFileName, toOsCd:toOsCd, fileId: originalFileId)
            } else {
                // local 폴더 업로드 to nas
//                print("upload path : \(newFoldrWholePathNm), oldFoldrWholePathNm: \(oldFoldrWholePathNm)")
//                ToNasFromLocalFolder().readyCreatFolders(getToUserId:toUserId, getNewFoldrWholePathNm:newFoldrWholePathNm, getOldFoldrWholePathNm:oldFoldrWholePathNm, getMultiArray:multiCheckedfolderArray, parent:ContainerViewController!)
//                
            }
            
            break
        case .googleDrive:
            var checkedFolderId = "root"
            var checkedFolderName = "root"
            var finalNewFoldrWholePathNm = "root"
            if listState == .deviceSelect {
                
            } else {
                print("listState : \(listState), index : \(checkedButtonRow)")
                checkedFolderId = driveFileArray[checkedButtonRow].fileId
                checkedFolderName = driveFileArray[checkedButtonRow].name
                finalNewFoldrWholePathNm = ""
                for (index, file) in driveFolderNameArray.enumerated() {
                    if(index < driveFolderNameArray.count){
                        finalNewFoldrWholePathNm += "\(driveFolderNameArray[index])/"
                    }
                }
                finalNewFoldrWholePathNm += "\(checkedFolderName)"
            }
            print("driveFolderIdArray: \(driveFolderIdArray), checkedFolderId : \(checkedFolderId)")
            print("driveFolderNameArray: \(driveFolderNameArray), checkedFolderName : \(checkedFolderName)")
            
            
            if(fromDevUuid == Util.getUuid()){
                if(!etsionNm.isEmpty){
                    let fileURL:URL = FileUtil().getFileUrl(fileNm: originalFileName, amdDate: amdDate)!
                    parent.sendToDriveFromLocal(name: originalFileName, path: oldFoldrWholePathNm, fileId: checkedFolderId, fileURL:fileURL)
                    
                    
                } else {
                    print("upload folder from local to gDrive, newFoldrWholePathNm: \(finalNewFoldrWholePathNm)")
                    
                    //                    print("\(driveFolderNameArray)")
//                    GoogleWork().readyCreatFolders(getAccessToken: accessToken, getNewFoldrWholePathNm: finalNewFoldrWholePathNm, getOldFoldrWholePathNm: oldFoldrWholePathNm,  getMultiArray: multiCheckedfolderArray, fileId: checkedFolderId, parent: )
                }
                
                
            } else if fromOsCd == "gDrive" {
                //gdrive to gdrive
                print("gdrive to gdrive")
                parent.activityIndicator.startAnimating()
                print("fileId : \(originalFileId), name : \(self.originalFileName), googleDriveFileIdPath : \(googleDriveFileIdPath)")
                GoogleWork().copyGdriveFile(name: originalFileName, fileId: originalFileId, parents: googleDriveFileIdPath) { responseObject, error in
                    if let fileUrl = responseObject {
                        DispatchQueue.main.async {
                            let alertController = UIAlertController(title: nil, message: "파일 복사에 성공했습니다.", preferredStyle: .alert)
                            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                                UIAlertAction in
                                //Do you Success button Stuff here
                                parent.activityIndicator.stopAnimating()
                                Util().dismissFromLeft(vc: parent)
                            }
                            alertController.addAction(yesAction)
                            parent.present(alertController, animated: true)
                            
                        }
                        
                    }
                    
                    return
                }
                
            } else {
                print("etsionNm : \(etsionNm)")
                if(!etsionNm.isEmpty){
                    // from nas to gdrive
                    print("downloadFromNasToDriveFile")
                    
                    
                    parent.downloadFromNasToDrive(name: originalFileName, path: oldFoldrWholePathNm, fileId: checkedFolderId)
                } else {
                    // from nas to gdrive folder
                    let inFoldrId:Int = Int(fromFoldrId) ?? 0
                    print("deviceName : \(deviceName), newFoldrWholePathNm: \(newFoldrWholePathNm)")
                    print("driveFolderIdArray: \(driveFolderIdArray), checkedFolderId : \(checkedFolderId)")
                    print("driveFolderNameArray: \(driveFolderNameArray), checkedFolderName : \(checkedFolderName)")
                    print("foldrId: \(inFoldrId), foldrWholePathNm: \(oldFoldrWholePathNm), userId:\(fromUserId), devUuid:\(fromDevUuid), deviceName:\(deviceName), getAccessToken: \(accessToken), getNewFoldrWholePathNm: \(newFoldrWholePathNm), getGdriveFolderIdToSave: \(checkedFolderId), getOldFoldrWholePathNm: \(oldFoldrWholePathNm),  getMultiArray: \(multiCheckedfolderArray), fileId: \(googleDriveFileIdPath), parent:\(parent), storageState: .googleDrive")
//                    SendFolderToGdriveFromNAS().downloadFolderFromNas(foldrId: inFoldrId, foldrWholePathNm: oldFoldrWholePathNm, userId:fromUserId, devUuid:fromDevUuid, deviceName:deviceName, getAccessToken: accessToken, getNewFoldrWholePathNm: newFoldrWholePathNm, getGdriveFolderIdToSave: checkedFolderId, getOldFoldrWholePathNm: oldFoldrWholePathNm,  getMultiArray: multiCheckedfolderArray, fileId: googleDriveFileIdPath, parent:parent, storageState: .googleDrive)
                    
                }
                
            }
            break
        default:
            break
        }
        
    }
}

