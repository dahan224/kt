//
//  App.swift
//  KT
//
//  Created by 이다한 on 2018. 1. 30..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
struct App {
    
    static let bundleID = Bundle.main.bundleIdentifier!
    
    static let nasFoldrFrontNm = "gs-"
    
    struct Size {
        static let screenWidth = UIScreen.main.bounds.width
        static let screenHeight = UIScreen.main.bounds.height
        static let optionWidth = UIScreen.main.bounds.width * 5 / 6
    }
    
    struct URL {
        static let google: String = ""
        static let server: String = "https://araise.iptime.org/GIGA_Storage/webservice/rest/"
//        static let NAS:String = "https://araise.iptime.org/namespace/ifs/home/gs-araise3/araise3-gs/GIGA_NAS/"
        static let gDriveFileOption:String = "&orderBy=folder,createdTime desc&fields=nextPageToken,files(id, name, mimeType,size,createdTime,modifiedTime,parents,properties,fileExtension,fullFileExtension,trashed,shared,starred,thumbnailLink)"
    }
    
    struct API {
        static let mainKey: String = ""
        static let subKey: String = ""
    }
    
    struct defaults {
        static let userId = UserDefaults.standard.string(forKey: "userId")!
       
    }
    
    
    struct Headrs{
        
        static let loginHeader:[String:String]  = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
       
    }
    
    struct DeviceInfo {
        var userId : String
        var devUuid : String
        var devNm : String
        var osCd : String
        var osDesc : String
        var mkngVndrNm : String
        var devAuthYn : String
        var rootFoldrNm : String
        var lastUpdtId : String
        var token: String
        
        init(userId : String, devUuid : String, devNm : String, osCd : String, osDesc : String, mkngVndrNm : String, devAuthYn : String, rootFoldrNm : String, lastUpdtId : String, token: String) {
            self.userId   = userId
            self.devUuid   = devUuid
            self.devNm   = devNm
            self.osCd   = osCd
            self.osDesc   = osDesc
            self.mkngVndrNm   = mkngVndrNm
            self.devAuthYn   = devAuthYn
            self.rootFoldrNm   = rootFoldrNm
            self.lastUpdtId   = lastUpdtId
            self.token = token
        }
        
        var getParameter: [String: String] {
            return [
                "userId" : userId,
                "devUuid" : devUuid,
                "devNm" : devNm,
                "osCd" : osCd,
                "osDesc" : osDesc,
                "mkngVndrNm" : mkngVndrNm,
                "devAuthYn" : devAuthYn,
                "rootFoldrNm" : rootFoldrNm,
                "lastUpdtId" : lastUpdtId,
                "token": token
            ]
        }
    }
    
    struct smsInfo {
        var smsCrtfcKey:String
        var smsCrtfcNo:String
        var today:String
        var devBas:DeviceStruct
        
        init(sms:AnyObject) {
            self.smsCrtfcKey = sms["smsCrtfcKey"] as? String ?? "nil"
            self.smsCrtfcNo = sms["smsCrtfcNo"] as? String ?? "nil"
            self.today = sms["today"] as? String ?? "nil"
            self.devBas = App.DeviceStruct(device: ((sms["devBasVO"] as? Dictionary<String,Any> ?? [:]) as? AnyObject)!)
        }
    }
    
    struct DeviceStruct:Codable {
        var devNm:String
        var devUuid:String
        var logical: String
        var mkngVndrNm:String
        var newFlag:String
        var onoff:String
        var osCd:String
        var osDesc:String
        var osNm:String
        var userId:String
        var userName:String
        
        var smsCrtfcKey:String
        var smsCrtfcNo:String
        var smsLoginDe:String
        
        init(devNm : String, devUuid : String, logical:String, mkngVndrNm : String, newFlag:String, onoff : String, osCd : String, osDesc : String, osNm : String, userId : String, userName : String) {
            self.devNm   = devNm
            self.devUuid   = devUuid
            self.logical = logical
            self.mkngVndrNm   = mkngVndrNm
            self.newFlag = newFlag
            self.onoff   = onoff
            self.osCd   = osCd
            self.osDesc   = osDesc
            self.osNm   = osNm
            self.userId   = userId
            self.userName   = userName
            
            self.smsCrtfcKey = "nil"
            self.smsCrtfcNo = "nil"
            self.smsLoginDe = "nil"
        }
        init(device: AnyObject) {
            self.devNm = device["devNm"] as? String ?? "nil"
            self.devUuid = device["devUuid"] as? String ?? "nil"
            self.logical = device["logical"] as? String ?? "nil"
            self.mkngVndrNm = device["mkngVndrNm"] as? String ?? "nil"
            self.newFlag = device["newFlag"] as? String ?? "nil"
            self.onoff = device["onoff"] as? String ?? "nil"
            self.osCd = device["osCd"] as? String ?? "nil"
            self.osDesc = device["osDesc"] as? String ?? "nil"
            self.osNm = device["osNm"] as? String ?? "nil"
            self.userId = device["userId"] as? String ?? "nil"
            self.userName = device["userName"] as? String ?? "nil"
            
            self.smsCrtfcKey = device["smsCrtfcKey"] as? String ?? "nil"
            self.smsCrtfcNo = device["smsCrtfcNo"] as? String ?? "nil"
            self.smsLoginDe = device["smsLoginDe"] as? String ?? "nil"
        }
    }
    struct FolderStruct {
    
