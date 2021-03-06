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
    
    let id = Expression<Int>("id")
    let devNm = Expression<String>("devNm")
    let devUuid = Expression<String>("devUuid")
    let mkngVndrNm = Expression<String>("mkngVndrNm")
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
    var DriveFileArray = [App.DriveFileStruct]()
    
    let filePath = Expression<String>("filePath")
    
    
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
                    try self.database.run(self.oneViewListTable.insert(devNm <- getArray[index].devNm, devUuid <- getArray[index].devUuid, mkngVndrNm <- getArray[index].mkngVndrNm, onoff <- getArray[index].onoff, osCd <- getArray[index].osCd, osDesc <- getArray[index].osDesc, osNm <- getArray[index].osNm, osNm <- getArray[index].osNm, userId <- getArray[index].userId, userName <- getArray[index].userName))
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
                let mkngVndrNmValue = "\(device[mkngVndrNm])"
                let onoffValue = "\(device[onoff])"
                let osCdValue = "\(device[osCd])"
                let osDescValue = "\(device[osDesc])"
                let osNmValue = "\(device[osNm])"
                let userIdValue = "\(device[userId])"
                let userNameValue = "\(device[userName])"
                                
                let deviceStruct = App.DeviceStruct(devNm : devNmValue, devUuid : devUuidValue, mkngVndrNm : mkngVndrNmValue, onoff : onoffValue, osCd : osCdValue, osDesc : osDescValue, osNm : osNmValue, userId : userIdValue, userName : userNameValue)
                
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
            table.column(mkngVndrNm)
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
                    try self.database.run(self.googleDriveFileListTable.insert(fileId <- getArray[index].fileId, kind <- getArray[index].kind, mimeType <- getArray[index].mimeType, name <- getArray[index].name))
                }
            }
        } catch {
            
        }
        
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
                
                let deviceStruct = App.DriveFileStruct(fileId : fileId, kind : kind, mimeType : mimeType, name : name)
                
                DriveFileArray.append(deviceStruct)
            }
            
            return DriveFileArray
        }catch{
            print(error)
            return DriveFileArray
            
        }
    }
}

