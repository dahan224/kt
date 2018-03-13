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


class SettingViewController: UIViewController, BEMCheckBoxDelegate{
   
  

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
    
    
    var userId = ""
    var autoLoginCheck = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        loginUserId.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        
        passwordView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        passwordView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        passwordView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        passwordView.topAnchor.constraint(equalTo: self.loginView.bottomAnchor, constant: 1).isActive = true
        addLeftLabel(view: passwordView, label: passwordLabel, text: "비밀번호 변경")
        passwordView.addSubview(passwordButton)
        passwordButton.widthAnchor.constraint(equalToConstant: 36).isActive = true
        passwordButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        passwordButton.trailingAnchor.constraint(equalTo: passwordView.trailingAnchor, constant: -20).isActive = true
        passwordButton.centerYAnchor.constraint(equalTo: passwordView.centerYAnchor).isActive = true
        passwordButton.addTarget(self, action: #selector(changePasswordButton), for: .touchUpInside)
        
        
        autoLoginView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        autoLoginView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        autoLoginView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        autoLoginView.topAnchor.constraint(equalTo: self.passwordView.bottomAnchor, constant: 1).isActive = true
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
        googleDriveLoginEmail.bottomAnchor.constraint(equalTo: googleDriveEmailView.bottomAnchor, constant: -15).isActive = true
        googleDriveLoginEmail.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        
        
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
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "비밀번호 입력"
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "비밀번호 확인"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            let textField1 = alert?.textFields![1] // Force unwrapping because we know it exists.
            print("Text field: \(textField?.text)")
            print("Text field1: \(textField1?.text)")
        }))
        let cancelButton = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancelButton)
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)

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
                self.performSegue(withIdentifier: "googleSignInFromSetting", sender: self)
                self.halfBlackView.removeFromSuperview()
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
        let loginState = UserDefaults.standard.string(forKey: "googleDriveLoginState")
        
        if(loginState == "login"){
            googleDriveLoginState = .login
            googleDriveLogInLabel.text = "Google Drive 로그아웃"
            if let googleEmail:String = UserDefaults.standard.string(forKey: "googleEmail") {
                googleDriveLoginEmail.text = googleEmail
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
        let alertController = UIAlertController(title: "로그아웃 되었습니다.",message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default){ (action: UIAlertAction) in
        
            self.halfBlackView.removeFromSuperview()
        }
        
        alertController.addAction(okAction)
        self.present(alertController,animated: true,completion: nil)
        
        
    }
   
    
    
    @IBAction func backToHome(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