        var foldrNm:String
        var foldrId:Int
        var fileId:Int
        var userId:String
        var devNm: String
        var childCnt: Int
        var devUuid:String
        var foldrWholePathNm:String
        var cretDate:String
        var amdDate:String
        var etsionNm:String
        var fileNm:String
        var fileShar:String
        var fileSize:String
        var upFoldrId:Int
        var osCd: String
        var fileThumbYn:String
        var checked:Bool
        init(data: AnyObject) {
            self.foldrNm = data["foldrNm"] as? String ?? "nil"
            self.foldrId = data["foldrId"] as? Int ?? 0
//            if(data.responds(to: "fileId")){
            var filnalFileId:Int? = 0
            if let getFileId = data["fileId"] as? Int {
                filnalFileId = getFileId
            } else if let getStringFileId = data["fileId"] as? String {
                filnalFileId = Int(getStringFileId)
            }
            self.fileId = filnalFileId ?? 0
//            } else {
//                self.fileId = 0
//            }
//
            self.userId = data["userId"] as? String ?? "nil"
            self.childCnt = data["childCnt"] as? Int ?? 0
            self.devUuid = data["devUuid"] as? String ?? "nil"
            self.foldrWholePathNm = data["foldrWholePathNm"] as? String ?? "nil"
            self.cretDate = data["cretDate"] as? String ?? "nil"
            self.amdDate = data["amdDate"] as? String ?? "nil"
            self.etsionNm = data["etsionNm"] as? String ?? "nil"
            self.fileNm = data["fileNm"] as? String ?? "nil"
            self.fileShar = data["fileShar"] as? String ?? "nil"
            self.fileSize = data["fileSize"] as? String ?? "0"
            self.upFoldrId = data["upFoldrId"] as? Int ?? 0
            self.devNm = data["devNm"] as? String ?? "nil"
            self.osCd = data["osCd"] as? String ?? "nil"
            self.checked = data["checked"] as? Bool ?? false
            self.fileThumbYn = data["fileThumbYn"] as? String ?? "nil"
            
        }
        init(data: [String:Any]) {
            self.foldrNm = data["foldrNm"] as? String ?? "nil"
            self.foldrId = data["foldrId"] as? Int ?? 0
            self.fileId = data["fileId"] as? Int ?? 0
            self.devNm = data["devNm"] as? String ?? "nil"
            self.userId = data["userId"] as? String ?? "nil"
            self.childCnt = data["childCnt"] as? Int ?? 0
            self.devUuid = data["devUuid"] as? String ?? "nil"
            self.foldrWholePathNm = data["foldrWholePathNm"] as? String ?? "nil"
            self.cretDate = data["cretDate"] as? String ?? "nil"
            self.amdDate = data["amdDate"] as? String ?? "nil"
            self.etsionNm = data["etsionNm"] as? String ?? "nil"
            self.fileNm = data["fileNm"] as? String ?? "nil"
            self.fileShar = data["fileShar"] as? String ?? "nil"
            self.fileSize = data["fileSize"] as? String ?? "0"
            self.upFoldrId = data["upFoldrId"] as? Int ?? 0
            self.osCd = data["osCd"] as? String ?? "nil"
            self.checked = data["checked"] as? Bool ?? false
            self.fileThumbYn = data["fileThumbYn"] as? String ?? "nil"
        }
    }
  
    struct SearchedFileStruct {
        var foldrYn: String
        var userNm: String
        var etsionNm: String
        var nasSynchYn: String
        var devNm: String
        var foldrId: Int
        var fileShar: String
        var userId: String
        var osCd: String
        var fileNm: String
        var fileSize: String
        var foldrNm: String
        var foldrWholePathNm: String
        var amdDate : String
        var cretDate : String
        var devUuid: String
        var fileId : String
        var syncFileId: String
        
