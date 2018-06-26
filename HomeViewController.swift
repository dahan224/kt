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

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, GIDSignInDelegate, GIDSignInUIDelegate {
    private let scopes = [kGTLRAuthScopeDriveFile, kGTLRAuthScopeDrive, kGTLRAuthScopeDriveReadonly]
    private let service = GTLRDriveService()    
    var containerViewController:ContainerViewController?
    var child : HomeDeviceCollectionVC?
    var child2 : HomeDeviceCollectionVC?
    var contextMenuWork:ContextMenuWork?
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
    var searchEndTapGesture:UITapGestureRecognizer = UITapGestureRecognizer()
    var multiCheckTapGesture:UITapGestureRecognizer = UITapGestureRecognizer()
    var cellStyle = 1
    
    enum viewStateEnum{
        case home
        case search
        case lately
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
        case bottomListSort = "sort"
        case bottomListOneViewSort = "oneViewSort"
        case nasFileInfo = "nasFileInfo"
        case localFileInfo = "localFileInfo"
        case remoteFileInfo = "remoteFileInfo"
        case bottomMultiListNas = "bottomMultiListNas"
        case bottomMultiListRemote = "bottomMultiListRemote"
        case bottomMultiListLocal = "bottomMultiListLocal"
        case bottomMultiListGDrive = "bottomMultiListGDrive"
        case oneView = "oneView"
        case googleDrive = "googleDrive"
        case bottomMultiListSearch = "bottomMultiListSearch"
        case bottomGDriveListSort = "bottomGDriveListSort"
    }
    
    var ifNavBarClicked = false
    var ifSortClicked = false
    
    var bottomListState:bottomListEnum = bottomListEnum.oneView
    var bottomListSort = ["날짜순-최신 항목 우선", "날짜순-오래된 항목 우선","이름순-ㄱ우선","이름순-ㅎ우선","종류순"]
    var bottomListSortKey = ["new", "old","asc","desc","kind"]
    var bottomListGdriveSortKey = [DbHelper.gDriveSortByEnum.new, DbHelper.gDriveSortByEnum.old, DbHelper.gDriveSortByEnum.asc,    DbHelper.gDriveSortByEnum.desc, DbHelper.gDriveSortByEnum.none]
    
    enum gDriveSortEnum:String {
        case new = "new"
        case old = "old"
        case asc = "asc"
        case desc = "desc"
        case none = "none"
    }
    var gDriveSortBy:String = gDriveSortEnum.none.rawValue
    
    
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
    var bottomMultiListSearch = ["GiGA NAS로 보내기"]
    
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
    
    enum searchSortEnum:String {
        case new = "new"
        case old = "old"
        case asc = "asc"
        case desc = "desc"
        case kind = "kind"
    }
    
    
    var sortBy:String = searchSortEnum.new.rawValue
    
    
    
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
    
    @IBOutlet weak var flickContainerView: UIView!
    @IBOutlet weak var flickContainerHeight: NSLayoutConstraint!
    
    
    
    let navView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view;
    }()
    
    
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
    
    
    let multiButtonInSearchView:UIButton = {
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
        bar.textField.clearButtonMode = .never
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
    
    let selectAllButtonInSearchView:UIButton = {
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
        label.padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
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
    var driveArrayWithoutUpfolder:[App.DriveFileStruct] = []
    var driveArrayFolder:[App.DriveFileStruct] = []
    
    
    var folderArray:[App.FolderStruct] = []
    var intFolderArrayIndexPathRow = 0
    var collectionView: UICollectionView!
    var currentDevUuid = ""
    var currentFolderId = ""
    var fromOsCd = ""
    var searchGubun = ""
    var oneViewSortState:DbHelper.sortByEnum = DbHelper.sortByEnum.none
    var gDriveSortState:DbHelper.gDriveSortByEnum = DbHelper.gDriveSortByEnum.none
    var containerViewTopAnchor:NSLayoutConstraint?
    var containerViewBottomAnchor:NSLayoutConstraint?
    var searchViewBottomAnchor:NSLayoutConstraint?
    
    var completeFolderNameForSearchView = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contextMenuWork = ContextMenuWork()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        
        // Do any additional setup after loading the view.
        sBar.delegate = self
        
        
        flickContainerView.isUserInteractionEnabled = true
        let swipeLeft = UISwipeGestureRecognizer(target: self,
                                                 action: #selector(flickContainerViewSwipedLeft))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        flickContainerView.addGestureRecognizer(swipeLeft)
        
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
                                               selector: #selector(inActiveMultiCheckFromMultiFileProcess),
                                               name: NSNotification.Name("inActiveMultiCheckFromMultiFileProcess"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(homeViewToggleIndicator),
                                               name: NSNotification.Name("homeViewToggleIndicator"),
                                               object: nil)
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(btnMulticlicked),
                                               name: NSNotification.Name("btnMulticlicked"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(backToOneView),
                                               name: NSNotification.Name("backToOneView"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(homeViewStopIndicator),
                                               name: NSNotification.Name("homeViewStopIndicator"),
                                               object: nil)
        

        let listStyle = UserDefaults.standard.string(forKey: "listViewStyleState") ?? "nil"
        if listStyle == "nil" {
            listViewStyleState = .grid
        } else if listStyle == "list" {
            listViewStyleState = .list
            listButton.setImage(#imageLiteral(resourceName: "card_view").withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            listViewStyleState = .grid
            listButton.setImage(#imageLiteral(resourceName: "list_view").withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        self.tableView.isHidden = true
        print("homeViewController called")
        setHomeView()
    }
    
    @objc func homeViewStopIndicator(){
        view.bringSubview(toFront: activityIndicator)
        if(indicatorAnimating) {
            activityIndicator.stopAnimating()
            indicatorAnimating = false
        }
        containerViewController?.finishLoading()
    }

    override func viewDidAppear(_ animated: Bool) {
        customNavBar.layer.shadowColor = UIColor.lightGray.cgColor
        customNavBar.layer.shadowOffset = CGSize(width:0,height: 2.0)
        customNavBar.layer.shadowRadius = 1.0
        customNavBar.layer.shadowOpacity = 1.0
        customNavBar.layer.masksToBounds = false;
        customNavBar.layer.shadowPath = UIBezierPath(roundedRect:customNavBar.bounds, cornerRadius:customNavBar.layer.cornerRadius).cgPath
        
//        self.setHomeView()
    }
    
    override func viewDidLayoutSubviews() {
    
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
        
        SetupHomeView.setupMainNavbar(View: customNavBar, navBarTitle: navBarTitle, hamburgerButton: hamburgerButton, listButton: listButton, downArrowButton: downArrowButton, title:"GiGA Storage")



    
        for view in self.searchView.subviews {
            
            view.removeFromSuperview()
        }
        SetupHomeView.setupMainSearchView(View:searchView, sortButton:sortButton, sBar:sBar, searchDownArrowButton:searchDownArrowButton, parentViewContoller:self, sBarTitle: "all Storage")
        print("setHomeView")

        oneViewSortState = DbHelper.sortByEnum.none


        hideKeyboard()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }

        self.setupDeviceListView(sortBy: oneViewSortState, gDriveSortBy: gDriveSortState,multiCheckd: multiButtonChecked)
        
    }
    
  
    func setupDeviceListView(sortBy: DbHelper.sortByEnum, gDriveSortBy:DbHelper.gDriveSortByEnum, multiCheckd:Bool){
        
        //devicelistview 호출시
        let previous = self.childViewControllers.first
        if let previous = previous {
            previous.willMove(toParentViewController: nil)
            previous.view.removeFromSuperview()
            previous.removeFromParentViewController()
        }
        child = storyboard!.instantiateViewController(withIdentifier: "HomeDeviceCollectionVC") as? HomeDeviceCollectionVC
        self.DeviceArray.removeAll()
        let dbHelper = DbHelper()
        self.DeviceArray = dbHelper.listSqlite(sortBy: sortBy)
        
        child?.DeviceArray = self.DeviceArray
        child?.listViewStyleState = self.listViewStyleState
        child?.mainContentState = self.mainContentState
        child?.flickState = self.flickState
        child?.LatelyUpdatedFileArray = self.LatelyUpdatedFileArray
        child?.driveArrayWithoutUpfolder = driveArrayWithoutUpfolder
        child?.driveArrayFolder = driveArrayFolder
        child?.driveFileArray = self.driveFileArray
        child?.folderArray = self.folderArray
        child?.SearchedFileArray = self.SearchedFileArray
        child?.homeViewController = self
        child?.containerViewController = containerViewController
        child?.viewState = viewStateEnum.home
        child?.cellStyle = self.cellStyle
        
        
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
        
        
        
        oneViewListView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
//        oneViewListView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        oneViewListView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        containerViewTopAnchor?.isActive = false
        containerViewTopAnchor =  oneViewListView.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: 0)        
        containerViewTopAnchor?.isActive = true
        
        DispatchQueue.main.async {
            self.containerViewBottomAnchor?.isActive = false
            if self.cellStyle == 2 || self.cellStyle == 3 {
                self.containerViewBottomAnchor = self.oneViewListView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
            } else {
                self.containerViewBottomAnchor = self.oneViewListView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -60)
            }
            self.containerViewBottomAnchor?.isActive = true
        }
        
//        self.willMove(toParentViewController: nil)
//        child?.willMove(toParentViewController: parent)
        self.addChildViewController(child!)
        oneViewListView.addSubview((child?.view)!)
        child?.didMove(toParentViewController: parent)
        
        let w = oneViewListView.frame.size.width;
        let h = oneViewListView.frame.size.height;
        child?.view.frame = CGRect(x: 0, y: 0, width: w, height: h)
        
        print("containerA setting called height : \(h)")
        let tableViewHeight = tableView.frame.size.height
        let tableViewHeightAnchor = tableView.heightAnchor
        let flickViewHeight = flickView.frame.size.height
        print("flickViewHeight : \(flickViewHeight), viewHeight : \(App.Size.screenHeight), tableViewHeight : \(tableViewHeight), tableViewHeightAnchor : \(tableViewHeightAnchor)")
        
       
//        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant : -300).isActive = true
    }
    
    @objc func subNavClicked() {
        child?.getChildFolder()
    }

    
    func setupSearchListView(sortBy: DbHelper.sortByEnum, multiCheckd:Bool){
//        let previous = self.childViewControllers.first
//        if let previous = previous {
//            previous.willMove(toParentViewController: nil)
//            previous.view.removeFromSuperview()
//            previous.removeFromParentViewController()
//        }
        
        child2 = storyboard!.instantiateViewController(withIdentifier: "HomeDeviceCollectionVC") as? HomeDeviceCollectionVC
        self.DeviceArray = DbHelper().listSqlite(sortBy: sortBy)
        child2?.DeviceArray = self.DeviceArray
        child2?.listViewStyleState = self.listViewStyleState
        child2?.cellStyle = 2
        child2?.mainContentState = self.mainContentState
        child2?.flickState = self.flickState
        child2?.LatelyUpdatedFileArray = self.LatelyUpdatedFileArray
        child2?.driveFileArray = self.driveFileArray
        child2?.folderArray = self.SearchedFileArray
        child2?.SearchedFileArray = self.SearchedFileArray
        child2?.homeViewController = self
        child2?.containerViewController = containerViewController
        child2?.viewState = viewStateEnum.search
        child2?.selectedDevUserId = selectedDevUserId
        print("selectedDevUserId in searchlist init")
        
        print("search view called")
        self.view.addSubview(searchListView)
        for containerSubview in searchListView.subviews {
            containerSubview.removeFromSuperview()
        }
        searchListView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        searchListView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        searchListView.topAnchor.constraint(equalTo: view.topAnchor, constant: 300).isActive = true
        searchListView.topAnchor.constraint(equalTo: searchCountLabel.bottomAnchor, constant: 2).isActive = true
        
        searchViewBottomAnchor = searchListView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        searchViewBottomAnchor?.isActive = false
        
        searchViewBottomAnchor?.isActive = true
        
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
        
        viewState = .search
        flickView.isHidden = true // 추가
        flickContainerView.isHidden = true
        
//        sBar.endEditing(true)
//        performSegue(withIdentifier: "showSearchViewSegue", sender: self)
        print("cellStyle : \(cellStyle)")
        if(!searchbarTextStarted){
            if(deviceName.isEmpty || cellStyle == 1){
                setSearchView(title: "GiGA Storage")
            } else {
                setSearchView(title: deviceName)
            }
            
            searchbarTextStarted = true
        }
        
        print("searchBarTextDidBeginEditing called maincontentSatate  :\(mainContentState)")
        
        searchEndTapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        searchEndTapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(searchEndTapGesture)

        
    }
    func setSearchView(title:String){
        print("setSearchView called")
        activityIndicator.isHidden = true
//        sBar.placeholder = "Search in all Storaged"
        viewState = .search
        navBarTitle.isUserInteractionEnabled = false
        searchGubun = ""
        for view in self.customNavBar.subviews {
            view.removeFromSuperview()
        }
        
        var sBarTitle = title
        if cellStyle == 1 {
            sBarTitle = "all Storage"
        }
        
        DispatchQueue.main.async {
            self.containerViewBottomAnchor?.isActive = false
            self.containerViewBottomAnchor = self.oneViewListView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
            self.containerViewBottomAnchor?.isActive = true
            self.flickView.isHidden = true
            self.flickContainerView.isHidden = true
            self.searchCountLabel.isHidden = false
            SetupSearchView.showFileCountLabel(count:0, view:self.view, searchCountLabel:self.searchCountLabel, searchCategoryView: self.searchCategoryView, multiButton:self.multiButtonInSearchView, multiButtonChecked:self.multiButtonChecked, selectAllButton:self.selectAllButtonInSearchView)
            
            self.oneViewListView.isHidden = true
        }
        SetupSearchView.setupSearchNavbar(View: customNavBar, navBarTitle: navBarTitle, backBUtton: backButton, title:title, listButton:listButton)
        
        SetupHomeView.setupMainSearchView(View:searchView, sortButton:sortButton, sBar:sBar, searchDownArrowButton:searchDownArrowButton, parentViewContoller:self, sBarTitle:sBarTitle)
        
        if cellStyle == 3 {
            searchDownArrowButton.isHidden = true
        } else {
            showSearchCategory()
        }
//        setupSearchListView(sortBy: oneViewSortState, multiCheckd: multiButtonChecked)
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("end")
        view.removeGestureRecognizer(searchEndTapGesture)
        sBar.endEditing(true)
    }
 
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        print("검색 : \(searchBar.text!)")
        self.multiCheckBottomView.isHidden = true
        view.removeGestureRecognizer(searchEndTapGesture)
        sBar.endEditing(true)
        searchedText = searchBar.text!
        
        print("selectedDevUuid in searchBarSearchButtonClicked : \(selectedDevUuid), currentDevUuid : \(currentDevUuid), mainContentState : \(mainContentState)")
        
        if searchedText.count >= 2 {
            if selectedDevUuid == "googleDrive"{
                mainContentState = .googleDriveList
            } else {
                mainContentState = .oneViewList
            }
            print("mainContentState : \(mainContentState), searchGubun : \(searchGubun), selectedDevUuid : \(selectedDevUuid), foldrWholePathNm : \(foldrWholePathNm)")
            if(mainContentState == .oneViewList) {
                
                searchInAllCategory(sortBy:sortBy, searchGubun:searchGubun, selectedDevUuid:selectedDevUuid, searchedText:searchedText, foldrWholePathNm:foldrWholePathNm)
                
            } else {
                searchInGoogleDrive(fileNm: searchedText)
            }
            cellStyle = 2
            child2?.cellStyle = 2
            child2?.viewState = .search
            child2?.searchedText = searchedText
        } else {
            let alertController = UIAlertController(title: nil, message: "2자 이상의 검색어를 입력해주세요.", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default)
            alertController.addAction(yesAction)
            self.present(alertController, animated: true)
        }

    }
    
    func refershSearchList(){
        searchInAllCategory(sortBy:sortBy, searchGubun:searchGubun, selectedDevUuid:selectedDevUuid, searchedText:searchedText, foldrWholePathNm:foldrWholePathNm)
    }
    
    func searchInAllCategory(sortBy:String, searchGubun:String, selectedDevUuid:String, searchedText:String, foldrWholePathNm:String){
        viewState = .search
        activityIndicator.startAnimating()
        SearchedFileArray.removeAll()
        var searchUserId:String = selectedDevUserId
        if searchUserId.isEmpty {
            searchUserId = UserDefaults.standard.string(forKey: "userId")!
        }
        SearchFileList().searchFile(userId:searchUserId,searchKeyword: searchedText, searchStep: searchStepState, searchId: searchId, foldrWholePathNm: foldrWholePathNm, sortBy:sortBy, searchGubun:searchGubun, devUuid : selectedDevUuid){ responseObject, error in
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
               
                SetupSearchView.showFileCountLabel(count: self.SearchedFileArray.count, view:self.view, searchCountLabel:self.searchCountLabel, searchCategoryView: self.searchCategoryView, multiButton: self.multiButtonInSearchView, multiButtonChecked:self.multiButtonChecked, selectAllButton:self.selectAllButtonInSearchView)
                
                
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
//        activityIndicator.startAnimating()
        containerViewController?.showIndicator()
        driveFileArray.removeAll()
        let accessToken = UserDefaults.standard.string(forKey: "googleAccessToken")!
        GoogleWork().getFilesByName(accessToken: accessToken, fileNm: fileNm) { responseObject, error in
            self.containerViewController?.finishLoading()
            if (error != nil){
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: nil, message: "네트워크 에러가 발생했습니다.잠시 후 재시도 부탁 드립니다.", preferredStyle: .alert)
                    let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default){
                        UIAlertAction in
                    }
                    alertController.addAction(yesAction)
                    self.present(alertController, animated: true)
                }
            } else {
                let json = JSON(responseObject)
//                print("json : \(json)")
                if let serverList:[AnyObject] = json["files"].arrayObject as? [AnyObject] {
                    for file in serverList {
                        if file["trashed"] as? Int == 0 && file["starred"] as? Int == 0 && file["shared"] as? Int == 0 && file["mimeType"] as? String != Util.getGoogleMimeType(etsionNm: "folder") && file["fileExtension"] as? String != "nil"{
                            let fileStruct = App.DriveFileStruct(device: file, foldrWholePaths: ["Google"])
                            self.driveFileArray.append(fileStruct)
                        }
                    }
                }
//                print("file count : \(self.driveFileArray.count)")
                SetupSearchView.showFileCountLabel(count: self.driveFileArray.count, view:self.view, searchCountLabel:self.searchCountLabel, searchCategoryView: self.searchCategoryView, multiButton: self.multiButtonInSearchView, multiButtonChecked:self.multiButtonChecked, selectAllButton:self.selectAllButtonInSearchView)
                self.setupSearchListView(sortBy: self.oneViewSortState, multiCheckd: self.multiButtonChecked)
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
//            searchGubun = ""
            break
        case .hide:
            searchDownArrowButton.setImage(#imageLiteral(resourceName: "ico_arr_down").withRenderingMode(.alwaysOriginal), for: .normal)
            searchDownArrowButton.isHidden = false
            searchCategoryView.isHidden = true
            searchCategoryHeightConstraint.constant = 0
            btnArrState = .show
//            searchGubun = ""
            break
        case .end:
            searchDownArrowButton.isHidden = true
            searchCategoryView.isHidden = true
            searchCountLabel.isHidden = true
            searchCategoryHeightConstraint.constant = 0
            btnArrState = .start
//            searchGubun = ""
            break
       
        }
        
     
    }
    

    func schemeAvailable(scheme: String) -> Bool {
        if let url = URL(string: scheme) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
   
    @objc func backToOneView() {
        cellStyle = 1
        backToHome()
    }
    
    @objc func inActiveMultiCheckFromMultiFileProcess(){
        print("inActiveMultiCheckFromMultiFileProcess called")
        DispatchQueue.main.async {
            self.inActiveMultiCheck()
            self.inActiveSelectAllFile()
        }
        
    }
    
    @objc func backToHome(){
        print("backToHome clicked")
        self.containerViewController?.showIndicator()
        
        inActiveMultiCheck()
        inActiveSelectAllFile()
        print("cellstyle when backToHome : \(cellStyle), searchStepState : \(searchStepState), fromOsCd : \(fromOsCd), deviceName : \(deviceName)")
        //        print("currentFolderId : \(currentFolderId)")
        //        print("folderArray : \(folderArray)")
        //        print("bottomListState : \(bottomListState)")
        
        view.removeGestureRecognizer(searchEndTapGesture)
        oneViewListView.isHidden = false
        navBarTitle.isUserInteractionEnabled = true
        for view in self.customNavBar.subviews {
            view.removeFromSuperview()
        }
        if viewState == .search && searchStepState == .all {
            cellStyle = 1
            
        }
        
        var title = "GiGA Storage"
        viewState = .home
        oneViewSortState = DbHelper.sortByEnum.none
        
        for b in btnCategories{
            b.isSelected = false
        }
        mainContentState = .oneViewList
        sBar.text = ""
        //        maintainFolder = true
        btnArrState = .end
        searchbarTextStarted = false
        showSearchCategory()
        flickView.isHidden = false
        DispatchQueue.main.async {
            self.flickContainerView.isHidden = false
            self.multiCheckBottomView.isHidden = true
            for view in self.searchListView.subviews {
                view.removeFromSuperview()
            }
            
        }
        
        
        searchListView.removeFromSuperview()
        view.bringSubview(toFront: oneViewListView)
        
        var googleOnOff = "N"
        let googleEmail = UserDefaults.standard.string(forKey: "googleEmail") ?? "nil"
        print("googleEmail : \(googleEmail)" )
        let now = Date()
        if(cellStyle == 1) {
            maintainFolder = false
            deviceName = title
            bottomListState = .oneView
            DeviceArray.removeAll()
            selectedDevUuid = ""
            //            homeViewToggleIndicator()
            containerViewController?.showIndicator()
            
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
                        NotificationCenter.default.post(name: NSNotification.Name("reloadSlideDev"), object: self)
                        title = "all Storage"
                        SetupHomeView.setupMainSearchView(View:self.searchView, sortButton:self.sortButton, sBar:self.sBar, searchDownArrowButton:self.searchDownArrowButton, parentViewContoller:self, sBarTitle: title)
                        print("setHomeView")
                        self.containerViewController?.finishLoading()
                    }
                    
                }
            }
        } else if cellStyle == 2 {
            maintainFolder = true
            if (searchStepState == .all) {
                tableView.reloadData()
                //                title = "all Storage"
                SetupHomeView.setupMainSearchView(View:searchView, sortButton:sortButton, sBar:sBar, searchDownArrowButton:searchDownArrowButton, parentViewContoller:self, sBarTitle: title)
                print("setHomeView")
                self.containerViewController?.finishLoading()
            } else {
                
                title = deviceName
                print("deviceName : \(deviceName) , selectedDevUuid : \(selectedDevUuid)")
                let folderName = ["folderName":completeFolderNameForSearchView,"deviceName":deviceName, "devUuid":selectedDevUuid]
                NotificationCenter.default.post(name: Notification.Name("setupFolderPathView"), object: self, userInfo: folderName)
                self.containerViewController?.finishLoading()
            }
        } else if cellStyle == 3 {
            //구글 드라이브
            maintainFolder = true
            deviceName = "Google Drive"
            mainContentState = .googleDriveList
            title = deviceName
            let folderName = ["folderName":"Google Drive","deviceName":"Google Drive", "devUuid":"googleDrive"]
            //            let folderName = ["folderName":completeFolderNameForSearchView,"deviceName":deviceName, "devUuid":selectedDevUuid]
            NotificationCenter.default.post(name: Notification.Name("setupFolderPathView"), object: self, userInfo: folderName)
            self.containerViewController?.finishLoading()
        }
        SetupHomeView.setupMainNavbar(View: customNavBar, navBarTitle: navBarTitle, hamburgerButton: hamburgerButton, listButton: listButton, downArrowButton: downArrowButton, title:title)
        
        
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
        print("searchStepState : \(searchStepState), id: \(searchId), bottomListyState: \(getBottomListState)")
        
    }
    
    @objc func bottomStateFromContainer(stateInfo: NSNotification){
        
        if let bottomState = stateInfo.userInfo?["bottomState"] as? String, let getFileId = stateInfo.userInfo?["fileId"] as? String, let getFoldrWholePathNm = stateInfo.userInfo?["foldrWholePathNm"] as? String, let getDeviceName = stateInfo.userInfo?["deviceName"] as? String, let getDevUuid = stateInfo.userInfo?["selectedDevUuid"] as? String, let getFileNm = stateInfo.userInfo?["fileNm"] as? String, let getUserId = stateInfo.userInfo?["userId"] as? String, let getFoldrId = stateInfo.userInfo?["foldrId"] as? String, let getFomOsCd = stateInfo.userInfo?["fromOsCd"] as? String, let getCurrentFolderId = stateInfo.userInfo?["currentFolderId"] as? String{
            
//            flickView.isHidden = true
//            flickContainerView.isHidden = true
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
//            containerViewBottomAnchor?.isActive = false
//            containerViewBottomAnchor = oneViewListView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
//            containerViewBottomAnchor?.isActive = true
            
        } else {
            print("not called")
        }
        
        if(listViewStyleState == .grid){
            if let getCellStyle = stateInfo.userInfo?["cellStyle"] as? String {
                print("getCellStyle : \(getCellStyle)")
                
                ifNavBarClicked = true
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
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
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.toggleBottomMenu(fileId: self.fileId)
                }
                let fileIdDict = ["fileId":"\(fileId)"]
//                NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self, userInfo: fileIdDict)

            }
        }
    }
    
    @IBAction func btnCategoryClicked(_ sender: UIButton) {
        let isSenderSelected = sender.isSelected
        
        for b in btnCategories{
            b.isSelected = false
        }
        
        print("sender : \(sender)")
        switch sender {
        case btnCategory1:
            
            searchGubun = "meta"
            sBar.placeholder = "#메타"
            break
        case btnCategory2:
            searchGubun = "amdDate"
            sBar.placeholder = "#최종수정일"
            break
        case btnCategory3:
            searchGubun = "emailSbjt"
            sBar.placeholder = "#이메일제목"
            break
        case btnCategory4:
            searchGubun = "emailTo"
            sBar.placeholder = "#이메일수/발신자"
            break
        default:
            break
        }
        
        if isSenderSelected {
            sender.isSelected = false
            searchGubun = ""
            var sBarPlaceHolder = "Search in all Storage"
            if bottomListState != bottomListEnum.oneView {
                sBarPlaceHolder = "Search in \(deviceName)"
            }
            sBar.placeholder = sBarPlaceHolder
        } else {
            sender.isSelected = true
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
        ifSortClicked = true
        
        
        if cellStyle == 1 {
            if (viewState == .search) {
                bottomListState = .bottomListSort
            } else {
                bottomListState = .bottomListOneViewSort
            }
        } else if cellStyle == 2 {
            bottomListState = .bottomListSort
        } else if cellStyle == 3 {
            bottomListState = .bottomGDriveListSort
        }
        
        
        DispatchQueue.main.async {
            print("btnSortClicked viewState : \(self.viewState),  bottomListState : \(self.bottomListState)")
            let fileIdDict = ["fileId":"0"]
            self.tableView.reloadData()
//            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self, userInfo: fileIdDict)
            
            self.toggleBottomMenu(fileId: "0")
        }
        
        
    }
    
    @objc func btnMulticlicked(){
        print("btnMulticlicked called, viewState : \(viewState), searchStepState: \(searchStepState), fromOsCd : \(fromOsCd)")
        var style = "nas"
        selectedAll = false
        selectAllButton.setTitleColor(HexStringToUIColor().getUIColor(hex: "4f4f4f"), for: .normal)
        selectAllButtonInSearchView.setTitleColor(HexStringToUIColor().getUIColor(hex: "4f4f4f"), for: .normal)

        if fromOsCd == "S" || fromOsCd == "G"{
            bottomListState = .bottomMultiListNas
        } else if fromOsCd == "D" {
            bottomListState = .bottomMultiListGDrive
            
        } else if selectedDevUuid != Util.getUuid() {
            style = "remote"
            bottomListState = .bottomMultiListRemote
        } else {
            bottomListState = .bottomMultiListLocal
            style = "local"
        }
        if viewState == .search {
            bottomListState = .bottomMultiListSearch
        }
        ifNavBarClicked = false
        var stringBool = "false"
        if(multiButtonChecked){
            multiButtonChecked = false
            multiButton.setImage(#imageLiteral(resourceName: "multi_off-1").withRenderingMode(.alwaysOriginal), for: .normal)
            multiButtonInSearchView.setImage(#imageLiteral(resourceName: "multi_off-1").withRenderingMode(.alwaysOriginal), for: .normal)
            if(viewState == .home) {
                containerViewBottomAnchor?.isActive = false
                containerViewBottomAnchor = oneViewListView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
                containerViewBottomAnchor?.isActive = true
                
                
                
            } else {
                searchViewBottomAnchor?.isActive = false
                searchViewBottomAnchor = searchListView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
                searchViewBottomAnchor?.isActive = true
                if fromOsCd == "D" {
                    
                    SetupSearchView.showFileCountLabel(count: self.driveFileArray.count, view:self.view, searchCountLabel:self.searchCountLabel, searchCategoryView: self.searchCategoryView, multiButton: self.multiButtonInSearchView, multiButtonChecked:self.multiButtonChecked, selectAllButton:self.selectAllButtonInSearchView)
                    
                } else {
                   
                    SetupSearchView.showFileCountLabel(count: self.SearchedFileArray.count, view:self.view, searchCountLabel:self.searchCountLabel, searchCategoryView: self.searchCategoryView, multiButton: self.multiButtonInSearchView, multiButtonChecked:self.multiButtonChecked, selectAllButton:self.selectAllButtonInSearchView)
                    
                }
            }
            
        } else {
            multiButtonChecked = true
            multiButton.setImage(#imageLiteral(resourceName: "multi_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            multiButtonInSearchView.setImage(#imageLiteral(resourceName: "multi_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            
            if(viewState == .home) {
                containerViewBottomAnchor?.isActive = false
                containerViewBottomAnchor = oneViewListView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60)
                containerViewBottomAnchor?.isActive = true
                
                
            } else {
                searchViewBottomAnchor?.isActive = false
                searchViewBottomAnchor = searchListView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60)
                searchViewBottomAnchor?.isActive = true
                
                if fromOsCd == "D" {
                    SetupSearchView.showFileCountLabel(count: self.driveFileArray.count, view:self.view, searchCountLabel:self.searchCountLabel, searchCategoryView: self.searchCategoryView, multiButton: self.multiButtonInSearchView, multiButtonChecked:self.multiButtonChecked, selectAllButton:self.selectAllButtonInSearchView)
                    
                } else {
                    
                    SetupSearchView.showFileCountLabel(count: self.SearchedFileArray.count, view:self.view, searchCountLabel:self.searchCountLabel, searchCategoryView: self.searchCategoryView, multiButton: self.multiButtonInSearchView, multiButtonChecked:self.multiButtonChecked, selectAllButton:self.selectAllButtonInSearchView)
                    
                }
                
            }
            
            
        }
        if viewState == .home {
            self.setupFileCollectionView(getFolerName: folderName, getDeviceName: deviceName, getDevUuid: selectedDevUuid)
        }
        
        setMultiCountLabel(multiButtonChecked:multiButtonChecked, count:0)
        stringBool = String(multiButtonChecked)
        print("stringBool :\(stringBool), style : \(style), cellstyle : \(cellStyle)")
//        let fileIdDict = ["multiChecked":stringBool]
//        NotificationCenter.default.post(name: Notification.Name("multiSelectActive"), object: self, userInfo: fileIdDict)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        if(viewState == .home) {
            child?.multiSelectActive(multiButtonActive: multiButtonChecked)
        } else if viewState == .search {
            child2?.multiSelectActive(multiButtonActive: multiButtonChecked)
        }
        
        
        
    }
    
    
    @objc func selectAllFile(){
    
        if folderArray.count > 0 {
            if selectedAll {
                selectedAll = false
                selectAllButton.setTitleColor(HexStringToUIColor().getUIColor(hex: "4f4f4f"), for: .normal)
                selectAllButtonInSearchView.setTitleColor(HexStringToUIColor().getUIColor(hex: "4f4f4f"), for: .normal)
            } else {
                selectedAll = true
                selectAllButton.setTitleColor(HexStringToUIColor().getUIColor(hex: "ff0000"), for: .normal)
                selectAllButtonInSearchView.setTitleColor(HexStringToUIColor().getUIColor(hex: "ff0000"), for: .normal)
            }
            
            if(viewState == .home) {
                child?.allMultiCheck(selectedAll:selectedAll)
            } else if viewState == .search {
                child2?.allMultiCheck(selectedAll:selectedAll)
                
            }
        } else {
            let alertController = UIAlertController(title: nil, message: "리스트가 없습니다.", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default)
            alertController.addAction(yesAction)
            self.present(alertController, animated: true)
        }
        
    }
    func inActiveSelectAllFile(){
        
        selectedAll = false
        selectAllButton.setTitleColor(HexStringToUIColor().getUIColor(hex: "4f4f4f"), for: .normal)
        selectAllButtonInSearchView.setTitleColor(HexStringToUIColor().getUIColor(hex: "4f4f4f"), for: .normal)
        selectAllButton.removeFromSuperview()
        selectAllButtonInSearchView.removeFromSuperview()
        
        if(viewState == .home) {
            child?.allMultiCheck(selectedAll:selectedAll)
        } else if viewState == .search {
            child2?.allMultiCheck(selectedAll:selectedAll)
            
        }
    }
    
    func setMultiCountLabel(multiButtonChecked:Bool, count:Int){
        flickView.isHidden = true
        flickContainerView.isHidden = true
        multiCheckBottomView.isHidden = false
        
        if self.view.contains(multiCheckBottomView){
            for view in multiCheckBottomView.subviews {
                view.removeFromSuperview()
            }
            multiCheckBottomView.removeFromSuperview()
        }
        
        if(multiButtonChecked){
            self.view.addSubview(multiCheckBottomView)
            self.view.bringSubview(toFront: multiCheckBottomView)
            multiCheckBottomView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            multiCheckBottomView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            multiCheckBottomView.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
            multiCheckBottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            view.bringSubview(toFront: multiCheckBottomView)
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
    
    func showBottomIndicator(){
        containerViewBottomAnchor?.isActive = false
        containerViewBottomAnchor = oneViewListView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60)
        containerViewBottomAnchor?.isActive = true
        flickView.isHidden = false
        flickContainerView.isHidden = false
    }
    
    func inActiveMultiCheck(){
        print("cellstyle : \(cellStyle)")
        multiButton.setImage(#imageLiteral(resourceName: "multi_off-1").withRenderingMode(.alwaysOriginal), for: .normal)
        multiButtonInSearchView.setImage(#imageLiteral(resourceName: "multi_off-1").withRenderingMode(.alwaysOriginal), for: .normal)
        containerViewBottomAnchor?.isActive = false
        if cellStyle == 2 || cellStyle == 3 {
            containerViewBottomAnchor = oneViewListView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        } else {
            containerViewBottomAnchor = oneViewListView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60)
        }
        
        containerViewBottomAnchor?.isActive = true
        if self.view.contains(multiCheckBottomView){
            for view in multiCheckBottomView.subviews {
                view.removeFromSuperview()
            }
            multiCheckBottomView.removeFromSuperview()
        }
        DispatchQueue.main.async {
            self.multiCheckBottomView.isHidden = true
            self.multiButtonChecked = false
            self.selectAllButton.isHidden = true
            self.selectAllButtonInSearchView.isHidden = true
            
        }
        if viewState == .home {
            child?.multiSelectActive(multiButtonActive: multiButtonChecked)
        } else {
            child2?.multiSelectActive(multiButtonActive: multiButtonChecked)
        }
    }
    
    func initMultiCheckFalseView(){
        //리스트는 안 지움
        print("initMultiCheckFalseView called")
        multiButton.setImage(#imageLiteral(resourceName: "multi_off-1").withRenderingMode(.alwaysOriginal), for: .normal)
        multiButtonInSearchView.setImage(#imageLiteral(resourceName: "multi_off-1").withRenderingMode(.alwaysOriginal), for: .normal)
        containerViewBottomAnchor?.isActive = false
        if cellStyle == 2 || cellStyle == 3 {
            containerViewBottomAnchor = oneViewListView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        } else {
            containerViewBottomAnchor = oneViewListView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60)
        }
        
        containerViewBottomAnchor?.isActive = true
        if self.view.contains(multiCheckBottomView){
            for view in multiCheckBottomView.subviews {
                view.removeFromSuperview()
            }
            multiCheckBottomView.removeFromSuperview()
        }
        DispatchQueue.main.async {
            self.multiCheckBottomView.isHidden = true
            self.multiButtonChecked = false
            self.selectAllButton.isHidden = true
            self.selectAllButtonInSearchView.isHidden = true
            
        }
        
    }
  
    @objc func multiCheckBottomViewTapped(){
        let fileIdDict = ["fileId":"0"]
        
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self, userInfo: fileIdDict)
    }
    
    
    @objc func navBarTitleClicked(){
        print("??")
        ifNavBarClicked = true
//        cellStyle = 1
        if viewState == .home {
            child?.cellStyle = self.cellStyle
        } else {
            child2?.cellStyle = self.cellStyle
        }
        
        
        
        
        let fileIdDict = ["fileId":"0"]
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
//        NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self, userInfo: fileIdDict)
        toggleBottomMenu(fileId: "0")
    }
    
 
    @objc func toggleBottomMenu(sortInfo: NSNotification) {
        tableView.scrollToRow(at: IndexPath(row:0, section:0), at: .top, animated: false)
        if let getInfo = sortInfo.userInfo?["fileId"] as? String {
            fileId = getInfo
            print("getFileId: \(fileId), bottomMenuOpen: \(bottomMenuOpen)")
        }
        print("local list count :\(bottomListLocalFileInfo.count)")
        
        if bottomMenuOpen {
            
            UIView.animate(withDuration: 0.2, animations: {
                self.tableBottomConstant.constant = -260
                self.bottomMenuOpen = false
                self.view.layoutIfNeeded()
//                print("animation duration")
            }, completion:{
                (finished: Bool) in
//                print("animation finished")
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
//                print("animation duration")
            }, completion:{
                (finished: Bool) in
//                print("animation finished")
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
    
    func toggleBottomMenu(fileId: String) {
        
        self.fileId = fileId
        tableView.scrollToRow(at: IndexPath(row:0, section:0), at: .top, animated: false)
//        print("local list count :\(bottomListLocalFileInfo.count)")
        print("local list count :\(bottomListLocalFileInfo.count)")
        if bottomMenuOpen {
            UIView.animate(withDuration: 0.2, animations: {
                self.tableBottomConstant.constant = -260
                self.bottomMenuOpen = false
                self.view.layoutIfNeeded()
                //                print("animation duration")
            }, completion:{
                (finished: Bool) in
                //                print("animation finished")
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
                //                print("animation duration")
            }, completion:{
                (finished: Bool) in
                //                print("animation finished")
                DispatchQueue.main.async {
                    //                print("backgroundview add")
                    self.view.addSubview(self.backgroundView)
                    self.backgroundView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
                    self.backgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
                    self.backgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
                    self.backgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
                    self.view.bringSubview(toFront: self.tableView)
                    
                }
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
        print("maintainFolder : \(maintainFolder), cellStyle : \(cellStyle), viewState : \(viewState), searchStepState : \(searchStepState)")
//        print("folderarray count : \(folderArray.count), cellStyle : \(self.cellStyle)")
        switch (listViewStyleState) {
        case .grid:
            listViewStyleState = .list
            containerViewController?.listViewStyleState = .list
            listButton.setImage(#imageLiteral(resourceName: "card_view").withRenderingMode(.alwaysOriginal), for: .normal)
            let defaults = UserDefaults.standard
            defaults.set("list", forKey: "listViewStyleState")
            if(viewState == .home) {
                if(maintainFolder){
//                    let fileDict = ["style":"list", "cellStyle":"\(self.cellStyle)"]
                    child?.changeListStyle2(getStyle : "list", getCellStyle : self.cellStyle)
//                    NotificationCenter.default.post(name: Notification.Name("changeListStyle"), object: self, userInfo: fileDict)
                    child2?.changeListStyle2(getStyle : "list", getCellStyle : self.cellStyle)
                    self.setupFileCollectionView(getFolerName: folderName, getDeviceName: deviceName, getDevUuid: selectedDevUuid)
                } else {
//                    setupDeviceListView(sortBy: oneViewSortState, multiCheckd: multiButtonChecked)
                    let fileDict = ["style":"list", "cellStyle":"\(self.cellStyle)"]
//                    NotificationCenter.default.post(name: Notification.Name("changeListStyle"), object: self, userInfo: fileDict)
                    child?.changeListStyle2(getStyle : "list", getCellStyle : self.cellStyle)
                    child2?.changeListStyle2(getStyle : "list", getCellStyle : self.cellStyle)
                    
                    
                }
                inActiveMultiCheck()
                if(selectedAll){
                    selectAllFile()
                }
//                backToHome()
            } else {
                // searchview
//                searchInAllCategory(sortBy: sortBy, searchGubun: searchGubun, selectedDevUuid: selectedDevUuid, searchedText: searchedText, foldrWholePathNm: foldrWholePathNm)
//                print("list style to list change in searchview")
//                let fileDict = ["style":"list", "cellStyle":"\(self.cellStyle)"]
                child?.changeListStyle2(getStyle : "list", getCellStyle : self.cellStyle)
                child2?.changeListStyle2(getStyle : "list", getCellStyle : self.cellStyle)
//                NotificationCenter.default.post(name: Notification.Name("changeListStyle"), object: self, userInfo: fileDict)
            }
            
            break
        case (.list):
            listViewStyleState = .grid
            containerViewController?.listViewStyleState = .grid
            listButton.setImage(#imageLiteral(resourceName: "list_view").withRenderingMode(.alwaysOriginal), for: .normal)
            let defaults = UserDefaults.standard
            defaults.set("grid", forKey: "listViewStyleState")
            
            //            if(mainContentState == .oneViewList){
            
            if(viewState == .home) {
                //homeview
                if(maintainFolder){
//                    let fileDict = ["style":"grid", "cellStyle":"\(self.cellStyle)"]
                    
//                    NotificationCenter.default.post(name: Notification.Name("changeListStyle"), object: self, userInfo: fileDict)
                    setupFileCollectionView(getFolerName: folderName, getDeviceName: deviceName, getDevUuid: selectedDevUuid)
                    child?.changeListStyle2(getStyle : "grid", getCellStyle : self.cellStyle)
                    child2?.changeListStyle2(getStyle : "grid", getCellStyle : self.cellStyle)
                    
                } else {
//                    setupDeviceListView(sortBy: oneViewSortState, multiCheckd: multiButtonChecked)
//                    let fileDict = ["style":"grid", "cellStyle":"\(self.cellStyle)"]
//                    NotificationCenter.default.post(name: Notification.Name("changeListStyle"), object: self, userInfo: fileDict)
                    child?.changeListStyle2(getStyle : "grid", getCellStyle : self.cellStyle)
                    child2?.changeListStyle2(getStyle : "grid", getCellStyle : self.cellStyle)
                }
                inActiveMultiCheck()
                if(selectedAll){
                    selectAllFile()
                }
//                backToHome()
            } else {
                // searchview
//                searchInAllCategory(sortBy: sortBy, searchGubun: searchGubun, selectedDevUuid: selectedDevUuid, searchedText: searchedText, foldrWholePathNm: foldrWholePathNm)
//                print("list style to grid change in searchview")
//                let fileDict = ["style":"grid", "cellStyle":"\(self.cellStyle)"]
                child2?.changeListStyle2(getStyle : "grid", getCellStyle : self.cellStyle)
                child?.changeListStyle2(getStyle : "grid", getCellStyle : self.cellStyle)
//                NotificationCenter.default.post(name: Notification.Name("changeListStyle"), object: self, userInfo: fileDict)
            }
            
            
            break
            
        }
        
    }
    
    @IBAction func btnFlick1Clicked(_ sender: UIButton) {
        
    }
    
    @IBAction func btnFlick2Clicked(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("removeOneView"), object: self)
    }
    
    @objc func flickContainerViewSwipedLeft() {
        print("flickContainerViewSwipedLeft")
        NotificationCenter.default.post(name: Notification.Name("removeOneView"), object: self)
    }
   

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  
        if(ifNavBarClicked){
            print("DeviceArray.count : \(DeviceArray.count)")
            return DeviceArray.count + 1
        } else {
            if(viewState == .home) {
                switch bottomListState {
                case .nasFileInfo:
                    return bottomListFileInfo.count
                case .localFileInfo:
                    return bottomListLocalFileInfo.count
                    
                case .remoteFileInfo:
                    return bottomListRemoteFileInfo.count
                case .bottomListSort:
                    return bottomListSort.count
                case .bottomListOneViewSort:
                    return bottomListOneViewSort.count
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
                case .bottomMultiListSearch:
                    return bottomMultiListSearch.count
                case .bottomGDriveListSort:
                    return bottomListSort.count
                }
            } else {
                
                if (bottomListState == .bottomListSort) {
                    return bottomListSort.count
                } else {
                    if (multiButtonChecked){
                        return bottomMultiListSearch.count
                    } else {
                        switch bottomListState {
                        case .nasFileInfo:
                            return bottomListFileInfo.count
                        case .localFileInfo:
                            return bottomListLocalFileInfo.count
                            
                        case .remoteFileInfo:
                            return bottomListRemoteFileInfo.count
                        case .bottomListSort:
                            return bottomListSort.count
                        case .bottomListOneViewSort:
                            return bottomListOneViewSort.count
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
                        case .bottomMultiListSearch:
                            return bottomMultiListSearch.count
                        case .bottomGDriveListSort:
                            return bottomListSort.count
                        }
                    }
                    
                }
                
            }
        }
    }
    
  
    
  
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeBottomCell") as! HomeBottomListCell
        let clearView = UIView()
        clearView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = clearView
//        print("ifNavBarClicked when slected : \(ifNavBarClicked)")
        if(ifNavBarClicked){
            cell.ivIcon.isHidden = false
            if(indexPath.row == 0){
                cell.lblTitle.text = "홈으로"
                cell.ivIcon.image = UIImage(named: "ico_home_r")
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
//            print("tableview bottomstate : \(bottomListState)")
            cell.lblTitle.textColor = HexStringToUIColor().getUIColor(hex: "4F4F4F")
            
                if bottomListState == .bottomListSort {
                    cell.ivIcon.isHidden = true
                    cell.lblTitle.text = bottomListSort[indexPath.row]
                    
                } else if bottomListState == .bottomListOneViewSort {
                    cell.ivIcon.isHidden = true
                    cell.lblTitle.text = bottomListOneViewSort[indexPath.row]
                } else {
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
                        case .bottomListSort:
                            cell.ivIcon.isHidden = true
                            cell.lblTitle.text = bottomListSort[indexPath.row]
                            break
                            
                        case .bottomListOneViewSort:
                            cell.ivIcon.isHidden = true
                            cell.lblTitle.text = bottomListOneViewSort[indexPath.row]
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
                            break
                        case .bottomMultiListLocal:
                            cell.ivIcon.isHidden = false
                            let imageString = Util.getContextImageString(context: bottomMultiListLocal[indexPath.row])
                            cell.ivIcon.image = UIImage(named: imageString)
                            cell.lblTitle.text = bottomMultiListLocal[indexPath.row]
                            break
                        case .googleDrive:
                            let imageString = Util.getContextImageString(context: bottomGoogleDrive[indexPath.row])
                            cell.ivIcon.image = UIImage(named: imageString)
                            cell.lblTitle.text = bottomGoogleDrive[indexPath.row]
                            break
                        case .bottomMultiListGDrive:
                            let imageString = Util.getContextImageString(context: bottomMultiListGDrive[indexPath.row])
                            cell.ivIcon.image = UIImage(named: imageString)
                            cell.lblTitle.text = bottomMultiListGDrive[indexPath.row]
                            break
                        case .bottomMultiListSearch:
                            let imageString = Util.getContextImageString(context: bottomMultiListSearch[indexPath.row])
                            cell.ivIcon.image = UIImage(named: imageString)
                            cell.lblTitle.text = bottomMultiListSearch[indexPath.row]
                            break
                        
                        case .bottomGDriveListSort:
                            cell.ivIcon.isHidden = true
                            cell.lblTitle.text = bottomListSort[indexPath.row]
                            break
                    }
                    
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
        //        print(indexPath.section)
        //        print(indexPath.row)
        print("fromOsCd : \(fromOsCd), viewState : \(self.viewState), ifNavBarClicked : \(ifNavBarClicked), flickState : \(flickState)")
        if(ifNavBarClicked){
            if viewState == .home {
                
                if(indexPath.row == 0){
                    //                        print("back to main")
                    cellStyle = 1
                    child?.cellStyle = 1
                    NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
                    self.flickView.isHidden = false
                    flickContainerView.isHidden = false
                    self.mainContentState = .oneViewList
                    self.multiCheckBottomView.isHidden = true
                    
                    backToHome()
                    
                    
                } else {
                    NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
                    self.flickView.isHidden = true
                    flickContainerView.isHidden = true
                    let indexPathRow = ["indexPathRow":"\(indexPath.row-1)"]
                    self.multiButtonChecked = false
                    self.selectedAll = false
                    self.child?.multiCheckListState = .inActive
                    self.child?.selectAllCheck = false
                    multiButton.setImage(#imageLiteral(resourceName: "multi_off-1").withRenderingMode(.alwaysOriginal), for: .normal)
                    self.multiCheckBottomView.isHidden = true
                    if let homeChild = child {
                        let sendIndex = indexPath.row - 1
                        homeChild.clickDeviceItem2(indexPathRow: indexPath.row - 1)
                    }
                    
                }
            } else {
                if(ifNavBarClicked){
                    
                    
                    if(indexPath.row == 0){
                        print("back to main")
                        NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
                        self.flickView.isHidden = false
                        flickContainerView.isHidden = false
                        self.mainContentState = .oneViewList
                        backToHome()
                    } else {
                        self.multiButtonChecked = false
                        self.selectedAll = false
                        self.child?.multiCheckListState = .inActive
                        self.child?.selectAllCheck = false
                        multiButtonInSearchView.setImage(#imageLiteral(resourceName: "multi_off-1").withRenderingMode(.alwaysOriginal), for: .normal)
                        self.multiCheckBottomView.isHidden = true
                        NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
                        self.flickView.isHidden = true
                        flickContainerView.isHidden = true
                        let indexPathRow = ["indexPathRow":"\(indexPath.row-1)"]
                        child?.clickDeviceItem2(indexPathRow: indexPath.row-1)
                        
                    }
                }
            }
            
        } else {
            switch bottomListState {
            case .bottomListOneViewSort:
                
                self.toggleBottomMenu(fileId: "0")
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                    self.oneViewSortState = self.bottomListOneViewSortKey[indexPath.row]
                    self.setupDeviceListView(sortBy: self.oneViewSortState, gDriveSortBy: self.gDriveSortState, multiCheckd: self.multiButtonChecked)
                    
                }
                
                break
            case .bottomListSort:
                if(viewState == .search){
                    NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
                    searchedText = sBar.text!
                    if searchedText.count >= 2 {
                        sortBy = bottomListSortKey[indexPath.row]
                        searchInAllCategory(sortBy: sortBy, searchGubun: searchGubun, selectedDevUuid: selectedDevUuid, searchedText: searchedText, foldrWholePathNm: foldrWholePathNm)
                    } else {
                        let alertController = UIAlertController(title: nil, message: "2자 이상의 검색어를 입력해주세요.", preferredStyle: .alert)
                        let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default)
                        alertController.addAction(yesAction)
                        self.present(alertController, animated: true)
                    }
                } else {
                    NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
                    let sortState = ["sortState":"\(bottomListSortKey[indexPath.row])"]
                    NotificationCenter.default.post(name: Notification.Name("sortFolderList"), object: self, userInfo: sortState)
                }
                break
            case .nasFileInfo:
                NasFileCellController().nasFileContextMenuCalledFromGrid(indexPath: indexPath, fileId: fileId, foldrWholePathNm: foldrWholePathNm, deviceName: deviceName, parentView: "deviceView", deviceView: self, userId: selectedDevUserId, fromOsCd: fromOsCd, currentFolderId: currentFolderId, folderArray:folderArray, intFolderArrayIndexPathRow: intFolderArrayIndexPathRow, containerView:containerViewController!)
                break
                
            case .localFileInfo:
                //                print("localFileInfo folderArray : \(folderArray), indexpathrow : \(intFolderArrayIndexPathRow)")
                LocalFileListCellController().localContextMenuCalledFromGrid(indexPath: indexPath, fileId: fileId, foldrWholePathNm: foldrWholePathNm, deviceName: deviceName, parentView: "deviceView", deviceView: self, userId: selectedDevUserId, fromOsCd: fromOsCd, currentFolderId: currentFolderId, folderArray:folderArray, intFolderArrayIndexPathRow: intFolderArrayIndexPathRow, containerView:containerViewController!)
                break
            case .remoteFileInfo:
                
                RemoteFileListCellController().remoteFileContextMenuCalledFromGrid(indexPath: indexPath, fileId: fileId, foldrWholePathNm: foldrWholePathNm, deviceName: deviceName, parentView: "deviceView", deviceView: self, userId: selectedDevUserId, fromOsCd: fromOsCd, currentDevUuid: currentDevUuid, currentFolderId: currentFolderId, folderArray:folderArray, intFolderArrayIndexPathRow: intFolderArrayIndexPathRow)
                break
                
                
            case .oneView:
                NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
                oneViewSortState = bottomListOneViewSortKey[indexPath.row]
                setupDeviceListView(sortBy: oneViewSortState, gDriveSortBy: gDriveSortState, multiCheckd: multiButtonChecked)
                
                break
            case .googleDrive:
                GDriveFileListCellController().ContextMenuCalledFromGrid(indexPath: indexPath, fileId: fileId, foldrWholePathNm: foldrWholePathNm, deviceName: "Google Drive", parentView: "deviceView", deviceView: self, userId: selectedDevUserId, fromOsCd: fromOsCd, currentDevUuid: currentDevUuid, currentFolderId: currentFolderId, folderArray:driveFileArray, intFolderArrayIndexPathRow: intFolderArrayIndexPathRow, containerView:containerViewController!)
                
                break
            case .bottomMultiListNas:
                
                NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
                
                
                switch indexPath.row {
                case 0 :
                    let fileDict = ["action":"download","fromOsCd":fromOsCd]
                    child?.handleMultiCheckFolderArray(fileDict: fileDict)
                    //                        NotificationCenter.default.post(name: Notification.Name("handleMultiCheckFolderArray"), object: self, userInfo:fileDict)
                    //                        inActiveMultiCheck()
                    break
                case 1 :
                    let fileDict = ["action":"nas","fromOsCd":fromOsCd]
                    child?.handleMultiCheckFolderArray(fileDict: fileDict)
                    //                        NotificationCenter.default.post(name: Notification.Name("handleMultiCheckFolderArray"), object: self, userInfo:fileDict)
//                    inActiveMultiCheck()
                    
                    break
                case 2 :
                    let fileDict = ["action":"gDrive","fromOsCd":fromOsCd]
                    child?.handleMultiCheckFolderArray(fileDict: fileDict)
                    //                        NotificationCenter.default.post(name: Notification.Name("handleMultiCheckFolderArray"), object: self, userInfo:fileDict)
                    //                        inActiveMultiCheck()
                    break
                case 3 :
                    let fileDict = ["action":"delete","fromOsCd":fromOsCd]
                    child?.handleMultiCheckFolderArray(fileDict: fileDict)
                    //                        NotificationCenter.default.post(name: Notification.Name("handleMultiCheckFolderArray"), object: self, userInfo:fileDict)
                    //                        inActiveMultiCheck()
                    break
                    
                default :
                    break
                }
                
                break
            case .bottomMultiListRemote:
                
                switch indexPath.row {
                case 0 :
                    let fileDict = ["action":"download","fromOsCd":fromOsCd]
                    child?.handleMultiCheckFolderArray(fileDict: fileDict)
                    //                        NotificationCenter.default.post(name: Notification.Name("handleMultiCheckFolderArray"), object: self, userInfo:fileDict)
                    break
                case 1 :
                    let fileDict = ["action":"nas","fromOsCd":fromOsCd]
                    child?.handleMultiCheckFolderArray(fileDict: fileDict)
                    //                        NotificationCenter.default.post(name: Notification.Name("handleMultiCheckFolderArray"), object: self, userInfo:fileDict)
                    break
                default:
                    
                    break
                    
                }
                break
            case .bottomMultiListLocal:
                
                NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
                
                switch indexPath.row {
                case 0 :
                    let fileDict = ["action":"nas","fromOsCd":fromOsCd]
                    child?.handleMultiCheckFolderArray(fileDict: fileDict)
                    //                        NotificationCenter.default.post(name: Notification.Name("handleMultiCheckFolderArray"), object: self, userInfo:fileDict)
                    break
                case 1 :
                    let fileDict = ["action":"gDrive","fromOsCd":fromOsCd]
                    child?.handleMultiCheckFolderArray(fileDict: fileDict)
                    //                        NotificationCenter.default.post(name: Notification.Name("handleMultiCheckFolderArray"), object: self, userInfo:fileDict)
                    break
                case 2 :
                    let fileDict = ["action":"delete","fromOsCd":fromOsCd]
                    child?.handleMultiCheckFolderArray(fileDict: fileDict)
                    //                        NotificationCenter.default.post(name: Notification.Name("handleMultiCheckFolderArray"), object: self, userInfo:fileDict)
                    break
                    
                default :
                    break
                }
                
            case .bottomMultiListGDrive:
                NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
                
                switch indexPath.row {
                case 0 :
                    let fileDict = ["action":"download","fromOsCd":fromOsCd]
                    child?.handleMultiCheckFolderArray(fileDict: fileDict)
                    //                        NotificationCenter.default.post(name: Notification.Name("handleMultiCheckFolderArray"), object: self, userInfo:fileDict)
                    break
                case 1 :
                    let fileDict = ["action":"nas","fromOsCd":fromOsCd]
                    child?.handleMultiCheckFolderArray(fileDict: fileDict)
                    //                        NotificationCenter.default.post(name: Notification.Name("handleMultiCheckFolderArray"), object: self, userInfo:fileDict)
                    break
                case 2 :
                    let fileDict = ["action":"delete","fromOsCd":fromOsCd]
                    child?.handleMultiCheckFolderArray(fileDict: fileDict)
                    //                        NotificationCenter.default.post(name: Notification.Name("handleMultiCheckFolderArray"), object: self, userInfo:fileDict)
                    break
                default:
                    break
                }
            case .bottomMultiListSearch:
                if (indexPath.row == 0){
                    print("fromOsCd : \(fromOsCd)")
                    let fileDict = ["action":"nas","fromOsCd":fromOsCd]
                    if (viewState == .search) {
                        child2?.handleMultiCheckFolderArray(fileDict: fileDict)
                    } else {
                        child?.handleMultiCheckFolderArray(fileDict: fileDict)
                    }
                    
                    
                    
                }
                break
            case .bottomGDriveListSort:
                NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
                
                gDriveSortState = bottomListGdriveSortKey[indexPath.row]
                let sortState = ["sortState":"\(bottomListGdriveSortKey[indexPath.row])"]
                NotificationCenter.default.post(name: Notification.Name("sortFolderList"), object: self, userInfo: sortState)
                break
            }
        }
    }
 
   
    
  
    @objc func setupFolderPathView(folderName: NSNotification){
        
        if let getInfo = folderName.userInfo?["folderName"] as? String, let getDeviceName = folderName.userInfo?["deviceName"] as? String, let getDevUuid = folderName.userInfo?["devUuid"] as? String  {
            self.deviceName = getDeviceName
            self.folderName = getInfo
            self.selectedDevUuid = getDevUuid
            maintainFolder = true
            print("getInfo : \(getInfo), getDeviceName : \(getDeviceName), getDevUuid : \(getDevUuid)")
            DispatchQueue.main.async {
                self.setupFileCollectionView(getFolerName: getInfo, getDeviceName:getDeviceName, getDevUuid:getDevUuid)
                self.containerViewBottomAnchor?.isActive = false
                print("setupFolderPathView cellStyle : \(self.cellStyle)")
                if self.cellStyle == 2 || self.cellStyle == 3 {
                    self.containerViewBottomAnchor = self.oneViewListView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
                } else {
                    self.containerViewBottomAnchor = self.oneViewListView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -60)
                }
                self.containerViewBottomAnchor?.isActive = true
                print("setupFolderPathView called finish")
            }

        }
    }
    
    func setupFileCollectionView(getFolerName:String, getDeviceName:String, getDevUuid:String){
        
       SetupFolderInsideCollectionView.searchView(searchView: searchView, searchButton: searchButton, sortButton: sortButton, customNavBar: customNavBar, hamburgerButton: hamburgerButton, listButton: listButton, multiButton:multiButton,navBarTitle: navBarTitle, getFolerName: getFolerName, getDeviceName: getDeviceName, listStyle: listViewStyleState, getDevUuid:getDevUuid, localRefreshButton:localRefreshButton, multiButtonChecked:multiButtonChecked, selectAllButton:selectAllButton, lblSubNav:lblSubNav, downArrowButton:downArrowButton)
        
        
    }
    
    @objc func searchButtonInFileViewClicked(){
        print("searchbarTextStarted : \(searchbarTextStarted)")
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
        inActiveMultiCheck()
        inActiveSelectAllFile()
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        
    }
   
    @objc func refreshButtonClicked(){
        let syncOngoing:Bool = UserDefaults.standard.bool(forKey: "syncOngoing")
        if syncOngoing == true {
            print("aleady Syncing")
        } else {
            containerViewController?.activityIndicator.startAnimating()
            SyncLocalFilleToNas().sync(view: "home", getFoldrId:currentFolderId)
            
        }
    }
   
    @objc func setGoogleDriveFileListView(cellStyle: NSNotification){
        
        self.mainContentState = .googleDriveList
        self.searchStepState = .device
        for view in self.customNavBar.subviews {
            view.removeFromSuperview()
        }
        SetupHomeView.setupMainNavbar(View: customNavBar, navBarTitle: navBarTitle, hamburgerButton: hamburgerButton, listButton: listButton, downArrowButton: downArrowButton, title:"Google Drive")
        
        
        // 0eun - start
        if let getInfo = cellStyle.userInfo?["cellStyle"] as? Int {
            self.cellStyle = getInfo
        }
        // 0eun - end
//        print("setGoogleDriveFileListView cellStyle : \(cellStyle)")
        self.cellStyle = 3
        child?.cellStyle = 3
//        flickView.isHidden = true // 추가
//        flickContainerView.isHidden = true
//        let fileDict = ["foldrId":"root"]
//        NotificationCenter.default.post(name: Notification.Name("refreshInsideList"), object: self, userInfo :fileDict)
        
        self.setupDeviceListView(sortBy: self.oneViewSortState, gDriveSortBy: gDriveSortState, multiCheckd: multiButtonChecked)
    }
    
    func downloadFromNas(name:String, path:String, fileId:String){
        self.containerViewController?.showIndicator()
        contextMenuWork?.downloadFromNas(userId:selectedDevUserId, fileNm:name, path:path, fileId:fileId){ responseObject, error in
            if (error == nil){
                if let success = responseObject {
                    print(success)
                    if(success == "success"){
                        DispatchQueue.main.async {
                            self.containerViewController?.finishLoading()
                            let alertController = UIAlertController(title: nil, message: "파일 다운로드를 성공하였습니다.", preferredStyle: .alert)
                            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default){
                                UIAlertAction in
                                print("download from nas finish")
                                if let syncOngoing:Bool = UserDefaults.standard.bool(forKey: "syncOngoing"), syncOngoing == true {
                                    print("aleady Syncing")
                                } else {
                                    SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
                                }
                            }
                            alertController.addAction(yesAction)
                            self.present(alertController, animated: true)
                        }
                        
                        
                    } else {
                        
                        self.containerViewController?.finishLoading()
                        let fileIdDict = ["fileId":"0"]
                        NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self, userInfo: fileIdDict)
                        self.containerViewController?.showErrorAlert()
                    }
                    
                }
            } else {
                self.containerViewController?.showErrorAlert()
            }
           
            return
        }
    }
    
    
    
    
    func deleteNasFile(param:[String:Any], foldrId:String){
        print(param)
        containerViewController?.showIndicator()
        ContextMenuWork().deleteNasFile(parameters:param){ responseObject, error in
            if let obj = responseObject {
                print(obj)
                let json = JSON(obj)
//                let message = obj.object(forKey: "message")
//                print("\(message), \(json["statusCode"].int)")
                if error == nil {
                    if let statusCode = json["statusCode"].int, statusCode == 100 {
                        DispatchQueue.main.async {
                            self.containerViewController?.finishLoading()
                            
                            if self.viewState == .home {
                                let fileDict = ["foldrId":self.currentFolderId]
                                NotificationCenter.default.post(name: Notification.Name("refreshInsideList"), object: self, userInfo :fileDict)
                            } else {
                                self.refershSearchList()
                            }
                            
                            let alertController = UIAlertController(title: nil, message: "파일 삭제가 완료 되었습니다.", preferredStyle: .alert)
                            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel)
                            
                            let fileIdDict = ["fileId":"0"]
                            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self, userInfo: fileIdDict)
                            
                            
                            alertController.addAction(yesAction)
                            self.present(alertController, animated: true)
                        }
                    } else {
                        self.containerViewController?.finishLoading()
                        self.containerViewController?.showErrorAlert()
                        
                    }
                } else {
                    self.containerViewController?.finishLoading()
                    self.containerViewController?.showErrorAlert()
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
    
    
   
    override func viewWillAppear(_ animated: Bool) {
      
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



