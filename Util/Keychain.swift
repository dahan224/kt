//
//  Keychain.swift
//  practiceExam
//
//  Created by 김영은 on 2018. 1. 30..
//  Copyright © 2018년 0eun. All rights reserved.
//

import UIKit
import Security

class Keychain {
    
    class func save(key: String, data: Data) -> Bool {
        let query = [kSecClass as String : kSecClassGenericPassword as String,
                     kSecAttrAccount as String : key,
                     kSecValueData as String : data]
            as [String: Any]
        
        SecItemDelete(query as CFDictionary)
        let status: OSStatus = SecItemAdd(query as CFDictionary, nil)
        
        return status == noErr
        //return ("".data(using: String.Encoding.utf8) != nil)
    }
    
    class func load(key: String) -> NSString? {
        let query = [kSecClass as String : kSecClassGenericPassword,
                     kSecAttrAccount as String : key,
                     kSecReturnData as String : kCFBooleanTrue,
                     kSecMatchLimit as String : kSecMatchLimitOne]
            as [String:Any]
        
        var dataTypeRef: AnyObject?
        let status = withUnsafeMutablePointer(to: &dataTypeRef) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        if status == errSecSuccess {
            if let data = dataTypeRef as! Data? {
                return NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            }
        }
        return nil
    }
    
    
}