        init(data: AnyObject){
            self.foldrYn = data["foldrYn"] as? String ?? "nil"
            self.fileId = data["fileId"] as? String ?? "nil"
            self.userNm = data["userNm"] as? String ?? "nil"
            self.etsionNm = data["etsionNm"] as? String ?? "nil"
            self.nasSynchYn = data["nasSynchYn"] as? String ?? "nil"
            self.devNm = data["devNm"] as? String ?? "nil"
            self.foldrId = data["foldrId"] as? Int ?? 0
            self.fileShar = data["fileShar"] as? String ?? "nil"
            self.userId = data["userId"] as? String ?? "nil"
            self.osCd = data["osCd"] as? String ?? "nil"
            self.fileNm = data["fileNm"] as? String ?? "nil"
            self.fileSize = data["fileSize"] as? String ?? "nil"
            self.foldrNm = data["fileNm"] as? String ?? "nil"
            self.foldrWholePathNm = data["foldrWholePathNm"] as? String ?? "nil"
            self.amdDate = data["amdDate"] as? String ?? "nil"
            self.cretDate = data["cretDate"] as? String ?? "nil"
            self.devUuid = data["devUuid"] as? String ?? "nil"
            
            self.syncFileId = data["syncFileId"] as? String ?? "nil"
        }
      
    }
    
    struct LatelyUpdatedFileStruct {
        var foldrYn: String
        var userNm: String
        var etsionNm: String
        var nasSynchYn: String
        var devNm: String
        var foldrId: Int
        var fileShar: String
        var userId: String
        var osCd: String
        var fileNm: String
        var fileSize: String
        var foldrNm: String
        var foldrWholePathNm: String
        var amdDate : String
        var cretDate : String
        var devUuid: String
        var fileId : Int
        var syncFileId: Double
        
        init(data: AnyObject){
            self.foldrYn = data["foldrYn"] as? String ?? "nil"
            self.fileId = data["fileId"] as? Int ?? 0
            self.userNm = data["userNm"] as? String ?? "nil"
            self.etsionNm = data["etsionNm"] as? String ?? "nil"
            self.nasSynchYn = data["nasSynchYn"] as? String ?? "nil"
            self.devNm = data["devNm"] as? String ?? "nil"
            self.foldrId = data["foldrId"] as? Int ?? 0
            self.fileShar = data["fileShar"] as? String ?? "nil"
            self.userId = data["userId"] as? String ?? "nil"
            self.osCd = data["osCd"] as? String ?? "nil"
            self.fileNm = data["fileNm"] as? String ?? "nil"
            self.fileSize = data["fileSize"] as? String ?? "nil"
            self.foldrNm = data["fileNm"] as? String ?? "nil"
            self.foldrWholePathNm = data["foldrWholePathNm"] as? String ?? "nil"
            self.amdDate = data["amdDate"] as? String ?? "nil"
            self.cretDate = data["cretDate"] as? String ?? "nil"
            self.devUuid = data["devUuid"] as? String ?? "nil"
            
            self.syncFileId = data["syncFileId"] as? Double ?? 0
        }
        
    }
    
    struct Folders:Codable {
        var cmd : String
        var userId : String
        var devUuid : String
        var foldrNm : String
        var foldrWholePathNm: String
        var cretDate : String
        var amdDate : String
   
        
        
        init(cmd : String, userId : String, devUuid : String, foldrNm : String, foldrWholePathNm: String, cretDate : String, amdDate : String) {
            self.cmd   = cmd
            self.userId   = userId
            self.devUuid   = devUuid
            self.foldrNm   = foldrNm
            self.foldrWholePathNm = foldrWholePathNm
            self.cretDate   = cretDate
            self.amdDate   = amdDate
        }
     
        init(data: AnyObject) {
            self.cmd   = "C"
            self.userId   = data["userId"] as! String
            self.devUuid   = data["devUuid"] as! String
            self.foldrNm   = data["foldrNm"] as! String
            self.foldrWholePathNm = data["foldrWholePathNm"] as! String
            self.cretDate   = ""
            self.amdDate   = ""
        }
        
        var getParameter: [String: Any] {
            return [
                "cmd":cmd,
                "userId": userId,
                "devUuid": devUuid,
                "foldrNm": foldrNm,
                "foldrWholePathNm": foldrWholePathNm,
                "cretDate": cretDate,
                "amdDate": amdDate
            ]
        }
    
        
    }
    
