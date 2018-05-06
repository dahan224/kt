//
//  LatelyUpdatedFileViewController.swift
//  KT
//
//  Created by 이다한 on 2018. 3. 9..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class LatelyUpdatedFileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var containerViewController:ContainerViewController?
    var child : HomeDeviceCollectionVC?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var customNavBar: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var btnHamburger: UIButton!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    
    @IBOutlet weak var btnCategory1: UIButton!
    
    
    @IBOutlet weak var btnCategory2: UIButton!
    @IBOutlet weak var btnCategory3: UIButton!
    @IBOutlet weak var btnCategory4: UIButton!
    var btnCategories:[UIButton] = [UIButton]()
    
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var searchCategoryHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchCategoryView: UIStackView!{
        didSet{
            searchCategoryView.isHidden = true
            searchCategoryHeightConstraint.constant = 0
        }
    }
    
    var jsonHeader:[String:String] = [
        "Content-Type": "application/json",
        "X-Auth-Token": UserDefaults.standard.string(forKey: "token")!,
        "Cookie": UserDefaults.standard.string(forKey: "cookie")!
    ]
    @IBOutlet weak var btnLIst: UIButton!
    @IBOutlet weak var btnSel: UIButton!
    var hexStringToUIColor:HexStringToUIColor = HexStringToUIColor()
    
    @IBOutlet weak var tableBottomConstant: NSLayoutConstraint!
    var bottomMenuOpen = false
    var sideMenuOpen = false
    var tapGesture:UITapGestureRecognizer = UITapGestureRecognizer()
    var multiCheckTapGesture:UITapGestureRecognizer = UITapGestureRecognizer()
    
    
    enum viewStateEnum{
        case home
        case search
    }
    var viewState = viewStateEnum.home
    
    enum searchCategoryEnum {
        case start
        case show
        case hide
        case end
    }
    var btnArrState:searchCategoryEnum = searchCategoryEnum.start
    
    
    enum bottomListEnum: String {
        case sort = "sort"
        case nasFileInfo = "nasFileInfo"
        case localFileInfo = "localFileInfo"
        case remoteFileInfo = "remoteFileInfo"
        case bottomMultiListNas = "bottomMultiListNas"
        case bottomMultiListRemote = "bottomMultiListRemote"
        case bottomMultiListLocal = "bottomMultiListLocal"
        case bottomMultiListGDrive = "bottomMultiListGDrive"
        case oneView = "oneView"
        case googleDrive = "googleDrive"
    }
    
    var ifNavBarClicked = false
    
    var bottomListState:bottomListEnum = bottomListEnum.oneView
    var bottomListSort = ["날짜순-최신 항목 우선", "날짜순-오래된 항목 우선","이름순-ㄱ우선","이름순-ㅎ우선","종류순"]
    var bottomListSortKey = ["new", "old","asc","desc","kind"]
    
    
    var bottomListLocalFileInfo = ["속성보기", "앱 실행", "GiGA NAS로 보내기", "Google Drive로 보내기", "삭제"]
    var bottomListFileInfo = ["속성보기", "다운로드", "GiGA NAS로 보내기", "Google Drive로 보내기", "삭제"]
    var bottomListRemoteFileInfo = ["속성보기", "다운로드", "GiGA NAS로 보내기"]
    var bottomMultiListNas = ["다운로드", "GiGA NAS로 보내기", "Google Drive로 보내기", "삭제"]
    var bottomMultiListRemote = ["다운로드", "GiGA NAS로 보내기"]
    var bottomMultiListLocal = ["GiGA NAS로 보내기", "Google Drive로 보내기", "삭제"]
    var bottomMultiListGDrive = ["다운로드", "GiGA NAS로 보내기", "삭제"]
    var bottomGoogleDrive = ["속성보기", "다운로드", "GiGA NAS로 보내기", "Google Drive로 보내기", "삭제"]
    
    var bottomListOneViewSort = ["기준정렬","이름순-ㄱ우선","이름순-ㅎ우선"]
    var bottomListOneViewSortKey = [DbHelper.sortByEnum.none, DbHelper.sortByEnum.asc, DbHelper.sortByEnum.desc]
    
    var bottomListDevice = ["홈으로"]
    
    enum searchStepEnum {
        case all
        case device
        case folder
    }
    var searchStepState = searchStepEnum.all
    var searchId:String = ""
    var foldrWholePathNm = ""
    
    enum searchGubunEnum {
        case meta
        case amdDate
        case emailSbjt
    }
    
    enum searchSortEnum {
        case new
        case old
        case asc
    }
    
    var sortBy = ""
    
  
    var listViewStyleState = ContainerViewController.listViewStyleEnum.list
    var mainContentState = HomeViewController.mainContentsStyleEnum.oneViewList
    
    var maintainFolder = false
    
    enum flickEnum {
        case main
        case lately
    }
    var flickState = HomeViewController.flickEnum.lately
    
    @IBOutlet weak var btnFlick1: UIButton!
    @IBOutlet weak var btnFlick2: UIButton!
    var flickCheck = 1;
    var listStyleCheck = 1;
    
    var multiCheckBottomView:UIView = {
        let view = UIView()
        view.backgroundColor = HexStringToUIColor().getUIColor(hex: "F5F5F5")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    let navBarTitle:UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(HexStringToUIColor().getUIColor(hex: "4f4f4f"), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.translatesAutoresizingMaskIntoConstraints = false
//        button.addTarget(self, action: #selector(navBarTitleClicked), for: .touchUpInside)
        return button
    }()

    let backButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "page_back").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
