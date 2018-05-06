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
                let size = attribute[FileAttributeKey.size] as? NSNumber
                let fileIsDirectory = file.isDirectory
                
                if(fileIsDirectory && !fileName.contains("Trash")){
                    print("size_folder : \(size), \(file.isDirectory)")
                    var foldrWholePathNm = "/Mobile"
                    if let folderNmArray = URLComponents(url: file, resolvingAgainstBaseURL: true)?.path.components(separatedBy: "/") {
                        let documentIndex = folderNmArray.index(of: "Documents")
                        for (index, path) in folderNmArray.enumerated() {
                            if(documentIndex! < index && index < folderNmArray.count - 1){
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
                let size = attribute[FileAttributeKey.size] as? NSNumber
                
                let fileCreateDate: Date = attribute[FileAttributeKey.creationDate] as! Date
                let fileIsDirectory = file.isDirectory
                if(!fileIsDirectory && !fileName.contains("Trash")){
                    print("size_file : \(size), \(file.isDirectory)")
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
                            if(!fileIsDirectory && !foldrWholePathNm.contains("Trash")){
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
    
    func getFileUrlWithFoldr(fileNm:String, foldrWholePathNm:String, amdDate:String) -> URL?{
        let documentsDirectory =  try? FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileEnumerator = FileManager.default.enumerator(at: documentsDirectory!, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions())
        var retrunUrl:URL?
  
        while let file = fileEnumerator?.nextObject() as? URL{
            let fileSavedPath = file.path
            do {
                let attribute = try FileManager.default.attributesOfItem(atPath: file.path)
                let fileName:String = (NSURL(fileURLWithPath: file.lastPathComponent).deletingPathExtension?.lastPathComponent)!
                let fileExtension = file.pathExtension
                var localFilFullName = "\(fileName).\(fileExtension)"
                if(fileExtension.isEmpty){
                    localFilFullName = fileName
                }
                let fullPathFromParameter = "\(foldrWholePathNm)/\(fileNm)"
                let folderNmArray = fileSavedPath.components(separatedBy: "/")
                let documentIndex = folderNmArray.index(of: "Documents")
                var revisedSavedPath = "/Mobile"
                for (index, path) in folderNmArray.enumerated() {
                    
                    if(documentIndex! < index && index < folderNmArray.count){
                        revisedSavedPath += "/\(folderNmArray[index])"
                    }
                }
                print("fullPathFromParameter : \(fullPathFromParameter), revisedSavedPath:\(revisedSavedPath)")
                
                let decodedFileName:String = localFilFullName.removingPercentEncoding!
                revisedSavedPath = revisedSavedPath.removingPercentEncoding!
                print("fullPathFromParameter : \(fullPathFromParameter), revisedSavedPath:\(revisedSavedPath)")
                
                let modifiedDate: Date = attribute[FileAttributeKey.modificationDate] as! Date
                let stringModifiedDate = Util.date(text: modifiedDate)
                print("fileNm : \(fileNm), localFilFullName : \(localFilFullName), amdDate: \(amdDate) , stringModifiedDate : \(stringModifiedDate), decodedFileName: \(decodedFileName)")
                //                    if(fileNm == decodedFileName && amdDate == stringModifiedDate){
                if(fileNm == decodedFileName && revisedSavedPath == fullPathFromParameter && !fileExtension.isEmpty && !foldrWholePathNm.contains("Trash")){
                    retrunUrl = file
                    print("return url : \(retrunUrl)")
                    break
                }
                
                
            } catch {
                print("Error: \(error)")
            }
        }
        
        print("return path : \(retrunUrl)")
        return retrunUrl
    }
    func getFilePath(fileNm:String, amdDate:String) -> String{
        let documentsDirectory =  try? FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileEnumerator = FileManager.default.enumerator(at: documentsDirectory!, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions())
        var returnPath = ""
        while let file = fileEnumerator?.nextObject() as? URL{
            let fileSavedPath = file.path
                do {
                    let attribute = try FileManager.default.attributesOfItem(atPath: file.path)
                    let fileName:String = (NSURL(fileURLWithPath: file.lastPathComponent).deletingPathExtension?.lastPathComponent)!
                    let fileExtension = file.pathExtension
                    var localFilFullName = "\(fileName).\(fileExtension)"
                    if(fileExtension.isEmpty){
                        localFilFullName = fileName
                    } 
                    let decodedFileName:String = localFilFullName.removingPercentEncoding!
                    print("fileSavedPath  : \(fileSavedPath)")
                    let fileCreateDate: Date = attribute[FileAttributeKey.creationDate] as! Date
                    let modifiedDate: Date = attribute[FileAttributeKey.modificationDate] as! Date
                    let stringModifiedDate = Util.date(text: modifiedDate)
                    print("for remove fileNm : \(fileNm), localFilFullName : \(localFilFullName), amdDate: \(amdDate) , stringModifiedDate : \(stringModifiedDate), decodedFileName: \(decodedFileName)")
//                    if(fileNm == decodedFileName && amdDate == stringModifiedDate){
                    if(fileNm == decodedFileName){
                        returnPath = fileSavedPath
                        print("return path : \(returnPath)")
                        break
                    }
                    
                    
                } catch {
                    print("Error: \(error)")
                }
            }
        
        print("return path : \(returnPath)")
        return returnPath
    }
    
    
    func getFilePathWithFoldr(fileNm:String, foldrWholePathNm:String, amdDate:String) -> String{
        let documentsDirectory =  try? FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileEnumerator = FileManager.default.enumerator(at: documentsDirectory!, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions())
        var returnPath = ""
        while let file = fileEnumerator?.nextObject() as? URL{
            let fileSavedPath = file.path
            do {
                let attribute = try FileManager.default.attributesOfItem(atPath: file.path)
                let fileName:String = (NSURL(fileURLWithPath: file.lastPathComponent).deletingPathExtension?.lastPathComponent)!
                let fileExtension = file.pathExtension
                var localFilFullName = "\(fileName).\(fileExtension)"
                if(fileExtension.isEmpty){
                    localFilFullName = fileName
                }
                let fullPathFromParameter = "\(foldrWholePathNm)/\(fileNm)"
                let folderNmArray = fileSavedPath.components(separatedBy: "/")
                let documentIndex = folderNmArray.index(of: "Documents")
                var revisedSavedPath = "/Mobile"
                for (index, path) in folderNmArray.enumerated() {
                    
                    if(documentIndex! < index && index < folderNmArray.count){
                        revisedSavedPath += "/\(folderNmArray[index])"
                    }
                }
                print("fullPathFromParameter : \(fullPathFromParameter), revisedSavedPath:\(revisedSavedPath)")
                
                let decodedFileName:String = localFilFullName.removingPercentEncoding!
                revisedSavedPath = revisedSavedPath.removingPercentEncoding!
                print("fullPathFromParameter : \(fullPathFromParameter), revisedSavedPath:\(revisedSavedPath)")
                
                let modifiedDate: Date = attribute[FileAttributeKey.modificationDate] as! Date
                let stringModifiedDate = Util.date(text: modifiedDate)
                print("for remove fileNm : \(fileNm), localFilFullName : \(localFilFullName), amdDate: \(amdDate) , stringModifiedDate : \(stringModifiedDate), decodedFileName: \(decodedFileName)")
                //                    if(fileNm == decodedFileName && amdDate == stringModifiedDate){
                if(fileNm == decodedFileName && revisedSavedPath == fullPathFromParameter){
                    returnPath = fileSavedPath
                    print("return path : \(returnPath)")
                    break
                }
                
                
            } catch {
                print("Error: \(error)")
            }
        }
        
        print("return path : \(returnPath)")
        return returnPath
    }
    
    func getFolderPathWithFoldr(fileNm:String, foldrWholePathNm:String, amdDate:String) -> String{
        let documentsDirectory =  try? FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileEnumerator = FileManager.default.enumerator(at: documentsDirectory!, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions())
        var returnPath = ""
        while let file = fileEnumerator?.nextObject() as? URL{
            let fileSavedPath = file.path
            do {
                let attribute = try FileManager.default.attributesOfItem(atPath: file.path)
                let fileName:String = (NSURL(fileURLWithPath: file.lastPathComponent).deletingPathExtension?.lastPathComponent)!
                let fileExtension = file.pathExtension
                if(fileExtension.isEmpty && !fileName.contains("Trash")){
                    let fullPathFromParameter = foldrWholePathNm
                    let folderNmArray = fileSavedPath.components(separatedBy: "/")
                    let documentIndex = folderNmArray.index(of: "Documents")
                    var revisedSavedPath = "/Mobile"
                    for (index, path) in folderNmArray.enumerated() {
                        
                        if(documentIndex! < index && index < folderNmArray.count){
                            revisedSavedPath += "/\(folderNmArray[index])"
                        }
                    }
//                    print("fullPathFromParameter : \(fullPathFromParameter), revisedSavedPath:\(revisedSavedPath)")
                    
                    let decodedFileName:String = fileName.removingPercentEncoding!
                    revisedSavedPath = revisedSavedPath.removingPercentEncoding!
                    print("fullPathFromParameter : \(fullPathFromParameter), revisedSavedPath:\(revisedSavedPath)")
                    
                    let modifiedDate: Date = attribute[FileAttributeKey.modificationDate] as! Date
                    let stringModifiedDate = Util.date(text: modifiedDate)
//                    print("for remove fileNm : \(fileNm), amdDate: \(amdDate) , stringModifiedDate : \(stringModifiedDate), decodedFileName: \(decodedFileName)")
                    //                    if(fileNm == decodedFileName && amdDate == stringModifiedDate){
                    if(fileNm == decodedFileName && revisedSavedPath == fullPathFromParameter && fileExtension.isEmpty){
                        returnPath = fileSavedPath
                        print("return path : \(returnPath)")
                        break
                    }
                }
            } catch {
                print("Error: \(error)")
            }
        }
        
        print("return path : \(returnPath)")
        return returnPath
    }
    func getFileUrlFromPath(filePath:String) -> URL?{
        let documentsDirectory =  try? FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileEnumerator = FileManager.default.enumerator(at: documentsDirectory!, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions())
        var retrunUrl:URL?
        while let file = fileEnumerator?.nextObject() as? URL{
            let fileSavedPath = file.path
            if(filePath == fileSavedPath){
               retrunUrl = file
                break
            }
        }
        print("return url : \(retrunUrl)")
        return retrunUrl
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
    func covertFileSize(getSize:String) -> String {
        var convertedValue: Double = Double(getSize)!
        var multiplyFactor = 0
        let tokens = ["bytes", "KB", "MB", "GB", "TB", "PB",  "EB",  "ZB", "YB"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
    }
    
}
