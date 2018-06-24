//
//  SettingViewController.swift
//  KT
//
//  Created by 이다한 on 2018. 2. 25..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import BEMCheckBox
import GoogleAPIClientForREST
import GoogleSignIn
import Alamofire
import SwiftyJSON



class SettingViewController: UIViewController, BEMCheckBoxDelegate, GIDSignInDelegate, GIDSignInUIDelegate, UITableViewDelegate, UITableViewDataSource {
  
    private let scopes = [kGTLRAuthScopeDriveFile, kGTLRAuthScopeDrive, kGTLRAuthScopeDriveReadonly ]
    private let service = GTLRDriveService()
    let signInButton = GIDSignInButton()
    var googleEmailArray = [String]()
    var googleEmail = ""
    @IBOutlet weak var customNavBar: UIView!
    var loginCookie = ""
    var loginToken = ""
    
    let loginView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view;
    }()
    
    let passwordView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view;
    }()
    
    let autoLoginView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view;
    }()
    
    let googleDriveEmailView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view;
    }()
    let googleDriveLoginView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view;
    }()
    
    let loginLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let loginUserId:UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let passwordLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let passwordButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ico_36dp_nxt").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    let autoLoginLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let googleDriveInfoLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let googleDriveLoginEmail:UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let googleDriveLogInLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let googleButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ico_36dp_nxt").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let halfBlackView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.alpha = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view;
    }()
    let blackView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view;
    }()
    
    
    enum emailSelectionEnum {
        case previous
        case add
    }
    var emailSelectState = emailSelectionEnum.previous
    
    enum googleDriveLoginEnum {
        case login
        case logout
    }
    var googleDriveLoginState = googleDriveLoginEnum.logout
    let checkButton = BEMCheckBox()
    let checkButton2 = BEMCheckBox()
    let autoLoginCheckButton = BEMCheckBox()
    
    var containerViewController:ContainerViewController?
    var userId = ""
    var autoLoginCheck = false
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        
        
        loginCookie = UserDefaults.standard.string(forKey: "cookie")!
        loginToken = UserDefaults.standard.string(forKey: "token")!
        userId = UserDefaults.standard.string(forKey: "userId")!
        autoLoginCheckButton.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loginStateUpdate),
                                               name: NSNotification.Name("loginStateUpdate"),
                                               object: nil)
        self.view.addSubview(loginView)
        self.view.addSubview(passwordView)
        self.view.addSubview(autoLoginView)
        self.view.addSubview(googleDriveEmailView)
        self.view.addSubview(googleDriveLoginView)
        loginView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        loginView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        loginView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        loginView.topAnchor.constraint(equalTo: self.customNavBar.bottomAnchor, constant: 5).isActive = true
        addLeftLabel(view: loginView, label: loginLabel, text: "로그인 정보")
        loginView.addSubview(loginUserId)
        loginUserId.text = userId
        loginUserId.textColor = HexStringToUIColor().getUIColor(hex: "ff0000")
        loginUserId.widthAnchor.constraint(equalToConstant: 100).isActive = true
        loginUserId.trailingAnchor.constraint(equalTo: loginView.trailingAnchor, constant: -25).isActive = true
        loginUserId.centerYAnchor.constraint(equalTo: loginView.centerYAnchor).isActive = true
        loginUserId.heightAnchor.constraint(equalToConstant: 17).isActive = true
        
