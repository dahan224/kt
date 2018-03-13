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
    func getFileList() -> [App.LocalFiles]{
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            print("files : \(fileURLs)")
            for (_, f) in fileURLs.enumerated() {
                do {
                    let attribute = try FileManager.default.attributesOfItem(atPath: f.path)
                    let fileName:String = (NSURL(fileURLWithPath: f.lastPathComponent).deletingPathExtension?.lastPathComponent)!
                    let fileExtension = f.pathExtension
                    let decodedFileName:String = fileName.removingPercentEncoding!
                    
//                    print("fileExtension : \(fileExtension)")
                    let fileSavedPath = f.path
//                    print("fileSavedPath : \(fileSavedPath)")
                    _ = f.lastPathComponent
                    let fileCreateDate: Date = attribute[FileAttributeKey.creationDate] as! Date
                    let modifiedDate: Date = attribute[FileAttributeKey.modificationDate] as! Date
                    if let folderNmArray = URLComponents(string: fileSavedPath)?.path.components(separatedBy: "/") {
                        let folderNm = folderNmArray[(folderNmArray.count) - 2]
                        if let size = attribute[FileAttributeKey.size] as? NSNumber {
                            //                        print("savedPath : \(fileSavedPath), fileLasPathComponent : \(fileLasPathComponent), \(folderNm)")
                            var foldrWholePathNm = "/Mobile"
                            
                            if(folderNm == "Documents"){
                            } else {
                                foldrWholePathNm += "/\(folderNm)"
                            }
                            
                            if(!fileExtension.isEmpty){
                                let files = App.LocalFiles(cmd:"C",userId:App.defaults.userId,devUuid:Util.getUuid(),fileNm:decodedFileName,etsionNm:fileExtension,fileSize:size.stringValue,cretDate:Util.date(text: fileCreateDate),amdDate:Util.date(text: modifiedDate), foldrWholePathNm: foldrWholePathNm, savedPath: fileSavedPath)
                                
                                localFileArray.append(files)
                            }
                            
//                            print("localFileArray : \(localFileArray)")
                            
                        }
                        
                    }
                    
                    
                } catch {
                    print("Error: \(error)")
                }
            }
            
        } catch {
            print(error.localizedDescription)
            
        }
        print("return localFileArray : \(localFileArray)")
        return localFileArray
    }
    
    func getSubDirectoryFileList(documentsURL:URL) -> [App.LocalFiles]{
        let fileManager = FileManager.default
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            print("files : \(fileURLs)")
            for (_, f) in fileURLs.enumerated() {
                do {
                    let attribute = try FileManager.default.attributesOfItem(atPath: f.path)
                    let fileName:String = (NSURL(fileURLWithPath: f.lastPathComponent).deletingPathExtension?.lastPathComponent)!
                    let fileExtension = f.pathExtension
                    let decodedFileName:String = fileName.removingPercentEncoding!
                    
                    print("fileName : \(fileName), fileExtension : \(fileExtension), encodedPath: \(f.path)")
                    let fileSavedPath = f.path
                    print("fileSavedPath : \(fileSavedPath)")
                    
                    _ = f.lastPathComponent
                    let fileCreateDate: Date = attribute[FileAttributeKey.creationDate] as! Date
                    let modifiedDate: Date = attribute[FileAttributeKey.modificationDate] as! Date
                    if let folderNmArray = URLComponents(string: fileSavedPath)?.path.components(separatedBy: "/") {
                        let documentIndex = folderNmArray.index(of: "Documents")
                        let folderNm = folderNmArray[(folderNmArray.count) - 2]
                        let pathLastIndex = (folderNmArray.count) - 1
                        var foldrWholePathNm = "/Mobile"
                        for (index, path) in folderNmArray.enumerated() {
                            if(documentIndex! < index && index < pathLastIndex){
                                    foldrWholePathNm += "/\(folderNmArray[index])"
                            }
                            
                        }
                        print("foldrWholePathNm : \(foldrWholePathNm)")
                        print("fileName : \(fileName), fileExtension : \(fileExtension), size : \(attribute[FileAttributeKey.size])")
                        
                        if let size = attribute[FileAttributeKey.size] as? NSNumber {
                            print("fileName : \(fileName), size : \(size)")
                            if(!fileExtension.isEmpty){
                                let files = App.LocalFiles(cmd:"C",userId:App.defaults.userId,devUuid:Util.getUuid(),fileNm:decodedFileName,etsionNm:fileExtension,fileSize:size.stringValue,cretDate:Util.date(text: fileCreateDate),amdDate:Util.date(text: modifiedDate), foldrWholePathNm: foldrWholePathNm, savedPath: fileSavedPath)
                                
                                localFileArray.append(files)
                            }
                            
                            //                            print("localFileArray : \(localFileArray)")
                            
                        }
                        
                    }
                    
                    
                } catch {
                    print("Error: \(error)")
                }
            }
            
        } catch {
            print(error.localizedDescription)
            
        }
        print("return localFileArray : \(localFileArray)")
        return localFileArray
    }
    
    
   
    func getFileUrl(fileNm:String, amdDate:String) -> URL{
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var retrunUrl:URL!
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            print("files : \(fileURLs)")
            for (_, f) in fileURLs.enumerated() {
                do {
                    let attribute = try FileManager.default.attributesOfItem(atPath: f.path)
                    let fileName:String = (NSURL(fileURLWithPath: f.lastPathComponent).deletingPathExtension?.lastPathComponent)!
                    let fileExtension = f.pathExtension
                    let localFilFullName = "\(fileName).\(fileExtension)"
                    let decodedFileName:String = localFilFullName.removingPercentEncoding!
                    
                    
                    print("fileExtension : \(fileExtension)")
                    let fileSavedPath = f.path
                    print("fileSavedPath : \(fileSavedPath)")
                    _ = f.lastPathComponent
                    let fileCreateDate: Date = attribute[FileAttributeKey.creationDate] as! Date
                    let modifiedDate: Date = attribute[FileAttributeKey.modificationDate] as! Date
                    let stringModifiedDate = Util.date(text: modifiedDate)
                    print("fileNm : \(fileNm), localFilFullName : \(localFilFullName), amdDate: \(amdDate) , stringModifiedDate : \(stringModifiedDate)")
                    if(fileNm == decodedFileName && amdDate == stringModifiedDate){
                        retrunUrl = f
                    } 
                    
                    
                } catch {
                    print("Error: \(error)")
                }
            }
            
        } catch {
            print(error.localizedDescription)
            
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
                    let localFilFullName = "\(fileName).\(fileExtension)"
                    let decodedFileName:String = localFilFullName.removingPercentEncoding!
                    let fileSavedPath = f.path
                    let fileCreateDate: Date = attribute[FileAttributeKey.creationDate] as! Date
                    let modifiedDate: Date = attribute[FileAttributeKey.modificationDate] as! Date
                    let stringModifiedDate = Util.date(text: modifiedDate)
                    print("for remove fileNm : \(fileNm), localFilFullName : \(localFilFullName), amdDate: \(amdDate) , stringModifiedDate : \(stringModifiedDate), decodedFileName: \(decodedFileName)")
                    if(fileNm == decodedFileName && amdDate == stringModifiedDate){
                        returnPath = fileSavedPath
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
    
}
