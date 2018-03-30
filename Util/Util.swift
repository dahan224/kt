//
//  Util.swift
//  KT
//
//  Created by 이다한 on 2018. 2. 8..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit

class Util{
    class func checkSpace(_ str:String) -> Bool {
        var check:Bool = false
        
        for char in str {
            if char == " " || char == "\n" {
                check = true
                break
            }
        }
        
        return check
    }
    class func date(text: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let stringDate = dateFormatter.string(from: text)
        
        return stringDate
    }
    class func stringToDate(text: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: text)        
        return date!
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
        ["context": "앱 실행",  "image": "ico_contextmenu_app"],
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
        ["etsionNm": "sound",  "image": "file_format_sound_192_list"],
        ["etsionNm": "code",  "image": "file_format_code_192_list"],
        ["etsionNm": "doc",  "image": "file_format_doc_192_list"],
        ["etsionNm": "etc",  "image": "file_format_etc_192_list"],
        ["etsionNm": "exe",  "image": "file_format_exe_192_list"],
        ["etsionNm": "film",  "image": "file_format_film_192_list"],
        ["etsionNm": "foldr",  "image": "file_format_folder_192_list"],
        ["etsionNm": "hwp",  "image": "file_format_hwp_192_list"],
        ["etsionNm": "img",  "image": "file_format_img_192_list"],
        ["etsionNm": "jpg",  "image": "file_format_img_192_list"],
        ["etsionNm": "png",  "image": "file_format_img_192_list"],
        ["etsionNm": "pdf",  "image": "file_format_pdf_192_list"],
        ["etsionNm": "ppt",  "image": "file_format_ppt_192_list"],
        ["etsionNm": "txt",  "image": "file_format_txt_192_list"],
        ["etsionNm": "webcode",  "image": "file_format_webcode_192_list"],
        ["etsionNm": "xls",  "image": "file_format_xls_192_list"],
        ["etsionNm": "zip",  "image": "file_format_zip_192_list"]
    ]
    class func getFileImageString(fileExtension:String) -> String {
        var imageString = ""
        let result = Util().fileImageCheck.filter({ $0["etsionNm"] == fileExtension})
        if (!result.isEmpty){
//            print("result  \(String(describing: result[0]["image"]))")
            imageString = result[0]["image"]!
        } else {
            imageString = "file_format_etc_192_list"
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
    
    let googleMimeTypeCheck = [
        ["etsionNm": "png",  "googleMimeType": "image/png"],
        ["etsionNm": "gif",  "googleMimeType": "image/gif"],
        ["etsionNm": "svg",  "googleMimeType": "image/svg"],
        ["etsionNm": "jpg",  "googleMimeType": "image/jpeg"],
        ["etsionNm": "jpeg",  "googleMimeType": "image/jpeg"],
        ["etsionNm": "csv",  "googleMimeType": "text/csv"],
        ["etsionNm": "html",  "googleMimeType": "text/html"],
        ["etsionNm": "htm",  "googleMimeType": "text/html"],
        ["etsionNm": "text",  "googleMimeType": "text/plain"],
        ["etsionNm": "txt",  "googleMimeType": "text/plain"],
        ["etsionNm": "xml", "googleMimeType": "text/xml"],
        ["etsionNm": "odt", "googleMimeType": "application/vnd.oasis.opendocument.text"],
        ["etsionNm": "odm", "googleMimeType": "application/vnd.oasis.opendocument.text-master"],
        ["etsionNm": "ott", "googleMimeType": "application/vnd.oasis.opendocument.text-template"],
        ["etsionNm": "ods", "googleMimeType": "application/vnd.oasis.opendocument.sheet"],
        ["etsionNm": "ots", "googleMimeType": "application/vnd.oasis.opendocument.spreadsheet-template"],
        ["etsionNm": "odg", "googleMimeType": "application/vnd.oasis.opendocument.graphics"],
        ["etsionNm": "otg", "googleMimeType": "application/vnd.oasis.opendocument.graphics-template"],
        ["etsionNm": "oth", "googleMimeType": "application/vnd.oasis.opendocument.text-web"],
        ["etsionNm": "odp", "googleMimeType": "application/vnd.oasis.opendocument.presentation"],
        ["etsionNm": "otp", "googleMimeType": "application/vnd.oasis.opendocument.presentation-template"],
        ["etsionNm": "odi", "googleMimeType": "application/vnd.oasis.opendocument.image"],
        ["etsionNm": "odb", "googleMimeType": "application/vnd.oasis.opendocument.database"],
        ["etsionNm": "oxt", "googleMimeType": "application/vnd.openofficeorg.extension"],
        ["etsionNm": "rtf", "googleMimeType": "application/rtf"],
        ["etsionNm": "pdf", "googleMimeType": "application/pdf"],
        ["etsionNm": "docx", "googleMimeType": "application/vnd.openxmlformats-officedocument.wordprocessingml.document"],
        ["etsionNm": "doc", "googleMimeType": "application/vnd.openxmlformats-officedocument.wordprocessingml.document"],
        ["etsionNm": "ppt", "googleMimeType": "application/vnd.openxmlformats-officedocument.wordprocessingml.presentation"],
        ["etsionNm": "pptx", "googleMimeType": "application/vnd.openxmlformats-officedocument.wordprocessingml.presentation"],
        ["etsionNm": "xlsx", "googleMimeType": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"],
        ["etsionNm": "xls", "googleMimeType": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"],
        ["etsionNm": "json", "googleMimeType":  "application/json"],
        ["etsionNm": "js", "googleMimeType": "application/x-javascript"],
        ["etsionNm": "apk", "googleMimeType": "application/vnd.android.package-archive"],
        ["etsionNm": "bin", "googleMimeType": "application/octet-stream"],
        ["etsionNm": "tif", "googleMimeType": "image/tiff"],
        ["etsionNm": "tiff", "googleMimeType": "image/tiff"],
        ["etsionNm": "tgz", "googleMimeType": "application/x-compressed"],
        ["etsionNm": "zip", "googleMimeType":  "application/zip"],
        ["etsionNm": "mp3", "googleMimeType": "audio/mpeg"]
    ]
    
    class func getGoogleMimeType(etsionNm:String) -> String {
        var imageString = ""
        let result = Util().googleMimeTypeCheck.filter({ $0["etsionNm"] == etsionNm})
        if (!result.isEmpty){
            imageString = result[0]["googleMimeType"]!
        } 
        return imageString
    }
}