//
//        passwordView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
//        passwordView.heightAnchor.constraint(equalToConstant: 70).isActive = true
//        passwordView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
//        passwordView.topAnchor.constraint(equalTo: self.loginView.bottomAnchor, constant: 1).isActive = true
//        addLeftLabel(view: passwordView, label: passwordLabel, text: "비밀번호 변경")
//        passwordView.addSubview(passwordButton)
//        passwordButton.widthAnchor.constraint(equalToConstant: 36).isActive = true
//        passwordButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
//        passwordButton.trailingAnchor.constraint(equalTo: passwordView.trailingAnchor, constant: -20).isActive = true
//        passwordButton.centerYAnchor.constraint(equalTo: passwordView.centerYAnchor).isActive = true
//        passwordButton.addTarget(self, action: #selector(changePasswordButton), for: .touchUpInside)
        
        
        autoLoginView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        autoLoginView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        autoLoginView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        autoLoginView.topAnchor.constraint(equalTo: self.loginView.bottomAnchor, constant: 1).isActive = true
        addLeftLabel(view: autoLoginView, label: autoLoginLabel, text: "자동 로그인")
        autoLoginView.addSubview(autoLoginCheckButton)
        autoLoginCheckButton.boxType = BEMBoxType.square
        autoLoginCheckButton.translatesAutoresizingMaskIntoConstraints = false
        autoLoginCheckButton.onTintColor = HexStringToUIColor().getUIColor(hex: "FF0000")
        autoLoginCheckButton.onCheckColor = HexStringToUIColor().getUIColor(hex: "FF0000")
        autoLoginCheckButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        autoLoginCheckButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        autoLoginCheckButton.trailingAnchor.constraint(equalTo: autoLoginView.trailingAnchor, constant: -20).isActive = true
        autoLoginCheckButton.centerYAnchor.constraint(equalTo: autoLoginView.centerYAnchor).isActive = true
        
        
        googleDriveEmailView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        googleDriveEmailView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        googleDriveEmailView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        googleDriveEmailView.topAnchor.constraint(equalTo: self.autoLoginView.bottomAnchor, constant: 1).isActive = true
        addLeftTopLabel(view: googleDriveEmailView, label: googleDriveInfoLabel, text: "Google Drive 로그인 정보")
        googleDriveEmailView.addSubview(googleDriveLoginEmail)
        googleDriveLoginEmail.text = ""
        googleDriveLoginEmail.textColor = HexStringToUIColor().getUIColor(hex: "ff0000")
        googleDriveLoginEmail.widthAnchor.constraint(equalTo: googleDriveEmailView.widthAnchor).isActive = true
        googleDriveLoginEmail.trailingAnchor.constraint(equalTo: googleDriveEmailView.trailingAnchor, constant: -25).isActive = true
        googleDriveLoginEmail.bottomAnchor.constraint(equalTo: googleDriveEmailView.bottomAnchor, constant: -17).isActive = true
        googleDriveLoginEmail.heightAnchor.constraint(equalToConstant: 17).isActive = true
        
        
        
        googleDriveLoginView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        googleDriveLoginView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        googleDriveLoginView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        googleDriveLoginView.topAnchor.constraint(equalTo: self.googleDriveEmailView.bottomAnchor, constant: 1).isActive = true
        addLeftLabel(view: googleDriveLoginView, label: googleDriveLogInLabel, text: "Google Drive 로그인")
        
        
        googleDriveLoginView.addSubview(googleButton)
        googleButton.widthAnchor.constraint(equalToConstant: 36).isActive = true
        googleButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        googleButton.trailingAnchor.constraint(equalTo: googleDriveLoginView.trailingAnchor, constant: -20).isActive = true
        googleButton.centerYAnchor.constraint(equalTo: googleDriveLoginView.centerYAnchor).isActive = true
        googleButton.addTarget(self, action: #selector(googleDriveLoginAlert), for: .touchUpInside)
        
        autoLoginCheck = UserDefaults.standard.bool(forKey: "autoLoginCheck")
        if(autoLoginCheck){
            autoLoginCheckButton.setOn(true, animated: false)
            
        }
        loginStateUpdate()
    }
    
    func addLeftLabel(view:UIView, label:UILabel, text:String){
        view.addSubview(label)
        label.textAlignment = .left
        label.text = text
        label.textColor = HexStringToUIColor().getUIColor(hex: "4f4f4f")
        label.widthAnchor.constraint(equalToConstant: 200).isActive = true
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
    }
   
    
    func addLeftTopLabel(view:UIView, label:UILabel, text:String){
        view.addSubview(label)
        label.textAlignment = .left
        label.text = text
        label.textColor = HexStringToUIColor().getUIColor(hex: "4f4f4f")
        label.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant : 10).isActive = true
        label.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        
        
    }
    
    func didTap(_ checkBox: BEMCheckBox) {
        if(autoLoginCheck){
            autoLoginCheckButton.setOn(false, animated: false)
            autoLoginCheck = false
        } else {
            autoLoginCheckButton.setOn(true, animated: false)
            autoLoginCheck = true
        }
        let defaults = UserDefaults.standard
        defaults.set(autoLoginCheck, forKey: "autoLoginCheck")
        print(autoLoginCheck)
    }
    
   
    
    @objc func changePasswordButton(){
        let alert = UIAlertController(title: "비밀번호 변경", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "현재 비밀번호"
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "비밀번호 입력"
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "비밀번호 확인"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            let textField1 = alert?.textFields![1] // Force unwrapping because we know it exists.
            let textField2 = alert?.textFields![2]
            self.checkPassword(oldPwd: (textField?.text)!, pwd: (textField1?.text)!, pwd2: (textField2?.text)!)
        }))
        let cancelButton = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancelButton)
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func checkPassword(oldPwd:String, pwd:String, pwd2:String) {
        var check:Bool = true
        var title = ""
        let orgPwd = UserDefaults.standard.string(forKey: "userPassword")
        let pwdRegEx = "^(?=.*[a-zA-Z])(?=.*[!@#$%^*+=-])(?=.*[0-9]).{8,15}$"
        let pwdTest = NSPredicate(format:"SELF MATCHES %@", pwdRegEx)
        
        if pwd2 == "" {
            title = "비밀번호를 확인해 주세요."
            check = false
        } else if orgPwd != oldPwd {
            title = "현재 비밀번호를 확인해주세요."
        }  else if pwd != pwd2 {
            title = "비밀번호가 동일하지 않습니다."
            check = false
        } else if pwd == orgPwd {
            title = "현재 비밀번호와 동일합니다."
            check = false
        } else if pwd.count < 8 {
            title = "8자 이상의 비밀번호를 입력해주세요."
            check = false
        } else if Util.checkSpace(pwd) {
            title = "비밀번호에 공백을 제거해 주세요."
            check = false
        } else if !pwdTest.evaluate(with: pwd) {
            title = "숫자,문자,특수문자를 포함하여 8~15를 입력해주세요."
            check = false
        }
        
        if check {
            
            let jsonHeader:[String:String] = [
                "Content-Type": "application/json",
                "X-Auth-Token": UserDefaults.standard.string(forKey: "token")!,
                "Cookie": UserDefaults.standard.string(forKey: "cookie")!
            ]
            
            let url = App.URL.hostIpServer + "modifyPassword.do"
            
            Alamofire.request(url, method:.post,parameters:["userId":userId, "password":pwd],encoding:JSONEncoding.default, headers:jsonHeader).responseJSON { response in
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let statusCode = json["statusCode"].int
                    /*
                     if let headerFields = response.response?.allHeaderFields as? [String:String] {
                     
                     if Int(headerFields["code"]!)! == 400 {
                     let alertController = UIAlertController(title: "세션 정보가 만료 되었습니다. 다시 로그인 해주세요.",message: "", preferredStyle: UIAlertControllerStyle.alert)
                     let okAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel) { UIAlertAction in
                     UserDefaults.standard.removeObject(forKey: "token")
                     UserDefaults.standard.removeObject(forKey: "cookie")
                     
                     // 로그인화면으로~
                     self.dismiss(animated: false, completion: nil)
                     }
                     alertController.addAction(okAction)
                     self.present(alertController,animated: true,completion: nil)
                     }
                     }*/
                    if statusCode == 100 {
                        let alertController = UIAlertController(title: "비밀번호가 변경 되었습니다. 다시 로그인 해주세요.",message: "", preferredStyle: UIAlertControllerStyle.alert)
                        let okAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel) { UIAlertAction in
                            UserDefaults.standard.removeObject(forKey: "token")
                            UserDefaults.standard.removeObject(forKey: "cookie")
                            
                            // 로그인화면으로~
                            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                        }
                        alertController.addAction(okAction)
                        self.present(alertController,animated: true,completion: nil)
                    }
                case .failure(let error):
                    print(error)
                    let alertController = UIAlertController(title: "요청처리를 실패했습니다.",message: "", preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel, handler:nil)
                    alertController.addAction(okAction)
                    self.present(alertController,animated: true,completion: nil)
                }
            }
            
        } else {
            let alertController = UIAlertController(title: title,message: "", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel) { UIAlertAction in
                self.changePasswordButton()
            }
            alertController.addAction(okAction)
            self.present(alertController,animated: true,completion: nil)
        }
    }
    
    @objc func googleDriveLoginAlert(){
        view.addSubview(self.halfBlackView)
        halfBlackView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        halfBlackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        halfBlackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        halfBlackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        if(googleDriveLoginState == .login){
            let alertController = UIAlertController(title: "Google Drive 로그아웃",message: "", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default){ (action: UIAlertAction) in
                self.logout()
                
            }
            let cancelButton = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel){ (action: UIAlertAction) in
                self.halfBlackView.removeFromSuperview()
            }
            alertController.addAction(okAction)
            alertController.addAction(cancelButton)
            self.present(alertController,animated: true,completion: nil)
            
        } else {
            
            let alertController = UIAlertController(title: "Google Drive에 로그인\n하시겠습니까?",message: "", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default){ (action: UIAlertAction) in
//                self.getPreviousSyncEmail()
//                self.performSegue(withIdentifier: "googleSignInFromSetting", sender: self)
//                self.halfBlackView.removeFromSuperview()
                self.containerViewController?.googleSignInSegueState = .loginForSetting
                self.googleSignInAlertShow()
            }
            let cancelButton = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel){ (action: UIAlertAction) in
                self.halfBlackView.removeFromSuperview()
            }
            alertController.addAction(okAction)
            alertController.addAction(cancelButton)
            self.present(alertController,animated: true,completion: nil)
        }
    }
    
    @objc func loginStateUpdate(){
        print("loginStateUpdate called")
        let loginState = UserDefaults.standard.string(forKey: "googleDriveLoginState")
//        if GIDSignIn.sharedInstance().hasAuthInKeychain() == true {
        print("loginState \(loginState)")
        if(loginState == "login"){
            googleDriveLoginState = .login
            googleDriveLogInLabel.text = "Google Drive 로그아웃"
            if let googleEmail:String = UserDefaults.standard.string(forKey: "googleEmail") {
                googleDriveLoginEmail.text = googleEmail
                print("googleEmail : \(googleEmail)")
            }
        } else {
            googleDriveLoginState = .logout
            googleDriveLogInLabel.text = "Google Drive 로그인"
            googleDriveLoginEmail.text = ""
        }
        
        
    }
    
    
    
    
    func logout(){
        googleDriveLoginState = .logout
        googleDriveLogInLabel.text = "Google Drive 로그인"
        googleDriveLoginEmail.text = ""
        GIDSignIn.sharedInstance().signOut()
        let defaults = UserDefaults.standard
        defaults.set("logout", forKey: "googleDriveLoginState")
        let alertController = UIAlertController(title: "로그아웃 되었습니다.",message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default){ (action: UIAlertAction) in
            
            
            self.halfBlackView.removeFromSuperview()
        }
        
        alertController.addAction(okAction)
        self.present(alertController,animated: true,completion: nil)
        
        
    }
   
    
    func googleSignInAlertShow(){
//        let transition = CATransition()
//        transition.type = kCATransitionPush
//        transition.subtype = kCATransitionFromRight
//        view.layer.add(transition, forKey: nil)
        view.addSubview(self.halfBlackView)
        
        halfBlackView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        halfBlackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        halfBlackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        halfBlackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        let alertController = UIAlertController(title: "Google Drive에 로그인\n하시겠습니까?",message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default){ (action: UIAlertAction) in
            //                self.getPreviousSyncEmail()
            
            self.getPreviousSyncEmail()
            //            self.performSegue(withIdentifier: "googleSignInSegue", sender: self)
            //            self.halfBlackView.removeFromSuperview()
        }
        let cancelButton = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel){ (action: UIAlertAction) in
            self.halfBlackView.removeFromSuperview()
            if(self.activityIndicator?.isAnimating)!{
                self.activityIndicator?.stopAnimating()
            }
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelButton)
        self.present(alertController,animated: true,completion: nil)
        
    }
    func getPreviousSyncEmail(){
        let headers = [
            "Content-Type": "application/json",
            "X-Auth-Token": UserDefaults.standard.string(forKey: "token") ?? "nil",
            "Cookie": UserDefaults.standard.string(forKey: "cookie") ?? "nil"
        ]
        
        print("headers : \(headers)")
        let userId:String = App.defaults.userId
        Alamofire.request(App.URL.hostIpServer+"selectCloudId.json"
            , method: .post
            , parameters:["userId":userId,"cloudKind":"D"]
            , encoding : JSONEncoding.default
            , headers: headers
            ).responseJSON { response in
                
                switch response.result {
                case .success(let value):
                    let responseData = value as! NSDictionary
                    let message = responseData.object(forKey: "message")
                    print("message : \(message)")
                    if let listData = responseData.object(forKey: "data") {
                        let data = listData as! NSDictionary
                        let cloudId = data.object(forKey: "cloudId") as! String
                        print("cloudId : \(cloudId)")
                        self.showPreviousSyncEmail(email:cloudId)
                    } else {
                        self.showRadioAlert()
                    }
                    
                    break
                case .failure(let error):
                    NSLog(error.localizedDescription)
                    self.halfBlackView.removeFromSuperview()
                    if(self.activityIndicator?.isAnimating)!{
                        self.activityIndicator?.stopAnimating()
                    }
                    
                    break
                }
        }
    }
    func showPreviousSyncEmail(email:String){
        let alertController = UIAlertController(title: "동기화 ID는\n\(email)\n입니다.",message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default){ (action: UIAlertAction) in
            self.showRadioAlert()
        }
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true,completion: nil)
    }
    
    
    func showRadioAlert(){
        googleEmailArray = DbHelper().googleEmailListArray()
        googleEmailArray.append("계정 추가")
        var checkButtons:[BEMCheckBox] = [BEMCheckBox]()
        checkButtons.removeAll()
        
        let alertController = UIAlertController(title: "계정 선택",message: "", preferredStyle: UIAlertControllerStyle.alert)
        var alertHeight:CGFloat = 40
        if(googleEmailArray.count > 0) {
            alertHeight = CGFloat(40 * (googleEmailArray.count + 1))
        }
        
        let customView = UIView()
        customView.isUserInteractionEnabled = true
        customView.translatesAutoresizingMaskIntoConstraints = false
        alertController.view.addSubview(customView)
        customView.centerYAnchor.constraint(equalTo: alertController.view.centerYAnchor).isActive = true
        customView.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor).isActive = true
        customView.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor).isActive = true
        var customViewHeightAnchor:NSLayoutConstraint?
        customViewHeightAnchor = customView.heightAnchor.constraint(equalToConstant: alertHeight)
        customViewHeightAnchor?.isActive = true
        
        
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(GoogleEmailTableViewCell.self, forCellReuseIdentifier: "GoogleEmailTableViewCell")
        customView.addSubview(tableView)
        
        tableView.topAnchor.constraint(equalTo: customView.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: customView.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: customView.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: customView.bottomAnchor).isActive = true
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        
        tableView.reloadData()
        
        let height:NSLayoutConstraint = NSLayoutConstraint(item: alertController.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: alertHeight + 100)
        alertController.view.addConstraint(height);
        
        
        let okAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default){ (action: UIAlertAction) in
            self.halfBlackView.removeFromSuperview()
            print("emailSelectState : \(self.emailSelectState)")
            if(self.emailSelectState == .add) {
                
                self.googleSignIn()
                
            } else {
                //                self.googleSignInSilently()
                self.loginWBySelectedEmail()
            }
            
        }
        let cancelAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel){ (action: UIAlertAction) in
            self.halfBlackView.removeFromSuperview()
            if(self.activityIndicator?.isAnimating)!{
                self.activityIndicator?.stopAnimating()
            }
            
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController,animated: true,completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return googleEmailArray.count
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoogleEmailTableViewCell") as! GoogleEmailTableViewCell
        cell.lblMain.text = googleEmailArray[indexPath.row]
        cell.btnCheck.setOn(false, animated: false)
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height:CGFloat = 50.0
        
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print(indexPath.section)
        print(indexPath.row)
        for (index, string) in googleEmailArray.enumerated() {
            let otherIndexPath = IndexPath(row: index, section: 0)
            if (otherIndexPath != indexPath){
                if let otherCell = tableView.cellForRow(at: otherIndexPath) as? GoogleEmailTableViewCell{
                    otherCell.btnCheck.setOn(false, animated: true)
                }
            } else {
                
                let clickedCell = tableView.cellForRow(at: indexPath) as? GoogleEmailTableViewCell
                clickedCell?.btnCheck.setOn(true, animated: true)
            }
            
        }
        googleEmail = googleEmailArray[indexPath.row]
        print("googleEmailArray.count : \(googleEmailArray.count)")
        if(indexPath.row == googleEmailArray.count - 1){
            emailSelectState = .add
            print("emailSelectState : \(emailSelectState)")
        } else {
            emailSelectState = .previous
            print("emailSelectState : \(emailSelectState)")
        }
        
    }
    
    func googleSignIn(){
        print("googleSignIn")
        GIDSignIn.sharedInstance().signOut()
        let userDefaults = UserDefaults.standard
        let dict = UserDefaults.standard.dictionaryRepresentation()
        for key in dict.keys {
            if key == "GID_AppHasRunBefore" || key == "token" || key == "cookie" || key == "userId" || key == "autoLoginCheck" || key == "userId" || key == "userPassword" || key == "googleDriveLoginState" || key == "idSaveCheck"{
                continue
            }
            userDefaults.removeObject(forKey: key);
        }
        UserDefaults.standard.synchronize()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signIn()
        
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("error: \(error)")
            GIDSignIn.sharedInstance().signOut()
            let userDefaults = UserDefaults.standard
            let dict = UserDefaults.standard.dictionaryRepresentation()
            for key in dict.keys {
                if key == "GID_AppHasRunBefore" || key == "token" || key == "cookie" || key == "userId" || key == "autoLoginCheck" || key == "userId" || key == "userPassword" || key == "googleDriveLoginState" {
                    continue
                }
                userDefaults.removeObject(forKey: key);
            }
            UserDefaults.standard.synchronize()
            DispatchQueue.main.async {
                self.service.authorizer = nil
                
                self.showAlert(title: "Authentication Error", message: "재 시도 부탁 드립니다.")
                
            }
            if(self.activityIndicator?.isAnimating)!{
                self.activityIndicator?.stopAnimating()
            }
            
        } else {
            var accessToken:String = ""
                accessToken = GIDSignIn.sharedInstance().currentUser.authentication.accessToken
                print("final")
                let today = Date()
                let stToday = Util.date(text: today)
                print("stToday : \(stToday)")
                self.signInButton.isHidden = true
                self.service.authorizer = user.authentication.fetcherAuthorizer()
                print("googleEmail : \(self.googleEmail)")
                self.googleEmail = user.profile.email
                self.googleDriveLoginState = .login
                let defaults = UserDefaults.standard
                defaults.set(self.googleEmail, forKey: "googleEmail")
                defaults.set(accessToken, forKey: "googleAccessToken")
                defaults.set(stToday, forKey: "googleLoginTime")
                defaults.set("login", forKey: "googleDriveLoginState")
                defaults.synchronize()
                if(self.activityIndicator?.isAnimating)!{
                    self.activityIndicator?.stopAnimating()
                }
                NotificationCenter.default.post(name: Notification.Name("loginStateUpdate"), object: self)
        }
    }
    func loginWBySelectedEmail(){
        print("loginWBySelectedEmail called")
        let loginState = UserDefaults.standard.string(forKey: "googleDriveLoginState")
        if(loginState != "login") {
            googleSignIn()
        }  else {
            GIDSignIn.sharedInstance().signInSilently()
        }
    }
    
    @IBAction func backToHome(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name("backToOneView"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name("toggleSideMenu"), object: nil)
        dismiss(animated: false, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
         loginStateUpdate()
        
        
    }
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
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
