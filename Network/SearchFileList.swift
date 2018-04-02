//
//  SearchFileList.swift
//  KT
//
//  Created by 이다한 on 2018. 2. 22..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SearchFileList {
    var loginCookie = UserDefaults.standard.string(forKey: "cookie")!
    var loginToken = UserDefaults.standard.string(forKey: "token")!
    var uuid = Util.getUuid()
    var userId = UserDefaults.standard.string(forKey: "userId")!
    var SearchedFileArray:[App.SearchedFileStruct] = []
  
   
    func searchFile(searchKeyword:String, searchStep: HomeViewController.searchStepEnum, searchId:String, foldrWholePathNm:String, sortBy:String, searchGubun:String, devUuid:String, completionHandler: @escaping (NSDictionary?, NSError?) -> ()){
         let headers = [
            "Content-Type": "application/json",
            "X-Auth-Token": loginToken,
            "Cookie": loginCookie
        ]
        var params:[String:Any] = [String:Any]()
        switch searchStep {
        case .all:
            
            params = ["userId":userId, "searchKeyword":searchKeyword,"sortBy":sortBy,"searchGubun":searchGubun]
            break
        case .device:
            params = ["userId":userId, "searchKeyword":searchKeyword,"devUuid":devUuid,"sortBy":sortBy,"searchGubun":searchGubun]
            break
        case .folder:
            params = ["userId":userId, "searchKeyword":searchKeyword,"devUuid":devUuid, "foldrWholePathNm":foldrWholePathNm,"sortBy":sortBy,"searchGubun":searchGubun]
            break
        
        }
        print("search param : \(params)")
        //모바일 폴더 동기화 리스트
        Alamofire.request(App.URL.server+"listSearch.json"
            , method: .post
            , parameters:params
            , encoding : JSONEncoding.default
            , headers: headers
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
