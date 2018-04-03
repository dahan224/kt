//
//  FileUtil.swift
//  KT
//
//  Created by 이다한 on 2018. 2. 7..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit

class FileUtil {
    var localFileArray:[App.LocalFiles] = []
    var localFolderArray:[App.Folders] = []
    
    func getFolderList() -> [App.Folders] {
        localFolderArray.removeAll()
        let documentsDirectory =  try? FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileEnumerator = FileManager.default.enumerator(at: documentsDirectory!, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions())
        while let file = fileEnumerator?.nextObject() as? URL {
            let fileSavedPath = file.path
            do {
                let attribute = try FileManager.default.attributesOfItem(atPath: fileSavedPath)
                let fileName:String = (NSURL(fileURLWithPath: file.lastPathComponent).deletingPathExtension?.lastPathComponent)!
                let fileExtension = file.pathExtension
                let folderCreateDate: Date = attribute[FileAttributeKey.creationDate] as! Date
                let modifiedDate: Date = attribute[FileAttributeKey.modificationDate] as! Date
                
                if(fileExtension.isEmpty && !fileName.contains("Trash")){
                    var foldrWholePathNm = "/Mobile"
                    if let folderNmArray = URLComponents(url: file, resolvingAgainstBaseURL: true)?.path.components(separatedBy: "/") {
                        let documentIndex = folderNmArray.index(of: "Documents")
                        for (index, path) in folderNmArray.enumerated() {
                            if(documentIndex! < index && index < folderNmArray.count){
                                foldrWholePathNm += "/\(folderNmArray[index])"
                            }
                        }
                    }
                    if(fileExtension.isEmpty && !foldrWholePathNm.contains("Trash")){
                        let folder = App.Folders(cmd : "C", userId : App.defaults.userId, devUuid : Util.getUuid(), foldrNm : fileName, foldrWholePathNm: foldrWholePathNm, cretDate : Util.date(text: folderCreateDate), amdDate : Util.date(text: modifiedDate))
                        localFolderArray.append(folder)
                    }
                    
                }
            } catch {
            }
        }
        return localFolderArray
    }
    
    func getFileLIst() -> [App.LocalFiles] {
        localFileArray.removeAll()
        let documentsDirectory =  try? FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileEnumerator = FileManager.default.enumerator(at: documentsDirectory!, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions())
        while let file = fileEnumerator?.nextObject() as? URL {
            let fileSavedPath = file.path
            do {
                let attribute = try FileManager.default.attributesOfItem(atPath: fileSavedPath)
                let fileName:String = (NSURL(fileURLWithPath: file.lastPathComponent).deletingPathExtension?.lastPathComponent)!
                let fileExtension = file.pathExtension
                let modifiedDate: Date = attribute[FileAttributeKey.modificationDate] as! Date
                let decodedFileName:String = fileName.removingPercentEncoding!
                
                let fileCreateDate: Date = attribute[FileAttributeKey.creationDate] as! Date
                
                if(!fileExtension.isEmpty && !fileName.contains("Trash")){
                    var foldrWholePathNm = "/Mobile"
                    if let folderNmArray = URLComponents(url: file, resolvingAgainstBaseURL: true)?.path.components(separatedBy: "/") {
                        let documentIndex = folderNmArray.index(of: "Documents")
                        let pathLastIndex = (folderNmArray.count) - 1
                        for (index, path) in folderNmArray.enumerated() {
                            if(documentIndex! < index && index < pathLastIndex){
                                foldrWholePathNm += "/\(folderNmArray[index])"
                            }
                        }
                        if let size = attribute[FileAttributeKey.size] as? NSNumber {
                            if(!fileExtension.isEmpty && !foldrWholePathNm.contains("Trash")){
                                let files = App.LocalFiles(cmd:"C",userId:App.defaults.userId,devUuid:Util.getUuid(),fileNm:decodedFileName,etsionNm:fileExtension,fileSize:size.stringValue,cretDate:Util.date(text: fileCreateDate),amdDate:Util.date(text: modifiedDate), foldrWholePathNm: foldrWholePathNm, savedPath: fileSavedPath)
                                localFileArray.append(files)
                            }
                        }
                    }
                }
            } catch {
                
            }
            
        }
        return localFileArray
    }
   
    func getFileUrl(fileNm:String, amdDate:String) -> URL?{
        let documentsDirectory =  try? FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileEnumerator = FileManager.default.enumerator(at: documentsDirectory!, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions())
        var retrunUrl:URL?
        while let file = fileEnumerator?.nextObject() as? URL{
            let fileSavedPath = file.path
            do {
                    let attribute = try FileManager.default.attributesOfItem(atPath: fileSavedPath)
                    let fileName:String = (NSURL(fileURLWithPath: file.lastPathComponent).deletingPathExtension?.lastPathComponent)!
                    let fileExtension = file.pathExtension
                    let folderCreateDate: Date = attribute[FileAttributeKey.creationDate] as! Date
                    let modifiedDate: Date = attribute[FileAttributeKey.modificationDate] as! Date
                    let localFilFullName = "\(fileName).\(fileExtension)"
                    let decodedFileName:String = localFilFullName.removingPercentEncoding!
                    print("fileExtension : \(fileExtension)")
                    print("fileSavedPath : \(fileSavedPath)")
                    let stringModifiedDate = Util.date(text: modifiedDate)
                    print("fileNm : \(fileNm), localFilFullName : \(localFilFullName), decodedFileName: \(decodedFileName), amdDate: \(amdDate) , stringModifiedDate : \(stringModifiedDate)")
//                    if(fileNm == decodedFileName && amdDate == stringModifiedDate){
                    if(fileNm == decodedFileName ){
                        retrunUrl = file
                        break
                    }
                
                } catch {
                    print("Error: \(error)")
                }
            }
      
        print("return url : \(retrunUrl)")
        
        return retrunUrl
    }
    
    func getFilePath(fileNm:String, amdDate:String) -> String{
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var returnPath = ""
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            print("files : \(fileURLs)")
            for (_, f) in fileURLs.enumerated() {
                do {
                    let attribute = try FileManager.default.attributesOfItem(atPath: f.path)
                    let fileName:String = (NSURL(fileURLWithPath: f.lastPathComponent).deletingPathExtension?.lastPathComponent)!
                    let fileExtension = f.pathExtension
                    var localFilFullName = "\(fileName).\(fileExtension)"
                    if(fileExtension.isEmpty){
                        localFilFullName = fileName
                    } 
                    
                    let decodedFileName:String = localFilFullName.removingPercentEncoding!
                    let fileSavedPath = f.path
                    print("fileSavedPath  : \(fileSavedPath)")
                    let fileCreateDate: Date = attribute[FileAttributeKey.creationDate] as! Date
                    let modifiedDate: Date = attribute[FileAttributeKey.modificationDate] as! Date
                    let stringModifiedDate = Util.date(text: modifiedDate)
                    print("for remove fileNm : \(fileNm), localFilFullName : \(localFilFullName), amdDate: \(amdDate) , stringModifiedDate : \(stringModifiedDate), decodedFileName: \(decodedFileName)")
//                    if(fileNm == decodedFileName && amdDate == stringModifiedDate){
                    if(fileNm == decodedFileName){
                        returnPath = fileSavedPath
                        print("return path : \(returnPath)")
                    }
                    
                    
                } catch {
                    print("Error: \(error)")
                }
            }
            
        } catch {
            print(error.localizedDescription)
            
        }
        print("return path : \(returnPath)")
        return returnPath
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
