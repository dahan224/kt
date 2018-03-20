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

class LatelyUpdatedFileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
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
    
    enum listViewStyleEnum {
        case grid
        case list
    }
    var listViewStyleState = listViewStyleEnum.list
    
    enum mainContentsStyleEnum {
        case oneViewList
        case googleDriveList
    }
    var mainContentsStyleState = mainContentsStyleEnum.oneViewList
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
    var LatelyUpdatedFileArray:[App.LatelyUpdatedFileStruct] = []
    var driveFileArray:[App.DriveFileStruct] = []
    var collectionView: UICollectionView!
    
    var searchGubun = ""
    var oneViewSortState:DbHelper.sortByEnum = DbHelper.sortByEnum.none
    

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
        mainContentsStyleState = .oneViewList
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
                            let fileStruct = App.LatelyUpdatedFileStruct(data: file)
                            print("fileStruct : \(fileStruct)")
                            self.LatelyUpdatedFileArray.append(fileStruct)
                        }
                    }
                    self.setCollectionView()
                    break
                case .failure(let error):
                    NSLog(error.localizedDescription)
                    
                    break
                }
        }
        
    }
    
    func setCollectionView(){
        print("LatelyUpdatedFileArray : \(LatelyUpdatedFileArray)")
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
//        self.view.addSubview(listContainerView)
//        listContainerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
//        listContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        listContainerView.topAnchor.constraint(equalTo: containerViewA.bottomAnchor, constant: 10).isActive = true
//        listContainerView.bottomAnchor.constraint(equalTo: containerViewA.bottomAnchor).isActive = true
        
        var cellWidth = (width - 35) / 2
        var height = cellWidth
        var minimumSpacing:CGFloat = 5
        
        switch listViewStyleState {
        case .grid:
            
            break
        case .list:
            cellWidth = width
            height = 80.0
            minimumSpacing = 1
            break
        }
        layout.sectionInset = UIEdgeInsets(top: 5, left: 15, bottom: 0, right: 15)
        layout.itemSize = CGSize(width: cellWidth, height: height )
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = minimumSpacing
        collectionView = UICollectionView(frame: containerViewA.frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = HexStringToUIColor().getUIColor(hex: "F5F5F5")
//        collectionView.register(CollectionViewGridCell.self, forCellWithReuseIdentifier: "fileCell1")
        collectionView.register(FileListCell.self, forCellWithReuseIdentifier: "fileCell2")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        containerViewA.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: containerViewA.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: containerViewA.bottomAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: containerViewA.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: containerViewA.trailingAnchor).isActive = true
        
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
        
        self.view.bringSubview(toFront: containerViewA)
        
//        self.view.bringSubview(toFront: tableView)
    }
    

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return LatelyUpdatedFileArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = fileListCellController(indexPathRow: indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    
    func fileListCellController(indexPathRow:Int) -> FileListCell {
        let indexPath = IndexPath(row: indexPathRow, section: 0)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "fileCell2", for: indexPath) as! FileListCell
        cell.btnOption.isHidden = false
        cell.btnMultiCheck.isHidden = true
        
        let imageString = Util.getFileImageString(fileExtension: LatelyUpdatedFileArray[indexPath.row].etsionNm)
        
        cell.ivSub.image = UIImage(named: imageString)
        cell.lblMain.text = LatelyUpdatedFileArray[indexPath.row].fileNm
        cell.lblSub.text = LatelyUpdatedFileArray[indexPath.row].amdDate
        cell.optionSHowCheck = 0
        cell.optionHide()
        let devId = LatelyUpdatedFileArray[indexPath.row].devUuid
        let osCd = LatelyUpdatedFileArray[indexPath.row].osCd
        
        
        
        if(devId == Util.getUuid()){
            cell.btnOption.tag = indexPath.row
            cell.btnOption.addTarget(self, action: #selector(localOptionClicked(sender:)), for: .touchUpInside)
            cell.btnOptionRed.tag = indexPath.row
            cell.btnOptionRed.addTarget(self, action: #selector(localOptionClicked(sender:)), for: .touchUpInside)
        } else {
            
            if(osCd == "S" || osCd == "G"){
                cell.btnOption.tag = indexPath.row
                cell.btnOption.addTarget(self, action: #selector(nasOptionClicked(sender:)), for: .touchUpInside)
                cell.btnOptionRed.tag = indexPath.row
                cell.btnOptionRed.addTarget(self, action: #selector(nasOptionClicked(sender:)), for: .touchUpInside)
            } else {
                cell.btnOption.tag = indexPath.row
                cell.btnOption.addTarget(self, action: #selector(otherOptionClicked(sender:)), for: .touchUpInside)
                cell.btnOptionRed.tag = indexPath.row
                cell.btnOptionRed.addTarget(self, action: #selector(otherOptionClicked(sender:)), for: .touchUpInside)
            }
        }
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
    
    @objc func localOptionClicked(sender:UIButton){
    showOptionMenu(sender: sender, style:0)
    }
    
    @objc func nasOptionClicked(sender:UIButton){
    showOptionMenu(sender: sender, style:1)
    }
    
    @objc func otherOptionClicked(sender:UIButton){
    showOptionMenu(sender: sender, style:2)
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
//            self.localContextMenuCalled(cell: cell, indexPath: indexPath, sender:sender)
        } else {
            //            self.nasContextMenuCalled(cell: cell, indexPath: indexPath, sender:sender)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
