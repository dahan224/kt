//
//  GoogleWork.swift
//  KT
//
//  Created by 이다한 on 2018. 3. 18..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GoogleSignIn

class GoogleWork{
    
    func googleSignInCheck(name:String, path:String, fileDict:[String:String]){
        if GIDSignIn.sharedInstance().hasAuthInKeychain() == true {
            GIDSignIn.sharedInstance().signInSilently()
            print("sign in silently")
            
            NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
            
        } else {
            print("need login")
            NotificationCenter.default.post(name: Notification.Name("googleSignInAlertShow"), object: self)
        }
    }
    
}