    struct FoldersToEdit:Codable {
        var cmd : String
        var userId : String
        var devUuid : String
        var foldrNm : String
        var foldrWholePathNm: String
        var cretDate : String
        var amdDate : String
        
        
        init(folder : Folders, cmd : String) {
            self.cmd   = cmd
            self.userId   = folder.userId
            self.devUuid   = folder.devUuid
            self.foldrNm   = folder.foldrNm
            self.foldrWholePathNm = folder.foldrWholePathNm
            self.cretDate   = folder.cretDate
            self.amdDate   = folder.amdDate
        }
        
        
        
        var getParameter: [String: Any] {
            return [
                "cmd":cmd,
                "userId": userId,
                "devUuid": devUuid,
                "foldrNm": foldrNm,
                "foldrWholePathNm": foldrWholePathNm,
                "cretDate": cretDate,
                "amdDate": amdDate
            ]
        }
        
        
    }
    
    struct LocalFiles:Codable {
        var cmd : String
        var userId : String
        var devUuid : String
        var fileNm : String
        var etsionNm : String
        var fileSize : String
        var cretDate : String
        var amdDate : String
        var foldrWholePathNm: String
        var savedPath: String
        
        init(cmd : String, userId : String, devUuid : String, fileNm : String, etsionNm : String, fileSize : String, cretDate : String, amdDate : String, foldrWholePathNm: String, savedPath:String) {
            self.cmd   = cmd
            self.userId   = userId
            self.devUuid   = devUuid
            self.fileNm   = fileNm
            self.etsionNm   = etsionNm
            self.fileSize   = fileSize
            self.cretDate   = cretDate
            self.amdDate   = amdDate
            self.foldrWholePathNm = foldrWholePathNm
            self.savedPath = savedPath
            
        }
        init(data: AnyObject) {
            self.cmd   = "C"
            self.userId   = data["userId"] as! String
            self.devUuid   = data["devUuid"] as! String
            self.fileNm   = data["fileNm"] as! String
            self.etsionNm   = data["etsionNm"] as! String
            self.fileSize   = data["fileSize"] as! String
            self.cretDate   = data["cretDate"] as! String
            self.amdDate   = data["amdDate"] as! String
            self.foldrWholePathNm = data["foldrWholePathNm"] as! String
            self.savedPath = "no"
            
        }
        var getParameter: [String: Any] {
            if etsionNm.isEmpty {
                return [
                    "cmd" : cmd,
                    "userId" : userId,
                    "devUuid" : devUuid,
                    "fileNm" : fileNm,
                    "etsionNm" : etsionNm,
                    "fileSize" : fileSize,
                    "cretDate" : cretDate,
                    "amdDate" : amdDate,
                    "foldrWholePathNm":foldrWholePathNm
                    
                ]
            } else {
                return [
                    "cmd" : cmd,
                    "userId" : userId,
                    "devUuid" : devUuid,
                    "fileNm" : "\(fileNm).\(etsionNm)",
                    "etsionNm" : etsionNm,
                    "fileSize" : fileSize,
                    "cretDate" : cretDate,
                    "amdDate" : amdDate,
                    "foldrWholePathNm":foldrWholePathNm
                    
                ]
            }
            
        }
    }
    
    struct Files:Codable {
        var cmd : String
        var userId : String
        var devUuid : String
        var fileNm : String
        var etsionNm : String
        var fileSize : String
        var cretDate : String
        var amdDate : String
        var foldrWholePathNm: String
        var fileId : Int
        
        init(cmd : String, userId : String, devUuid : String, fileNm : String, etsionNm : String, fileSize : String, cretDate : String, amdDate : String, foldrWholePathNm: String, fileId:Int) {
            self.cmd   = cmd
            self.userId   = userId
            self.devUuid   = devUuid
            self.fileNm   = fileNm
            self.etsionNm   = etsionNm
            self.fileSize   = fileSize
            self.cretDate   = cretDate
            self.amdDate   = amdDate
            self.foldrWholePathNm = foldrWholePathNm
            self.fileId = fileId
            
        }
        init(data: AnyObject) {
            self.cmd   = "C"
            self.userId   = data["userId"] as? String ?? App.defaults.userId
            self.devUuid   = data["devUuid"] as? String ?? Util.getUuid()
            self.fileNm   = data["fileNm"] as! String
            self.etsionNm   = data["etsionNm"] as? String ?? "nil"
            self.fileSize   = data["fileSize"] as? String ?? "nil"
            self.cretDate   = data["cretDate"] as? String ?? "nil"
            self.amdDate   = data["amdDate"] as! String
            self.foldrWholePathNm = data["foldrWholePathNm"] as! String
            self.fileId = data["fileId"] as? Int ?? 0
           
        }
        var getParameter: [String: Any] {
            return [
                "cmd" : cmd,
                "userId" : userId,
                "devUuid" : devUuid,
                "fileNm" : fileNm,
                "etsionNm" : etsionNm,
                "fileSize" : fileSize,
                "cretDate" : cretDate,
                "amdDate" : amdDate,
                "foldrWholePathNm":foldrWholePathNm,
                "fileId":fileId
            ]
        }
    }
    struct FilesToEdit {
        var cmd : String
        var fileId : Int
        var userId : String
        var devUuid : String
        var fileNm : String
        var etsionNm : String
        var fileSize : String
        var cretDate : String
        var amdDate : String
        var foldrWholePathNm: String
        
