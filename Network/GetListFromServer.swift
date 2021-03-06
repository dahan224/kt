//
//  GetDeviceList.swift
//  KT
//
//  Created by 이다한 on 2018. 2. 23..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class GetListFromServer {
    var loginCookie = UserDefaults.standard.string(forKey: "cookie")!
    var loginToken = UserDefaults.standard.string(forKey: "token")!
    var uuid = Util.getUuid()
    var userId = UserDefaults.standard.string(forKey: "userId")!
    var SearchedFileArray:[App.SearchedFileStruct] = []
    
    
    func getDevice(completionHandler: @escaping (NSDictionary?, NSError?) -> ()){
        var params:[String:Any] = [String:Any]()
        params = ["userId":userId]
       
        //모바일 폴더 동기화 리스트
        Alamofire.request(App.URL.server+"listOneview.json"
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
    func getFoldrList(devUuid:String, userId:String, deviceName:String,completionHandler: @escaping (NSDictionary?, NSError?) -> ()){
        var params:[String:Any] = [String:Any]()
        params = ["userId":userId,"devUuid":devUuid]
        var filnalUrl = "listFoldr.json"
        Alamofire.request(App.URL.server+filnalUrl
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
    
    func showInsideFoldrList(params:[String:Any], deviceName:String, completionHandler: @escaping (NSDictionary?, NSError?) -> ()){
        let filnalUrl = "listFoldr.json"
        Alamofire.request(App.URL.server+filnalUrl
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
 
}


