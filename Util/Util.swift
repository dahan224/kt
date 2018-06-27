//
//  Util.swift
//  KT
//
//  Created by 이다한 on 2018. 2. 8..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit

class Util{
    class func date(text: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let stringDate = dateFormatter.string(from: text)
        
        return stringDate
    }
    
    class  func getUuid() -> String {
        
        let prefer = UserDefaults.standard
        var returnUdid:String!
        
        if let udidData = prefer.string(forKey: "uuId") {
            returnUdid = udidData
        } else {
            if let udidData = Keychain.load(key: "uuId") {
                returnUdid = udidData as String!
                prefer.set(returnUdid, forKey: "uuId")
            } else {
                if let identifierForVendor = UIDevice.current.identifierForVendor?.uuidString {
                    if Keychain.save(key: "uuId", data: identifierForVendor.data(using: String.Encoding.utf8)!) {
                        prefer.set(identifierForVendor, forKey: "uuId")
                        returnUdid =  identifierForVendor
                    }
                }
            }
        }
        
        return (returnUdid)!
    }
    
    func dismissFromLeft(vc:UIViewController){
        let transition: CATransition = CATransition()
        transition.duration = 0.25
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionReveal
        transition.subtype = kCATransitionFromLeft
        vc.view.window!.layer.add(transition, forKey: nil)
        vc.dismiss(animated: false, completion: nil)
    }
    
    let deviceImageCheck = [
        ["osNm": "GIGA Storage",  "image": "ico_device_giganas_on", "onoff": "Y"],
        ["osNm": "GIGA Storage",  "image": "ico_device_giganas_on", "onoff": "N"],
        ["osNm": "SHARE GIGA Storage",  "image": "ico_device_giganas_share_on", "onoff": "Y"],
        ["osNm": "SHARE GIGA Storage",  "image": "ico_device_giganas_share_on", "onoff": "N"],
        ["osNm": "Windows",  "image": "ico_device_pc_on", "onoff": "Y"],
        ["osNm": "Windows",  "image": "ico_device_pc", "onoff": "N"],
        ["osNm": "Android",  "image": "ico_device_mobile_on", "onoff": "Y"],
        ["osNm": "Android",  "image": "ico_device_mobile", "onoff": "N"],
        ["osNm": "iOS",  "image": "ico_device_mobile_on", "onoff": "Y"],
        ["osNm": "iOS",  "image": "ico_device_mobile", "onoff": "N"],
        ["osNm": "D",  "image": "ico_device_googledrive_on", "onoff": "Y"],
        ["osNm": "D",  "image": "ico_device_googledrive", "onoff": "N"]
        ]
    
    class func getDeviceImageString(osNm:String, onoff:String) -> String {
        let result = Util().deviceImageCheck.filter({ $0["osNm"] == osNm && $0["onoff"] == onoff})
//        print("result  \(String(describing: result[0]["image"]))")
        return result[0]["image"]!
    }
    
    let contextImageCheck = [
        ["context": "속성보기",  "image": "ico_contextmenu_info"],
        ["context": "다운로드",  "image": "ico_contextmenu_dwld"],
        ["context": "GiGA NAS로 보내기",  "image": "ico_contextmenu_send"],
        ["context": "Google Drive로 보내기",  "image": "ico_contextmenu_send"],
        ["context": "삭제",  "image": "ico_contextmenu_del"]
        ]
    
    class func getContextImageString(context:String) -> String {
        let result = Util().contextImageCheck.filter({ $0["context"] == context})
//        print("result  \(String(describing: result[0]["image"]))")
        return result[0]["image"]!
    }
    
    let fileImageCheck = [
        ["etsionNm": "sound",  "image": "file_format_sound"],
        ["etsionNm": "code",  "image": "ico_24dp_filetype_code"],
        ["etsionNm": "etc",  "image": "ico_24dp_filetype_etc"],
        ["etsionNm": "exe",  "image": "ico_24dp_filetype_exe"],
        ["etsionNm": "hwp",  "image": "ico_24dp_filetype_hwp"],
        ["etsionNm": "img",  "image": "ico_24dp_filetype_img"],
        ["etsionNm": "jpg",  "image": "ico_24dp_filetype_img"],
        ["etsionNm": "png",  "image": "ico_24dp_filetype_img"],
        ["etsionNm": "pdf",  "image": "ico_24dp_filetype_pdf"],
        ["etsionNm": "ppt",  "image": "ico_24dp_filetype_ppt"],
        ["etsionNm": "txt",  "image": "ico_24dp_filetype_txt"],
        ["etsionNm": "webcode",  "image": "ico_24dp_filetype_webcode"],
        ["etsionNm": "xls",  "image": "ico_24dp_filetype_xls"],
        ["etsionNm": "zip",  "image": "ico_24dp_filetype_zip"]
    ]
    class func getFileImageString(fileExtension:String) -> String {
        var imageString = ""
        let result = Util().fileImageCheck.filter({ $0["etsionNm"] == fileExtension})
        if (!result.isEmpty){
//            print("result  \(String(describing: result[0]["image"]))")
            imageString = result[0]["image"]!
        } else {
            imageString = "ico_24dp_filetype_etc"
        }
        
        return imageString
    }
    
    let googleImageCheck = [
        ["mimeType": "application/vnd.google-apps.document",  "image": "ico_24dp_filetype_etc"],
        ["mimeType": "image/jpeg",  "image": "ico_24dp_filetype_img"],
        ["mimeType": "application/vnd.google-apps.folder",  "image": "ico_folder"],
        ["mimeType": "image/png",  "image": "ico_24dp_filetype_img"]        
    ]
    class func getGoogleImageString(mimeType:String) -> String {
        var imageString = ""
        let result = Util().googleImageCheck.filter({ $0["mimeType"] == mimeType})
        if (!result.isEmpty){
            imageString = result[0]["image"]!
        } else {
            imageString = "ico_24dp_filetype_etc"
        }        
        return imageString
    }
}