        init(file:Files, cmd:String) {
            self.cmd   = cmd
            self.userId   = file.userId
            self.devUuid   = file.devUuid
            self.fileNm   = file.fileNm
            self.fileId = file.fileId
            self.etsionNm   = file.etsionNm
            self.fileSize   = file.fileSize
            self.cretDate   = file.cretDate
            self.amdDate   = file.amdDate
            self.foldrWholePathNm = file.foldrWholePathNm
            
        }
        
        var getParameter: [String: Any] {
            return [
                "cmd" : cmd,
                "userId" : userId,
                "devUuid" : devUuid,
                "fileNm" : fileNm,
                "fileId" : fileId,
                "etsionNm" : etsionNm,
                "fileSize" : fileSize,
                "cretDate" : cretDate,
                "amdDate" : amdDate,
                "foldrWholePathNm":foldrWholePathNm
            ]
        }
        var getDeleteParameter: [String: Any] {
            return [
                "cmd" : "D",
                "userId" : userId,
                "devUuid" : devUuid,
                "fileId" : fileId,
                "fileNm" : fileNm,
                "foldrWholePathNm":foldrWholePathNm
            ]
        }
       
    }
    
    
    struct DriveFileStruct:Codable {
        var fileId:String
        var kind:String
        var mimeType:String
        var name:String
        var createdTime:String
        var modifiedTime:String
        var parents:String
        
        var fileExtension:String
        var foldrWholePath:String
        var size:String
        var thumbnailLink:String
        
        init(device: AnyObject, foldrWholePaths: [String]) {
            self.fileId = device["id"] as? String ?? "nil"
            self.kind = device["kind"] as? String ?? "nil"
            self.mimeType = device["mimeType"] as? String ?? "nil"
            self.name = device["name"] as? String ?? "nil"
            self.createdTime = device["createdTime"] as? String ?? "nil"
            self.modifiedTime = device["modifiedTime"] as? String ?? "nil"
            let parentArry:[String] = device["parents"] as? [String] ?? ["nil"]
            self.parents = parentArry[0]
            self.fileExtension = device["fileExtension"] as? String ?? "nil"
            self.foldrWholePath = ""
            for foldr in foldrWholePaths {
                self.foldrWholePath += "/" + foldr
            }
            self.size = device["size"] as? String ?? "0"
            self.thumbnailLink = device["thumbnailLink"] as? String ?? "nil"
        }
        init(fileId : String, kind : String, mimeType : String, name : String, createdTime:String, modifiedTime:String, parents:String, fileExtension:String, size:String, foldrWholePath:String, thumbnailLink:String) {
            self.fileId   = fileId
            self.kind   = kind
            self.mimeType   = mimeType
            self.name   = name
            self.createdTime = createdTime
            self.modifiedTime = modifiedTime
            self.parents = parents
            self.fileExtension = fileExtension
            self.size = size
            self.foldrWholePath = foldrWholePath
            self.thumbnailLink = thumbnailLink
        }
    }

    struct FileTagStruct {
        var fileId:String
        var fileTag:String
        
        init(fileId : String, fileTag : String) {
            self.fileId   = fileId
            self.fileTag   = fileTag
        }
        var getParameter: [String: Any] {
            return [
                "fileId" :fileId,
                "fileTag" : fileTag
            ]
        }
    }
    struct Color {
        static let listBorder = "D1D2D4"
        static let navBorder = "666666"
    }
    func covertFileSize(getSize:String) -> String {
        var convertedValue: Double = Double(getSize)!
        var multiplyFactor = 0
        let tokens = ["B", "KB", "MB", "GB", "TB", "PB",  "EB",  "ZB", "YB"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        
        let result = String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
        
        return result.replacingOccurrences(of: ".00", with: "")
    }
}
