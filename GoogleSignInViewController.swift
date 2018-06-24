//
//  GoogleSignInViewController.swift
//  KT
//
//  Created by 이다한 on 2018. 3. 1..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GoogleSignIn 
import Alamofire
import SwiftyJSON
import BEMCheckBox



class GoogleSignInViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate  {
    private let scopes = [kGTLRAuthScopeDriveFile, kGTLRAuthScopeDrive, kGTLRAuthScopeDriveReadonly ]
    private let service = GTLRDriveService()
    let signInButton = GIDSignInButton()
    var loginCookie = ""
    var loginToken = ""
    var userId = ""
    var googleEmail = ""
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
    var segueCheck = 0
    var googleSignInSegueState = ContainerViewController.googleSignInSegueEnum.loginForList
    
    
    var driveFileArray:[App.DriveFileStruct] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        
        loginCookie = UserDefaults.standard.string(forKey: "cookie")!
        loginToken = UserDefaults.standard.string(forKey: "token")!
        
        userId = UserDefaults.standard.string(forKey: "userId")!
        
        self.view.backgroundColor = UIColor.black
        print("google sign in viewcontroller called")
        
        getPreviousSyncEmail()

        // Do any additional setup after loading the view.
    }
    func getPreviousSyncEmail(){
        let headers = [
            "Content-Type": "application/json",
            "X-Auth-Token": self.loginToken,
            "Cookie": self.loginCookie
        ]
        
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
                        
                    }
                    
                    break
                case .failure(let error):
                    NSLog(error.localizedDescription)
                    
                    break
                }
        }
    }

    func showPreviousSyncEmail(email:String){
        let alertController = UIAlertController(title: "동기화 ID는\n\(email)\n입니다.",message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default){ (action: UIAlertAction) in
            self.showRadioAlert(email: email)
        }
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true,completion: nil)
    }
    
    func showRadioAlert(email:String){
        let alertController = UIAlertController(title: "계정 선택",message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        let customView = UIView()
        customView.translatesAutoresizingMaskIntoConstraints = false
        //        customView.backgroundColor = UIColor.gray
        alertController.view.addSubview(customView)
        customView.centerYAnchor.constraint(equalTo: alertController.view.centerYAnchor).isActive = true
        customView.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor).isActive = true
        customView.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor).isActive = true
        customView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        let emailView = UIView()
        emailView.translatesAutoresizingMaskIntoConstraints = false
        customView.addSubview(emailView)
        emailView.topAnchor.constraint(equalTo: customView.topAnchor).isActive = true
        emailView.leadingAnchor.constraint(equalTo: customView.leadingAnchor).isActive = true
        emailView.trailingAnchor.constraint(equalTo: customView.trailingAnchor).isActive = true
        emailView.bottomAnchor.constraint(equalTo: customView.centerYAnchor).isActive = true
        let gesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectEmail))
        gesture.numberOfTapsRequired = 1
        emailView.isUserInteractionEnabled = true
        emailView.addGestureRecognizer(gesture)
        
        checkButton.boxType = .circle
        checkButton.translatesAutoresizingMaskIntoConstraints = false
        emailView.addSubview(checkButton)
        checkButton.centerYAnchor.constraint(equalTo: emailView.centerYAnchor).isActive = true
        checkButton.leadingAnchor.constraint(equalTo: emailView.leadingAnchor, constant: 10).isActive = true
        checkButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        checkButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        checkButton.addTarget(self, action: #selector(selectEmail), for: .touchUpInside)
        
        let defaults = UserDefaults.standard
        let googleEmail:String = defaults.string(forKey: "googleEmail") as? String ?? "nil"
        var finalEmail:String = email
        if (googleEmail.isEmpty || googleEmail == "nil"){
        } else {
            finalEmail = googleEmail
        }
        
        let emailLabel = UILabel()
        emailLabel.textAlignment = .left
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.text = finalEmail
        emailView.addSubview(emailLabel)
        emailLabel.centerYAnchor.constraint(equalTo: emailView.centerYAnchor).isActive = true
        emailLabel.leadingAnchor.constraint(equalTo: checkButton.trailingAnchor, constant: 5).isActive = true
        emailLabel.trailingAnchor.constraint(equalTo: emailView.trailingAnchor).isActive = true
        emailLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        let addView = UIView()
        addView.translatesAutoresizingMaskIntoConstraints = false
        customView.addSubview(addView)
        addView.topAnchor.constraint(equalTo: customView.centerYAnchor).isActive = true
        addView.leadingAnchor.constraint(equalTo: customView.leadingAnchor).isActive = true
        addView.trailingAnchor.constraint(equalTo: customView.trailingAnchor).isActive = true
        addView.bottomAnchor.constraint(equalTo: customView.bottomAnchor).isActive = true
        
        let gesture2:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectAdd))
        gesture2.numberOfTapsRequired = 1
        addView.isUserInteractionEnabled = true
        addView.addGestureRecognizer(gesture2)
        
        checkButton2.boxType = .circle
        checkButton2.translatesAutoresizingMaskIntoConstraints = false
        addView.addSubview(checkButton2)
        checkButton2.centerYAnchor.constraint(equalTo: addView.centerYAnchor).isActive = true
        checkButton2.leadingAnchor.constraint(equalTo: addView.leadingAnchor, constant: 10).isActive = true
        checkButton2.widthAnchor.constraint(equalToConstant: 25).isActive = true
        checkButton2.heightAnchor.constraint(equalToConstant: 25).isActive = true
        checkButton2.addTarget(self, action: #selector(selectAdd), for: .touchUpInside)
        
        let addLabel = UILabel()
        addLabel.textAlignment = .left
        addLabel.translatesAutoresizingMaskIntoConstraints = false
        addLabel.text = "계정 추가"
        addView.addSubview(addLabel)
        addLabel.centerYAnchor.constraint(equalTo: addView.centerYAnchor).isActive = true
        addLabel.leadingAnchor.constraint(equalTo: checkButton2.trailingAnchor, constant: 5).isActive = true
        addLabel.trailingAnchor.constraint(equalTo: addView.trailingAnchor).isActive = true
        addLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        
        let height:NSLayoutConstraint = NSLayoutConstraint(item: alertController.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: self.view.frame.width * 0.60)
        alertController.view.addConstraint(height);
        
        let okAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default){ (action: UIAlertAction) in
            if(self.emailSelectState == .add) {
                self.googleSignIn()
            } else {
                self.googleSignInSilently()
            }
            
        }
        let cancelAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel){ (action: UIAlertAction) in
            self.dismiss(animated: false, completion:  nil)
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController,animated: true,completion: nil)
    }
    
    func googleSignInSilently(){
        
        UserDefaults.standard.synchronize()
        if GIDSignIn.sharedInstance().hasAuthInKeychain() == true {
            GIDSignIn.sharedInstance().signInSilently()
            print("sign in silently")
//            self.googleSignIn()
        } else {
            GIDSignIn.sharedInstance().signOut()
            let userDefaults = UserDefaults.standard
            let dict = UserDefaults.standard.dictionaryRepresentation()
            for key in dict.keys {
                if key == "GID_AppHasRunBefore"{
                    continue
                }
                userDefaults.removeObject(forKey: key);
            }
            UserDefaults.standard.synchronize()
            print("sign in")
            self.googleSignIn()
            
        }
    }
    func googleSignIn(){
        GIDSignIn.sharedInstance().signIn()
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("error: \(error)")
            DispatchQueue.main.async {
                self.service.authorizer = nil
                self.showAlert(title: "Authentication Error", message: error.localizedDescription)
                
            }
            
        } else {
            var accessToken:String = ""
            DispatchQueue.main.async {
                self.signInButton.isHidden = true
                self.service.authorizer = user.authentication.fetcherAuthorizer()
                self.googleEmail = user.profile.email
                self.googleDriveLoginState = .login
                let defaults = UserDefaults.standard
                defaults.set(self.googleEmail, forKey: "googleEmail")
                defaults.set("login", forKey: "googleDriveLoginState")
                
            }
            print("logedIn")
//            self.listFiles()
            accessToken = GIDSignIn.sharedInstance().currentUser.authentication.accessToken
            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: "accessToken")
            print("accessToken : \(accessToken)")
            getFiles(accessToken: accessToken, root: "root")
            
            
        }
    }
    
    func getFiles(accessToken:String, root:String){
        self.driveFileArray.removeAll()
        var url = "https://www.googleapis.com/drive/v3/files?q='\(root)' in parents and trashed=false&access_token=\(accessToken)" + App.URL.gDriveFileOption // 0eun
        url = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        Alamofire.request(url,
                          method: .get,
                          encoding: JSONEncoding.default,
                          headers: nil).responseJSON { response in
                            switch response.result {
                            case .success(let value):
                                let json = JSON(value)
                                print("json : \(json)")
                                if let serverList:[AnyObject] = json["files"].arrayObject as! [AnyObject] {
                                    for file in serverList {
                                        print("file : \(file)")
                                        if file["trashed"] as? Int == 0 && file["starred"] as? Int == 0 && file["shared"] as? Int == 0 {
                                            let fileStruct = App.DriveFileStruct(device: file, foldrWholePaths: ["Google"])
                                            if fileStruct.fileExtension == "nil" {
                                                continue
                                            }
                                            self.driveFileArray.append(fileStruct)
                                        }
                                    }
                                    DbHelper().googleDriveToSqlite(getArray: self.driveFileArray)
                                    self.syncCloudEmailToServer(cloudId: self.googleEmail)
                                } else {
                                    print("error: \(json["errors"])")
                                }
                                
                            case .failure(let error):
                                NSLog(error.localizedDescription)
                            }
                            
        }
    }

    
    // List up to 10 files in Drive
    func listFiles() {
        let query = GTLRDriveQuery_FilesList.query()
//        query.pageSize = 10
//        query.q = "'root' in parents"
        print("user : \(GIDSignIn.sharedInstance().currentUser)")
        self.service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:))
        )
    }
    
    // Process the response and display output
    @objc func displayResultWithTicket(ticket: GTLRServiceTicket,
                                       finishedWithObject result : GTLRDrive_FileList,
                                       error : NSError?) {
        
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            print("error :\(error)" )
            return
        }
        
        var text = "";
        if let files = result.files, !files.isEmpty {
            text += "Files:\n"
            for file in files {
                text += "\(file.name!) (\(file.identifier!))\n"
            }
        } else {
            text += "No files found."
        }
        print("list : \(text)")
    }
    
    
    // Helper for showing an alert
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
    
    @objc func selectEmail(){
        checkButton.setOn(true, animated: true)
        checkButton2.setOn(false, animated: true)
        emailSelectState = .previous
        print("selectEmail clicked : \(emailSelectState)")
    }
    
    @objc func selectAdd(){
        checkButton.setOn(false, animated: true)
        checkButton2.setOn(true, animated: true)
        emailSelectState = .add
        print("selectAdd clicked : \(emailSelectState)")
    }
    
    
    func syncCloudEmailToServer(cloudId: String){
        
        let urlString = App.URL.hostIpServer+"registCloudId.do"
        let headers = [
            "Content-Type": "application/json",
            "X-Auth-Token": self.loginToken,
            "Cookie": self.loginCookie
        ]
        Alamofire.request(urlString,
                          method: .post,
                          parameters: ["userId":userId,"cloudKind":"D","cloudId":cloudId],
                          encoding : JSONEncoding.default,
                          headers: headers).responseJSON{ (response) in
                            switch response.result {
                            case .success(let value):
//                                let json = JSON(value)
//                                let responseData = value as! NSDictionary
//                                let message = responseData.object(forKey: "message")
//                                print("mesage : \(message)")
                                if(self.segueCheck == 1){
                                    
                                }
                                // 0eun - start
                                if (self.googleSignInSegueState == .loginForList){
                                    let cellStyle = ["cellStyle":3]
                                    NotificationCenter.default.post(name: Notification.Name("setGoogleDriveFileListView"), object: self, userInfo: cellStyle)
                                    // 0eun - end
                                } else {
                                    
                                }
                                Util().dismissFromLeft(vc:self)
                                break
                            case .failure(let error):
                                NSLog(error.localizedDescription)
                                break
                            }
        }
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
