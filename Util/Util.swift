//
//  Util.swift
//  KT
//
//  Created by 이다한 on 2018. 2. 8..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import SystemConfiguration
import ImageIO

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
        ["etsionNm": "mp3",  "image": "ico_24dp_filetype_sound"],
        ["etsionNm": "ogg",  "image": "ico_24dp_filetype_sound"],
        ["etsionNm": "wma",  "image": "ico_24dp_filetype_sound"],
        ["etsionNm": "wav",  "image": "ico_24dp_filetype_sound"],
        ["etsionNm": "au",  "image": "ico_24dp_filetype_sound"],
        ["etsionNm": "rm",  "image": "ico_24dp_filetype_sound"],
        ["etsionNm": "mid",  "image": "ico_24dp_filetype_sound"],
        
        ["etsionNm": "css",  "image": "ico_24dp_filetype_code"],
        ["etsionNm": "js",  "image": "ico_24dp_filetype_code"],
        ["etsionNm": "xml",  "image": "ico_24dp_filetype_code"],
        
        ["etsionNm": "doc",  "image": "ico_24dp_filetype_doc"],
        ["etsionNm": "docx",  "image": "ico_24dp_filetype_doc"],
        
        ["etsionNm": "etc",  "image": "ico_24dp_filetype_etc"],
        
        ["etsionNm": "exe",  "image": "ico_24dp_filetype_exe"],
        
        ["etsionNm": "avi",  "image": "ico_24dp_filetype_film"],
        ["etsionNm": "mp4",  "image": "ico_24dp_filetype_film"],
        ["etsionNm": "mkv",  "image": "ico_24dp_filetype_film"],
        ["etsionNm": "mpg",  "image": "ico_24dp_filetype_film"],
        ["etsionNm": "mpeg",  "image": "ico_24dp_filetype_film"],
        ["etsionNm": "wmv",  "image": "ico_24dp_filetype_film"],
        ["etsionNm": "asf",  "image": "ico_24dp_filetype_film"],
        
        ["etsionNm": "hwp",  "image": "ico_24dp_filetype_hwp"],
        
        ["etsionNm": "img",  "image": "ico_24dp_filetype_img"],
        ["etsionNm": "jpg",  "image": "ico_24dp_filetype_img"],
        ["etsionNm": "png",  "image": "ico_24dp_filetype_img"],
        
        ["etsionNm": "pdf",  "image": "ico_24dp_filetype_pdf"],
        
        ["etsionNm": "ppt",  "image": "ico_24dp_filetype_ppt"],
        ["etsionNm": "pptx",  "image": "ico_24dp_filetype_ppt"],
        
        ["etsionNm": "txt",  "image": "ico_24dp_filetype_txt"],
        
        ["etsionNm": "htm",  "image": "ico_24dp_filetype_webcode"],
        ["etsionNm": "html",  "image": "ico_24dp_filetype_webcode"],
        
        ["etsionNm": "xls",  "image": "ico_24dp_filetype_xls"],
        ["etsionNm": "xlsx",  "image": "ico_24dp_filetype_xls"],
        
        ["etsionNm": "zip",  "image": "ico_24dp_filetype_zip"],
        ["etsionNm": "egg",  "image": "ico_24dp_filetype_zip"]
    ]
    class func getFileImageString(fileExtension:String) -> String {
        var imageString = ""
        let result = Util().fileImageCheck.filter({ $0["etsionNm"] == fileExtension.lowercased()})
        if (!result.isEmpty){
            //            print("result  \(String(describing: result[0]["image"]))")
            imageString = result[0]["image"]!
        } else {
            imageString = "ico_24dp_filetype_etc"
        }
        
        return imageString
    }
    let thumbNailImageCheck = [
        ["etsionNm": "mp3",  "image": "file_format_sound"],
        ["etsionNm": "ogg",  "image": "file_format_sound"],
        ["etsionNm": "wma",  "image": "file_format_sound"],
        ["etsionNm": "wav",  "image": "file_format_sound"],
        ["etsionNm": "au",  "image": "file_format_sound"],
        ["etsionNm": "rm",  "image": "file_format_sound"],
        ["etsionNm": "mid",  "image": "file_format_sound"],
        
        ["etsionNm": "css",  "image": "file_format_code"],
        ["etsionNm": "js",  "image": "file_format_code"],
        ["etsionNm": "xml",  "image": "file_format_code"],
        
        ["etsionNm": "doc",  "image": "file_format_doc"],
        ["etsionNm": "docx",  "image": "file_format_doc"],
        
        ["etsionNm": "etc",  "image": "file_format_etc"],
        
        ["etsionNm": "exe",  "image": "file_format_exe"],
        
        ["etsionNm": "avi",  "image": "file_format_film"],
        ["etsionNm": "mp4",  "image": "file_format_film"],
        ["etsionNm": "mkv",  "image": "file_format_film"],
        ["etsionNm": "mpg",  "image": "file_format_film"],
        ["etsionNm": "mpeg",  "image": "file_format_film"],
        ["etsionNm": "wmv",  "image": "file_format_film"],
        ["etsionNm": "asf",  "image": "file_format_film"],
        
        ["etsionNm": "hwp",  "image": "file_format_hwp"],
        
        ["etsionNm": "img",  "image": "file_format_img"],
        ["etsionNm": "jpg",  "image": "file_format_img"],
        ["etsionNm": "png",  "image": "file_format_img"],
        
        ["etsionNm": "pdf",  "image": "file_format_pdf"],
        
        ["etsionNm": "ppt",  "image": "file_format_ppt"],
        ["etsionNm": "pptx",  "image": "file_format_ppt"],
        
        ["etsionNm": "txt",  "image": "file_format_txt"],
        
        ["etsionNm": "htm",  "image": "file_format_webcode"],
        ["etsionNm": "html",  "image": "file_format_webcode"],
        
        ["etsionNm": "xls",  "image": "file_format_xls"],
        ["etsionNm": "xlsx",  "image": "file_format_xls"],
        
        ["etsionNm": "zip",  "image": "file_format_zip"],
        ["etsionNm": "egg",  "image": "file_format_zip"]
    ]
    class func getthumbNailImageString(fileExtension:String) -> String {
        var imageString = ""
        let result = Util().thumbNailImageCheck.filter({ $0["etsionNm"] == fileExtension.lowercased()})
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
        ["mimeType": "image/jpeg",  "image": "file_format_img"],
        ["mimeType": "application/vnd.google-apps.folder",  "image": "ico_folder"],
        ["mimeType": "image/png",  "image": "file_format_img"]
    ]
    class func getGoogleImageString(mimeType:String) -> String {
        var imageString = ""
        let result = Util().googleImageCheck.filter({ $0["mimeType"] == mimeType.lowercased()})
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
        ["etsionNm": "mp3", "googleMimeType": "audio/mpeg"],
        ["etsionNm": "folder", "googleMimeType": "application/vnd.google-apps.folder"]
    ]
    
    class func getGoogleMimeType(etsionNm:String) -> String {
        var imageString = ""
        let result = Util().googleMimeTypeCheck.filter({ $0["etsionNm"] == etsionNm.lowercased()})
        if (!result.isEmpty){
            imageString = result[0]["googleMimeType"]!
        }
        return imageString
    }
    
    class func getEtsionFromMimetype(mimeType:String) -> String {
        var imageString = ""
        let result = Util().googleMimeTypeCheck.filter({ $0["googleMimeType"] == mimeType.lowercased()})
        if (!result.isEmpty){
            imageString = result[0]["etsionNm"]!
        }
        return imageString
    }
}

