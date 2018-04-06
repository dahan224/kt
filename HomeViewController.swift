//
//  HomeViewController.swift
//  KT
//
//  Created by 이다한 on 2018. 1. 22..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import GoogleAPIClientForREST
import GoogleSignIn
import SQLite

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIDocumentInteractionControllerDelegate, GIDSignInDelegate, GIDSignInUIDelegate {
    private let scopes = [kGTLRAuthScopeDriveFile, kGTLRAuthScopeDrive, kGTLRAuthScopeDriveReadonly]
    private let service = GTLRDriveService()
    
    var documentController:UIDocumentInteractionController = UIDocumentInteractionController()
    var containerViewController:ContainerViewController?
    var child : HomeDeviceCollectionVC?
    var child2 : HomeDeviceCollectionVC?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var indicatorAnimating = false
    
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
    
    
    @IBOutlet weak var btnLIst: UIButton!
    @IBOutlet weak var btnSel: UIButton!
    var hexStringToUIColor:HexStringToUIColor = HexStringToUIColor()
    
    @IBOutlet weak var tableBottomConstant: NSLayoutConstraint!
    var bottomMenuOpen = false
    var sideMenuOpen = false
    var tapGesture:UITapGestureRecognizer = UITapGestureRecognizer()
    var multiCheckTapGesture:UITapGestureRecognizer = UITapGestureRecognizer()
    var cellStyle = 1
    
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
    var selectedDevUuid = ""
    var selectedDevUserId = ""
    
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
    
    enum mainContentsStyleEnum {
        case oneViewList
        case googleDriveList
        
    }
    var mainContentState = mainContentsStyleEnum.oneViewList
    var maintainFolder = false
    
    enum flickEnum {
        case main
        case lately
    }
    var flickState = flickEnum.main
    
    @IBOutlet weak var btnFlick1: UIButton!
    @IBOutlet weak var btnFlick2: UIButton!
    var flickCheck = 1;
    var listStyleCheck = 1;
    
    @IBOutlet weak var flickView: UIStackView!
    
    
    let navBarTitle:UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(HexStringToUIColor().getUIColor(hex: "4f4f4f"), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(navBarTitleClicked), for: .touchUpInside)
        return button
    }()
    
    let backButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "page_back").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(backToHome), for: .touchUpInside)
        return button
    }()
    
    let hamburgerButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ico_24dp_nav").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(MenuButtonTabbed), for: .touchUpInside)
        return button
    }()
    
    let downArrowButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ico_24dp_email_open").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(navBarTitleClicked), for: .touchUpInside)
        return button
    }()
    
    let listButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "card_view").withRenderingMode(.alwaysOriginal), for: .normal)
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
        button.addTarget(self, action: #selector(btnSortClicked), for: .touchUpInside)
        
        return button
    }()
    
    let searchButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "search").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(searchButtonInFileViewClicked), for: .touchUpInside)
        
        return button
    }()
    
    let localRefreshButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "refresh").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(refreshButtonClicked), for: .touchUpInside)
        
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
        
        return bar
    }()
    
    let searchDownArrowButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ico_arr_down").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(btnArrDownClicked), for: .touchUpInside)
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
    
    
    var oneViewListView:UIView = {
        let view = UIView()
//        view.backgroundColor = HexStringToUIColor().getUIColor(hex: "F5F5F5")
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    var searchListView:UIView = {
        let view = UIView()
        //        view.backgroundColor = HexStringToUIColor().getUIColor(hex: "F5F5F5")
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    var multiCheckBottomView:UIView = {
        let view = UIView()
        view.backgroundColor = HexStringToUIColor().getUIColor(hex: "F5F5F5")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let selectAllButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("전체 선택", for: .normal)
        button.titleLabel?.textAlignment = .right
        button.setTitleColor(HexStringToUIColor().getUIColor(hex: "4f4f4f"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(selectAllFile), for: .touchUpInside)
        return button
    }()
    
    var lblSubNav:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = ">GiGA NAS"
        label.textColor = HexStringToUIColor().getUIColor(hex: "4f4f4f")
        label.isUserInteractionEnabled = true
        return label
    }()

    var selectedAll = false
    
    
    var loginCookie = ""
    var loginToken = ""
    var userId = ""
    var uuid = ""
    var fileId = ""
    var searchedText = ""
    var deviceName = ""
    var folderName = ""
    var foldrId = ""
    var fileNm = ""
    var searchbarTextStarted = false
    var DeviceArray:[App.DeviceStruct] = []
    var SearchedFileArray:[App.FolderStruct] = []
    var LatelyUpdatedFileArray:[App.LatelyUpdatedFileStruct] = []
    var driveFileArray:[App.DriveFileStruct] = []
    var folderArray:[App.FolderStruct] = []
    var intFolderArrayIndexPathRow = 0
    var collectionView: UICollectionView!
    var currentDevUuid = ""
    var currentFolderId = ""
    var fromOsCd = ""
    var searchGubun = ""
    var oneViewSortState:DbHelper.sortByEnum = DbHelper.sortByEnum.none
    var containerViewTopAnchor:NSLayoutConstraint?
    var containerViewBottomAnchor:NSLayoutConstraint?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        
        // Do any additional setup after loading the view.
        sBar.delegate = self
        documentController.delegate = self
         
        customNavBar.layer.shadowColor = UIColor.lightGray.cgColor
        customNavBar.layer.shadowOffset = CGSize(width:0,height: 2.0)
        customNavBar.layer.shadowRadius = 1.0
        customNavBar.layer.shadowOpacity = 1.0
        customNavBar.layer.masksToBounds = false;
        customNavBar.layer.shadowPath = UIBezierPath(roundedRect:customNavBar.bounds, cornerRadius:customNavBar.layer.cornerRadius).cgPath
        
//        setupNavBar()
       
        let tap = UITapGestureRecognizer(target: self, action: #selector(subNavClicked))
        lblSubNav.addGestureRecognizer(tap)

        
        
        btnCategories  = [btnCategory1, btnCategory2, btnCategory3, btnCategory4]
        for b in btnCategories{
            b.setTitleColor(HexStringToUIColor().getUIColor(hex: "ff0000"), for: .selected)
           
        }
        loginCookie = UserDefaults.standard.string(forKey: "cookie") ?? "nil"
        loginToken = UserDefaults.standard.string(forKey: "token") ?? "nil"
        uuid = Util.getUuid()
        userId = UserDefaults.standard.string(forKey: "userId")!
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(toggleBottomMenu(sortInfo: )),
                                               name: NSNotification.Name("toggleBottomMenu"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setupFolderPathView),
                                               name: NSNotification.Name("setupFolderPathView"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(bottomStateFromContainer(stateInfo: )),
                                               name: NSNotification.Name("bottomStateFromContainer"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setGoogleDriveFileListView),
                                               name: NSNotification.Name("setGoogleDriveFileListView"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(homeViewToggleIndicator),
                                               name: NSNotification.Name("homeViewToggleIndicator"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(openDocument(urlDict:)),
                                               name: NSNotification.Name("openDocument"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(btnMulticlicked),
                                               name: NSNotification.Name("btnMulticlicked"),
                                               object: nil)
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        self.setHomeView()
    }
    
    func setHomeView(){
        bottomListState = .oneView
        viewState = .home
        navBarTitle.isUserInteractionEnabled = true
        searchStepState = .all
        mainContentState = .oneViewList
        for view in self.customNavBar.subviews {
            view.removeFromSuperview()
        }
        SetupHomeView.setupMainNavbar(View: customNavBar, navBarTitle: navBarTitle, hamburgerButton: hamburgerButton, listButton: listButton, downArrowButton: downArrowButton, title:"GiGA Stroage")
        
        
        
        for view in self.searchView.subviews {
            view.removeFromSuperview()
        }
        SetupHomeView.setupMainSearchView(View:searchView, sortButton:sortButton, sBar:sBar, searchDownArrowButton:searchDownArrowButton, parentViewContoller:self)
        print("setHomeView")
        
        oneViewSortState = DbHelper.sortByEnum.none
     
        self.setupDeviceListView(sortBy: oneViewSortState,multiCheckd: multiButtonChecked)
        hideKeyboard()
        tableView.reloadData()
        
    }
    
  
    func setupDeviceListView(sortBy: DbHelper.sortByEnum, multiCheckd:Bool){
        
        //devicelistview 호출시
        let previous = self.childViewControllers.first
        if let previous = previous {
            previous.willMove(toParentViewController: nil)
            previous.view.removeFromSuperview()
            previous.removeFromParentViewController()
        }
        child = storyboard!.instantiateViewController(withIdentifier: "HomeDeviceCollectionVC") as! HomeDeviceCollectionVC
        self.DeviceArray = DbHelper().listSqlite(sortBy: sortBy)
        self.driveFileArray = DbHelper().googleDrivelistSqlite(sortBy: sortBy)
//        print("table deviceList: \(DeviceArray)")
        
        
        child?.DeviceArray = self.DeviceArray
        child?.listViewStyleState = self.listViewStyleState
        child?.mainContentState = self.mainContentState
        child?.flickState = self.flickState
        child?.LatelyUpdatedFileArray = self.LatelyUpdatedFileArray
        child?.driveFileArray = self.driveFileArray
        child?.folderArray = self.SearchedFileArray
        child?.SearchedFileArray = self.SearchedFileArray
        child?.homeViewController = self
        child?.containerViewController = containerViewController
        child?.viewState = viewStateEnum.home
    
        
        // 0eun - start
        if self.mainContentState == .googleDriveList {
            child?.cellStyle = self.cellStyle
        }
        // 0eun - end
        
       
        print("called")
        self.view.addSubview(oneViewListView)
        for containerSubview in oneViewListView.subviews {
            containerSubview.removeFromSuperview()
        }
        containerViewTopAnchor?.isActive = false
        containerViewBottomAnchor?.isActive = false
        oneViewListView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        oneViewListView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerViewTopAnchor =  oneViewListView.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: 0)
        containerViewTopAnchor?.isActive = true
        containerViewBottomAnchor = oneViewListView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60)
        containerViewBottomAnchor?.isActive = true
        self.willMove(toParentViewController: nil)
        child?.willMove(toParentViewController: parent)
        self.addChildViewController(child!)
        oneViewListView.addSubview((child?.view)!)
        
        child?.didMove(toParentViewController: parent)
        
        let w = oneViewListView.frame.size.width;
        let h = oneViewListView.frame.size.height;
        child?.view.frame = CGRect(x: 0, y: 0, width: w, height: h)
        
        print("containerA setting called")
        
        
    }
    
    @objc func subNavClicked() {
        child?.getChildFolder()
    }

    
    func setupSearchListView(sortBy: DbHelper.sortByEnum, multiCheckd:Bool){
        
        child2 = storyboard!.instantiateViewController(withIdentifier: "HomeDeviceCollectionVC") as! HomeDeviceCollectionVC
        self.DeviceArray = DbHelper().listSqlite(sortBy: sortBy)
        child2?.DeviceArray = self.DeviceArray
        child2?.listViewStyleState = self.listViewStyleState
        child2?.mainContentState = self.mainContentState
        child2?.flickState = self.flickState
        child2?.LatelyUpdatedFileArray = self.LatelyUpdatedFileArray
        child2?.driveFileArray = self.driveFileArray
        child2?.folderArray = self.SearchedFileArray
        child2?.SearchedFileArray = self.SearchedFileArray
        child2?.homeViewController = self
        child2?.containerViewController = containerViewController
        child2?.viewState = viewStateEnum.search
        
        print("called")
        self.view.addSubview(searchListView)
        for containerSubview in searchListView.subviews {
            containerSubview.removeFromSuperview()
        }
        searchListView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        searchListView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        searchListView.topAnchor.constraint(equalTo: view.topAnchor, constant: 300).isActive = true
        searchListView.topAnchor.constraint(equalTo: searchCountLabel.bottomAnchor, constant: 2).isActive = true
        searchListView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        self.willMove(toParentViewController: nil)
        child2?.willMove(toParentViewController: parent)
        self.addChildViewController(child2!)
        searchListView.addSubview((child2?.view)!)
        
        child2?.didMove(toParentViewController: parent)
        
        let w = searchListView.frame.size.width;
        let h = searchListView.frame.size.height;
        child2?.view.frame = CGRect(x: 0, y: 0, width: w, height: h)
        
        print("containerb setting called")
        
    }
    
    @objc func hideKeyboard() {
        sBar.endEditing(true)
        print("hide keyboard")
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedText = searchText
        print("search text : \(searchText)")
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("begin")
        
//        sBar.endEditing(true)
//        performSegue(withIdentifier: "showSearchViewSegue", sender: self)
        if(!searchbarTextStarted){
            if(deviceName.isEmpty){
                setSearchView(title: "GiGA Storage")
            } else {
                setSearchView(title: deviceName)
            }
            
            searchbarTextStarted = true
        }
        
        print("called")
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        
    }
    func setSearchView(title:String){
        navBarTitle.isUserInteractionEnabled = false
        
        for view in self.customNavBar.subviews {
            view.removeFromSuperview()
        }
        
        SetupSearchView.setupSearchNavbar(View: customNavBar, navBarTitle: navBarTitle, backBUtton: backButton, title:title)
        
        SetupHomeView.setupMainSearchView(View:searchView, sortButton:sortButton, sBar:sBar, searchDownArrowButton:searchDownArrowButton, parentViewContoller:self)
        
        showSearchCategory()
        SetupSearchView.showFileCountLabel(count:0, view:self.view, searchCountLabel:searchCountLabel, searchCategoryView: searchCategoryView)
        oneViewListView.isHidden = true
//        setupSearchListView(sortBy: oneViewSortState, multiCheckd: multiButtonChecked)
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("end")
        view.removeGestureRecognizer(tapGesture)
        sBar.endEditing(true)
    }
 
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("검색 : \(searchBar.text!)")
        view.removeGestureRecognizer(tapGesture)
        sBar.endEditing(true)
        searchedText = searchBar.text!
        print("\(mainContentState)")
        if(mainContentState == .oneViewList) {
            searchInAllCategory()
        } else {
            searchInGoogleDrive(fileNm: searchedText)
        }
    }
    
    func searchInAllCategory(){
        viewState = .search
        activityIndicator.startAnimating()
        SearchedFileArray.removeAll()
        SearchFileList().searchFile(searchKeyword: searchedText, searchStep: searchStepState, searchId: searchId, foldrWholePathNm: foldrWholePathNm, sortBy:sortBy, searchGubun:searchGubun, devUuid : selectedDevUuid){ responseObject, error in
            let json = JSON(responseObject as? Any)
            if let statusCode = json["statusCode"].int, statusCode == 100 {
                let serverList:[AnyObject] = json["listData"].arrayObject! as [AnyObject]
                for file in serverList {
                    
                    let fileStruct = App.FolderStruct(data: file)
                    let fileId = fileStruct.fileId
                    if(fileId == 0){
                    } else {
                        self.SearchedFileArray.append(fileStruct)
                    }
                    //                    print("searchFile : \(file), fileStruct : \(fileStruct)")
                }
                print("file count : \(self.SearchedFileArray.count)")
                SetupSearchView.showFileCountLabel(count: self.SearchedFileArray.count, view:self.view, searchCountLabel:self.searchCountLabel, searchCategoryView: self.searchCategoryView)
                
                //                self.setupDeviceListView(sortBy: self.oneViewSortState, multiCheckd: self.multiButtonChecked)
                self.setupSearchListView(sortBy: self.oneViewSortState, multiCheckd: self.multiButtonChecked)
                
                //                self.setSearchFileCollectionView()
                self.activityIndicator.stopAnimating()
                if(self.SearchedFileArray.count == 0){
                    self.searchListView.backgroundColor = UIColor.white
                }
            }
            return
        }
    }
    
    func searchInGoogleDrive(fileNm:String){
        viewState = .search
        activityIndicator.startAnimating()
        driveFileArray.removeAll()
        if let googleEmail = UserDefaults.standard.string(forKey: "googleEmail"){
            let accessToken = DbHelper().getAccessToken(email: googleEmail)
            
            GoogleWork().getFilesByName(accessToken: accessToken, fileNm: fileNm) { responseObject, error in
                let json = JSON(responseObject!)
                print("json : \(json)")
                if let serverList:[AnyObject] = json["files"].arrayObject as! [AnyObject] {
                    for file in serverList {
                        if file["trashed"] as? Int == 0 && file["starred"] as? Int == 0 && file["shared"] as? Int == 0 && file["mimeType"] as? String != Util.getGoogleMimeType(etsionNm: "folder"){
                            let fileStruct = App.DriveFileStruct(device: file, foldrWholePaths: ["Google"])
                            
                            self.driveFileArray.append(fileStruct)
                        }
                    }
                }
                print("file count : \(self.driveFileArray.count)")
                SetupSearchView.showFileCountLabel(count: self.driveFileArray.count, view:self.view, searchCountLabel:self.searchCountLabel, searchCategoryView: self.searchCategoryView)
                
                //                self.setupDeviceListView(sortBy: self.oneViewSortState, multiCheckd: self.multiButtonChecked)
                self.setupSearchListView(sortBy: self.oneViewSortState, multiCheckd: self.multiButtonChecked)
                
                //                self.setSearchFileCollectionView()
                self.activityIndicator.stopAnimating()
                if(self.SearchedFileArray.count == 0){
                    self.searchListView.backgroundColor = UIColor.white
                }
            }
        }
    }
    
    
    @objc func btnArrDownClicked() {
        showSearchCategory()
    }
  
    @objc func showSearchCategory(){
        switch btnArrState {
        case .start:
            searchDownArrowButton.setImage(#imageLiteral(resourceName: "ico_arr_down").withRenderingMode(.alwaysOriginal), for: .normal)
            searchDownArrowButton.isHidden = false
            searchCategoryView.isHidden = true
            searchCategoryHeightConstraint.constant = 0
            searchCountLabel.isHidden = false
            btnArrState = .show
            break
        case .show:
            searchDownArrowButton.setImage(#imageLiteral(resourceName: "ico_arr_up").withRenderingMode(.alwaysOriginal), for: .normal)
            searchDownArrowButton.isHidden = false
            searchCategoryView.isHidden = false
            searchCategoryHeightConstraint.constant = 41
            btnArrState = .hide
            break
        case .hide:
            searchDownArrowButton.setImage(#imageLiteral(resourceName: "ico_arr_down").withRenderingMode(.alwaysOriginal), for: .normal)
            searchDownArrowButton.isHidden = false
            searchCategoryView.isHidden = true
            searchCategoryHeightConstraint.constant = 0
            btnArrState = .show
            searchGubun = ""
            break
        case .end:
            searchDownArrowButton.isHidden = true
            searchCategoryView.isHidden = true
            searchCountLabel.isHidden = true
            searchCategoryHeightConstraint.constant = 0
            btnArrState = .start
            searchGubun = ""
            break
       
        }
        
     
    }
    

    func schemeAvailable(scheme: String) -> Bool {
        if let url = URL(string: scheme) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
   
    
    
    @objc func backToHome(){
        print("cellstyle when backToHome : \(cellStyle)")
        print("currentFolderId : \(currentFolderId)")
        print("folderArray : \(folderArray)")
        oneViewListView.isHidden = false
        navBarTitle.isUserInteractionEnabled = true
        for view in self.customNavBar.subviews {
            view.removeFromSuperview()
        }
        var title = "GiGA Stroage"
        if(!deviceName.isEmpty){
            title = deviceName
        }
        SetupHomeView.setupMainNavbar(View: customNavBar, navBarTitle: navBarTitle, hamburgerButton: hamburgerButton, listButton: listButton, downArrowButton: downArrowButton, title:title)
        for view in self.searchView.subviews {
            view.removeFromSuperview()
        }
        SetupHomeView.setupMainSearchView(View:searchView, sortButton:sortButton, sBar:sBar, searchDownArrowButton:searchDownArrowButton, parentViewContoller:self)
        print("setHomeView")
        
        oneViewSortState = DbHelper.sortByEnum.none
        
        for b in btnCategories{
            b.isSelected = false
        }
        mainContentState = .oneViewList
        sBar.text = ""
        maintainFolder = true
        btnArrState = .end
        searchbarTextStarted = false
        showSearchCategory()
        flickView.isHidden = false
        for view in self.searchListView.subviews {
            view.removeFromSuperview()
        }
        searchListView.removeFromSuperview()
        view.bringSubview(toFront: oneViewListView)
        
        var googleOnOff = "N"
        let googleEmail = UserDefaults.standard.string(forKey: "googleEmail") ?? "nil"
        print("googleEmail : \(googleEmail)" )
        let getTokenTime = DbHelper().getTokenTime(email: googleEmail)
        print("getTokenTime : \(getTokenTime)")
        let now = Date()
        if(cellStyle == 1) {
            DeviceArray.removeAll()
            homeViewToggleIndicator()
            
            GetListFromServer().getDevice(){ responseObject, error in
                let json = JSON(responseObject as Any)
                if let statusCode = json["statusCode"].int, statusCode == 100 {
                    let serverList:[AnyObject] = json["listData"].arrayObject! as [AnyObject]
                    //                                print("one view list : \(serverList)")
                    for device in serverList {
                        let deviceStruct = App.DeviceStruct(device: device)
                        self.DeviceArray.append(deviceStruct)
                        let defaults = UserDefaults.standard
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
                    
                    if GIDSignIn.sharedInstance().hasAuthInKeychain() == true {
                        googleOnOff = "Y"
                    } else {
                        googleOnOff = "N"
                    }
                    let googleDrive = App.DeviceStruct(devNm : "Google Drive", devUuid : "devUuidValue", logical: "nll", mkngVndrNm : "mkngVndrNmValue", newFlag: "N", onoff : googleOnOff, osCd : "D", osDesc : "D", osNm : "D", userId : "userIdValue", userName : "Y")
                    self.DeviceArray.append(googleDrive)
                    DbHelper().jsonToSqlite(getArray: self.DeviceArray)
                    DispatchQueue.main.async {
                        self.setHomeView()
                        self.homeViewToggleIndicator()
                    }
                    
                }
            }
        }
        
        
    }
    func getFolderArrayFromContainer(getFolderArray:[App.FolderStruct], getFolderArrayIndexPathRow:Int){
        folderArray = getFolderArray
        intFolderArrayIndexPathRow = getFolderArrayIndexPathRow
//        print("folderArray : \(folderArray), folderArrayIndexPath : \(intFolderArrayIndexPathRow), \(folderArray[intFolderArrayIndexPathRow].fileNm)")
    }
    
    func dataFromContainer(containerData : Int, getStepState:searchStepEnum, getBottomListState: bottomListEnum, getStringId:String, getStringFolderPath:String, getCurrentDevUuid:String, getCurrentFolderId:String){
        searchStepState = getStepState
        searchId = getStringId
        foldrWholePathNm = getStringFolderPath
        bottomListState = getBottomListState
        currentDevUuid = getCurrentDevUuid
        currentFolderId = getCurrentFolderId
        
//        tableView.reloadData()
//        print("searchStepState : \(searchStepState), id: \(searchId), bottomListyState: \(getBottomListState)")
        
    }
    
    @objc func bottomStateFromContainer(stateInfo: NSNotification){
        if let bottomState = stateInfo.userInfo?["bottomState"] as? String, let getFileId = stateInfo.userInfo?["fileId"] as? String, let getFoldrWholePathNm = stateInfo.userInfo?["foldrWholePathNm"] as? String, let getDeviceName = stateInfo.userInfo?["deviceName"] as? String, let getDevUuid = stateInfo.userInfo?["selectedDevUuid"] as? String, let getFileNm = stateInfo.userInfo?["fileNm"] as? String, let getUserId = stateInfo.userInfo?["userId"] as? String, let getFoldrId = stateInfo.userInfo?["foldrId"] as? String, let getFomOsCd = stateInfo.userInfo?["fromOsCd"] as? String, let getCurrentFolderId = stateInfo.userInfo?["currentFolderId"] as? String{
            
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
//            print("bottomListState: \(bottomListState), foldrWholePathNm : \(foldrWholePathNm)")
            ifNavBarClicked = false
            containerViewBottomAnchor?.isActive = false
            containerViewBottomAnchor = oneViewListView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
            containerViewBottomAnchor?.isActive = true
            
        } else {
            print("not called")
        }
        
        if(listViewStyleState == .grid){
            if let getCellStyle = stateInfo.userInfo?["cellStyle"] as? String {
                print("getCellStyle : \(getCellStyle)")
                
                ifNavBarClicked = true
                tableView.reloadData()
            } else {
                if let getFolderArray = stateInfo.userInfo?["folderArray"] as? [App.FolderStruct], let getIndexPath = stateInfo.userInfo?["selectedIndex"] as? IndexPath {
                    
//                    print("getFolderArray : \(getFolderArray)")
                    print("getIndexPath : \(getIndexPath)")
                    folderArray = getFolderArray
                    intFolderArrayIndexPathRow = getIndexPath.row
                    
                } else if let getDriveFileArray = stateInfo.userInfo?["driveFileArray"] as? [App.DriveFileStruct], let getIndexPath = stateInfo.userInfo?["selectedIndex"] as? IndexPath {
                    
                    print("getFolderArray : \(getDriveFileArray)")
                    print("getIndexPath : \(getIndexPath)")
                    driveFileArray = getDriveFileArray
                    intFolderArrayIndexPathRow = getIndexPath.row
                }
                tableView.reloadData()
                let fileIdDict = ["fileId":"\(fileId)"]
                NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self, userInfo: fileIdDict)
            }
        }
    }
    
    @IBAction func btnCategoryClicked(_ sender: UIButton) {
        
        for b in btnCategories{
            b.isSelected = false
        }
        sender.isSelected = true
        print("sender : \(sender)")
        switch sender {
            case btnCategory1:
                
                searchGubun = "meta"
                break
            case btnCategory2:
                searchGubun = "amdDate"
                break
            case btnCategory3:
                searchGubun = "emailSbjt"
                break
            case btnCategory4:
                searchGubun = "emailTo"
                break
            default:
                break
        }
    }
    
    
 
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    @objc func btnSortClicked(){
        ifNavBarClicked = false
        
        let fileIdDict = ["fileId":"0"]
        if cellStyle == 1 {
            bottomListState = .oneView
        } else if cellStyle == 2 {
            bottomListState = .sort
        }
        tableView.reloadData()
        NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self, userInfo: fileIdDict)
        
    }
    
    @objc func btnMulticlicked(){
        var style = "nas"
        if fromOsCd == "S" || fromOsCd == "G"{
            bottomListState = .bottomMultiListNas
        } else if fromOsCd == "D" {
            bottomListState = .bottomMultiListGDrive
            
        }else if selectedDevUuid != Util.getUuid() {
            style = "remote"
            bottomListState = .bottomMultiListRemote
        } else {
            bottomListState = .bottomMultiListLocal
            style = "local"
        }
        ifNavBarClicked = false
        var stringBool = "false"
        if(multiButtonChecked){
            multiButtonChecked = false
            multiButton.setImage(#imageLiteral(resourceName: "multi_off-1").withRenderingMode(.alwaysOriginal), for: .normal)
            containerViewBottomAnchor?.isActive = false
            containerViewBottomAnchor = oneViewListView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
            containerViewBottomAnchor?.isActive = true
            
        } else {
            multiButtonChecked = true
            multiButton.setImage(#imageLiteral(resourceName: "multi_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            containerViewBottomAnchor?.isActive = false
            containerViewBottomAnchor = oneViewListView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60)
            containerViewBottomAnchor?.isActive = true
            
        }
        if(style == "local"){
            self.setupFileCollectionView(getFolerName: folderName, getDeviceName: deviceName, getDevUuid: selectedDevUuid)
        }
      
        setMultiCountLabel(multiButtonChecked:multiButtonChecked, count:0)
        stringBool = String(multiButtonChecked)
        print("stringBool :\(stringBool), style : \(style)")
//        let fileIdDict = ["multiChecked":stringBool]
//        NotificationCenter.default.post(name: Notification.Name("multiSelectActive"), object: self, userInfo: fileIdDict)
        
        tableView.reloadData()
        child?.multiSelectActive(multiButtonActive: multiButtonChecked)
        
    }
    
    @objc func selectAllFile(){
    
        
        if selectedAll {
            selectedAll = false
            selectAllButton.setTitleColor(HexStringToUIColor().getUIColor(hex: "4f4f4f"), for: .normal)
        } else {
            selectedAll = true
            selectAllButton.setTitleColor(HexStringToUIColor().getUIColor(hex: "ff0000"), for: .normal)
        }
        child?.allMultiCheck(selectedAll:selectedAll)
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
            print("fromOsCd:\(fromOsCd)")
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
                multiCheckTapGesture = UITapGestureRecognizer(target: self, action: #selector(multiCheckBottomViewTapped))
                multiCheckBottomView.addGestureRecognizer(multiCheckTapGesture)
                
            }
        }
    }
    
    
    func inActiveMultiCheck(){
        multiButtonChecked = false
        multiButton.setImage(#imageLiteral(resourceName: "multi_off-1").withRenderingMode(.alwaysOriginal), for: .normal)
        containerViewBottomAnchor?.isActive = false
        containerViewBottomAnchor = oneViewListView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        containerViewBottomAnchor?.isActive = true
        if self.view.contains(multiCheckBottomView){
            for view in multiCheckBottomView.subviews {
                view.removeFromSuperview()
            }
            multiCheckBottomView.removeFromSuperview()
        }
        child?.multiSelectActive(multiButtonActive: multiButtonChecked)
        
    }
  
    @objc func multiCheckBottomViewTapped(){
        let fileIdDict = ["fileId":"0"]
        
        
        tableView.reloadData()
        NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self, userInfo: fileIdDict)
    }
    
    
    @objc func navBarTitleClicked(){
        print("??")
        ifNavBarClicked = true
        cellStyle = 1
        let fileIdDict = ["fileId":"0"]
        tableView.reloadData()
        
        NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self, userInfo: fileIdDict)
    }
    
 
    @objc func toggleBottomMenu(sortInfo: NSNotification) {
        if let getInfo = sortInfo.userInfo?["fileId"] as? String {
            fileId = getInfo
            print("getFileId: \(fileId)")
        }
        print("local list count :\(bottomListLocalFileInfo.count)")
        
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
                
            })
            
        }else{
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
            tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeBottomMenu))
            tapGesture.cancelsTouchesInView = false
            backgroundView.addGestureRecognizer(tapGesture)
            
        }
        UserDefaults.standard.set(bottomMenuOpen, forKey: "bottomMenuOpen")
    
        
    }
    @objc func closeBottomMenu() {
        bottomMenuOpen = UserDefaults.standard.bool(forKey: "bottomMenuOpen")
        if(bottomMenuOpen){
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: nil)
        }
        backgroundView.removeGestureRecognizer(tapGesture)
    }
    @IBAction func listStyleChange() {
        switch (listViewStyleState) {
        case .grid:
            
            listViewStyleState = .list
            containerViewController?.listViewStyleState = .list
            listButton.setImage(#imageLiteral(resourceName: "card_view").withRenderingMode(.alwaysOriginal), for: .normal)
//            if(mainContentState == .oneViewList){
                if(maintainFolder){
                    let fileDict = ["style":"list"]
                    NotificationCenter.default.post(name: Notification.Name("changeListStyle"), object: self, userInfo: fileDict)
                    self.setupFileCollectionView(getFolerName: folderName, getDeviceName: deviceName, getDevUuid: selectedDevUuid)
                } else {
                    setupDeviceListView(sortBy: oneViewSortState, multiCheckd: multiButtonChecked)
                }
//            }
            break
        case (.list):
            listViewStyleState = .grid
            containerViewController?.listViewStyleState = .grid
            listButton.setImage(#imageLiteral(resourceName: "list_view").withRenderingMode(.alwaysOriginal), for: .normal)
//            if(mainContentState == .oneViewList){
                if(maintainFolder){
                    let fileDict = ["style":"grid"]
                    NotificationCenter.default.post(name: Notification.Name("changeListStyle"), object: self, userInfo: fileDict)
                    setupFileCollectionView(getFolerName: folderName, getDeviceName: deviceName, getDevUuid: selectedDevUuid)
                } else {
                    setupDeviceListView(sortBy: oneViewSortState, multiCheckd: multiButtonChecked)
                }
//            }
            
            break
     
        }
        
    }
    
    @IBAction func btnFlick1Clicked(_ sender: UIButton) {
        
    }
    
    @IBAction func btnFlick2Clicked(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("removeOneView"), object: self)
    }
   

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  
        if(ifNavBarClicked){
            print("DeviceArray.count : \(DeviceArray.count)")
            return DeviceArray.count + 1
        } else {
            switch bottomListState {
            case .nasFileInfo:
                return bottomListFileInfo.count
            case .localFileInfo:
                return bottomListLocalFileInfo.count
                
            case .remoteFileInfo:
                return bottomListRemoteFileInfo.count
            case .sort:
                return bottomListSort.count
                
            case .oneView:
                return bottomListOneViewSort.count
                
            case .bottomMultiListNas:
                return bottomMultiListNas.count
            case .bottomMultiListRemote:
                return bottomMultiListRemote.count
            case .bottomMultiListLocal:
                return bottomMultiListLocal.count
            case .googleDrive:
                return bottomGoogleDrive.count
            case .bottomMultiListGDrive:
                return bottomMultiListGDrive.count
            }
        }
      
       
        
    }
    
  
    
  
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeBottomCell") as! HomeBottomListCell
        let clearView = UIView()
        clearView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = clearView
        print("ifNavBarClicked when slected : \(ifNavBarClicked)")
        if(ifNavBarClicked){
            cell.ivIcon.isHidden = false
            if(indexPath.row == 0){
                cell.lblTitle.text = "홈으로"
                cell.ivIcon.image = UIImage(named: "ico_home")
            } else {
                if(indexPath.row < DeviceArray.count+1){
                    let imageString = Util.getDeviceImageString(osNm: DeviceArray[indexPath.row-1].osNm, onoff: DeviceArray[indexPath.row-1].onoff)
                    cell.ivIcon.image = UIImage(named: imageString)
//                    print("DeviceArray[indexPath.row-1].osNm : \(DeviceArray[indexPath.row-1].onoff)")
                    cell.lblTitle.text = DeviceArray[indexPath.row-1].devNm
                    if(DeviceArray[indexPath.row-1].devUuid == Util.getUuid()){
                        cell.lblTitle.textColor = HexStringToUIColor().getUIColor(hex: "ff0000")
                    } else {
                        cell.lblTitle.textColor = HexStringToUIColor().getUIColor(hex: "4F4F4F")
                    }

                }
            }
        } else {
            print("tableview bottomstate : \(bottomListState)")
            switch bottomListState {
            case .nasFileInfo:
                cell.ivIcon.isHidden = false
                let imageString = Util.getContextImageString(context: bottomListFileInfo[indexPath.row])
                cell.ivIcon.image = UIImage(named: imageString)
                cell.lblTitle.text = bottomListFileInfo[indexPath.row]
                break
                
            case .localFileInfo:
                cell.ivIcon.isHidden = false
                let imageString = Util.getContextImageString(context: bottomListLocalFileInfo[indexPath.row])
                cell.ivIcon.image = UIImage(named: imageString)
                cell.lblTitle.text = bottomListLocalFileInfo[indexPath.row]
                break
            case .remoteFileInfo:
                cell.ivIcon.isHidden = false
                let imageString = Util.getContextImageString(context: bottomListRemoteFileInfo[indexPath.row])
                cell.ivIcon.image = UIImage(named: imageString)
                cell.lblTitle.text = bottomListRemoteFileInfo[indexPath.row]
                break
            case .sort:
                cell.ivIcon.isHidden = true
                cell.lblTitle.text = bottomListSort[indexPath.row]
                break
          
            case .oneView:
                cell.ivIcon.isHidden = true
                cell.lblTitle.text = bottomListOneViewSort[indexPath.row]
                break
                
            case .bottomMultiListNas:
                cell.ivIcon.isHidden = false
                let imageString = Util.getContextImageString(context: bottomMultiListNas[indexPath.row])
                cell.ivIcon.image = UIImage(named: imageString)
                cell.lblTitle.text = bottomMultiListNas[indexPath.row]
                break
            case .bottomMultiListRemote:
                cell.ivIcon.isHidden = false
                let imageString = Util.getContextImageString(context: bottomMultiListRemote[indexPath.row])
                cell.ivIcon.image = UIImage(named: imageString)
                cell.lblTitle.text = bottomMultiListRemote[indexPath.row]
            case .bottomMultiListLocal:
                cell.ivIcon.isHidden = false
                let imageString = Util.getContextImageString(context: bottomMultiListLocal[indexPath.row])
                cell.ivIcon.image = UIImage(named: imageString)
                cell.lblTitle.text = bottomMultiListLocal[indexPath.row]
            case .googleDrive:
                let imageString = Util.getContextImageString(context: bottomGoogleDrive[indexPath.row])
                cell.ivIcon.image = UIImage(named: imageString)
                cell.lblTitle.text = bottomGoogleDrive[indexPath.row]
            case .bottomMultiListGDrive:
                let imageString = Util.getContextImageString(context: bottomMultiListGDrive[indexPath.row])
                cell.ivIcon.image = UIImage(named: imageString)
                cell.lblTitle.text = bottomMultiListGDrive[indexPath.row]
            }
            
        }
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
        print("fromOsCd : \(fromOsCd)")
        
        if(ifNavBarClicked){
            inActiveMultiCheck()
            if(indexPath.row == 0){
                print("back to main")
                self.flickView.isHidden = false
                self.mainContentState = .oneViewList
                backToHome()
                NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
                
            } else {
                let indexPathRow = ["indexPathRow":"\(indexPath.row-1)"]
                NotificationCenter.default.post(name: Notification.Name("clickDeviceItem"), object: self, userInfo: indexPathRow)
                NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
                
                //                print(DeviceArray[indexPath.row].devNm)
                
            }
            
        } else {
            switch bottomListState {
            case .sort:
                if(viewState == .search){
                    sortBy = bottomListSortKey[indexPath.row]
//                    searchInAllCategory()
                    
                } else {
                    let sortState = ["sortState":"\(bottomListSortKey[indexPath.row])"]
                    NotificationCenter.default.post(name: Notification.Name("sortFolderList"), object: self, userInfo: sortState)
                    NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
                }
                
                
                break
            case .nasFileInfo:
                NasFileCellController().nasFileContextMenuCalledFromGrid(indexPath: indexPath, fileId: fileId, foldrWholePathNm: foldrWholePathNm, deviceName: deviceName, parentView: "deviceView", deviceView: self, userId: userId, fromOsCd: fromOsCd, currentDevUuid: currentDevUuid, currentFolderId: currentFolderId, folderArray:folderArray, intFolderArrayIndexPathRow: intFolderArrayIndexPathRow, containerView:containerViewController!)
                break
                
            case .localFileInfo:
//                print("localFileInfo folderArray : \(folderArray), indexpathrow : \(intFolderArrayIndexPathRow)")
                LocalFileListCellController().localContextMenuCalledFromGrid(indexPath: indexPath, fileId: fileId, foldrWholePathNm: foldrWholePathNm, deviceName: deviceName, parentView: "deviceView", deviceView: self, userId: userId, fromOsCd: fromOsCd, currentDevUuid: currentDevUuid, currentFolderId: currentFolderId, folderArray:folderArray, intFolderArrayIndexPathRow: intFolderArrayIndexPathRow, containerView:containerViewController!)
                break
            case .remoteFileInfo:
                
                RemoteFileListCellController().remoteFileContextMenuCalledFromGrid(indexPath: indexPath, fileId: fileId, foldrWholePathNm: foldrWholePathNm, deviceName: deviceName, parentView: "deviceView", deviceView: self, userId: userId, fromOsCd: fromOsCd, currentDevUuid: currentDevUuid, currentFolderId: currentFolderId, folderArray:folderArray, intFolderArrayIndexPathRow: intFolderArrayIndexPathRow)
                break
                
           
            case .oneView:
                oneViewSortState = bottomListOneViewSortKey[indexPath.row]
                setupDeviceListView(sortBy: oneViewSortState, multiCheckd: multiButtonChecked)
                NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
                break
            case .googleDrive:
                GDriveFileListCellController().localContextMenuCalledFromGrid(indexPath: indexPath, fileId: fileId, foldrWholePathNm: foldrWholePathNm, deviceName: "Google Drive", parentView: "deviceView", deviceView: self, userId: userId, fromOsCd: fromOsCd, currentDevUuid: currentDevUuid, currentFolderId: currentFolderId, folderArray:driveFileArray, intFolderArrayIndexPathRow: intFolderArrayIndexPathRow, containerView:containerViewController!)
                
                break            
            case .bottomMultiListNas:
                switch indexPath.row {
                case 0 :
                    let fileDict = ["action":"download","fromOsCd":fromOsCd]
                    NotificationCenter.default.post(name: Notification.Name("handleMultiCheckFolderArray"), object: self, userInfo:fileDict)
                    inActiveMultiCheck()
                    break
                case 1 :
                    let fileDict = ["action":"nas","fromOsCd":fromOsCd]
                    NotificationCenter.default.post(name: Notification.Name("handleMultiCheckFolderArray"), object: self, userInfo:fileDict)
                    inActiveMultiCheck()
                    break
                case 2 :
                    let fileDict = ["action":"gDrive","fromOsCd":fromOsCd]
                    NotificationCenter.default.post(name: Notification.Name("handleMultiCheckFolderArray"), object: self, userInfo:fileDict)
                    inActiveMultiCheck()
                    break
                case 3 :
                    let fileDict = ["action":"delete","fromOsCd":fromOsCd]
                    NotificationCenter.default.post(name: Notification.Name("handleMultiCheckFolderArray"), object: self, userInfo:fileDict)
                    inActiveMultiCheck()
                    break
                
                default :
                    break
                }
                NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
                break
            case .bottomMultiListRemote:
                switch indexPath.row {
                case 0 :
                    let fileDict = ["action":"download","fromOsCd":fromOsCd]
                    NotificationCenter.default.post(name: Notification.Name("handleMultiCheckFolderArray"), object: self, userInfo:fileDict)
                    break
                case 1 :
                    let fileDict = ["action":"nas","fromOsCd":fromOsCd]
                    NotificationCenter.default.post(name: Notification.Name("handleMultiCheckFolderArray"), object: self, userInfo:fileDict)
                    break
                default:
                    
                    break
                    
                }
                break
            case .bottomMultiListLocal:
                switch indexPath.row {
                case 0 :
                    let fileDict = ["action":"nas","fromOsCd":fromOsCd]
                    NotificationCenter.default.post(name: Notification.Name("handleMultiCheckFolderArray"), object: self, userInfo:fileDict)
                    break
                case 1 :
                    let fileDict = ["action":"gDrive","fromOsCd":fromOsCd]
                    NotificationCenter.default.post(name: Notification.Name("handleMultiCheckFolderArray"), object: self, userInfo:fileDict)
                    break
                case 2 :
                    let fileDict = ["action":"delete","fromOsCd":fromOsCd]
                    NotificationCenter.default.post(name: Notification.Name("handleMultiCheckFolderArray"), object: self, userInfo:fileDict)
                    break
                    
                default :
                    break
                }
                NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
            case .bottomMultiListGDrive:
                switch indexPath.row {
                    case 0 :
                        let fileDict = ["action":"download","fromOsCd":fromOsCd]
                        NotificationCenter.default.post(name: Notification.Name("handleMultiCheckFolderArray"), object: self, userInfo:fileDict)
                        break
                    case 1 :
                        let fileDict = ["action":"nas","fromOsCd":fromOsCd]
                        NotificationCenter.default.post(name: Notification.Name("handleMultiCheckFolderArray"), object: self, userInfo:fileDict)
                        break
                    case 2 :
                        let fileDict = ["action":"delete","fromOsCd":fromOsCd]
                        NotificationCenter.default.post(name: Notification.Name("handleMultiCheckFolderArray"), object: self, userInfo:fileDict)
                        break
                default:
                    break
                }
            }
        }
    }
 
   
    
  
    @objc func setupFolderPathView(folderName: NSNotification){
        
        if let getInfo = folderName.userInfo?["folderName"] as? String, let getDeviceName = folderName.userInfo?["deviceName"] as? String, let getDevUuid = folderName.userInfo?["devUuid"] as? String  {
            self.deviceName = getDeviceName
            self.folderName = getInfo
            maintainFolder = true
            print("folderName : \(self.folderName)")
            setupFileCollectionView(getFolerName: getInfo, getDeviceName:getDeviceName, getDevUuid:getDevUuid)
            
            
        }
    }
    
    func setupFileCollectionView(getFolerName:String, getDeviceName:String, getDevUuid:String){
        SetupFolderInsideCollectionView.searchView(searchView: searchView, searchButton: searchButton, sortButton: sortButton, customNavBar: customNavBar, hamburgerButton: hamburgerButton, listButton: listButton, multiButton:multiButton,navBarTitle: navBarTitle, getFolerName: getFolerName, getDeviceName: getDeviceName, listStyle: listViewStyleState, getDevUuid:getDevUuid, localRefreshButton:localRefreshButton, multiButtonChecked:multiButtonChecked, selectAllButton:selectAllButton, lblSubNav:lblSubNav)
        
    }
    
    @objc func searchButtonInFileViewClicked(){
        searchStepState = .device
        for view in self.customNavBar.subviews {
            view.removeFromSuperview()
        }
        for view in self.searchView.subviews {
            view.removeFromSuperview()
        }
        if(!searchbarTextStarted){
            setSearchView(title: deviceName)
            searchbarTextStarted = true
        }

        print("called")
       
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        
    }
   
    @objc func refreshButtonClicked(){
        SyncLocalFilleToNas().sync(view: "home", getFoldrId:currentFolderId)
        
    }
   
    @objc func setGoogleDriveFileListView(cellStyle: NSNotification){
        self.mainContentState = .googleDriveList
        for view in self.customNavBar.subviews {
            view.removeFromSuperview()
        }
        SetupHomeView.setupMainNavbar(View: customNavBar, navBarTitle: navBarTitle, hamburgerButton: hamburgerButton, listButton: listButton, downArrowButton: downArrowButton, title:"Google Drive")
        
        
        // 0eun - start
        if let getInfo = cellStyle.userInfo?["cellStyle"] as? Int {
            self.cellStyle = getInfo
        }
        // 0eun - end
        
        self.setupDeviceListView(sortBy: self.oneViewSortState, multiCheckd: multiButtonChecked)
    }
    
    func downloadFromNas(name:String, path:String, fileId:String){
        homeViewToggleIndicator()
        ContextMenuWork().downloadFromNas(userId:userId, fileNm:name, path:path, fileId:fileId){ responseObject, error in
            if let success = responseObject {
                print(success)
                if(success == "success"){
                    
                    DispatchQueue.main.async {
                        let fileIdDict = ["fileId":"0"]
                        NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self, userInfo: fileIdDict)
                        self.homeViewToggleIndicator()
                        let alertController = UIAlertController(title: nil, message: "파일 다운로드를 성공하였습니다.", preferredStyle: .alert)
                        let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default){
                        UIAlertAction in
                            print("download from nas finish")
                            SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
                        }
                        alertController.addAction(yesAction)
                        self.present(alertController, animated: true)
                    }
                    
                    
                } else {
                    self.homeViewToggleIndicator()
                    let fileIdDict = ["fileId":"0"]
                    NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self, userInfo: fileIdDict)
                }
                
            }
            return
        }
    }
    
    
    
    
    func deleteNasFile(param:[String:Any], foldrId:String){
        print(param)
        homeViewToggleIndicator()
        ContextMenuWork().deleteNasFile(parameters:param){ responseObject, error in
            if let obj = responseObject {
                print(obj)
                let json = JSON(obj)
                let message = obj.object(forKey: "message")
                print("\(message), \(json["statusCode"].int)")
                if let statusCode = json["statusCode"].int, statusCode == 100 {
                    DispatchQueue.main.async {
                        self.homeViewToggleIndicator()
                        NotificationCenter.default.post(name: Notification.Name("refreshInsideList"), object: self)
                        let alertController = UIAlertController(title: nil, message: "파일 삭제가 완료 되었습니다.", preferredStyle: .alert)
                        let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel)
                        
                        let fileIdDict = ["fileId":"0"]
                        NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self, userInfo: fileIdDict)
                        alertController.addAction(yesAction)
                        self.present(alertController, animated: true)
                    }
                } else {
                    self.homeViewToggleIndicator()
                }
            }
            
            
            return
        }
    }
    func googleSignInCheck(name:String, path:String, fileDict:[String:String]){
        if GIDSignIn.sharedInstance().hasAuthInKeychain() == true {
            GIDSignIn.sharedInstance().signInSilently()
            print("sign in silently")
            let fileDict = ["fileId":fileId, "fileNm":fileNm, "oldFoldrWholePathNm":foldrWholePathNm,"state":"googleDrive","fromUserId":selectedDevUserId, "fromOsCd":fromOsCd]
            print("fileDict to google drive: \(fileDict)")
            NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
            
            //            downloadFromNasToDrive(name: name, path: path)
        } else {
            print("need login")
            NotificationCenter.default.post(name: Notification.Name("googleSignInAlertShow"), object: self)
        }
        
    }
    
    @objc func homeViewToggleIndicator(){
        view.bringSubview(toFront: activityIndicator)
        if(indicatorAnimating){
            activityIndicator.stopAnimating()
            indicatorAnimating = false
        } else {
            print("activityIndicator")
            activityIndicator.startAnimating()
            indicatorAnimating = true
        }
    }
    
    @objc func openDocument(urlDict:NSNotification){
        
        if let getUrl = urlDict.userInfo!["url"] as? URL {
            if(!indicatorAnimating){
                homeViewToggleIndicator()
            }            
            documentController = UIDocumentInteractionController(url: getUrl)
            documentController.delegate = self
//            documentController.presentOptionsMenu(from: CGRect.zero, in: self.view, animated: true)
            documentController.presentPreview(animated: true)
        }
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView? {
        return self.view
    }
    
    func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
    
        return self.view.frame
    }
    func documentInteractionControllerWillBeginPreview(_ controller: UIDocumentInteractionController) {
        print("documentInteractionControllerWillBeginPreview")
    }
    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        print("documentInteractionControllerDidEndPreview")
        homeViewToggleIndicator()
        let fileIdDict = ["fileId":"0"]
        if (listViewStyleState == .grid) {
//            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self, userInfo: fileIdDict)
        }
    
        //remove appplay file
        let pathForRemove:String = FileUtil().getFilePath(fileNm: "AppPlay", amdDate: "amdDate")
        print("pathForRemove : \(pathForRemove)")
        if(pathForRemove.isEmpty){
            
        } else {
            FileUtil().removeFile(path: pathForRemove)
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
            print("viewWillAppear")
        
        renewDeviceList()
       
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
    }
    
    func renewDeviceList(){
        print("renewDeviceList")
        self.DeviceArray.removeAll()
        GetListFromServer().getDevice(){ responseObject, error in
            let json = JSON(responseObject as Any)
            if let statusCode = json["statusCode"].int, statusCode == 100 {
                let serverList:[AnyObject] = json["listData"].arrayObject! as [AnyObject]
                //                                print("one view list : \(serverList)")
                for device in serverList {
                    let deviceStruct = App.DeviceStruct(device: device)
                    self.DeviceArray.append(deviceStruct)
                    let defaults = UserDefaults.standard
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
                var googleOnOff = "N"
                if GIDSignIn.sharedInstance().hasAuthInKeychain() == true {
//                    GIDSignIn.sharedInstance().signInSilently()
                    googleOnOff = "Y"
                } else {
                    googleOnOff = "N"
                }
                let googleDrive = App.DeviceStruct(devNm : "Google Drive", devUuid : "devUuidValue", logical: "nll", mkngVndrNm : "mkngVndrNmValue", newFlag: "N", onoff : googleOnOff, osCd : "D", osDesc : "D", osNm : "D", userId : "userIdValue", userName : "Y")
                self.DeviceArray.append(googleDrive)
                DbHelper().jsonToSqlite(getArray: self.DeviceArray)
                DispatchQueue.main.async {
                    
                }
                
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("error: \(error)")
            DispatchQueue.main.async {
                self.service.authorizer = nil
                
            }
            
        } else {
          
            
            
        }
    }
    
}



