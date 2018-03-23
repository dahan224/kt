//
//  HomeViewController.swift
//  KT
//
//  Created by 이다한 on 2018. 1. 22..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ContainerViewController: UIViewController {
    
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
    
    enum googleSignInSegueEnum: String {
        case loginForList = "loginForList"
        case loginForSend = "loginForSend"
    }
    var googleSignInSegueState = googleSignInSegueEnum.loginForList
    
    var oneViewSortState:DbHelper.sortByEnum = DbHelper.sortByEnum.none
    var DeviceArray:[App.DeviceStruct] = []
    
    var storageKind = NasSendFolderSelectVC.toStorageKind.nas
    var savedPath = ""
    var amdDate = ""
    
    var fromDevUuid = ""
    var fromFoldr = ""
    
    @IBOutlet weak var containerView: UIView!
    
    
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
    }
    
    func setupDeviceListView(container: UIView){
      
        let child = storyboard!.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        child.containerViewController = self
        
        child.willMove(toParentViewController: parent)
        self.addChildViewController(child)
        container.addSubview(child.view)
        child.didMove(toParentViewController: parent)
        
        let w = container.frame.size.width;
        let h = container.frame.size.height;
        child.view.frame = CGRect(x: 0, y: 0, width: w, height: h)
        
        print("containerA setting called")
        
        
    }
    
    @objc func removeOneView(){
        
        let previous = storyboard!.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            previous.willMove(toParentViewController: nil)
            previous.view.removeFromSuperview()
            previous.removeFromParentViewController()
        
        let child = storyboard!.instantiateViewController(withIdentifier: "LatelyUpdatedFileViewController") as! LatelyUpdatedFileViewController
        
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
        
        let child = storyboard!.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        
        self.willMove(toParentViewController: nil)
        child.willMove(toParentViewController: parent)
        self.addChildViewController(child)
        
        let transition = CATransition()
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        transition.speed = 1.8
        containerView.layer.add(transition, forKey: nil)
        containerView.addSubview(child.view)
        child.didMove(toParentViewController: parent)
        
        let w = containerView.frame.size.width;
        let h = containerView.frame.size.height;
        child.view.frame = CGRect(x: 0, y: 0, width: w, height: h)
        
        print("containerA setting called")
    
    }
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFileInfoSegue" {
            if let vc = segue.destination as? FileInfoViewController {
                vc.fileId = self.fileId
                vc.foldrWholePathNm = self.foldrWholePathNm
                vc.deviceName = self.deviceName
                vc.fileSavedPath = self.savedPath
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
            print("getFileId: \(fileId), \(deviceName)")
            performSegue(withIdentifier: "showFileInfoSegue", sender: self)
        }
       
        
    }
    @objc func showSettingSegue(){
        performSegue(withIdentifier: "showSettingSegue", sender: self)
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
            self.googleSignInSegueState = .loginForSend
            self.performSegue(withIdentifier: "googleSignInSegue", sender: self)
            self.halfBlackView.removeFromSuperview()
        }
        let cancelButton = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel){ (action: UIAlertAction) in
            self.halfBlackView.removeFromSuperview()
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelButton)
        self.present(alertController,animated: true,completion: nil)
    }
    
    @objc func nasFolderSelectSegue(fileDict:NSNotification){
        if let getFileId = fileDict.userInfo?["fileId"] as? String, let getFromDevUuid = fileDict.userInfo?["fromDevUuid"] as? String, let getUserId = fileDict.userInfo?["fromUserId"] as? String, let getOsCd = fileDict.userInfo?["fromOsCd"] as? String, let getToState = fileDict.userInfo?["toStorage"] as? String {
            fileId = getFileId
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
            print("fromUserId : \(fromUserId)")
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
        } else {
            storageKind = .remote_nas_multi
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
