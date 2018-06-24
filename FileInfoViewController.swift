//
//  FileInfoViewController.swift
//  KT
//
//  Created by 이다한 on 2018. 2. 14..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FileInfoViewController: UIViewController {
    var fileExtension = ""
    var size = ""
    var createdTime = ""
    var modifiedTime = ""
    var fileThumbYn = ""
    var fromOsCd = ""
    var thumbnailLink = ""
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var customNavBar: UIView!
    @IBOutlet weak var ivMain: UIImageView!
    
    @IBOutlet weak var firsrDivider: UIView!
    
    
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    var fileId = ""
    var deviceName = ""
    var foldrWholePathNm = ""
    var loginCookie = ""
    var loginToken = ""
    var userId = ""
    var uuid = ""
    
    @IBOutlet weak var lblEtsion: UILabel!
    @IBOutlet weak var lblSize: UILabel!
    @IBOutlet weak var lblPath: UILabel!
    @IBOutlet weak var lblCret: UILabel!
    @IBOutlet weak var lblAmd: UILabel!
    @IBOutlet weak var lblDevice: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tagAddView: UIView!
    @IBOutlet weak var tagAddViewHeight: NSLayoutConstraint!
    
    var fileTagArray:[App.FileTagStruct] = [App.FileTagStruct]()
    var tagAddedWidth:CGFloat = 0
    var tagAddedHeight:CGFloat = 10
    var fileSavedPath = ""
    
    @IBOutlet weak var ivInfo: UIImageView!    
    @IBOutlet weak var ivInfoTopConstraint: NSLayoutConstraint!
    
    var ivEmail:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
        
    }()
    
    let lblEmail:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = HexStringToUIColor().getUIColor(hex: "4f4f4f")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var emailUnderLine:UIView = {
        let view = UIView()
        view.backgroundColor =  HexStringToUIColor().getUIColor(hex: "4f4f4f")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        
    }()
    
    let lblEmailSubj:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = HexStringToUIColor().getUIColor(hex: "4f4f4f")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let lblSendDate:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = HexStringToUIColor().getUIColor(hex: "4f4f4f")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let lblEmailFrom:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = HexStringToUIColor().getUIColor(hex: "4f4f4f")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var emailViewShowCheck = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ivInfo.translatesAutoresizingMaskIntoConstraints = false
        customNavBar.layer.shadowColor = UIColor.lightGray.cgColor
        customNavBar.layer.shadowOffset = CGSize(width:0,height: 2.0)
        customNavBar.layer.shadowRadius = 1.0
        customNavBar.layer.shadowOpacity = 1.0
        customNavBar.layer.masksToBounds = false;
        customNavBar.layer.shadowPath = UIBezierPath(roundedRect:customNavBar.bounds, cornerRadius:customNavBar.layer.cornerRadius).cgPath
        
        loginCookie = UserDefaults.standard.string(forKey: "cookie")!
        loginToken = UserDefaults.standard.string(forKey: "token")!
        uuid = Util.getUuid()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showFileInfo),
                                               name: NSNotification.Name("showFileInfo"),
                                               object: nil)
        
        btnBack.addTarget(self, action: #selector(btnBackClicked), for: .touchUpInside)
        print("FileInfoViewController called: \(deviceName), \(fileId)")
        // Do any additional setup after loading the view.
        if(!fileId.isEmpty){
            /* 이부분 수정 start */
            if deviceName == "Google Drive" {
                self.lblEtsion.text = fileExtension
                self.lblSize.text = self.covertFileSize(getSize: size)
                self.lblPath.text = self.foldrWholePathNm
                self.lblCret.text = createdTime
                self.lblAmd.text = modifiedTime
                self.lblDevice.text = self.deviceName
            } else {
                showFileInfo()
            }
            /* 이부분 수정 end */
            
        }
        
        if fileThumbYn == "Y" {
            if fromOsCd.isEmpty {
                Alamofire.request("\(App.URL.thumbnailLink)\(fileId)").responseImage { response in
                    if let getImage = response.result.value {
                        print("image downloaded: \(getImage)")
                        self.ivMain.contentMode = .scaleAspectFit
                        self.ivMain.image = getImage
                        
                    }
                }
            } else {
                Alamofire.request("\(thumbnailLink)").responseImage { response in
                    if let getImage = response.result.value {
                        print("image downloaded: \(getImage)")
                        self.ivMain.contentMode = .scaleAspectFit
                        self.ivMain.image = getImage
                        
                    }
                }
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func btnBackClicked(){
        print("back")
        Util().dismissFromLeft(vc:self)
    }
    
    
    
    @objc func showFileInfo(){
        self.fileTagArray.removeAll()
        ContextMenuWork().getFileDetailInfo(fileId: fileId){ responseObject, error in
            let json = JSON(responseObject!)
            print("showFileInfo json : \(json)")
            if(json["fileData"].exists()){
                var fileData = json["fileData"]
                print("fileData : \(fileData["fileNm"])")
                DispatchQueue.main.async {
                    self.lblEtsion.text = fileData["etsionNm"].rawString()
                    self.lblSize.text = self.covertFileSize(getSize: fileData["fileSize"].rawString()!)
                    self.lblPath.text = self.foldrWholePathNm
                    self.lblCret.text = fileData["cretDate"].rawString()
                    self.lblAmd.text = fileData["amdDate"].rawString()
                    self.lblDevice.text = self.deviceName
                }
            }
            if(json["listData2"].exists()){
                let serverList:[AnyObject] = json["listData2"].arrayObject! as [AnyObject]
                for server in serverList {
                    let emailSbjt = server["emailSbjt"] as? String  ?? "nil"
                    let sendDate = server["sendDate"] as? String  ?? "nil"
                    let emailFrom = server["emailFrom"] as? String  ?? "nil"
                    if(emailSbjt != "nil" && !emailSbjt.isEmpty){
                        DispatchQueue.main.async {
                            self.showEmailView(emailSbjt:emailSbjt, sendDate:sendDate, emailFrom:emailFrom)
                        }
                        
                    }
                }
                
            } else {
                
            }
            
            if(json["listData3"].exists()){
                var fileData = json["listData3"]
                print("tag update listData3 : \(fileData["listData3"])")
                let serverList:[AnyObject] = json["listData3"].arrayObject! as [AnyObject]
                for server in serverList {
                    let fileTag = server["fileTag"] as? String  ?? "nil"
                    if(fileTag != "nil" && !fileTag.isEmpty){
                        let tagStruct = App.FileTagStruct(fileId: self.fileId, fileTag: fileTag)
                        print("tagStruct : \(tagStruct)")
                        self.fileTagArray.append(tagStruct)
                    }
                    
                }
                self.resetTagVIew()
//                }
            }
            return
        }
    }
  
    func showEmailView(emailSbjt:String, sendDate:String, emailFrom:String){
        ivEmail.image = UIImage(named: "ico_24dp_email")
        scrollView.addSubview(ivEmail)
        scrollView.addSubview(lblEmail)
        scrollView.addSubview(emailUnderLine)
        scrollView.addSubview(lblEmailSubj)
        scrollView.addSubview(lblSendDate)
        scrollView.addSubview(lblEmailFrom)
        
        ivEmail.widthAnchor.constraint(equalToConstant: 24).isActive = true
        ivEmail.heightAnchor.constraint(equalToConstant: 24).isActive = true
        ivEmail.topAnchor.constraint(equalTo: firsrDivider.bottomAnchor, constant: 15).isActive = true
        ivEmail.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 25).isActive = true
        
        lblEmail.leadingAnchor.constraint(equalTo: ivEmail.trailingAnchor, constant: 10).isActive = true
        lblEmail.widthAnchor.constraint(equalToConstant: 200).isActive = true
        lblEmail.heightAnchor.constraint(equalToConstant: 22).isActive = true
        lblEmail.centerYAnchor.constraint(equalTo: ivEmail.centerYAnchor).isActive = true
        lblEmail.text = "Email"
        
        emailUnderLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        emailUnderLine.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant : 10).isActive = true
        emailUnderLine.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant : 10).isActive = true
        emailUnderLine.topAnchor.constraint(equalTo: ivEmail.bottomAnchor, constant: 3).isActive = true
        
        lblEmailSubj.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 70).isActive = true
        lblEmailSubj.widthAnchor.constraint(equalToConstant: 200).isActive = true
        lblEmailSubj.heightAnchor.constraint(equalToConstant: 22).isActive = true
        lblEmailSubj.topAnchor.constraint(equalTo: emailUnderLine.bottomAnchor, constant: 6).isActive = true
        lblEmailSubj.text = emailSbjt
        
        lblSendDate.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 70).isActive = true
        lblSendDate.widthAnchor.constraint(equalToConstant: 200).isActive = true
        lblSendDate.heightAnchor.constraint(equalToConstant: 22).isActive = true
        lblSendDate.topAnchor.constraint(equalTo: lblEmailSubj.bottomAnchor, constant: 3).isActive = true
        lblSendDate.text = sendDate
        
        lblEmailFrom.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 70).isActive = true
        lblEmailFrom.widthAnchor.constraint(equalToConstant: 200).isActive = true
        lblEmailFrom.heightAnchor.constraint(equalToConstant: 22).isActive = true
        lblEmailFrom.topAnchor.constraint(equalTo: lblSendDate.bottomAnchor, constant: 3).isActive = true
        lblEmailFrom.text = emailFrom
        
      
        
