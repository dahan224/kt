//
//  DbHelper.swift
//  KT
//
//  Created by 이다한 on 2018. 2. 26..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import SQLite

class DbHelper{
    var database: Connection!
    let oneViewListTable = Table("oneViewList")
    let googleDriveFileListTable = Table("googleDriveFileList")
    let localFileListTable = Table("localFileListTable")
    let googleEmailListTable = Table("googleEmailListTable")
    
    let id = Expression<Int>("id")
    let devNm = Expression<String>("devNm")
    let devUuid = Expression<String>("devUuid")
    let logical = Expression<String>("logical")
    let mkngVndrNm = Expression<String>("mkngVndrNm")
    let newFlag = Expression<String>("newFlag")
    let onoff = Expression<String>("onoff")
    let osCd = Expression<String>("osCd")
    let osDesc = Expression<String>("osDesc")
    let osNm = Expression<String>("osNm")
    let userId = Expression<String>("userId")
    let userName = Expression<String>("userName")
    var DeviceArray = [App.DeviceStruct]()
    
    let fileId = Expression<String>("fileId")
    let kind = Expression<String>("kind")
    let mimeType = Expression<String>("mimeType")
    let name = Expression<String>("name")
    
    let createdTime = Expression<String>("createdTime")
    let modifiedTime = Expression<String>("modifiedTime")
    let parents = Expression<String>("parents")
    let fileExtension = Expression<String>("fileExtension")
    let foldrWholePath = Expression<String>("foldrWholePath")
    let size = Expression<String>("size")
    let thumbnailLink = Expression<String>("thumbnailLink")
    
    let googleEmail = Expression<String>("googleEmail")
    let accessToken = Expression<String>("accessToken")
    let getTokenTime = Expression<String>("getTokenTime")
    
    var DriveFileArray = [App.DriveFileStruct]()
    
    let filePath = Expression<String>("filePath")
    var jsonHeader:[String:String] = [
        "Content-Type": "application/json",
        "X-Auth-Token": UserDefaults.standard.string(forKey: "token") ?? "nil",
        "Cookie": UserDefaults.standard.string(forKey: "cookie") ?? "nil"
    ]
    
    enum sortByEnum{
        case none
        case asc
        case desc
    }
    var sortByState = sortByEnum.asc
    
