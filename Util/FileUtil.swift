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
                    
                    print("fileExtension : \(fileExtension)")
                    let fileSavedPath = f.path
                    print("fileSavedPath : \(fileSavedPath)")
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
                            
                            let files = App.LocalFiles(cmd:"C",userId:App.defaults.userId,devUuid:Util.getUuid(),fileNm:fileName,etsionNm:fileExtension,fileSize:size.stringValue,cretDate:Util.date(text: fileCreateDate),amdDate:Util.date(text: modifiedDate), foldrWholePathNm: foldrWholePathNm, savedPath: fileSavedPath)
                            
                            localFileArray.append(files)
                            
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
                    let localFilFullName = "\(fileNm)"
                    
                    print("fileExtension : \(fileExtension)")
                    let fileSavedPath = f.path
                    print("fileSavedPath : \(fileSavedPath)")
                    _ = f.lastPathComponent
                    let fileCreateDate: Date = attribute[FileAttributeKey.creationDate] as! Date
                    let modifiedDate: Date = attribute[FileAttributeKey.modificationDate] as! Date
                    let stringModifiedDate = Util.date(text: modifiedDate)
                    print("fileNm : \(fileNm), localFilFullName : \(localFilFullName), amdDate: \(amdDate) , stringModifiedDate : \(stringModifiedDate)")
                    if(fileNm == localFilFullName && amdDate == stringModifiedDate){
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
                    let localFilFullName = "\(fileNm)"
                    let fileSavedPath = f.path
                    let fileCreateDate: Date = attribute[FileAttributeKey.creationDate] as! Date
                    let modifiedDate: Date = attribute[FileAttributeKey.modificationDate] as! Date
                    let stringModifiedDate = Util.date(text: modifiedDate)
                    print("for remove fileNm : \(fileNm), localFilFullName : \(localFilFullName), amdDate: \(amdDate) , stringModifiedDate : \(stringModifiedDate)")
                    if(fileNm == localFilFullName && amdDate == stringModifiedDate){
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
