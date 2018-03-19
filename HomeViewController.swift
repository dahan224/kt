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

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIDocumentInteractionControllerDelegate{
    
    var documentController:UIDocumentInteractionController = UIDocumentInteractionController()
    
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
        case oneView = "oneView"
    }
    
    var ifNavBarClicked = false
    
    var bottomListState:bottomListEnum = bottomListEnum.oneView
    var bottomListSort = ["날짜순-최신 항목 우선", "날짜순-오래된 항목 우선","이름순-ㄱ우선","이름순-ㅎ우선","종류순"]
    var bottomListSortKey = ["new", "old","asc","desc","kind"]
    
    
    var bottomListLocalFileInfo = ["속성보기", "앱 실행", "GiGA NAS로 보내기", "Google Drive로 보내기", "삭제"]
    var bottomListFileInfo = ["속성보기", "다운로드", "GiGA NAS로 보내기", "Google Drive로 보내기", "삭제"]
    var bottomListRemoteFileInfo = ["속성보기", "다운로드", "GiGA NAS로 보내기"]
    
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
    
    enum listViewStyleEnum {
        case grid
        case list
    }
    var listViewStyleState = listViewStyleEnum.list
    
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
    
    @IBOutlet weak var filckView: UIStackView!
    
    
    
    @IBOutlet weak var containerViewA: UIView!
    @IBOutlet weak var containerViewABottomConstraint: NSLayoutConstraint!
    
    
    
    
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
        button.setImage(#imageLiteral(resourceName: "multi_off").withRenderingMode(.alwaysOriginal), for: .normal)
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
    var foldrId = ""
    var fileNm = ""
    var searchbarTextStarted = false
    var DeviceArray:[App.DeviceStruct] = []
    var SearchedFileArray:[App.SearchedFileStruct] = []
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
       
        
        
        
        btnCategories  = [btnCategory1, btnCategory2, btnCategory3, btnCategory4]
        for b in btnCategories{
            b.setTitleColor(HexStringToUIColor().getUIColor(hex: "ff0000"), for: .selected)
           
        }
        loginCookie = UserDefaults.standard.string(forKey: "cookie")!
        loginToken = UserDefaults.standard.string(forKey: "token")!
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
        
        setHomeView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
    }
    
    func setHomeView(){
        bottomListState = .oneView
        viewState = .home
        searchStepState = .all
        mainContentState = .oneViewList
        for view in self.customNavBar.subviews {
            view.removeFromSuperview()
        }
        SetupHomeView.setupMainNavbar(View: customNavBar, navBarTitle: navBarTitle, hamburgerButton: hamburgerButton, listButton: listButton, downArrowButton: downArrowButton)
        
        
        
        for view in self.searchView.subviews {
            view.removeFromSuperview()
        }
        SetupHomeView.setupMainSearchView(View:searchView, sortButton:sortButton, sBar:sBar, searchDownArrowButton:searchDownArrowButton, parentViewContoller:self)
        print("setHomeView")
        
        oneViewSortState = DbHelper.sortByEnum.none
        
        self.setupDeviceListView(container: self.containerViewA, sortBy: oneViewSortState,multiCheckd: multiButtonChecked)
    }
    
  
    func setupDeviceListView(container: UIView, sortBy: DbHelper.sortByEnum, multiCheckd:Bool){
        let previous = self.childViewControllers.first
        if let previous = previous {
            previous.willMove(toParentViewController: nil)
            previous.view.removeFromSuperview()
            previous.removeFromParentViewController()
        }
        let child = storyboard!.instantiateViewController(withIdentifier: "HomeDeviceCollectionVC") as! HomeDeviceCollectionVC
        self.DeviceArray = DbHelper().listSqlite(sortBy: sortBy)
        self.driveFileArray = DbHelper().googleDrivelistSqlite(sortBy: sortBy)
//        print("table deviceList: \(DeviceArray)")
        
        
        child.DeviceArray = self.DeviceArray
        child.listViewStyleState = self.listViewStyleState
        child.mainContentState = self.mainContentState
        child.flickState = self.flickState
        child.LatelyUpdatedFileArray = self.LatelyUpdatedFileArray
        child.driveFileArray = self.driveFileArray
        
        // 0eun - start
        if self.mainContentState == .googleDriveList {
            child.cellStyle = self.cellStyle
        }
        // 0eun - end
        
        self.willMove(toParentViewController: nil)
        child.willMove(toParentViewController: parent)
        self.addChildViewController(child)
        container.addSubview(child.view)
        child.didMove(toParentViewController: parent)
        
        let w = container.frame.size.width;
        let h = container.frame.size.height;
        child.view.frame = CGRect(x: 0, y: 0, width: w, height: h)
        
        print("containerA setting called")
        
    }
    
    
    @objc func hideKeyboard() {
        view.endEditing(true)
        
      
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedText = searchText
        print("search text : \(searchText)")
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("begin")
        
        if(!searchbarTextStarted){
            setSearchView(title: "GiGA Storage")
            searchbarTextStarted = true
        }
        
        
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        sBar.becomeFirstResponder()
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("end")
        view.removeGestureRecognizer(tapGesture)
        sBar.resignFirstResponder()
    }
    
    func setSearchView(title:String){
        viewState = .search
       
        
        for view in self.customNavBar.subviews {
            view.removeFromSuperview()
        }
        
        SetupSearchView.setupSearchNavbar(View: customNavBar, navBarTitle: navBarTitle, backBUtton: backButton, title:title)
        for view in self.searchView.subviews {
            view.removeFromSuperview()
        }
        SetupHomeView.setupMainSearchView(View:searchView, sortButton:sortButton, sBar:sBar, searchDownArrowButton:searchDownArrowButton, parentViewContoller:self)
        
        showSearchCategory()
        SetupSearchView.showFileCountLabel(count:0, view:self.view, searchCountLabel:searchCountLabel, searchCategoryView: searchCategoryView)
        

    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("검색 : \(searchBar.text!)")
        searchedText = searchBar.text!
        searchInAllCategory()
    }
    
    func searchInAllCategory(){
        activityIndicator.startAnimating()
        SearchedFileArray.removeAll()
        SearchFileList().searchFile(searchKeyword: searchedText, searchStep: searchStepState, searchId: searchId, foldrWholePathNm: foldrWholePathNm, sortBy:sortBy, searchGubun:searchGubun){ responseObject, error in
            let json = JSON(responseObject!)
            if let statusCode = json["statusCode"].int, statusCode == 100 {
                let serverList:[AnyObject] = json["listData"].arrayObject! as [AnyObject]
                for file in serverList {
                    let fileStruct = App.SearchedFileStruct(data: file)
                    let fileId = fileStruct.fileId
                    if(fileId.isEmpty || fileId == "nil"){
                    } else {
                        self.SearchedFileArray.append(fileStruct)
                    }
                    
                }
                print("file count : \(self.SearchedFileArray.count)")
                SetupSearchView.showFileCountLabel(count: self.SearchedFileArray.count, view:self.view, searchCountLabel:self.searchCountLabel, searchCategoryView: self.searchCategoryView)
                self.setSearchFileCollectionView()
                self.activityIndicator.stopAnimating()
            }
            return
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
    

    
    func setSearchFileCollectionView(){
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        self.view.addSubview(listContainerView)
        listContainerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        listContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        listContainerView.topAnchor.constraint(equalTo: searchCountLabel.bottomAnchor, constant: 10).isActive = true
        listContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        var cellWidth = (width - 35) / 2
        var height = cellWidth
        var minimumSpacing:CGFloat = 5
        switch listViewStyleState {
        case .grid:
            
            break
        case .list:
            cellWidth = width
            height = 80.0
            minimumSpacing = 10
            break
        }
        layout.sectionInset = UIEdgeInsets(top: 5, left: 15, bottom: 0, right: 15)
        layout.itemSize = CGSize(width: cellWidth, height: height )
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = minimumSpacing
        collectionView = UICollectionView(frame: listContainerView.frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = HexStringToUIColor().getUIColor(hex: "F5F5F5")
        collectionView.register(CollectionViewGridCell.self, forCellWithReuseIdentifier: "fileCell1")
        collectionView.register(FileListCell.self, forCellWithReuseIdentifier: "fileCell2")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        listContainerView.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: listContainerView.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: listContainerView.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: listContainerView.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: listContainerView.trailingAnchor).isActive = true
        collectionView.centerXAnchor.constraint(equalTo: listContainerView.centerXAnchor).isActive = true
        collectionView.reloadData()
        
        self.view.bringSubview(toFront: tableView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SearchedFileArray.count
    }
    
    func fileListCellController(indexPathRow:Int) -> FileListCell {
        let indexPath = IndexPath(row: indexPathRow, section: 0)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "fileCell2", for: indexPath) as! FileListCell
        cell.btnOption.isHidden = false
        cell.btnMultiCheck.isHidden = true
      
        let imageString = Util.getFileImageString(fileExtension: SearchedFileArray[indexPath.row].etsionNm)
        
        cell.ivSub.image = UIImage(named: imageString)
        cell.lblMain.text = SearchedFileArray[indexPath.row].fileNm
        cell.lblSub.text = SearchedFileArray[indexPath.row].amdDate
        cell.optionSHowCheck = 0
        cell.optionHide()
        let devId = SearchedFileArray[indexPath.row].devUuid
        if(devId == Util.getUuid()){
            cell.btnOption.tag = indexPath.row
            cell.btnOption.addTarget(self, action: #selector(btnOptionLocalClicked(sender:)), for: .touchUpInside)
            cell.btnOptionRed.tag = indexPath.row
            cell.btnOptionRed.addTarget(self, action: #selector(btnOptionLocalClicked(sender:)), for: .touchUpInside)
            
        } else {
            cell.btnOption.tag = indexPath.row
            cell.btnOption.addTarget(self, action: #selector(btnOptionClicked(sender:)), for: .touchUpInside)
            cell.btnOptionRed.tag = indexPath.row
            cell.btnOptionRed.addTarget(self, action: #selector(btnOptionClicked(sender:)), for: .touchUpInside)
            
        }
        cell.lblDevice.isHidden = false
        cell.lblDevice.text = SearchedFileArray[indexPath.row].devNm
        cell.btnOption.isHidden = false
        cell.btnShow.tag = indexPath.row
        cell.btnShow.addTarget(self, action: #selector(optionShowClicked(sender:)), for: .touchUpInside)
        cell.btnAction.tag = indexPath.row
        cell.btnAction.addTarget(self, action: #selector(optionShowClicked(sender:)), for: .touchUpInside)
        cell.btnDwnld.tag = indexPath.row
        cell.btnDwnld.addTarget(self, action: #selector(optionShowClicked(sender:)), for: .touchUpInside)
        cell.btnNas.tag = indexPath.row
        cell.btnNas.addTarget(self, action: #selector(optionShowClicked(sender:)), for: .touchUpInside)
        cell.btnGDrive.tag = indexPath.row
        cell.btnGDrive.addTarget(self, action: #selector(optionShowClicked(sender:)), for: .touchUpInside)
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(optionShowClicked(sender:)), for: .touchUpInside)
        return cell
    }
    @objc func btnOptionClicked(sender:UIButton){
        //        print("optionSHow")
        showOptionMenu(sender: sender, style:0)
    }
    @objc func btnOptionLocalClicked(sender:UIButton){
        //        print("optionSHow")
        showOptionMenu(sender: sender, style:2)
    }

    func showOptionMenu(sender:UIButton, style:Int){
        let buttonRow = sender.tag
        let indexPath = IndexPath(row: buttonRow, section: 0)
        let cell = collectionView.cellForItem(at: indexPath) as! FileListCell
        if(cell.optionSHowCheck == 0){
            if(style == 0) {
                let width = App.Size.optionWidth
                let spacing = (width - 300) / 5
                cell.spacing = spacing
                cell.optionShow(spacing: spacing, style: style)
            } else{
                let width = App.Size.optionWidth
                let spacing = (width - 180) / 4
                cell.optionShow(spacing: spacing, style:style)
            }
            cell.optionSHowCheck = 1
        } else {
            cell.optionHide()
            cell.optionSHowCheck = 0
        }
        
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
    }
    
    
    @objc func optionShowClicked(sender:UIButton){
        let buttonRow = sender.tag
        let indexPath = IndexPath(row: buttonRow, section: 0)
        let cell = collectionView.cellForItem(at: indexPath) as! FileListCell
        let osCd = SearchedFileArray[indexPath.row].osCd
        print("osCd : \(osCd)", SearchedFileArray[indexPath.row].devNm)
        let devId = SearchedFileArray[indexPath.row].devUuid
        if(devId == Util.getUuid()){
            self.localContextMenuCalled(cell: cell, indexPath: indexPath, sender:sender)
        } else {
//            self.nasContextMenuCalled(cell: cell, indexPath: indexPath, sender:sender)
        }
    }
    func localContextMenuCalled(cell:FileListCell, indexPath:IndexPath, sender:UIButton){
        let fileNm = SearchedFileArray[indexPath.row].fileNm
        foldrWholePathNm = SearchedFileArray[indexPath.row].foldrWholePathNm
        switch sender {
        case cell.btnShow:
            let fileId = SearchedFileArray[indexPath.row].fileId
            print("fileId : \(fileId)")
            let fileIdDict = ["fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":deviceName, "savedPath":"sdf"]
            NotificationCenter.default.post(name: Notification.Name("getFileIdFromBtnShow"), object: self, userInfo: fileIdDict)
            
            break
        case cell.btnAction:
            let mailURL = URL(string: "photos-redirect://")!
            if UIApplication.shared.canOpenURL(mailURL) {
//                UIApplication.shared.openURL(mailURL)
                
                UIApplication.shared.open(mailURL, options: [:], completionHandler: {
                    (success) in
                    
                    
                })
                
            }
            break
        case cell.btnNas:
            print(deviceName)
            let fileDict = ["fileId":fileId, "fileNm":fileNm, "oldFoldrWholePathNm":foldrWholePathNm,"state":"local","fromUserId":userId]
            NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
            showOptionMenu(sender: sender, style: 0)

//            switch(flickState){
//            case .main :
//                switch mainContentState {
//                case .oneViewList:
//                    let fileSavedPath = "\(SearchedFileArray[indexPath.row].savedPath)"
//                    let fileId = DbHelper().getLocalFileId(path: fileSavedPath)
//                    let fileDict = ["fileId":fileId, "fileNm":fileNm, "oldFoldrWholePathNm":foldrWholePathNm,"state":"local","fromUserId":userId]
//                    print("fileDict : \(fileDict)")
//                    NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
//                    showOptionMenu(sender: sender, style: 0)
//
//                case .googleDriveList:
//                    break
//                }
//                break
//            case .lately:
//                break
//            }
            break
        default:
            break
        }
    }
    
    func schemeAvailable(scheme: String) -> Bool {
        if let url = URL(string: scheme) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "fileCell1", for: indexPath) as! CollectionViewGridCell
        let cell2 = fileListCellController(indexPathRow: indexPath.row)
        
        let cells = [cell1, cell2]
        var cell = cells[0]
        let imageString = Util.getFileImageString(fileExtension: SearchedFileArray[indexPath.row].etsionNm)
        
        switch listViewStyleState{
        case .grid:
            cell1.ivMain.image = UIImage(named: imageString)
            cell1.ivSub.image = UIImage(named: imageString)
            cell1.lblMain.text = SearchedFileArray[indexPath.row].fileNm
            cell1.lblSub.text = SearchedFileArray[indexPath.row].amdDate
            cell = cells[0]
            break
        case .list:
            cell2.ivSub.image = UIImage(named: imageString)
            cell2.lblMain.text = SearchedFileArray[indexPath.row].fileNm
            cell2.lblSub.text = SearchedFileArray[indexPath.row].amdDate
            cell = cells[1]
            break
        }
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width:0,height: 2.0)
        cell.layer.shadowRadius = 1.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false;
        cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("fileId : \(SearchedFileArray[indexPath.row].fileNm)")
        print("fileId : \(SearchedFileArray[indexPath.row].foldrId)")
        print("fileId : \(self.SearchedFileArray[indexPath.row].fileId)")
        print("fileId : \(self.SearchedFileArray[indexPath.row].syncFileId)")
    }
    
    
    
    @objc func backToHome(){
        sBar.text = ""
        maintainFolder = false
        btnArrState = .end
        searchbarTextStarted = false
        showSearchCategory()
        for view in self.listContainerView.subviews {
            view.removeFromSuperview()
        }
        listContainerView.removeFromSuperview()
        
        setHomeView()
        
    }
    func getFolderArrayFromContainer(getFolderArray:[App.FolderStruct], getFolderArrayIndexPathRow:Int){
        folderArray = getFolderArray
        intFolderArrayIndexPathRow = getFolderArrayIndexPathRow
        print("folderArray : \(folderArray), folderArrayIndexPath : \(intFolderArrayIndexPathRow), \(folderArray[intFolderArrayIndexPathRow].fileNm)")
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
            
            filckView.isHidden = true
            containerViewABottomConstraint.constant = 0
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
            ifNavBarClicked = false
            
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
                    
                    print("getFolderArray : \(getFolderArray)")
                    print("getIndexPath : \(getIndexPath)")
                    folderArray = getFolderArray
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
                searchGubun = "emailSbjt"
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
        bottomListState = .oneView
        tableView.reloadData()
        NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self, userInfo: fileIdDict)
        
    }
    
    @objc func btnMulticlicked(){
        
        ifNavBarClicked = false
        var stringBool = "false"
        if(multiButtonChecked){
            multiButtonChecked = false
            
            multiButton.setImage(#imageLiteral(resourceName: "multi_off").withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            multiButtonChecked = true
            multiButton.setImage(#imageLiteral(resourceName: "multi_on").withRenderingMode(.alwaysOriginal), for: .normal)
        }
        stringBool = String(multiButtonChecked)
        print("stringBool :\(stringBool)")
        let fileIdDict = ["multiChecked":stringBool]
        NotificationCenter.default.post(name: Notification.Name("multiSelectActive"), object: self, userInfo: fileIdDict)

        
    }
    
    @objc func navBarTitleClicked(){
        print("??")
        ifNavBarClicked = true        
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
            listButton.setImage(#imageLiteral(resourceName: "card_view").withRenderingMode(.alwaysOriginal), for: .normal)
            if(mainContentState == .oneViewList){
                if(maintainFolder){
                    let fileDict = ["style":"list"]
                    NotificationCenter.default.post(name: Notification.Name("changeListStyle"), object: self, userInfo: fileDict)
                    self.setupFileCollectionView(getFolerName: folderName, getDeviceName: deviceName)
                } else {
                    setupDeviceListView(container: containerViewA, sortBy: oneViewSortState, multiCheckd: multiButtonChecked)
                }
            }
            break
        case (.list):
            listViewStyleState = .grid
            listButton.setImage(#imageLiteral(resourceName: "list_view").withRenderingMode(.alwaysOriginal), for: .normal)
            if(mainContentState == .oneViewList){
                if(maintainFolder){
                    let fileDict = ["style":"grid"]
                    NotificationCenter.default.post(name: Notification.Name("changeListStyle"), object: self, userInfo: fileDict)
                    setupFileCollectionView(getFolerName: folderName, getDeviceName: deviceName)
                } else {
                    setupDeviceListView(container: containerViewA, sortBy: oneViewSortState, multiCheckd: multiButtonChecked)
                }
            }
            
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
            return DeviceArray.count + 1
        } else {
            switch bottomListState {
            case .nasFileInfo:
                return bottomListFileInfo.count
            case .localFileInfo:
                return bottomListLocalFileInfo.count
                
            case .remoteFileInfo:
                return bottomListRemoteFileInfo.count
                break
                
            case .sort:
                return bottomListSort.count
                
            case .oneView:
                return bottomListOneViewSort.count
                
            }
        }
      
       
        
    }
    
  
    
  
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeBottomCell") as! HomeBottomListCell
        let clearView = UIView()
        clearView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = clearView
        if(ifNavBarClicked){
            cell.ivIcon.isHidden = false
            if(indexPath.row == 0){
                cell.lblTitle.text = "홈으로"
                cell.ivIcon.image = UIImage(named: "ico_home")
            } else {
                if(indexPath.row < DeviceArray.count+1){
                    let imageString = Util.getDeviceImageString(osNm: DeviceArray[indexPath.row-1].osNm, onoff: DeviceArray[indexPath.row-1].onoff)
                    cell.ivIcon.image = UIImage(named: imageString)
                    print("DeviceArray[indexPath.row-1].osNm : \(DeviceArray[indexPath.row-1].onoff)")
                    cell.lblTitle.text = DeviceArray[indexPath.row-1].devNm
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
                let imageString = Util.getContextImageString(context: bottomListLocalFileInfo[indexPath.row])
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
        if(ifNavBarClicked){
            if(indexPath.row == 0){
                print("back to main")
                self.filckView.isHidden = false
                containerViewABottomConstraint.constant = 40
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
                    searchInAllCategory()
                    
                } else {
                    let sortState = ["sortState":"\(bottomListSortKey[indexPath.row])"]
                    NotificationCenter.default.post(name: Notification.Name("sortFolderList"), object: self, userInfo: sortState)
                    NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
                }
                
                
                break
            case .nasFileInfo:
               NasFileCellController().nasFileContextMenuCalledFromGrid(indexPath: indexPath, fileId: fileId, foldrWholePathNm: foldrWholePathNm, deviceName: deviceName, parentView: "deviceView", deviceView: self, userId: userId, fromOsCd: fromOsCd, currentDevUuid: currentDevUuid, currentFolderId: currentFolderId, folderArray:folderArray, intFolderArrayIndexPathRow: intFolderArrayIndexPathRow)
                break
                
            case .localFileInfo:
                print("localFileInfo folderArray : \(folderArray), indexpathrow : \(intFolderArrayIndexPathRow)")
                LocalFileListCellController().localContextMenuCalledFromGrid(indexPath: indexPath, fileId: fileId, foldrWholePathNm: foldrWholePathNm, deviceName: deviceName, parentView: "deviceView", deviceView: self, userId: userId, fromOsCd: fromOsCd, currentDevUuid: currentDevUuid, currentFolderId: currentFolderId, folderArray:folderArray, intFolderArrayIndexPathRow: intFolderArrayIndexPathRow)
                break
            case .remoteFileInfo:
                
                break
                
           
            case .oneView:
                oneViewSortState = bottomListOneViewSortKey[indexPath.row]
                setupDeviceListView(container: containerViewA, sortBy: oneViewSortState, multiCheckd: multiButtonChecked)
                NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self)
                break
            }
        }
       
        
    }
 
   
    
  
    @objc func setupFolderPathView(folderName: NSNotification){
        
        if let getInfo = folderName.userInfo?["folderName"] as? String, let getDeviceName = folderName.userInfo?["deviceName"] as? String {
            self.deviceName = getDeviceName
            self.folderName = getInfo
            maintainFolder = true
            print("folderName : \(self.folderName)")
            setupFileCollectionView(getFolerName: getInfo, getDeviceName:getDeviceName)
        }
    }
    
    func setupFileCollectionView(getFolerName:String, getDeviceName:String){
        SetupFolderInsideCollectionView.searchView(searchView: searchView, searchButton: searchButton, sortButton: sortButton, customNavBar: customNavBar, hamburgerButton: hamburgerButton, listButton: listButton, multiButton:multiButton,navBarTitle: navBarTitle, getFolerName: getFolerName, getDeviceName: getDeviceName, listStyle: listViewStyleState)
    }
    
    @objc func searchButtonInFileViewClicked(){
       
        setSearchView(title: "title")
        
    }
   
   
   var cellStyle = 1 // 0eun
    @objc func setGoogleDriveFileListView(cellStyle: NSNotification){
        self.mainContentState = .googleDriveList
        // 0eun - start
        if let getInfo = cellStyle.userInfo?["cellStyle"] as? Int {
            self.cellStyle = getInfo
        }
        // 0eun - end
        self.setupDeviceListView(container: self.containerViewA, sortBy: self.oneViewSortState, multiCheckd: multiButtonChecked)
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
                            SyncLocalFilleToNas().sync()
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
        if(indicatorAnimating){
            activityIndicator.stopAnimating()
            indicatorAnimating = false
        } else {
            activityIndicator.startAnimating()
            indicatorAnimating = true
        }
    }
    
    @objc func openDocument(urlDict:NSNotification){
        
        if let getUrl = urlDict.userInfo!["url"] as? URL {
            homeViewToggleIndicator()
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
            NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self, userInfo: fileIdDict)
        }
    
    }
}



