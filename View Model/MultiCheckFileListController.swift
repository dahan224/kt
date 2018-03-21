//
//  MultiCheckFileListController.swift
//  KT
//
//  Created by 이다한 on 2018. 3. 21..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MultiCheckFileListController {
    
    var multiCheckedfolderArray:[App.FolderStruct] = []
    var dv:HomeDeviceCollectionVC?
    func callDwonLoad(getFolderArray:[App.FolderStruct], parent:HomeDeviceCollectionVC){
        dv = parent
        if (getFolderArray.count > 0){
            let index = getFolderArray.count - 1
            let name = getFolderArray[index].fileNm
            let path = getFolderArray[index].foldrWholePathNm
            let fileId = String(getFolderArray[index].fileId)
            let userId = getFolderArray[index].userId
            downloadFromNas(name: name, path: path, fileId: fileId, userId:userId, getFolderArray:getFolderArray)
            return
        }
        
        SyncLocalFilleToNas().sync()
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: nil, message: "다운로드를 성공하였습니다.", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel){
                UIAlertAction in
                NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
                NotificationCenter.default.post(name: Notification.Name("btnMulticlicked"), object: self, userInfo: nil)
            }
            
            alertController.addAction(yesAction)
            parent.present(alertController, animated: true)
        }
        
    }
    func downloadFromNas(name:String, path:String, fileId:String, userId:String,getFolderArray:[App.FolderStruct]){
        
        ContextMenuWork().downloadFromNas(userId:userId, fileNm:name, path:path, fileId:fileId){ responseObject, error in
            if let success = responseObject {
                print(success)
                if(success == "success"){
                    var newArray = getFolderArray
                    newArray.remove(at: newArray.count - 1)
                    self.callDwonLoad(getFolderArray: newArray, parent: self.dv!)
                    
                } else {
                    NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
                }
            }
            
            return
        }
    }
   
}

