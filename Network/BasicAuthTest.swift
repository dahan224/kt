//
//  BasicAuthTest.swift
//  KT
//
//  Created by 이다한 on 2018. 3. 2..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class basicAuthTest{

    class func getImage(){
        let user = "acc_ba7ad750a143396"
        let password = "d580a33d4f38495c54d5605bf0e40ad0"
        
        let credentialData = "\(user):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        let headers = [
            "Authorization": "Basic \(base64Credentials)"
        ]
        
        print("header :\(headers)")
        var stringUrl = "http://api.imagga.com/v1/tagging?url=http://imagga.com/static/images/tagging/wind-farm-538576_640.jpg"
        stringUrl = stringUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        Alamofire.request(stringUrl, method: .get, headers: headers)
            .responseData {
                response in
                print(response)
                guard response.response != nil else {
                    print("Something went wrong uploading")
                    return
                }
                switch(response.result){
                case .success(let value):
                    print(value)
                    
                    break
                case .failure(let error):
                    print(error)
                    
                    break
                }
        }
            
    }
    
}
