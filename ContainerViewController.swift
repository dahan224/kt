//
//  HomeViewController.swift
//  KT
//
//  Created by 이다한 on 2018. 1. 22..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GoogleSignIn
import Alamofire
import SwiftyJSON
import BEMCheckBox

class ContainerViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, GIDSignInDelegate, GIDSignInUIDelegate {
    
    var homeViewController:HomeViewController?
    var latelyUpdatedFileViewController:LatelyUpdatedFileViewController?
    let g = DispatchGroup()
    let q1 = DispatchQueue(label: "queue1")
    let q2 = DispatchQueue(label: "queue2")
    
    
    private let scopes = [kGTLRAuthScopeDriveFile, kGTLRAuthScopeDrive, kGTLRAuthScopeDriveReadonly ]
    private let service = GTLRDriveService()
    let signInButton = GIDSignInButton()
    var googleEmailArray = [String]()
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
    var driveFileArray:[App.DriveFileStruct] = []
    
    
    var multiCheckedfolderArray:[App.FolderStruct] = []
    let halfBlackView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.alpha = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view;
    }()
    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var slideView: UIView!
    
    @IBOutlet weak var slideViewWithConstraint: NSLayoutConstraint!
    var sideMenuOpen = false
    var slideViewWith:CGFloat = 0.0
    let backgroundView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.alpha = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view;
    }()
    var tapGesture:UITapGestureRecognizer = UITapGestureRecognizer()
    
    var fileId = ""
    var foldrWholePathNm = ""
    var fileNm = ""
    var deviceName = ""
    var fromUserId = ""
    var fileSavedPath = ""
    var fromOsCd = ""
    var fromFoldrId = ""
    var fileExtension = ""
    var size = ""
    var createdTime = ""
    var modifiedTime = ""
    var mimeType = ""

    enum googleSignInSegueEnum: String {
        case loginForList = "loginForList"
        case loginForSend = "loginForSend"
        case loginForMultiSend = "loginForMultiSend"
    }
    var googleSignInSegueState = googleSignInSegueEnum.loginForList
    
    var oneViewSortState:DbHelper.sortByEnum = DbHelper.sortByEnum.none
    var DeviceArray:[App.DeviceStruct] = []
    
    var storageKind = NasSendFolderSelectVC.toStorageKind.nas
    var savedPath = ""
    var amdDate = ""
    
    var fromDevUuid = ""
    var fromFoldr = ""
    var getFileDict:[String:String] = [:]
    @IBOutlet weak var containerView: UIView!
    
    enum listViewStyleEnum {
        case grid
        case list
    }
    var listViewStyleState = listViewStyleEnum.list
    var emailCheckViews:[UIView] = [UIView]()
    
    @objc func toggleSideMenu(){
        print("sideMEnuOepn")
        if sideMenuOpen {
            
            sideMenuConstraint.constant = -slideViewWith
            sideMenuOpen = false
            backgroundView.removeGestureRecognizer(tapGesture)
            self.backgroundView.removeFromSuperview()
            
            
        }else{
            slideView.isHidden = false
            sideMenuConstraint.constant = 0
            sideMenuOpen = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                //                print("backgroundview add")
                self.view.addSubview(self.backgroundView)
                self.backgroundView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
                self.backgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
                self.backgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
                self.backgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
                self.view.bringSubview(toFront: self.slideView)
                
            })
            
            tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleSideMenu))
            tapGesture.cancelsTouchesInView = false
            backgroundView.addGestureRecognizer(tapGesture)
            
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(toggleSideMenu))
            swipeLeft.direction = UISwipeGestureRecognizerDirection.left
            backgroundView.addGestureRecognizer(swipeLeft)
            
        }
        UserDefaults.standard.set(sideMenuOpen, forKey: "sideMenuOpen")
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slideView.isHidden = true
        oneViewSortState = DbHelper.sortByEnum.none
        
        slideViewWith = UIScreen.main.bounds.width * 0.8
        slideViewWithConstraint.constant = slideViewWith
        print("slideViewWith: \(slideViewWith)")
       
        
        setupDeviceListView(container: containerView)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(openLicenseSegue),
                                               name: NSNotification.Name("openLicenseSegue"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(toggleSideMenu),
                                               name: NSNotification.Name("toggleSideMenu"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dismissContainerView),
                                               name: NSNotification.Name("dismissContainerView"),
                                               object: nil)
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showSettingSegue),
                                               name: NSNotification.Name("showSettingSegue"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(deviceManageSegue),
                                               name: NSNotification.Name("deviceManageSegue"),
                                               object: nil)
     
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(googleSignInSegue(segueInfo: )),
                                               name: NSNotification.Name("googleSignInSegue"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(googleSignInAlertShow),
                                               name: NSNotification.Name("googleSignInAlertShow"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(getFileIdFromBtnShow(fileInfo: )),
                                               name: NSNotification.Name("getFileIdFromBtnShow"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(nasFolderSelectSegue),
                                               name: NSNotification.Name("nasFolderSelectSegue"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(removeOneView),
                                               name: NSNotification.Name("removeOneView"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(removeLatelyView),
                                               name: NSNotification.Name("removeLatelyView"),
                                               object: nil)
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        
    }
    
    func setupDeviceListView(container: UIView){
      
        homeViewController = storyboard!.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        homeViewController?.containerViewController = self
        
        homeViewController?.willMove(toParentViewController: parent)
        self.addChildViewController(homeViewController!)
        container.addSubview(homeViewController!.view)
        homeViewController?.didMove(toParentViewController: parent)
        
        let w = container.frame.size.width;
        let h = container.frame.size.height;
        homeViewController?.view.frame = CGRect(x: 0, y: 0, width: w, height: h)
        
        print("containerA setting called")
        
        
    }
    
    @objc func removeOneView(){
        
        let previous = storyboard!.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            previous.willMove(toParentViewController: nil)
            previous.view.removeFromSuperview()
            previous.removeFromParentViewController()
        
        let child = storyboard!.instantiateViewController(withIdentifier: "LatelyUpdatedFileViewController") as! LatelyUpdatedFileViewController
        child.containerViewController = self
        child.listViewStyleState = listViewStyleState
        self.willMove(toParentViewController: nil)
        child.willMove(toParentViewController: parent)
        self.addChildViewController(child)
        
        let transition = CATransition()
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.speed = 1.8
        containerView.layer.add(transition, forKey: nil)
        containerView.addSubview(child.view)
        child.didMove(toParentViewController: parent)
        
        let w = containerView.frame.size.width;
        let h = containerView.frame.size.height;
        child.view.frame = CGRect(x: 0, y: 0, width: w, height: h)
        
        print("containerA setting called")
    }
    
    @objc func removeLatelyView(){
        let previous = storyboard!.instantiateViewController(withIdentifier: "LatelyUpdatedFileViewController") as! LatelyUpdatedFileViewController
        previous.willMove(toParentViewController: nil)
        previous.view.removeFromSuperview()
        previous.removeFromParentViewController()
        
        homeViewController = storyboard!.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        homeViewController?.containerViewController = self
        homeViewController?.listViewStyleState = listViewStyleState
        self.willMove(toParentViewController: nil)
        homeViewController?.willMove(toParentViewController: parent)
        self.addChildViewController(homeViewController!)
        
        let transition = CATransition()
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        transition.speed = 1.8
        containerView.layer.add(transition, forKey: nil)
        containerView.addSubview(homeViewController!.view)
        homeViewController?.didMove(toParentViewController: parent)
        
        let w = containerView.frame.size.width;
        let h = containerView.frame.size.height;
        homeViewController?.view.frame = CGRect(x: 0, y: 0, width: w, height: h)
        
        print("containerA setting called")
    
    }
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFileInfoSegue" {
            if let vc = segue.destination as? FileInfoViewController {
                vc.fileId = self.fileId
                vc.foldrWholePathNm = self.foldrWholePathNm
                vc.deviceName = self.deviceName
                vc.fileSavedPath = self.savedPath
                vc.fileExtension = self.fileExtension
                vc.size = self.size
                vc.createdTime = self.createdTime
                vc.modifiedTime = self.modifiedTime

            }
        } else if segue.identifier == "googleSignInSegue" {
            if let vc = segue.destination as? GoogleSignInViewController {
                vc.segueCheck = 1
                vc.googleSignInSegueState = googleSignInSegueState
            }
        } else if segue.identifier == "nasFolderSelectSegue" {
            if let vc = segue.destination as? NasSendFolderSelectVC{
                vc.oldFoldrWholePathNm = self.foldrWholePathNm
                vc.originalFileId = self.fileId
                vc.originalFileName = self.fileNm
                vc.storageState = storageKind
                vc.fromUserId = fromUserId
                vc.amdDate = amdDate
                vc.fromOsCd = fromOsCd
                vc.fromDevUuid = fromDevUuid
                vc.fromFoldr = fromFoldr
                vc.fromFoldrId = fromFoldrId
                vc.multiCheckedfolderArray = multiCheckedfolderArray
                vc.mimeType = mimeType
            }
            
        }
        
    }
    //파일 디테일 뷰 오픈 from 파일 리스트 속성보기 버튼
    
    @objc func getFileIdFromBtnShow(fileInfo: NSNotification) {
        print("sdfs")
        if let getFileId = fileInfo.userInfo?["fileId"] as? String, let getFoldrWholePathNm = fileInfo.userInfo?["foldrWholePathNm"] as? String, let getDeviceName = fileInfo.userInfo?["deviceName"] as? String {
            fileId = getFileId
            foldrWholePathNm = getFoldrWholePathNm
            deviceName = getDeviceName
            if let getSavedPath = fileInfo.userInfo?["savedPath"] as? String {
                savedPath = getSavedPath
            }
            /* 이부분 추가 start */
            fileExtension = fileInfo.userInfo?["fileExtension"] as? String ?? ""
            size = fileInfo.userInfo?["size"] as? String ?? ""
            createdTime = fileInfo.userInfo?["createdTime"] as? String ?? ""
            modifiedTime = fileInfo.userInfo?["modifiedTime"] as? String ?? ""
            /* 이부분 추가 end */
            
            print("getFileId: \(fileId), \(deviceName)")
            performSegue(withIdentifier: "showFileInfoSegue", sender: self)
        }
       
        
    }
    @objc func showSettingSegue(){
        performSegue(withIdentifier: "showSettingSegue", sender: self)
    }
    @objc func openLicenseSegue(){
        performSegue(withIdentifier: "openLicenseSegue", sender: self)
    }

    @objc func deviceManageSegue(){
        performSegue(withIdentifier: "deviceManageSegue", sender: self)
    }
    @objc func googleSignInSegue(segueInfo: NSNotification){
        if let getState = segueInfo.userInfo?["state"] as? String {
            self.googleSignInSegueState = googleSignInSegueEnum(rawValue: getState)!
            performSegue(withIdentifier: "googleSignInSegue", sender: self)
        }
        
    }

    @objc func googleSignInAlertShow(){
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
        Alamofire.request(App.URL.server+"selectCloudId.json"
            , method: .post
            , parameters:["userId":App.defaults.userId,"cloudKind":"D"]
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
                print("googleSignInSegueState : \(self.googleSignInSegueState)")
                self.loginWBySelectedEmail()
            }
            
        }
        let cancelAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel){ (action: UIAlertAction) in
            self.halfBlackView.removeFromSuperview()
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
            if key == "GID_AppHasRunBefore" || key == "token" || key == "cookie" || key == "userId" || key == "autoLoginCheck" || key == "userId" || key == "userPassword" || key == "googleDriveLoginState" {
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
    
    func loginWBySelectedEmail(){
        print("loginWBySelectedEmail called")
        let loginState = UserDefaults.standard.string(forKey: "googleDriveLoginState")
        print("loginState : \(loginState)")
        print("loginWBySelectedEmail sigin in purpose : \(self.googleSignInSegueState)")
        if(loginState != "login") {
            googleSignIn()
        }  else {
            GIDSignIn.sharedInstance().signInSilently()
        }
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
            
            
        } else {
            var accessToken:String = ""
            q1.async(group:g) {
                print("whatethe")
                
            }
            q2.async(group:g) {
                let today = Date()
                let stToday = Util.date(text: today)
                
                print("stToday : \(stToday)")
                let check = DbHelper().googleEmailExistenceCheck(email: user.profile.email)
                if(check){                    
                    accessToken = GIDSignIn.sharedInstance().currentUser.authentication.accessToken
                    DbHelper().googleAccessTokenUpdate(getEmail: user.profile.email, getAccessToken: accessToken, getTime:stToday)
                } else {
                    accessToken = GIDSignIn.sharedInstance().currentUser.authentication.accessToken
                    DbHelper().googleEmailToSqlite(getEmail: user.profile.email, getAccessToken : accessToken, getTime:stToday)
                    
                }
                print("logedIn")
            }
            g.notify(queue: DispatchQueue.main){
                print("final")
            
                self.signInButton.isHidden = true
                self.service.authorizer = user.authentication.fetcherAuthorizer()
                
                print("googleEmail : \(self.googleEmail)")
                print("sigin in purpose : \(self.googleSignInSegueState)")
                if(self.googleSignInSegueState == .loginForList) {
                    self.googleEmail = user.profile.email
                    self.googleDriveLoginState = .login
                    let defaults = UserDefaults.standard
                    defaults.set(self.googleEmail, forKey: "googleEmail")
                    defaults.set("login", forKey: "googleDriveLoginState")
                    defaults.synchronize()
                    self.getFiles(accessToken: accessToken, root: "root")
                } else {
                    if(self.googleDriveLoginState != .login){
                        self.googleEmail = user.profile.email
                        self.googleDriveLoginState = .login
                        let defaults = UserDefaults.standard
                        defaults.set(self.googleEmail, forKey: "googleEmail")
                        defaults.set("login", forKey: "googleDriveLoginState")
                        defaults.synchronize()
                        let alertController = UIAlertController(title: "로그인 되었습니다.",message: "", preferredStyle: UIAlertControllerStyle.alert)
                        
                        let okAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default){ (action: UIAlertAction) in
                            self.halfBlackView.removeFromSuperview()
                            if(self.homeViewController?.indicatorAnimating)!{
                                self.homeViewController?.homeViewToggleIndicator()
                            }
                            NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: self.getFileDict)
                        }
                        alertController.addAction(okAction)
                        self.present(alertController,animated: true,completion: nil)
                        return
                    } else {
                        if(self.homeViewController?.indicatorAnimating)!{
                            self.homeViewController?.homeViewToggleIndicator()
                        }
                        NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: self.getFileDict)
                    }
                   
                }
                
            }
            
            
            
            
            
        }
    }
    
    func getFiles(accessToken:String, root:String){
        homeViewController?.homeViewToggleIndicator()
        print("getFiles token : \(accessToken)")
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
//                                print("json : \(json)")
                                if(json["error"].exists()){
                                    print("error: \(json["error"])")
                                    self.googleSignIn()
                                    if(self.homeViewController?.indicatorAnimating)!{
                                        self.homeViewController?.homeViewToggleIndicator()
                                    }
                                    
                                } else {
                                    if let serverList:[AnyObject] = json["files"].arrayObject as! [AnyObject] {
                                        for file in serverList {
//                                            print("file : \(file)")
                                            if file["trashed"] as? Int == 0 && file["starred"] as? Int == 0 && file["shared"] as? Int == 0 {
                                                let fileStruct = App.DriveFileStruct(device: file, foldrWholePaths: ["Google"])
                                                self.driveFileArray.append(fileStruct)
                                            }
                                        }
                                        DbHelper().googleDriveToSqlite(getArray: self.driveFileArray)
                                        self.syncCloudEmailToServer(cloudId: self.googleEmail)
                                        if(self.homeViewController?.indicatorAnimating)!{
                                            self.homeViewController?.homeViewToggleIndicator()
                                        }
                                    } else {
                                        print("error: \(json["errors"])")
                                        self.googleSignIn()
                                        if(self.homeViewController?.indicatorAnimating)!{
                                            self.homeViewController?.homeViewToggleIndicator()
                                        }
                                    }
                                }
                                
                            case .failure(let error):
                                NSLog(error.localizedDescription)
                                self.homeViewController?.homeViewToggleIndicator()
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

    
    func syncCloudEmailToServer(cloudId: String){
        
        let urlString = App.URL.server+"registCloudId.do"
        let headers = [
            "Content-Type": "application/json",
            "X-Auth-Token": UserDefaults.standard.string(forKey: "token")!,
            "Cookie": UserDefaults.standard.string(forKey: "cookie")!
        ]
        Alamofire.request(urlString,
                          method: .post,
                          parameters: ["userId":App.defaults.userId,"cloudKind":"D","cloudId":cloudId],
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
                                // 0eun - start'
                                print("googleSignInSegueState : \(self.googleSignInSegueState)")
                                if (self.googleSignInSegueState == .loginForList){
                                    if(self.homeViewController?.indicatorAnimating)!{
                                        self.homeViewController?.homeViewToggleIndicator()
                                    }
                                    let cellStyle = ["cellStyle":3]
                                    NotificationCenter.default.post(name: Notification.Name("setGoogleDriveFileListView"), object: self, userInfo: cellStyle)
//                                     0eun - end
                                } else {
                                    if(self.homeViewController?.indicatorAnimating)!{
                                        self.homeViewController?.homeViewToggleIndicator()
                                    }
                                    NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: self.getFileDict)
                                }
//                                Util().dismissFromLeft(vc:self)
                                break
                            case .failure(let error):
                                NSLog(error.localizedDescription)
                                break
                            }
        }
    }
    
    
    func googleSignInCheck(name:String, path:String, fileDict:[String:String]){
        if let googleEmail = UserDefaults.standard.string(forKey: "googleEmail"){
            GIDSignIn.sharedInstance().delegate = self
            GIDSignIn.sharedInstance().uiDelegate = self
            GIDSignIn.sharedInstance().scopes = scopes
            homeViewController?.homeViewToggleIndicator()
            var accessToken = DbHelper().getAccessToken(email: googleEmail)
            let getTokenTime = DbHelper().getTokenTime(email: googleEmail)
            print("accessToken : \(accessToken), getTokenTime : \(getTokenTime)")
            let now = Date()
            let dateGetTokenTime = Util.stringToDate(text: getTokenTime)
            var userCalendar = Calendar.current
            userCalendar.timeZone = TimeZone.current
            let requestedComponent: Set<Calendar.Component> = [.hour,.minute,.second]
            //        let requestedComponent: Set<Calendar.Component> = [.hour]
            let timeDifference = userCalendar.dateComponents(requestedComponent, from: dateGetTokenTime, to: now)
            //                        print(timeDifference.hour)
            let hour = timeDifference.hour
            if(hour! < 1){
                //                            if(GIDSignIn.sharedInstance().hasAuthInKeychain()){
                let loginState = UserDefaults.standard.string(forKey: "googleDriveLoginState")
                if(loginState == "login" && GIDSignIn.sharedInstance().hasAuthInKeychain()){
                    print("get file")
                    getFileDict = fileDict
                    googleSignInSegueState = .loginForSend
                    GIDSignIn.sharedInstance().signInSilently()
                    
                    
                } else {
                    
                    print("login called")
                    googleSignInSegueState = .loginForSend
                    googleSignInAlertShow()
                }
                
            } else {
                print("token time expired")
                googleSignInSegueState = .loginForSend
                googleSignInAlertShow()
            }
        } else {
            print("google email")
            googleSignInSegueState = .loginForSend
            googleSignInAlertShow()
        }
   
    }
    
    @objc func nasFolderSelectSegue(fileDict:NSNotification){
        if let getFileId = fileDict.userInfo?["fileId"] as? String, let getFromDevUuid = fileDict.userInfo?["fromDevUuid"] as? String, let getUserId = fileDict.userInfo?["fromUserId"] as? String, let getOsCd = fileDict.userInfo?["fromOsCd"] as? String, let getToState = fileDict.userInfo?["toStorage"] as? String {
            fileId = getFileId
            print("getFileId : \(fileId)")
            
            foldrWholePathNm = fileDict.userInfo?["oldFoldrWholePathNm"] as? String ?? "nil"
            fileNm = fileDict.userInfo?["fileNm"] as? String ?? "nil"
            fromOsCd = getOsCd
            fromDevUuid = getFromDevUuid
            fromFoldr = fileDict.userInfo?["fromFoldr"] as? String ?? "nil"
            if let getDate =  fileDict.userInfo?["amdDate"] as? String {
                amdDate = getDate
            }
            
            if let getFromFoldrId = fileDict.userInfo?["fromFoldrId"] as? String {
                fromFoldrId = getFromFoldrId
            }
            
            if let getMimeType = fileDict.userInfo?["mimeType"] as? String {
                mimeType = getMimeType
            }
            
            switch getToState {
                case "nas":
                    storageKind = .nas
                break
                case "googleDrive":
                    storageKind = .googleDrive
                break

                default:
                break
            }
            
            fromUserId = getUserId
            print("nasFolderSelectSegue called fromUserId : \(fromUserId)")
            performSegue(withIdentifier: "nasFolderSelectSegue", sender: self)
        }
        
    }
    
    @objc func dismissContainerView(){
      
        dismiss(animated: false, completion: nil)
        
    }
    
    func getMultiFolderArray(getArray:[App.FolderStruct], toStorage:String, fromUserId:String, fromOsCd:String,fromDevUuid:String){
        print("getArray : \(getArray)")
        multiCheckedfolderArray = getArray
        if toStorage == "nas_multi" {
            storageKind = .nas_multi
        } else if toStorage == "remote_nas_multi" {
            storageKind = .remote_nas_multi
        } else if toStorage == "local_nas_multi" {
            storageKind = .local_nas_multi
        } else if toStorage == "local_gdrive_multi" {
            storageKind = .local_gdrive_multi
        } else {
            storageKind = .multi_nas_multi
        }
        
        self.fromOsCd = fromOsCd
        self.fromUserId = fromUserId
        self.fromDevUuid = fromDevUuid
        
        performSegue(withIdentifier: "nasFolderSelectSegue", sender: self)
        //파일
      
//        let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"toStorage":"nas","fromUserId":userId, "fromOsCd":fromOsCd,"fromDevUuid":currentDevUuid]
//
//        NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
//        //폴더
//        let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"toStorage":"nas","fromUserId":userId, "fromOsCd":fromOsCd,"fromDevUuid":currentDevUuid,"fromFoldrId":String(foldrId)]
//
        
    }
    
        
}