extension CALayer {
    func addBorder(_ arr_edge: [UIRectEdge], color: UIColor, width: CGFloat) {
        for edge in arr_edge {
            let border = CALayer()
            switch edge {
            case UIRectEdge.top:
                border.frame = CGRect.init(x: 0, y: 0, width: frame.width, height: width)
                break
            case UIRectEdge.bottom:
                border.frame = CGRect.init(x: 0, y: frame.height - width, width: frame.width, height: width)
                break
            case UIRectEdge.left:
                border.frame = CGRect.init(x: 0, y: 0, width: width, height: frame.height)
                break
            case UIRectEdge.right:
                border.frame = CGRect.init(x: frame.width - width, y: 0, width: width, height: frame.height)
                break
            default:
                break
            }
            border.backgroundColor = color.cgColor;
            self.addSublayer(border)
        }
    }
}
extension UILabel {
    func setLineHeight(lineHeight: CGFloat) {
        
        let text = self.text
        if let text = text {
            
            let attributeString = NSMutableAttributedString(string: text)
            let style = NSMutableParagraphStyle()
            
            style.lineSpacing = lineHeight
            attributeString.addAttribute(NSAttributedStringKey.paragraphStyle,
                                         value: style,
                                         range: NSMakeRange(0, text.characters.count))
            
            self.attributedText = attributeString
        }
    }
    private struct AssociatedKeys {
        static var padding = UIEdgeInsets()
    }
    
