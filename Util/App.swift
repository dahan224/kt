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
    
    
    struct Size {
        static let screenWidth = UIScreen.main.bounds.width
        static let screenHeight = UIScreen.main.bounds.height
        static let optionWidth = UIScreen.main.bounds.width * 5 / 6
    }
    
    struct URL {
        static let google: String = ""
        static let server: String = "https://araise.iptime.org/GIGA_Storage/webservice/rest/"
        static let NAS:String = "https://araise.iptime.org/namespace/ifs/home/gs-araise3/araise3-gs/GIGA_NAS/"
    }
    
    struct API {
        static let mainKey: String = ""
        static let subKey: String = ""
    }
    
    struct defaults {
        static let notificationToken = UserDefaults.standard.string(forKey: "notification_token")!
        static let loginToken = UserDefaults.standard.string(forKey: "token")!
        static let loginCookie = UserDefaults.standard.string(forKey: "cookie")!
        static let userId = UserDefaults.standard.string(forKey: "userId")!
       
    }
    
    
    struct Headrs{
        
        static let loginHeader:[String:String]  = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        static let jsonHeader:[String:String] = [
            "Content-Type": "application/json",
            "X-Auth-Token": UserDefaults.standard.string(forKey: "token")!,
            "Cookie": UserDefaults.standard.string(forKey: "cookie")!
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
    struct DeviceStruct:Codable {
        var devNm:String
        var devUuid:String
        var mkngVndrNm:String
        var onoff:String
        var osCd:String
        var osDesc:String
        var osNm:String
        var userId:String
        var userName:String
        
        init(devNm : String, devUuid : String, mkngVndrNm : String, onoff : String, osCd : String, osDesc : String, osNm : String, userId : String, userName : String) {
            self.devNm   = devNm
            self.devUuid   = devUuid
            self.mkngVndrNm   = mkngVndrNm
            self.onoff   = onoff
            self.osCd   = osCd
            self.osDesc   = osDesc
            self.osNm   = osNm
            self.userId   = userId
            self.userName   = userName
        }
        init(device: AnyObject) {
            self.devNm = device["devNm"] as? String ?? "nil"
            self.devUuid = device["devUuid"] as? String ?? "nil"
            self.mkngVndrNm = device["mkngVndrNm"] as? String ?? "nil"
            self.onoff = device["onoff"] as? String ?? "nil"
            self.osCd = device["osCd"] as? String ?? "nil"
            self.osDesc = device["osDesc"] as? String ?? "nil"
            self.osNm = device["osNm"] as? String ?? "nil"
            self.userId = device["userId"] as? String ?? "nil"
            self.userName = device["userName"] as? String ?? "nil"
        }
    }
    struct FolderStruct {
    
        var foldrNm:String
        var foldrId:Int
        var fileId:Int
        var userId:String
        var childCnt: Int
        var devUuid:String
        var foldrWholePathNm:String
        var cretDate:String
        var amdDate:String
        var etsionNm:String
        var fileNm:String
        var fileShar:String
        var fileSize:Int
        
        init(data: AnyObject) {
            self.foldrNm = data["foldrNm"] as? String ?? "nil"
            self.foldrId = data["foldrId"] as? Int ?? 0
//            if(data.responds(to: "fileId")){
                self.fileId = data["fileId"] as? Int ?? 0
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
            self.fileSize = data["fileSize"] as? Int ?? 0
        }
        init(data: [String:Any]) {
            self.foldrNm = data["foldrNm"] as? String ?? "nil"
            self.foldrId = data["foldrId"] as? Int ?? 0
            
            self.fileId = data["fileId"] as? Int ?? 0
            
            self.userId = data["userId"] as? String ?? "nil"
            self.childCnt = data["childCnt"] as? Int ?? 0
            self.devUuid = data["devUuid"] as? String ?? "nil"
            self.foldrWholePathNm = data["foldrWholePathNm"] as? String ?? "nil"
            self.cretDate = data["cretDate"] as? String ?? "nil"
            self.amdDate = data["amdDate"] as? String ?? "nil"
            self.etsionNm = data["etsionNm"] as? String ?? "nil"
            self.fileNm = data["fileNm"] as? String ?? "nil"
            self.fileShar = data["fileShar"] as? String ?? "nil"
            self.fileSize = data["fileSize"] as? Int ?? 0
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
        
        init(cmd : String, userId : String, devUuid : String, fileNm : String, etsionNm : String, fileSize : String, cretDate : String, amdDate : String, foldrWholePathNm: String) {
            self.cmd   = cmd
            self.userId   = userId
            self.devUuid   = devUuid
            self.fileNm   = fileNm
            self.etsionNm   = etsionNm
            self.fileSize   = fileSize
            self.cretDate   = cretDate
            self.amdDate   = amdDate
            self.foldrWholePathNm = foldrWholePathNm
            
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
                "foldrWholePathNm":foldrWholePathNm
            ]
        }
    }
    struct FilesToEdit {
        var cmd : String
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
                "fileNm" : fileNm,
                "etsionNm" : etsionNm,
                "amdDate" : amdDate,
                "foldrWholePathNm":foldrWholePathNm
            ]
        }
       
    }
    
    
    struct DriveFileStruct:Codable {
        var fileId:String
        var kind:String
        var mimeType:String
        var name:String        
      
        init(device: AnyObject) {
            self.fileId = device["id"] as? String ?? "nil"
            self.kind = device["kind"] as? String ?? "nil"
            self.mimeType = device["mimeType"] as? String ?? "nil"
            self.name = device["name"] as? String ?? "nil"
           
        }
        init(fileId : String, kind : String, mimeType : String, name : String) {
        self.fileId   = fileId
        self.kind   = kind
        self.mimeType   = mimeType
        self.name   = name
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
   
}
