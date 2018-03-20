//
//  ViewController.swift
//  KT
//
//  Created by 이다한 on 2018. 1. 22..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import Alamofire
import BEMCheckBox
import SwiftyJSON


class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var checkBox: BEMCheckBox!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var hexToUIColor:HexStringToUIColor = HexStringToUIColor()
    var uuId:String = ""
    var deviceModel:String = ""
    var osCd = "I"
    var osDesc = "IOS"
    var mkngVndrNm = "Apple"
    var rootFoldrNm = "Mobile"
    var lastUpdtId = "ktuser2"
    
    var userId:String = ""
    var userPassword:String = ""
    var loginToken:String = ""
    var loginCookie:String = ""
    var autoLoginCheck = false
    
    var DeviceArray:[App.DeviceStruct] = []
    
    
    @IBOutlet weak var loginWarningLabel: UILabel!
    @IBOutlet weak var loginWarningLabelHeight: NSLayoutConstraint!
    
    
    
    var fileNames = [String]()
    var fileSize = [NSNumber]()
    var fileDate = [Date]()
    
    
    var localFolderArray:[App.Folders] = []
    var folderPathArray = [String]()
    var folderArrayToCreate:[[String:Any]] = []
    var folderArrayToUpdate:[[String:Any]] = []
    var folderArrayToDelete:[[String:Any]] = []
    
    
    var localFileArray:[App.Files] = []
    var serverFileArray:[[String:Any]] = []
    var fileArrayToCreate:[[String:Any]] = []
    var fileArrayToUpdate:[[String:Any]] = []
    var fileArrayToDelete:[[String:Any]] = []
    var FileParameterArrayForUpload:[[String:Any]] = []
    
    var folderSyncFinished = false
    var fileSyncFinished = false
    
  
    
    @IBOutlet weak var textFieldId: UITextField!{
        didSet{
            textFieldId.placeholder = "아이디"
            textFieldId.addBorderBottom(height: 1.0, color: hexToUIColor.getUIColor(hex: "D1D2D4"))
            textFieldId.addTarget(self,
                                  action: #selector(LoginViewController.textFieldDidChange),
                                  for: .editingDidBegin)
            textFieldId.addTarget(self,
                                  action: #selector(LoginViewController.textFieldChangeFinished),
                                  for: .editingDidEnd)
            textFieldId.delegate = self
        }
    }
    @IBOutlet weak var textFieldPw: UITextField!{
        didSet{
            textFieldPw.placeholder = "비밀번호"
            textFieldPw.addBorderBottom(height: 1.0, color: hexToUIColor.getUIColor(hex: "D1D2D4"))
            textFieldPw.addTarget(self,
                                  action: #selector(LoginViewController.textFieldDidChange),
                                  for: .editingDidBegin)
            textFieldPw.addTarget(self,
                                  action: #selector(LoginViewController.textFieldChangeFinished),
                                  for: .editingDidEnd)
            textFieldPw.delegate = self
        }
    }
    @objc func textFieldDidChange(textField: UITextField) {
        //your code
        textField.addBorderBottom(height: 1.0, color: hexToUIColor.getUIColor(hex: "FF0000"))
    }
    @objc func textFieldChangeFinished(textField: UITextField) {
        //your code
        textField.addBorderBottom(height: 1.0, color: hexToUIColor.getUIColor(hex: "D1D2D4"))
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        for textField in self.view.subviews where textField is UITextField {
            textField.resignFirstResponder()
        }
        return true
    }
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    var jsonHeader:[String:String] = [
        "Content-Type": "application/json",
        "X-Auth-Token": "",
        "Cookie": ""
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        UserDefaults.standard.removeObject(forKey: "cookie")
        UserDefaults.standard.removeObject(forKey: "token")
        
        let string = "/Mobile"
        let str =  string.cString(using: String.Encoding.utf8)
        print("encodedString : \(str)")
        
        
        checkBox.boxType = BEMBoxType.square
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        uuId = Util.getUuid()
        deviceModel = DeviceModel.getModel()
        print("uuId : \(uuId)")
        print("model :\(deviceModel)")
        
        autoLogin()
    }
    
    @IBAction func autoLocinChecked(_ sender: BEMCheckBox) {
        autoLoginCheck = checkBox.on
        print("autocheck : \(autoLoginCheck)")
        let defaults = UserDefaults.standard
        defaults.set(autoLoginCheck, forKey: "autoLoginCheck")
    }
    
    func autoLogin(){
        autoLoginCheck = UserDefaults.standard.bool(forKey: "autoLoginCheck")
        print("autoLoginCheck : \(autoLoginCheck)")
        if(autoLoginCheck){
            checkBox.setOn(true, animated: false)
            login()
        }
    }
    
    @IBAction func btnLoginClicked(_ sender: UIButton) {
        
        if (textFieldId.text?.isEmpty ?? true) || (textFieldPw.text?.isEmpty ?? true) {
            print("textField is empty")
            loginWarningLabel.text = "로그인 정보를 확인해 주세요."
            loginWarningLabel.isHidden = false
        } else {
            userId = textFieldId.text!
            userPassword = textFieldPw.text!
            let defaults = UserDefaults.standard
            defaults.set(userId, forKey: "userId")
            defaults.set(userPassword, forKey: "userPassword")
            self.login()
            
        }
    }
    
    
    
    
    func login(){
        activityIndicator.startAnimating()
        userId =  UserDefaults.standard.string(forKey: "userId") ?? "nil"
        userPassword =  UserDefaults.standard.string(forKey: "userPassword") ?? "nil"
        loginWarningLabel.isHidden = true
        let urlString = App.URL.server+"login.do"
        let url = URL(string:urlString)
        let cstorage = HTTPCookieStorage.shared
        if let cookies = cstorage.cookies(for: url!) {
            for cookie in cookies {
                print("cookie : \(cookie)")
                cstorage.deleteCookie(cookie)
            }
        }
        Alamofire.request(urlString,
                          method: .post,
                          parameters: ["userId": userId,"password":userPassword],
                          encoding : URLEncoding.default,
                          headers: App.Headrs.loginHeader).responseJSON { response in
                            switch response.result {
                            case .success(let value) :
                                let json = JSON(value)
                                let responseData = value as! NSDictionary
                                let message = responseData.object(forKey: "message")
                                print(message)
                                if let statusCode = json["statusCode"].int, statusCode != 100 {
                                    let url = URL(string:urlString)
                                    let cstorage = HTTPCookieStorage.shared
                                    if let cookies = cstorage.cookies(for: url!) {
                                        for cookie in cookies {
                                            cstorage.deleteCookie(cookie)
                                        }
                                    }
                                    DispatchQueue.main.async {
                                        self.loginWarningLabelHeight.constant = 60
                                        self.loginWarningLabel.text = message as! String
                                        self.loginWarningLabel.isHidden = false
                                        self.activityIndicator.stopAnimating()
                                        print("whatCalled")
                                    }
                                } else {
                                  
                                    if let headerFields = response.response?.allHeaderFields as? [String: String]{
                                        if(headerFields["Cookie"] != nil){
                                            self.loginCookie = headerFields["Cookie"]!
                                            print("loginCookie : \(self.loginCookie)")
                                        }
                                        if(headerFields["X-Auth-Token"] != nil){
                                            self.loginToken = headerFields["X-Auth-Token"]!
                                            print("self.loginToken : \(self.loginToken)")
                                        }
                                        if(!self.loginCookie.isEmpty && !self.loginToken.isEmpty){
                                            
                                            let defaults = UserDefaults.standard
                                            defaults.set(self.loginCookie, forKey: "cookie")
                                            defaults.set(self.loginToken, forKey: "token")
                                            defaults.set(self.userId, forKey: "userId")
                                            defaults.synchronize()
                                            DispatchQueue.main.async {
                                                self.loginWarningLabelHeight.constant = 20
                                                self.loginWarningLabel.isHidden = true
                                            }
                                            if(self.loginCookie.isEmpty || self.loginToken.isEmpty){
                                                
                                            } else {
                                                
                                                if(self.loginCookie == UserDefaults.standard.string(forKey: "cookie") && self.loginToken == UserDefaults.standard.string(forKey: "token")){
                                                    print("true")
                                                    self.jsonHeader = [
                                                        "Content-Type": "application/json",
                                                        "X-Auth-Token": self.loginToken,
                                                        "Cookie": self.loginCookie
                                                    ]
                                                    self.registerDevice(jsonHeader:self.jsonHeader)
                                                } else {
                                                    print("false")
                                                }
                                                
                                                
                                            }
                                            
                                            
                                        }
                                    }
                                }
                                break
                            case .failure(let error):
                                print(error.localizedDescription)
                                DispatchQueue.main.async {
                                    self.loginWarningLabel.text = error.localizedDescription
                                    self.loginWarningLabel.isHidden = false
                                }
                                
                                break
                            }
        }
        
        
    }
    func initDevice(){
        
        let urlString = App.URL.server+"devDataInita.do"
        
        Alamofire.request(urlString,
                          method: .post,
                          parameters: ["userId":self.userId,"devUuid":uuId,"comnd":"N"],
                          encoding : JSONEncoding.default,
                          headers: jsonHeader).responseJSON{ (response) in
                            print("init device response : \(response)")
                            switch response.result {
                            case .success(let JSON):
                                print(response)
                                let responseData = JSON as! NSDictionary
                                let message = responseData.object(forKey: "message")
                                print("initDevice message : \(String(describing: message))")
                                break
                            case .failure(let error):
                                NSLog(error.localizedDescription)
                                self.activityIndicator.stopAnimating()
                                break
                            }
                            
                            
        }
    }
    
    func registerDevice(jsonHeader:[String:String]){
        
        let deviceParameter = App.DeviceInfo(userId: userId, devUuid: uuId, devNm: UIDevice.current.name, osCd: "I", osDesc: "IOS", mkngVndrNm: "apple", devAuthYn: "N", rootFoldrNm: "Mobile", lastUpdtId: userId, token: App.defaults.notificationToken)
        let urlString = App.URL.server+"devAthn.do"
        Alamofire.request(urlString,
                          method: .post,
                          parameters: deviceParameter.getParameter,
                          encoding : JSONEncoding.default,
                          headers: jsonHeader).responseJSON{ (response) in
                            print("registerDevice response : \(response.result)")
                            switch response.result {
                            case .success(let value):
                                print(response)
                                let json = JSON(value)
                                let responseData = value as! NSDictionary
                                let message = responseData.object(forKey: "message")
                                print("registerDevice message : \(String(describing: message))")
                                if let statusCode = json["statusCode"].int, statusCode != 100 {
                                    
                                    
                                } else {
                                    self.smsAuth(device:deviceParameter)
                                }
                                
                                break
                            case .failure(let error):
                                self.activityIndicator.stopAnimating()
                                NSLog(error.localizedDescription)
                                break
                            }
                            
                            
        }
    }
    
    func smsAuth(device:App.DeviceInfo) {
        
        let urlString = App.URL.server+"smsAuth.do"
        Alamofire.request(urlString,
                          method: .post,
                          parameters: device.getParameter,
                          encoding : JSONEncoding.default,
                          headers: jsonHeader).responseJSON{ (response) in
                            switch response.result {
                            case .success(let value):
                                print(value)
                                let json = JSON(value)
                                let responseData = value as! NSDictionary
                                let message = responseData.object(forKey: "message")
                                print("smsAuth message : \(message)")
                                if let statusCode = json["statusCode"].int, statusCode != 100 {
                                    
                                } else {
                                    
                                    if let listData = responseData.object(forKey: "data") as? NSDictionary {
                                        
                                        // 사용자정의 팝업
                                        let popup: PopupView = UINib(nibName: "PopupView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! PopupView
                                        
                                        // 팝업뷰 배경
                                        let viewColor = UIColor.black
                                        popup.backgroundColor = viewColor.withAlphaComponent(0.3)
                                        popup.frame = self.view.frame // 팝업뷰를 화면크기에 맞추기
                                        
                                        // 팝업창 배경
                                        let baseViewColor = UIColor.white
                                        popup.popupView.backgroundColor = baseViewColor.withAlphaComponent(1.0)
                                        
                                        popup.lblTop.backgroundColor = HexStringToUIColor().getUIColor(hex: "FF0000")
                                        popup.lblTop.textColor = UIColor.white
                                        
                                        //popup.devBas = App.DeviceStruct(device: data.object(forKey: "devBasVO") as! AnyObject)
                                        popup.data = App.smsInfo(sms: listData as! AnyObject)
                                        
                                        self.view.addSubview(popup)
                                        
                                    } else {
                                        self.sysncFileInfo()
                                    }
                                }
                            case .failure(let error):
                                self.activityIndicator.stopAnimating()
                                NSLog(error.localizedDescription)
                            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sysncFileInfo() {
        print("syncFileInfo called")
        SyncLocalFilleToNas().sync()
        getDeviceList(sortBy: DbHelper.sortByEnum.none)
        
        
    }
    
    func getDeviceList(sortBy: DbHelper.sortByEnum){
        DeviceArray.removeAll()
        GetListFromServer().getDevice(){ responseObject, error in
            let json = JSON(responseObject as Any)
            if let statusCode = json["statusCode"].int, statusCode == 100 {
                let serverList:[AnyObject] = json["listData"].arrayObject! as [AnyObject]
                //                                print("one view list : \(serverList)")
                for device in serverList {
                    let deviceStruct = App.DeviceStruct(device: device)
                    self.DeviceArray.append(deviceStruct)
                    let defaults = UserDefaults.standard
                    //                    print("deviceStruct.devNm : \(deviceStruct.devNm)")
                    if(deviceStruct.osCd == "G"){
                        print("giga nas id saved : \(deviceStruct.devNm)")
                        defaults.set(deviceStruct.devUuid, forKey: "nasDevId")
                        defaults.set(deviceStruct.userId, forKey: "nasUserId")
                    }
                    if(deviceStruct.osCd == "S"){
                        print("giga storageDevId id saved : \(deviceStruct.devNm)")
                        defaults.set(deviceStruct.devUuid, forKey: "storageDevId")
                        defaults.set(deviceStruct.userId, forKey: "storageUserId")
                    }
                }
                
                let googleDrive = App.DeviceStruct(devNm : "Google Drive", devUuid : "devUuidValue", logical: "nll", mkngVndrNm : "mkngVndrNmValue", newFlag: "N", onoff : "N", osCd : "D", osDesc : "D", osNm : "D", userId : "userIdValue", userName : "Y")
                self.DeviceArray.append(googleDrive)
                //
                DbHelper().jsonToSqlite(getArray: self.DeviceArray)
                DispatchQueue.main.async {
                    
                    self.segueToMain()
                }
                
            }
            return
        }
    }
    
    func segueToMain(){
        //        print("segueToMain called \(self.folderSyncFinished), \(self.fileSyncFinished)")
        //        if(self.folderSyncFinished && self.fileSyncFinished){
        self.activityIndicator.stopAnimating()
        self.performSegue(withIdentifier: "LoginSegue", sender: nil)
        self.dismiss(animated: false, completion: nil)
        
        //        }
    }
    
    func stopAnimating() {
        self.activityIndicator.stopAnimating()
    }
    
    
}

extension URL {
    var isDirectory: Bool {
        return (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
    var subDirectories: [URL] {
        guard isDirectory else { return [] }
        return (try? FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]).filter{ $0.isDirectory }) ?? []
    }
}

extension UITextField {
    func addBorderBottom(height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: self.frame.height-height, width: self.frame.width, height: height)
        border.backgroundColor = color.cgColor
        self.layer.addSublayer(border)
    }
}