    public var padding: UIEdgeInsets? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.padding) as? UIEdgeInsets
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.padding, newValue as UIEdgeInsets!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    override open func draw(_ rect: CGRect) {
        if let insets = padding {
            self.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
        } else {
            self.drawText(in: rect)
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        guard let text = self.text else { return super.intrinsicContentSize }
        
        var contentSize = super.intrinsicContentSize
        var textWidth: CGFloat = frame.size.width
        var insetsHeight: CGFloat = 0.0
        
        if let insets = padding {
            textWidth -= insets.left + insets.right
            insetsHeight += insets.top + insets.bottom
        }
        
        let newSize = text.boundingRect(with: CGSize(width: textWidth, height: CGFloat.greatestFiniteMagnitude),
                                        options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                        attributes: [NSAttributedStringKey.font: self.font], context: nil)
        
        contentSize.height = ceil(newSize.size.height) + insetsHeight
        
        return contentSize
    }
    
}
extension UISearchBar {
    var textField : UITextField{
        return self.value(forKey: "_searchField") as! UITextField
        
    }
}
extension NSObject{
    
    enum ReachabilityStatus {
        case notReachable
        case reachableViaWWAN
        case reachableViaWiFi
    }
    
    var currentReachabilityStatus: ReachabilityStatus {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return .notReachable
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return .notReachable
        }
        
        if flags.contains(.reachable) == false {
            // The target host is not reachable.
            return .notReachable
        }
        else if flags.contains(.isWWAN) == true {
            // WWAN connections are OK if the calling application is using the CFNetwork APIs.
            return .reachableViaWWAN
        }
        else if flags.contains(.connectionRequired) == false {
            // If the target host is reachable and no connection is required then we'll assume that you're on Wi-Fi...
            return .reachableViaWiFi
        }
        else if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true) && flags.contains(.interventionRequired) == false {
            // The connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs and no [user] intervention is needed
            return .reachableViaWiFi
        }
        else {
            return .notReachable
        }
    }
    
}

extension UIImage {
    
    public class func gifImageWithData(data: NSData) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data, nil) else {
            print("image doesn't exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source: source)
    }
    
    public class func gifImageWithURL(gifUrl:String) -> UIImage? {
        guard let bundleURL = NSURL(string: gifUrl)
            else {
                print("image named \"\(gifUrl)\" doesn't exist")
                return nil
        }
        guard let imageData = NSData(contentsOf: bundleURL as URL) else {
            print("image named \"\(gifUrl)\" into NSData")
            return nil
        }
        
        return gifImageWithData(data: imageData)
    }
    
    public class func gifImageWithName(name: String) -> UIImage? {
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                print("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        
        guard let imageData = NSData(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gifImageWithData(data: imageData)
    }
    
    class func delayForImageAtIndex(index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(CFDictionaryGetValue(cfProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()), to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()), to: AnyObject.self)
        
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as! Double
        
        if delay < 0.1 {
            delay = 0.1
        }
        
        return delay
    }
    
    class func gcdForPair(a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        if a! < b! {
            let c = a!
            a = b!
            b = c
        }
        
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b!
            } else {
                a = b!
                b = rest
            }
        }
    }
    
    class func gcdForArray(array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(a: val, gcd)
        }
        
        return gcd
    }
    
    class func animatedImageWithSource(source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(index: Int(i), source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        let gcd = gcdForArray(array: delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImage(with: frames, duration: Double(duration) / 1000.0)
        
        return animation
    }
}
