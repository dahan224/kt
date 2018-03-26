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

class LatelyUpdatedFileViewController: UIViewController {
    var containerViewController:ContainerViewController?
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
        case fileInfo = "fileInfo"
        case oneView = "oneView"
    }
    
    var ifNavBarClicked = false
    
    var bottomListState:bottomListEnum = bottomListEnum.oneView
    var bottomListSort = ["날짜순-최신 항목 우선", "날짜순-오래된 항목 우선","이름순-ㄱ우선","이름순-ㅎ우선","종류순"]
    var bottomListSortKey = ["new", "old","asc","desc","kind"]
    
    var bottomListFileInfo = ["속성보기", "다운로드", "GiGA NAS로 보내기", "Google Drive로 보내기", "삭제"]
    
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
    
  
    var listViewStyleState = HomeViewController.listViewStyleEnum.list
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
    
    @IBOutlet weak var containerViewA: UIView!
    
    
    
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
//        button.addTarget(self, action: #selector(MenuButtonTabbed), for: .touchUpInside)
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
//        button.addTarget(self, action: #selector(listStyleChange), for: .touchUpInside)
        return button
    }()

    let multiButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "multi_off").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
//        button.addTarget(self, action: #selector(btnMulticlicked), for: .touchUpInside)
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
    

    override func viewDidLoad() {
        super.viewDidLoad()

        customNavBar.layer.shadowColor = UIColor.lightGray.cgColor
        customNavBar.layer.shadowOffset = CGSize(width:0,height: 2.0)
        customNavBar.layer.shadowRadius = 1.0
        customNavBar.layer.shadowOpacity = 1.0
        customNavBar.layer.masksToBounds = false;
        customNavBar.layer.shadowPath = UIBezierPath(roundedRect:customNavBar.bounds, cornerRadius:customNavBar.layer.cornerRadius).cgPath

        setLatelyView()
        // Do any additional setup after loading the view.
        
        getLatelyUpdateFileList()
        
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
        SetupHomeView.setupLatelySearchView(View:searchView, sortButton:sortButton, sBar:sBar, searchDownArrowButton:searchDownArrowButton, parentViewContoller:self)
        
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
        let child = storyboard!.instantiateViewController(withIdentifier: "HomeDeviceCollectionVC") as! HomeDeviceCollectionVC
        self.DeviceArray = DbHelper().listSqlite(sortBy: sortBy)
        self.driveFileArray = DbHelper().googleDrivelistSqlite(sortBy: sortBy)
        //        print("table deviceList: \(DeviceArray)")
        
        
        child.DeviceArray = self.DeviceArray
        child.listViewStyleState = self.listViewStyleState
        child.mainContentState = self.mainContentState
        child.flickState = self.flickState
        child.folderArray = self.LatelyUpdatedFileArray
        child.driveFileArray = self.driveFileArray
        child.containerViewController = containerViewController
        
        
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
        containerViewBottomAnchor = listContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40)
        containerViewBottomAnchor?.isActive = true
        
        
        
        
        self.willMove(toParentViewController: nil)
        child.willMove(toParentViewController: parent)
        self.addChildViewController(child)
        listContainerView.addSubview(child.view)
        
        child.didMove(toParentViewController: parent)
        
        let w = listContainerView.frame.size.width;
        let h = listContainerView.frame.size.height;
        child.view.frame = CGRect(x: 0, y: 0, width: w, height: h)
        
        print("containerA setting called")
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