//        button.addTarget(self, action: #selector(backToHome), for: .touchUpInside)
        return button
    }()

    let hamburgerButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ico_24dp_nav").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(MenuButtonTabbed), for: .touchUpInside)
        return button
    }()
//
    let downArrowButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ico_24dp_email_open").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
//        button.addTarget(self, action: #selector(navBarTitleClicked), for: .touchUpInside)
        return button
    }()

    let listButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "list_view").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(listStyleChange), for: .touchUpInside)
        return button
    }()

    let multiButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "multi_off-1").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(btnMulticlicked), for: .touchUpInside)
        return button
    }()


    var multiButtonChecked = false

    let sortButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "sort").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
//        button.addTarget(self, action: #selector(btnSortClicked), for: .touchUpInside)
        button.isUserInteractionEnabled = false
        return button
    }()

    let searchButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "search_input").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
//        button.addTarget(self, action: #selector(searchButtonInFileViewClicked), for: .touchUpInside)

        return button
    }()

    let sBar:UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Search in all Storage"
        bar.backgroundImage = UIImage()
        bar.setImage(UIImage(), for: .clear, state: .normal)
        for s in bar.subviews[0].subviews {
            if s is UITextField {
                s.layer.borderWidth = 1.0
                //s.layer.borderColor = UIColor.gray.cgColor
                var borderColor = HexStringToUIColor().getUIColor(hex: "d1d2d4")
                s.layer.borderColor =  borderColor.cgColor
                s.layer.cornerRadius = 5
            }
        }
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.isUserInteractionEnabled = false

        return bar
    }()

    let searchDownArrowButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ico_arr_down").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