//        ivInfoTopConstraint.isActive = false
        ivInfoTopConstraint.constant = 150
        emailViewShowCheck = true
        self.scrollView.frame = CGRect(x: 0, y: 0, width: App.Size.screenWidth, height: App.Size.screenHeight)
        
        self.scrollView.contentSize = CGSize(width: App.Size.screenWidth, height: App.Size.screenHeight + 150)
    }
    
    func thumbnailCheck(){
        
    }
    
    func resetTagVIew(){
        print("resetTagVIew called")
        
        DispatchQueue.main.async {
            for view in self.tagAddView.subviews{
                view.removeFromSuperview()
            }
            
            self.tagAddedHeight = 10
            self.tagAddedWidth = 0
            
            for (index, fileTag) in self.fileTagArray.enumerated(){
                
                let tagView:UIView = {
                    let view = UIView()
                    view.translatesAutoresizingMaskIntoConstraints = false
                    return view;
                }()
                let tagLabel:UILabel = {
                    let label = UILabel()
                    label.textAlignment = .left
                    label.textColor = HexStringToUIColor().getUIColor(hex: "4f4f4f")
                    label.font = UIFont.systemFont(ofSize: 17)
                    label.translatesAutoresizingMaskIntoConstraints = false
                    return label
                }()
                if(fileTag.fileTag.isEmpty) {
                    
                } else {
                    self.tagAddView.addSubview(tagView)
                    let stringTag = self.fileTagArray[index].fileTag
                    let Font =  UIFont.systemFont(ofSize: 17.0)
                    let labelWidth = stringTag.witdthOfString(font: Font)
                    let totalWidth = self.tagAddView.frame.size.width
                    if(totalWidth <= self.tagAddedWidth + labelWidth + 30){
                        self.tagAddedWidth = 0
                        self.tagAddedHeight += 30
                    }
                    
                    tagView.topAnchor.constraint(equalTo: self.tagAddView.topAnchor, constant: self.tagAddedHeight).isActive = true
                    tagView.leadingAnchor.constraint(equalTo: self.tagAddView.leadingAnchor, constant: self.tagAddedWidth).isActive = true
                    tagView.widthAnchor.constraint(equalToConstant: labelWidth + 20).isActive = true
                    tagView.heightAnchor.constraint(equalToConstant: 30).isActive = true
                    tagView.tag = index
                    
                    tagView.addSubview(tagLabel)
                    
                    tagLabel.textAlignment = .left
                    tagLabel.text = "#\(stringTag)"
                    tagLabel.widthAnchor.constraint(equalToConstant: labelWidth+20).isActive = true
                    tagLabel.leftAnchor.constraint(equalTo: tagView.leftAnchor).isActive = true
                    tagLabel.centerYAnchor.constraint(equalTo: tagView.centerYAnchor).isActive = true
                    tagLabel.heightAnchor.constraint(equalTo: tagView.heightAnchor).isActive = true
                    
                    
                    self.tagAddedWidth += (labelWidth + 30)
                    self.scrollView.frame = CGRect(x: 0, y: 0, width: App.Size.screenWidth, height: App.Size.screenHeight)
                    
                    if (self.emailViewShowCheck) {
                    self.scrollView.contentSize = CGSize(width: App.Size.screenWidth, height: App.Size.screenHeight + self.tagAddedHeight - 100 + 150)
                    } else {
                    self.scrollView.contentSize = CGSize(width: App.Size.screenWidth, height: App.Size.screenHeight + self.tagAddedHeight - 100)
                    }
                    
                    print("totalWidth: \(totalWidth), \(self.tagAddedWidth)")
                }
                
            }
            self.tagAddViewHeight.constant = self.tagAddedHeight
//            self.contentViewHeight.constant = App.Size.screenHeight + self.tagAddedHeight
//            
        }
    }
    
    func covertFileSize(getSize:String) -> String {
        var convertedValue: Double = Double(getSize)!
        var multiplyFactor = 0
        let tokens = ["bytes", "KB", "MB", "GB", "TB", "PB",  "EB",  "ZB", "YB"]
        while convertedValue >= 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        var result = String(format: "%4.2f", convertedValue)
        result = "\(Float(result)!) \(tokens[multiplyFactor])"
        
        return result.replacingOccurrences(of: ".0 ", with: " ")
    }
    
    @IBAction func btnEditClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "fileTagEditSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fileTagEditSegue" {
            if let vc = segue.destination as? FileInfoTagEditVC {
                vc.fileId = self.fileId
                vc.fileTagArray = self.fileTagArray
                
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
