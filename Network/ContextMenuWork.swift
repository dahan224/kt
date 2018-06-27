//
//  ContextMenuWork.swift
//  KT
//
//  Created by 이다한 on 2018. 3. 4..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ContextMenuWork {
    
    var userId = UserDefaults.standard.string(forKey: "userId") as? String ?? "nil"
    var uuid = Util.getUuid()
    
      
    func login(userId:String, password:String, completionHandler: @escaping (NSDictionary?, NSError?) -> ()){
        var params:[String:Any] = [String:Any]()
        params = ["userId":userId,"password":password]
        Alamofire.request(App.URL.server+"login.do"
            , method: .post
            , parameters:params
            , encoding : URLEncoding.default
            , headers: App.Headrs.jsonHeader
            ).responseJSON { response in
                switch response.result {
                case .success(let value):
                    completionHandler(value as? NSDictionary, nil)
                    
                    break
                case .failure(let error):
                    NSLog(error.localizedDescription)
                    completionHandler(nil, error as NSError)
                    break
                }
        }
    }
    
    
    func getFileDetailInfo(fileId:String, completionHandler: @escaping (NSDictionary?, NSError?) -> ()){
        var params:[String:Any] = [String:Any]()
        params = ["userId":userId,"devUuid":uuid,"fileId":fileId]
        Alamofire.request(App.URL.server+"fileDtl.json"
            , method: .post
            , parameters:params
            , encoding : JSONEncoding.default
            , headers: App.Headrs.jsonHeader
            ).responseJSON { response in
                switch response.result {
                    case .success(let value):
                        completionHandler(value as? NSDictionary, nil)
                        
                        break
                    case .failure(let error):
                        NSLog(error.localizedDescription)
                        completionHandler(nil, error as NSError)
                        break
                }
        }
    }
    func editFileTag(parameters:[[String:Any]], completionHandler: @escaping (NSDictionary?, NSError?) -> ()){
        var request = URLRequest(url: try! (App.URL.server+"nasFileTagUpdate.do").asURL())
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(App.defaults.loginToken, forHTTPHeaderField: "X-Auth-Token")
        request.setValue(App.defaults.loginCookie, forHTTPHeaderField: "Cookie")
        let values = parameters
        request.httpBody = try! JSONSerialization.data(withJSONObject: values)
        Alamofire.request(request).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                completionHandler(value as? NSDictionary, nil)
                
                break
            case .failure(let error):
                NSLog(error.localizedDescription)
                completionHandler(nil, error as NSError)
                break
            }
        }
    }
    func fromNasToNas(parameters:[String:Any], completionHandler: @escaping (NSDictionary?, NSError?) -> ()){
        Alamofire.request(App.URL.server+"nasFileCopy.do"
            , method: .post
            , parameters:parameters
            , encoding : JSONEncoding.default
            , headers: App.Headrs.jsonHeader
            ).responseJSON { response in
                switch response.result {
                case .success(let value):
                    completionHandler(value as? NSDictionary, nil)
                    
                    break
                case .failure(let error):
                    NSLog(error.localizedDescription)
                    completionHandler(nil, error as NSError)
                    break
                }
        }
    }
  
    func fromNasToStorage(parameters:[String:Any], completionHandler: @escaping (NSDictionary?, NSError?) -> ()){
        Alamofire.request(App.URL.server+"shareNasFileCopy.do"
            , method: .post
            , parameters:parameters
            , encoding : JSONEncoding.default
            , headers: App.Headrs.jsonHeader
            ).responseJSON { response in
                switch response.result {
                case .success(let value):
                    completionHandler(value as? NSDictionary, nil)
                    
                    break
                case .failure(let error):
                    NSLog(error.localizedDescription)
                    completionHandler(nil, error as NSError)
                    break
                }
        }
    }
    func downloadFromNas(userId:String, fileNm:String, path:String, fileId:String, completionHandler: @escaping (String?, NSError?) -> ()){
        var stringUrl = "https://araise.iptime.org/namespace/ifs/home/gs-\(userId)/\(userId)-gs\(path)/\(fileNm)"
        stringUrl = stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        let user = userId
        let password = "1234"
        let credentialData = "gs-\(user):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString()
        let headers = [
            "Authorization": "Basic \(base64Credentials)"
        ]
        print("stringUrl : \(stringUrl)")
        let downloadUrl:URL = URL(string: stringUrl)!
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent("\(fileNm)")
            return (documentsURL, [.removePreviousFile])
        }
        
        Alamofire.download(downloadUrl, method: .get, headers:headers, to: destination)
            .downloadProgress(closure: { (progress) in
                print("download progress : \(progress.fractionCompleted)")
//                 completionHandler(progress.fractionCompleted, nil)
            })
            .response { response in
                print("response : \(response)")
                if response.destinationURL != nil {
                    print(response.destinationURL!)
                    if let path = response.destinationURL?.path{
                        let path2 = "/private\(path)"
                        
                        DbHelper().localFileToSqlite(id: fileId, path: path2)
                        print("path2 : \(path2)" )
                        print("saved fileId : \(UserDefaults.standard.string(forKey: path2)), fileId : \(fileId)")
                        completionHandler("success", nil)
                    }
                    
                }
        }
    }
    func downloadFromNasToSend(userId:String, fileNm:String, path:String, completionHandler: @escaping (String?, NSError?) -> ()){
        var stringUrl = "https://araise.iptime.org/namespace/ifs/home/gs-\(userId)/\(userId)-gs\(path)/\(fileNm)"
        stringUrl = stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        let user = userId
        let password = "1234"
        let credentialData = "gs-\(user):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString()
        let headers = [
            "Authorization": "Basic \(base64Credentials)"
        ]
        print("stringUrl : \(stringUrl)")
        let downloadUrl:URL = URL(string: stringUrl)!
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent("\(fileNm)")
            return (documentsURL, [.removePreviousFile])
        }
        
        Alamofire.download(downloadUrl, method: .get, headers:headers, to: destination)
            .downloadProgress(closure: { (progress) in
                print("download progress : \(progress.fractionCompleted)")
                //                 completionHandler(progress.fractionCompleted, nil)
            })
            .response { response in
                print("response : \(response)")
                if response.destinationURL != nil {
                    let stringDestinationUrl = response.destinationURL?.absoluteString
                    print(stringDestinationUrl)
                    completionHandler(stringDestinationUrl, nil)
                }
        }
    }
    func deleteNasFile(parameters:[String:Any], completionHandler: @escaping (NSDictionary?, NSError?) -> ()){
        Alamofire.request(App.URL.server+"nasFileDel.do"
            , method: .post
            , parameters:parameters
            , encoding : JSONEncoding.default
            , headers: App.Headrs.jsonHeader
            ).responseJSON { response in
                switch response.result {
                case .success(let value):
                    completionHandler(value as? NSDictionary, nil)
                    
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    completionHandler(nil, error as NSError)
                    break
                }
        }
    }
    func uploadToNasFromLocal(userId:String, fileNm:String, path:String, completionHandler: @escaping (String?, NSError?) -> ()){
        var stringUrl = "https://araise.iptime.org/namespace/ifs/home/gs-\(userId)/\(userId)-gs\(path)/\(fileNm)"
        stringUrl = stringUrl.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        let user = userId
        let password = "1234"
        let credentialData = "gs-\(user):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString()
        let headers = [
            "Authorization": "Basic \(base64Credentials)"
        ]
        print("stringUrl : \(stringUrl)")
        let downloadUrl:URL = URL(string: stringUrl)!
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent("\(fileNm)")
            return (documentsURL, [.removePreviousFile])
        }
        
        Alamofire.download(downloadUrl, method: .get, headers:headers, to: destination)
            .downloadProgress(closure: { (progress) in
                print("download progress : \(progress.fractionCompleted)")
                //                 completionHandler(progress.fractionCompleted, nil)
            })
            .response { response in
                print("response : \(response)")
                if response.destinationURL != nil {
                    print(response.destinationURL!)
                    completionHandler("success", nil)
                }
        }
    }
   
}