//        button.addTarget(self, action: #selector(btnArrDownClicked), for: .touchUpInside)
        return button
    }()
    
    
    let searchCountLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let backgroundView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray
        view.alpha = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view;
    }()
    
    
    var listContainerView:UIView = {
        let view = UIView()
        view.backgroundColor = HexStringToUIColor().getUIColor(hex: "F5F5F5")
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    
    var loginCookie = ""
    var loginToken = ""
    var userId = ""
    var uuid = ""
    var fileId = ""
    var searchedText = ""
    var deviceName = ""
    var folderName = ""
    var searchbarTextStarted = false
    var DeviceArray:[App.DeviceStruct] = []
    var SearchedFileArray:[App.SearchedFileStruct] = []
    var LatelyUpdatedFileArray:[App.FolderStruct] = []
    var driveFileArray:[App.DriveFileStruct] = []
    var collectionView: UICollectionView!
    
    var searchGubun = ""
    var oneViewSortState:DbHelper.sortByEnum = DbHelper.sortByEnum.none
    var containerViewTopAnchor:NSLayoutConstraint?
    var containerViewBottomAnchor:NSLayoutConstraint?
    
    var selectedDevUuid = ""
    var currentDevUuid = ""
    var selectedDevUserId = ""
    var fileNm = ""
    var foldrId = ""
    var fromOsCd = ""
    var currentFolderId = ""
    
    @IBOutlet weak var flickView: UIStackView!
    var bottomMultiList = ["GiGA NAS로 보내기"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

          // Do any additional setup after loading the view.
        var listStyle = UserDefaults.standard.string(forKey: "listViewStyleState") ?? "nil"
        if listStyle == "nil" {
            listViewStyleState = .grid
        } else if listStyle == "list" {
            listViewStyleState = .list
        } else {
            listViewStyleState = .grid
            
        }
        getLatelyUpdateFileList()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        self.tableView.isHidden = true
        
    }
    
    override func viewDidLayoutSubviews() {
        customNavBar.layer.shadowColor = UIColor.lightGray.cgColor
        customNavBar.layer.shadowOffset = CGSize(width:0,height: 2.0)
        customNavBar.layer.shadowRadius = 1.0
        customNavBar.layer.shadowOpacity = 1.0
        customNavBar.layer.masksToBounds = false;
        customNavBar.layer.shadowPath = UIBezierPath(roundedRect:customNavBar.bounds, cornerRadius:customNavBar.layer.cornerRadius).cgPath
        
        setLatelyView()
        
    }
    
    func setLatelyView(){
        searchStepState = .all
        mainContentState = .oneViewList
        for view in self.customNavBar.subviews {
            view.removeFromSuperview()
        }
        SetupHomeView.setuplatelyNavbar(View: customNavBar, navBarTitle: navBarTitle, hamburgerButton: hamburgerButton, listButton: listButton, downArrowButton: downArrowButton)
        
        
        
        for view in self.searchView.subviews {
            view.removeFromSuperview()
        }
        SetupHomeView.setupLatelySearchView(searchView:searchView, multiButton: multiButton)
        
        oneViewSortState = DbHelper.sortByEnum.none
        
//        self.setupDeviceListView(container: self.containerViewA, sortBy: oneViewSortState,multiCheckd: multiButtonChecked)
    }
    
    func getLatelyUpdateFileList(){
        LatelyUpdatedFileArray.removeAll()
        Alamofire.request(App.URL.server+"listLatelyUpdateFile.json"
            , method: .post
            , parameters:["userId":App.defaults.userId]
            , encoding : JSONEncoding.default
            , headers: jsonHeader
            ).responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if let statusCode = json["statusCode"].int, statusCode == 100 {
                        let serverList:[AnyObject] = json["listData"].arrayObject! as [AnyObject]
                        for file in serverList {
                            let fileStruct = App.FolderStruct(data: file)
                            print("file : \(file)")
                            self.LatelyUpdatedFileArray.append(fileStruct)
                        }
                    }
                    
                    self.setupDeviceListView(sortBy: self.oneViewSortState, multiCheckd: self.multiButtonChecked)
                    break
                case .failure(let error):
                    NSLog(error.localizedDescription)
                    
                    break
                }
        }
        
    }
    
    func setupDeviceListView(sortBy: DbHelper.sortByEnum, multiCheckd:Bool){
        let previous = self.childViewControllers.first
        if let previous = previous {
            previous.willMove(toParentViewController: nil)
            previous.view.removeFromSuperview()
            previous.removeFromParentViewController()
        }
        child = storyboard!.instantiateViewController(withIdentifier: "HomeDeviceCollectionVC") as? HomeDeviceCollectionVC
        self.DeviceArray = DbHelper().listSqlite(sortBy: sortBy)
        self.driveFileArray = DbHelper().googleDrivelistSqlite(sortBy: sortBy)
        //        print("table deviceList: \(DeviceArray)")
        
        
        child?.DeviceArray = self.DeviceArray
        child?.listViewStyleState = self.listViewStyleState
        child?.mainContentState = self.mainContentState
        child?.flickState = self.flickState
        child?.cellStyle = 2
        child?.folderArray = self.LatelyUpdatedFileArray
        child?.driveFileArray = self.driveFileArray
        child?.containerViewController = containerViewController
        child?.latelyUpdatedFileViewController = self
         
        
        print("called")
        self.view.addSubview(listContainerView)
        for containerSubview in listContainerView.subviews {
            containerSubview.removeFromSuperview()
        }
        containerViewTopAnchor?.isActive = false
        containerViewBottomAnchor?.isActive = false
        listContainerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        listContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true      
        containerViewTopAnchor =  listContainerView.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: 0)
        containerViewTopAnchor?.isActive = true
        containerViewBottomAnchor = listContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60)
        containerViewBottomAnchor?.isActive = true
        
        self.addChildViewController(child!)
        listContainerView.addSubview((child?.view)!)
        
        child?.didMove(toParentViewController: parent)
        
        let w = listContainerView.frame.size.width;
        let h = listContainerView.frame.size.height;
        child?.view.frame = CGRect(x: 0, y: 0, width: w, height: h)
        
        print("containerA setting called")
        
    }
    
    @objc func btnMulticlicked(){
        ifNavBarClicked = false
        print("lately btnMulticlicked called, multiButtonChecked : \(multiButtonChecked)")
        var stringBool = "false"
        if(multiButtonChecked){
            flickView.isHidden = false
            multiButtonChecked = false
            multiButton.setImage(#imageLiteral(resourceName: "multi_off-1").withRenderingMode(.alwaysOriginal), for: .normal)
            containerViewBottomAnchor?.isActive = false
            containerViewBottomAnchor = listContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60)
            containerViewBottomAnchor?.isActive = true
        } else {
            multiButtonChecked = true
            flickView.isHidden = true
            multiButton.setImage(#imageLiteral(resourceName: "multi_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            containerViewBottomAnchor?.isActive = false
            containerViewBottomAnchor = listContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60)
            containerViewBottomAnchor?.isActive = true
        }
        setMultiCountLabel(multiButtonChecked:multiButtonChecked, count:0)
        stringBool = String(multiButtonChecked)
        print("stringBool :\(stringBool)")
//        let fileIdDict = ["multiChecked":stringBool]
//        NotificationCenter.default.post(name: Notification.Name("multiSelectActive"), object: self, userInfo: fileIdDict)
        print("lately btnMulticlicked called, multiButtonChecked : \(multiButtonChecked)")
        child?.multiSelectActive(multiButtonActive: multiButtonChecked)
    }
   
    func setMultiCountLabel(multiButtonChecked:Bool, count:Int){
        if self.view.contains(multiCheckBottomView){
            for view in multiCheckBottomView.subviews {
                view.removeFromSuperview()
            }
            multiCheckBottomView.removeFromSuperview()
        }
        
        if(multiButtonChecked){
            
            self.view.addSubview(multiCheckBottomView)
            multiCheckBottomView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            multiCheckBottomView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            multiCheckBottomView.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
            multiCheckBottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            let label = UILabel()
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 18)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "\(count)개 파일 선택 완료"
            label.textColor = UIColor.gray
            multiCheckBottomView.addSubview(label)
            
            label.widthAnchor.constraint(equalToConstant: 150).isActive = true
            label.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
            label.centerXAnchor.constraint(equalTo: multiCheckBottomView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: multiCheckBottomView.centerYAnchor).isActive = true
            multiCheckBottomView.backgroundColor = UIColor.clear
            multiCheckBottomView.removeGestureRecognizer(multiCheckTapGesture)
            if(count > 0) {
                print("called")
                label.textColor = UIColor.white
                multiCheckBottomView.backgroundColor = hexStringToUIColor.getUIColor(hex: "4F4F4F")
                let button = UIButton(type: .system)
                button.setImage(#imageLiteral(resourceName: "multi_confirm").withRenderingMode(.alwaysOriginal), for: .normal)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.isUserInteractionEnabled = false
                multiCheckBottomView.addSubview(button)
                
                button.widthAnchor.constraint(equalToConstant: 36).isActive = true
                button.heightAnchor.constraint(equalToConstant: 36).isActive = true
                button.centerYAnchor.constraint(equalTo: multiCheckBottomView.centerYAnchor).isActive = true
                button.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 0).isActive = true
                multiCheckTapGesture = UITapGestureRecognizer(target: self, action: #selector(latelyViewmultiCheckBottomViewTapped))
                multiCheckBottomView.addGestureRecognizer(multiCheckTapGesture)
                
            }
        }
    }
    
    
    func inActiveMultiCheck(){
        multiButtonChecked = false
        flickView.isHidden = false
        multiButton.setImage(#imageLiteral(resourceName: "multi_off-1").withRenderingMode(.alwaysOriginal), for: .normal)
        
//        containerViewBottomAnchor?.isActive = false
//        containerViewBottomAnchor = listContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60)
//        containerViewBottomAnchor?.isActive = true
        if self.view.contains(multiCheckBottomView){
            for view in multiCheckBottomView.subviews {
                view.removeFromSuperview()
            }
            multiCheckBottomView.removeFromSuperview()
        }
        child?.multiSelectActive(multiButtonActive: multiButtonChecked)
    }
    
    @objc func latelyViewmultiCheckBottomViewTapped(){
        let fileIdDict = ["fileId":"0"]
        tableView.reloadData()
        latelyCloseBottomMenu()
    }

    
    
    func latelyViewToggleBottomMenu() {
      
        if bottomMenuOpen {
            UIView.animate(withDuration: 0.2, animations: {
                self.tableBottomConstant.constant = 260
                self.bottomMenuOpen = false
                self.view.layoutIfNeeded()
                print("animation duration")
            }, completion:{
                (finished: Bool) in
                print("animation finished")
                self.backgroundView.removeGestureRecognizer(self.tapGesture)
                self.backgroundView.removeFromSuperview()
                self.tableView.isHidden = true
            })
            
        }else{
            self.tableView.isHidden = false
            UIView.animate(withDuration: 0.2, animations: {
                self.tableBottomConstant.constant = 0
                self.bottomMenuOpen = true
                self.view.layoutIfNeeded()
                print("animation duration")
            }, completion:{
                (finished: Bool) in
                print("animation finished")
                
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                //                print("backgroundview add")
                self.view.addSubview(self.backgroundView)
                self.backgroundView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
                self.backgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
                self.backgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
                self.backgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
                self.view.bringSubview(toFront: self.tableView)
                
            })
            print("bottom state : \(bottomListState)")
            tapGesture = UITapGestureRecognizer(target: self, action: #selector(latelyCloseBottomMenu))
            tapGesture.cancelsTouchesInView = false
            backgroundView.addGestureRecognizer(tapGesture)
            
        }
        
    }
    
    @objc func latelyCloseBottomMenu() {
        print("latelyCloseBottomMenu called")
        latelyViewToggleBottomMenu()
//        backgroundView.removeGestureRecognizer(tapGesture)
    }
    
    func bottomStateFromContainer(fileDict:[String:Any]){
        
        if let bottomState = fileDict["bottomState"] as? String, let getFileId = fileDict["fileId"] as? String, let getFoldrWholePathNm = fileDict["foldrWholePathNm"] as? String, let getDeviceName = fileDict["deviceName"] as? String, let getDevUuid = fileDict["selectedDevUuid"] as? String, let getFileNm = fileDict["fileNm"] as? String, let getUserId = fileDict["userId"] as? String, let getFoldrId = fileDict["foldrId"] as? String, let getFomOsCd = fileDict["fromOsCd"] as? String, let getCurrentFolderId = fileDict["currentFolderId"] as? String{
            
            flickView.isHidden = true
            bottomListState = bottomListEnum(rawValue: bottomState)!
            
            
            fileId = getFileId
            foldrWholePathNm = getFoldrWholePathNm
            deviceName = getDeviceName
            selectedDevUuid = getDevUuid
            currentDevUuid = getDevUuid
            selectedDevUserId = getUserId
            fileNm = getFileNm
            foldrId = getFoldrId
            fromOsCd = getFomOsCd
            currentFolderId = getCurrentFolderId
            
            
            print("bottomListState: \(bottomListState), foldrWholePathNm : \(foldrWholePathNm)")
            if(selectedDevUuid == Util.getUuid()){
                //로컬 파일
                bottomListState = .localFileInfo
            }
            ifNavBarClicked = false
            containerViewBottomAnchor?.isActive = false
            containerViewBottomAnchor = listContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
            containerViewBottomAnchor?.isActive = true
            
        } else {
            print("not called")
        }
        
        if(listViewStyleState == .grid){
       
            if  let getIndexPath = fileDict["selectedIndex"] as? IndexPath {
            
                tableView.reloadData()
                let fileIdDict = ["fileId":"\(fileId)"]
                latelyViewToggleBottomMenu()
//                NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self, userInfo: fileIdDict)
       
            }
        }
    }
    
    
    @objc func listStyleChange() {
        switch (listViewStyleState) {
        case .grid:
            listViewStyleState = .list
            containerViewController?.listViewStyleState = .list
            listButton.setImage(#imageLiteral(resourceName: "card_view").withRenderingMode(.alwaysOriginal), for: .normal)
            let defaults = UserDefaults.standard
            defaults.set("list", forKey: "listViewStyleState")
            
            if(mainContentState == .oneViewList){
                let fileDict = ["style":"list"]
                NotificationCenter.default.post(name: Notification.Name("changeListStyle"), object: self, userInfo: fileDict)
            }
            break
        case (.list):
            listViewStyleState = .grid
            containerViewController?.listViewStyleState = .grid
            listButton.setImage(#imageLiteral(resourceName: "list_view").withRenderingMode(.alwaysOriginal), for: .normal)
            let defaults = UserDefaults.standard
            defaults.set("grid", forKey: "listViewStyleState")
            
            if(mainContentState == .oneViewList){
                let fileDict = ["style":"grid"]
                NotificationCenter.default.post(name: Notification.Name("changeListStyle"), object: self, userInfo: fileDict)
                
            }
            
            break
            
        }
        
    }
    
    @IBAction func btnFlick1Clicked(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("removeLatelyView"), object: self)
    }
    
    @IBAction func btnFlick2Clicked(_ sender: UIButton) {
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return bottomMultiList.count
        
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeBottomCell") as! HomeBottomListCell
        let clearView = UIView()
        clearView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = clearView
        cell.ivIcon.isHidden = false
        let imageString = Util.getContextImageString(context: bottomMultiList[indexPath.row])
        cell.ivIcon.image = UIImage(named: imageString)
        cell.lblTitle.text = bottomMultiList[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height:CGFloat = 80.0
        
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print(indexPath.section)
        print(indexPath.row)
        inActiveMultiCheck()
        let fileDict = ["action":"nas","fromOsCd":"multi"]
        latelyViewToggleBottomMenu()
//        NotificationCenter.default.post(name: Notification.Name("handleMultiCheckFolderArray"), object: self, userInfo:fileDict)
        child?.handleMultiCheckFromLatelyView()
        
        
        
    }
    
    
    @objc func MenuButtonTabbed() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeMenu))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        NotificationCenter.default.post(name: Notification.Name("toggleSideMenu"), object: nil)
        inActiveMultiCheck()
    }
    @objc func closeMenu() {
        sideMenuOpen = UserDefaults.standard.bool(forKey: "sideMenuOpen")
        if(sideMenuOpen){
            NotificationCenter.default.post(name: Notification.Name("toggleSideMenu"), object: nil)
        }
        view.removeGestureRecognizer(tapGesture)
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
