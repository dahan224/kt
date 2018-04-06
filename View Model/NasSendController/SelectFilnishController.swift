
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
    
    func send(){
        if(fromFoldrId.isEmpty){
            toOsCd = "G"
//            if(toUserId != App.defaults.userId){
                toOsCd = "S"
//            }
//            let fileUrl:URL = FileUtil().getFileUrl(fileNm: originalFileName, amdDate: amdDate)!
//            sendToNasFromLocal(url: fileUrl, name: originalFileName, toOsCd:toOsCd, fileId: originalFileId)
        } else {
            // local 폴더 업로드 to nas
//            print("upload path : \(newFoldrWholePathNm)")
//            ToNasFromLocalFolder().readyCreatFolders(getToUserId:toUserId, getNewFoldrWholePathNm:newFoldrWholePathNm, getOldFoldrWholePathNm:oldFoldrWholePathNm, getMultiArray:multiCheckedfolderArray, parent:self)
            
        }
    }
}