    func jsonToSqlite(getArray: [App.DeviceStruct]){
        do {
            let documentDirectory = try FileManager.default.url(for: .applicationSupportDirectory, in: .allDomainsMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("oneViewList").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
        
        if(tableExists(tableName: "oneViewList")){
            dropTable(table: oneViewListTable)
        }
        
        createOneViewListTable()
//        let insertData = oneViewListTable.insert(deviceNm <- "wow")
//        do {
//            try self.database.run(insertData)
//            print("table Inserted Data")
//
//        }catch{
//            print(error)
//        }
        do {
            try self.database.transaction {
                for (index,device) in getArray.enumerated() {
                    try self.database.run(self.oneViewListTable.insert(devNm <- getArray[index].devNm, devUuid <- getArray[index].devUuid,  logical <- getArray[index].logical, mkngVndrNm <- getArray[index].mkngVndrNm, newFlag <- getArray[index].newFlag, onoff <- getArray[index].onoff, osCd <- getArray[index].osCd, osDesc <- getArray[index].osDesc, osNm <- getArray[index].osNm, osNm <- getArray[index].osNm, userId <- getArray[index].userId, userName <- getArray[index].userName))
                }
            }
        } catch {
            
        }
      
        
//        listSqlite()
    }
    
    func listSqlite(sortBy:sortByEnum) -> [App.DeviceStruct] {
        do {
            let documentDirectory = try FileManager.default.url(for: .applicationSupportDirectory, in: .allDomainsMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("oneViewList").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
        
        self.DeviceArray.removeAll()
        var tableOrder = self.oneViewListTable.order()
        do {
            switch sortBy {
            case .asc:
                tableOrder = self.oneViewListTable.order(devNm.asc)
                break
            case .desc:
                tableOrder = self.oneViewListTable.order(devNm.desc)
                break
            case .none:
                tableOrder = self.oneViewListTable.order()
            }
            let devices = try database.prepare(tableOrder)
            for device in devices {
//                print("table data: id : \(device[id]), deviceData : \(device)")
                let devNmValue = "\(device[devNm])"
                let devUuidValue = "\(device[devUuid])"
                let logical = "\(device[self.logical])"
                let mkngVndrNmValue = "\(device[mkngVndrNm])"
                let newFlag = "\(device[self.newFlag])"
                let onoffValue = "\(device[onoff])"
                let osCdValue = "\(device[osCd])"
                let osDescValue = "\(device[osDesc])"
                let osNmValue = "\(device[osNm])"
                let userIdValue = "\(device[userId])"
                let userNameValue = "\(device[userName])"
                                
                let deviceStruct = App.DeviceStruct(devNm : devNmValue, devUuid : devUuidValue, logical:logical, mkngVndrNm : mkngVndrNmValue, newFlag : newFlag, onoff : onoffValue, osCd : osCdValue, osDesc : osDescValue, osNm : osNmValue, userId : userIdValue, userName : userNameValue)
                
                DeviceArray.append(deviceStruct)
            }
            
            
            return DeviceArray
        }catch{
            print(error)
            return DeviceArray
            
        }
    }
    func createOneViewListTable(){
        let createTable = self.oneViewListTable.create { (table) in
            table.column(id, primaryKey: true)
            table.column(devNm)
            table.column(devUuid)
            table.column(logical)
            table.column(mkngVndrNm)
            table.column(newFlag)
            table.column(onoff)
            table.column(osCd)
            table.column(osDesc)
            table.column(osNm)
            table.column(userId)
            table.column(userName)
            
        }
        do {
            try self.database.run(createTable)
            print("Created table")
            
        }catch{
            print("Created table error : \(error)")
            print(error)
        }
    }
    
    func createGoogleDriveListTable(){
        let createTable = self.googleDriveFileListTable.create { (table) in
            table.column(id, primaryKey: true)
            table.column(fileId)
            table.column(kind)
            table.column(mimeType)
            table.column(name)
            table.column(createdTime)
            table.column(modifiedTime)
            table.column(parents)
            table.column(fileExtension)
            table.column(foldrWholePath)
            table.column(size)
            table.column(thumbnailLink)
            
        }
        do {
            try self.database.run(createTable)
            print("Created table")
            
        }catch{
            print("Created table error : \(error)")
            print(error)
        }
    }
    
    func localFileToSqlite(id: String, path:String){
        do {
            let documentDirectory = try FileManager.default.url(for: .applicationSupportDirectory, in: .allDomainsMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("localFileListTable").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
        
        if(tableExists(tableName: "localFileListTable")){
            
        } else {
            createLocalFileListTable()
        }
        
        do {
            try self.database.run(self.localFileListTable.insert(fileId <- id, filePath <- path))
        } catch {
            print(error)
        }
    }
    
    
    func createLocalFileListTable(){
        let createTable = self.localFileListTable.create { (table) in
            table.column(id, primaryKey: true)
            table.column(fileId)
            table.column(filePath)
            
        }
        do {
            try self.database.run(createTable)
            print("Created table")
            
        }catch{
            print("Created table error : \(error)")
            print(error)
        }
    }
    func getLocalFileId(path:String) -> String {
        do {
            let documentDirectory = try FileManager.default.url(for: .applicationSupportDirectory, in: .allDomainsMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("localFileListTable").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
        
        var fileId = ""
        let tableOrder = self.localFileListTable.order()
        do {
            let devices = try database.prepare(tableOrder)
            for device in devices {
                //                print("table data: id : \(device[id]), deviceData : \(device)")
                let filePath = "\(device[self.filePath])"
                if(filePath == path){
                    fileId = "\(device[self.fileId])"
                }
            }
            return fileId
        }catch{
            print(error)
            return fileId
        }
    }
    
    func dropTable(table:Table){
        do {
            try self.database.run(table.drop(ifExists: true))
            print("table dropped")
        } catch {
            print("error")
        }
    }
    func tableExists(tableName: String) -> Bool {
        do {
            let count:Int64 = try self.database.scalar(
                "SELECT EXISTS(SELECT name FROM sqlite_master WHERE name = ?)", tableName
                ) as! Int64
                if count > 0{
                    return true
                }
                else{
                    return false
                }
        } catch {
            return false
        }
       
    }
    
   
    func googleDriveToSqlite(getArray: [App.DriveFileStruct]){
        do {
            let documentDirectory = try FileManager.default.url(for: .applicationSupportDirectory, in: .allDomainsMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("googleDriveFileList").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
        
        if(tableExists(tableName: "googleDriveFileList")){
            dropTable(table:googleDriveFileListTable)
        }
        
        createGoogleDriveListTable()
        do {
            try self.database.transaction {
                for (index,device) in getArray.enumerated() {
                    try self.database.run(self.googleDriveFileListTable.insert(fileId <- getArray[index].fileId, kind <- getArray[index].kind, mimeType <- getArray[index].mimeType, name <- getArray[index].name, createdTime <- getArray[index].createdTime, modifiedTime <- getArray[index].modifiedTime, parents <- getArray[index].parents, fileExtension <- getArray[index].fileExtension, foldrWholePath <- getArray[index].foldrWholePath, size <- getArray[index].size, thumbnailLink <- getArray[index].thumbnailLink))
                }
            }
        } catch {
            
        }
        self.database = nil
        
    }
    
    func googleDrivelistSqlite(sortBy:sortByEnum) -> [App.DriveFileStruct] {
        do {
            let documentDirectory = try FileManager.default.url(for: .applicationSupportDirectory, in: .allDomainsMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("googleDriveFileList").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
        
        self.DriveFileArray.removeAll()
        var tableOrder = self.googleDriveFileListTable.order()
        do {
            switch sortBy {
            case .asc:
                tableOrder = self.googleDriveFileListTable.order(name.asc)
                break
            case .desc:
                tableOrder = self.googleDriveFileListTable.order(name.desc)
                break
            case .none:
                tableOrder = self.googleDriveFileListTable.order()
            }
            let devices = try database.prepare(tableOrder)
            for device in devices {
                //                print("table data: id : \(device[id]), deviceData : \(device)")
                let fileId = "\(device[self.fileId])"
                let kind = "\(device[self.kind])"
                let mimeType = "\(device[self.mimeType])"
                let name = "\(device[self.name])"
                let createdTime = "\(device[self.createdTime])"
                let modifiedTime = "\(device[self.modifiedTime])"
                let parents = "\(device[self.parents])"
                let fileExtension = "\(device[self.fileExtension])"
                let foldrWholePath = "\(device[self.foldrWholePath])"
                let size = device[self.size]
                let thumbnailLink = device[self.thumbnailLink]
                
                let deviceStruct = App.DriveFileStruct(fileId : fileId, kind : kind, mimeType : mimeType, name : name, createdTime:createdTime, modifiedTime:modifiedTime, parents:parents, fileExtension:fileExtension,  size:size, foldrWholePath:foldrWholePath, thumbnailLink:thumbnailLink)
                
                DriveFileArray.append(deviceStruct)
            }
            self.database = nil
            return DriveFileArray
            
        }catch{
            print(error)
            self.database = nil
            return DriveFileArray
            
        }
        
    }
    
    func googleDrivelistByName(sortBy:sortByEnum, fileNm:String) -> [App.DriveFileStruct] {
        do {
            let documentDirectory = try FileManager.default.url(for: .applicationSupportDirectory, in: .allDomainsMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("googleDriveFileList").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
        
        self.DriveFileArray.removeAll()
        var tableOrder = self.googleDriveFileListTable.order()
        do {
            switch sortBy {
            case .asc:
                tableOrder = self.googleDriveFileListTable.order(name.asc)
                break
            case .desc:
                tableOrder = self.googleDriveFileListTable.order(name.desc)
                break
            case .none:
                tableOrder = self.googleDriveFileListTable.order()
            }
            let devices = try database.prepare(tableOrder)
            for device in devices {
                //                print("table data: id : \(device[id]), deviceData : \(device)")
                let fileId = "\(device[self.fileId])"
                let kind = "\(device[self.kind])"
                let mimeType = "\(device[self.mimeType])"
                let name = "\(device[self.name])"
                let createdTime = "\(device[self.createdTime])"
                let modifiedTime = "\(device[self.modifiedTime])"
                let parents = "\(device[self.parents])"
                let fileExtension = "\(device[self.fileExtension])"
                let foldrWholePath = "\(device[self.foldrWholePath])"
                let size = device[self.size]
                let thumbnailLink = device[self.thumbnailLink]
                if(name.contains(fileNm)){
                    let deviceStruct = App.DriveFileStruct(fileId : fileId, kind : kind, mimeType : mimeType, name : name, createdTime:createdTime, modifiedTime:modifiedTime, parents:parents, fileExtension:fileExtension,  size:size, foldrWholePath:foldrWholePath, thumbnailLink:thumbnailLink)
                    DriveFileArray.append(deviceStruct)
                }
                
            }
            self.database = nil
            return DriveFileArray
        }catch{
            print(error)
            self.database = nil
            return DriveFileArray
            
        }
    }
    
    func googleEmailToSqlite(getEmail: String, getAccessToken:String, getTime:String){
        do {
            let documentDirectory = try FileManager.default.url(for: .applicationSupportDirectory, in: .allDomainsMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("googleEmailListTable").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
        
        if(tableExists(tableName: "googleEmailListTable")){
            do {
                try self.database.run(self.googleEmailListTable.insert(googleEmail <- getEmail, accessToken <- getAccessToken, getTokenTime <- getTime))
            } catch {
                print(error)
            }
        } else {
            createGoogleEmailListTable()
        }
        
        
        self.database = nil
    }
    func googleAccessTokenUpdate(getEmail: String, getAccessToken:String, getTime:String){
        
        do {
            let documentDirectory = try FileManager.default.url(for: .applicationSupportDirectory, in: .allDomainsMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("googleEmailListTable").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
        if(tableExists(tableName: "googleEmailListTable")){
            let alice = googleEmailListTable.filter(googleEmail == getEmail)
            do {
                try self.database.run(alice.update(accessToken <- getAccessToken, getTokenTime <- getTime))
                print("access token updated")
            } catch {
                print(error)
            }
        } else {
            createGoogleEmailListTable()
        }
        
        self.database = nil
    }
    
    func googleEmailListTableExistCheck(){
        do {
            let documentDirectory = try FileManager.default.url(for: .applicationSupportDirectory, in: .allDomainsMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("googleEmailListTable").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
        if(tableExists(tableName: "googleEmailListTable")){
            self.database = nil
        } else {
            createGoogleEmailListTable()
        }
    }
    func createGoogleEmailListTable(){
        let createTable = self.googleEmailListTable.create { (table) in
            table.column(id, primaryKey: true)
            table.column(googleEmail)
            table.column(accessToken)
            table.column(getTokenTime)
            
        }
        do {
            try self.database.run(createTable)

            print("Created createGoogleEmailListTable")
           

        }catch{
            print("Created createGoogleEmailListTable error : \(error)")
            print(error)
        }
        
        self.database = nil
    }
    
    func googleEmailExistenceCheck(email:String) -> Bool {
        do {
            let documentDirectory = try FileManager.default.url(for: .applicationSupportDirectory, in: .allDomainsMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("googleEmailListTable").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
        
        var check = false
        let tableOrder = self.googleEmailListTable.order()
        do {
            let devices = try database.prepare(tableOrder)
            for device in devices {
                let sliteEmail = "\(device[self.googleEmail])"
                print("sliteEmail : \(sliteEmail)")
                if(sliteEmail == email){
                    check = true
                }
            }
            return check
        }catch{
            print(error)
            return false
        }
        self.database = nil
    }
    
    
    func getAccessToken(email:String) -> String {
        var database: Connection!
        do {
            let documentDirectory = try FileManager.default.url(for: .applicationSupportDirectory, in: .allDomainsMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("googleEmailListTable").appendingPathExtension("sqlite3")
            database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
        
        var token = ""
        let tableOrder = self.googleEmailListTable.order()
        do {
            let devices = try self.database.prepare(tableOrder)
            for device in devices {
                let sliteEmail = "\(device[self.googleEmail])"
                print("sliteEmail : \(sliteEmail)")
                if(sliteEmail == email){
                    token = device[accessToken]
                }
            }
            self.database = nil
            return token
        }catch{
            print(error)
            self.database = nil
            return token
        }
        
    }
    
    func getTokenTime(email:String) -> String {
        var database: Connection!
        do {
            let documentDirectory = try FileManager.default.url(for: .applicationSupportDirectory, in: .allDomainsMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("googleEmailListTable").appendingPathExtension("sqlite3")
            database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
        
        var token = ""
        let tableOrder = self.googleEmailListTable.order()
        do {
            let devices = try self.database.prepare(tableOrder)
            for device in devices {
                let sliteEmail = "\(device[self.googleEmail])"
                print("sliteEmail : \(sliteEmail)")
                if(sliteEmail == email){
                    token = device[getTokenTime]
                }
            }
            self.database = nil
            return token
        }catch{
            print(error)
            self.database = nil
            return token
        }
        
    }
    
    func googleEmailListArray() -> [String] {
        var emailArray = [String]()
        emailArray.removeAll()
        do {
            let documentDirectory = try FileManager.default.url(for: .applicationSupportDirectory, in: .allDomainsMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("googleEmailListTable").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
        
        var tableOrder = self.googleEmailListTable.order()
        do {
            let devices = try self.database.prepare(tableOrder)
            for device in devices {
                print("table data: googleEmail : \(device[googleEmail])")
                let email = "\(device[self.googleEmail])"
                if(email.isEmpty){
                    
                } else {
                    emailArray.append(email)
                }
                
            }
            database = nil
            return emailArray
        }catch{
            print(error)
            database = nil
            return emailArray
        }
    }
    
}

