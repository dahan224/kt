//
//  HomeDeviceCollectionVC.swift
//  KT
//
//  Created by 이다한 on 2018. 1. 25..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import GoogleAPIClientForREST
import GoogleSignIn
import QuickLook

protocol PassItemInfo {
    func passDataToHome()
}

class HomeDeviceCollectionVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, QLPreviewControllerDataSource, QLPreviewControllerDelegate, UIGestureRecognizerDelegate, GIDSignInDelegate, GIDSignInUIDelegate {
    private let scopes = [kGTLRAuthScopeDriveFile, kGTLRAuthScopeDrive, kGTLRAuthScopeDriveReadonly ]
    private let service = GTLRDriveService()
    var homeViewController: HomeViewController?
    var containerViewController:ContainerViewController?
    var latelyUpdatedFileViewController:LatelyUpdatedFileViewController?
    var contextMenuWork:ContextMenuWork?
    var stParentViewController = "home"
    let quickLookController = QLPreviewController()
    var loginCookie = ""
    var loginToken = ""
    var userId = ""
    var fromOsCd = ""
    var folderPathToLabel = ""
    var foldrWholePathNm = ""
    var fileId = ""
    var foldrId = ""
    var fileNm = ""
    var deviceName = ""
    var test = ""
    var selectedDevUuid = ""
    var selectedDevUserId = ""
    var selectedDevFoldrId = ""
    var currentFolderId = ""
    var sortBy = ""
    var upFolderId = ""
    var remoteMultiFileDownloadedCount = 0
    var stPartentContainerView = ""
    
    var listViewStyleState = ContainerViewController.listViewStyleEnum.list
    var flickState = HomeViewController.flickEnum.main
    var mainContentState = HomeViewController.mainContentsStyleEnum.oneViewList
    var LatelyUpdatedFileArray:[App.LatelyUpdatedFileStruct] = []
    var driveFileArray:[App.DriveFileStruct] = []
    var driveFolderIdArray:[String] = ["root"] // 0eun
    var driveFolderNameArray:[String] = ["Google"] // 수정
    var request: Alamofire.Request?
    
    
    @IBOutlet weak var deviceCollectionView: UICollectionView!

    
    var DeviceArray:[App.DeviceStruct] = []
    var folderArray:[App.FolderStruct] = []
    var SearchedFileArray:[App.FolderStruct] = []
    var fileArrayToDownload:[App.FolderStruct] = []
    var localFileArray:[App.LocalFiles] = []
    var folderIdArray = [Int]()
    var folderNameArray = [String]()
    var folderStep = 0
    
    var multiCheckedfolderArray:[App.FolderStruct] = []
    var gDriveMultiCheckedfolderArray:[App.DriveFileStruct] = []
    
    var cellStyle = 1
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    var searchStepState: HomeViewController.searchStepEnum = .device
    var id = ""
    let Vc:HomeViewController = HomeViewController()
    
    var accessToken:String = ""
    
    enum contextMenuEnum {
        case nas
        case local
    }
    var contextMenuState = contextMenuEnum.nas
    
    enum multiCheckListEnum:String{
        case active = "active"
        case inActive = "inActive"
    }
    var multiCheckListState = multiCheckListEnum.inActive
    var documentController : UIDocumentInteractionController!
    var folderPathToDownLoad:[String] = []
    var getFolderFinish = false
    var viewState : HomeViewController.viewStateEnum = .home
    var tapGesture:UITapGestureRecognizer = UITapGestureRecognizer()
    let halfBlackView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.alpha = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view;
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        print("HomeDeviceCollectionVC did load")
        contextMenuWork = ContextMenuWork()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        
        
        if(viewState == .search){
            
            cellStyle = 2
            homeViewController?.cellStyle = 2
            if(mainContentState == .googleDriveList){
                cellStyle = 3
                homeViewController?.cellStyle = 3
                
            }
            stPartentContainerView = "search"
            
        } else {
            stPartentContainerView = "oneView"
        }
        if(flickState == .lately){
            cellStyle = 2
            homeViewController?.cellStyle = 2
        }
        quickLookController.dataSource = self
        quickLookController.delegate = self
        deviceCollectionView.delegate = self
        deviceCollectionView.dataSource = self
        
    
        deviceCollectionView.register(DeviceListCell.self, forCellWithReuseIdentifier: "HomeDeviceCell3")
        deviceCollectionView.register(FileListCell.self, forCellWithReuseIdentifier: "HomeDeviceCell4")
        deviceCollectionView.register(NasFileListCell.self, forCellWithReuseIdentifier: "NasFileListCell")
        deviceCollectionView.register(NasFolderListCell.self, forCellWithReuseIdentifier: "NasFolderListCell")
        deviceCollectionView.register(LocalFileListCell.self, forCellWithReuseIdentifier: "LocalFileListCell")
        deviceCollectionView.register(LocalFolderListCell.self, forCellWithReuseIdentifier: "LocalFolderListCell")
        deviceCollectionView.register(RemoteFileListCell.self, forCellWithReuseIdentifier: "RemoteFileListCell")
        deviceCollectionView.register(RemoteFolderListCell.self, forCellWithReuseIdentifier: "RemoteFolderListCell")
        deviceCollectionView.register(CollectionViewGridCell.self, forCellWithReuseIdentifier: "CollectionViewGridCell")
        deviceCollectionView.register(GDriveFileListCell.self, forCellWithReuseIdentifier: "GDriveFileListCell")
        deviceCollectionView.register(GDriveFolderListCell.self, forCellWithReuseIdentifier: "GDriveFolderListCell")
        let lpgr : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        
        
        self.deviceCollectionView?.addGestureRecognizer(lpgr)
        
        
        collectionviewCellSpcing()
        
        loginCookie = UserDefaults.standard.string(forKey: "cookie")!
        loginToken = UserDefaults.standard.string(forKey: "token")!
        userId = UserDefaults.standard.string(forKey: "userId")!
        
//        print("deviceList: \(DeviceArray)")
        deviceCollectionView.reloadData()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sortFolderList),
                                               name: NSNotification.Name("sortFolderList"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(clickDeviceItem),
                                               name: NSNotification.Name("clickDeviceItem"),
                                               object: nil)
        
     
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changeListStyle(fileDict:)),
                                               name: NSNotification.Name("changeListStyle"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshInsideList(folderIdDict:)),
                                               name: NSNotification.Name("refreshInsideList"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showAlert(messageDict:)),
                                               name: NSNotification.Name("showAlert"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleMultiCheckFolderArray(fileDict:)),
                                               name: NSNotification.Name("handleMultiCheckFolderArray"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(countRemoteDownloadFinished),
                                               name: NSNotification.Name("countRemoteDownloadFinished"),
                                               object: nil)
        
//        print("mainContentsStyleState : \((flickState))")
//        print("LatelyUpdatedFileArray: \(LatelyUpdatedFileArray)")
        
        
    }
    
    @objc func changeListStyle(fileDict:NSNotification){
        if let getStyle = fileDict.userInfo?["style"] as? String {
            if(getStyle == "list"){
                self.listViewStyleState = .list
            } else {
                self.listViewStyleState = .grid
            }
            collectionviewCellSpcing()
            
            if(multiCheckListState == .active){
                if(flickState == .main){
                    homeViewController?.btnMulticlicked()
                } else {
                    latelyUpdatedFileViewController?.btnMulticlicked()
                }
            }
            
            deviceCollectionView.reloadData()
            
        }
        
    }
    
    
    func multiSelectActive(multiButtonActive:Bool){
//        if let getChecked = multiDict.userInfo?["multiChecked"] as? String {
            self.multiCheckedfolderArray.removeAll()
            print("multiChecked : \(multiButtonActive)")
            if(multiButtonActive){
                self.multiCheckListState = .active
            } else {
                self.multiCheckListState = .inActive
            }
            deviceCollectionView.reloadData()
        
        
    }
    
    func collectionviewCellSpcing(){
        let width = UIScreen.main.bounds.width
        
        var cellWidth = (width - 35) / 2
        var height = cellWidth
        var minimumSpacing:CGFloat = 5
        let edgieInsets = UIEdgeInsets(top: 5, left: 15, bottom: 0, right: 15)
        switch listViewStyleState {
        case .grid:
            self.deviceCollectionView.backgroundColor = UIColor.clear

            break
        case .list:
            self.deviceCollectionView.backgroundColor = HexStringToUIColor().getUIColor(hex: "ffffff")

            cellWidth = width 
            height = 80.0
            minimumSpacing = 10
            if(cellStyle == 2 || flickState == .lately || viewState == .search || cellStyle == 3){
                minimumSpacing = 1
                cellWidth = width 
            }
            break
        }
        
        
//        print("width : \(width)")
//        print("deviceCollectionViewWidth : \(cellWidth)")
        layout.sectionInset = edgieInsets
        layout.itemSize = CGSize(width: cellWidth, height: height )
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = minimumSpacing
        deviceCollectionView.collectionViewLayout = layout

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        var count = 0
        switch mainContentState {
        case .oneViewList:
                if cellStyle == 1{
                    count = DeviceArray.count
                } else {
                    count = folderArray.count
                }
            break
        case .googleDriveList:
            count = driveFileArray.count
            break
        }
        return count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeDeviceCell", for: indexPath) as! HomeDeviceCollectionViewCell
        let cell2 = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeDeviceCell2", for: indexPath) as! HomeDeviceFolerCollectionViewCell
        let cell3 = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeDeviceCell3", for: indexPath) as! DeviceListCell
        
        var cells = [cell1, cell2, cell3]
        var cell = cells[0]
        print("cellStyle : \(cellStyle)")
            switch mainContentState {
            case .oneViewList:
                if(cellStyle == 1){
                    let imageString = Util.getDeviceImageString(osNm: DeviceArray[indexPath.row].osNm, onoff: DeviceArray[indexPath.row].onoff)
                    cell1.deviceImage.image = UIImage(named: imageString)
                    cell1.lblMain.text = DeviceArray[indexPath.row].devNm
                    cell1.lblSub.isHidden = true
                    cell3.ivSub.image = UIImage(named: imageString)
                    cell3.lblMain.text = DeviceArray[indexPath.row].devNm
                    if(DeviceArray[indexPath.row].newFlag == "Y"){
                        cell3.ivFlagNew.isHidden = false
                    } else {
                        cell3.ivFlagNew.isHidden = true
                    }
                    if(DeviceArray[indexPath.row].osCd == "G" && DeviceArray[indexPath.row].logical != "nil"){
                        cell3.lblLogical.isHidden = false
                        cell3.lblLogical.text = "\(DeviceArray[indexPath.row].logical) 사용"
                    } else {
                        cell3.lblLogical.isHidden = true
                    }
                    
                    if(DeviceArray[indexPath.row].devUuid == Util.getUuid()){
                        cell3.lblMain.textColor = HexStringToUIColor().getUIColor(hex: "ff0000")
                        cell1.lblMain.textColor = HexStringToUIColor().getUIColor(hex: "ff0000")
                    } else {
                        cell3.lblMain.textColor = HexStringToUIColor().getUIColor(hex: "4F4F4F")
                        cell1.lblMain.textColor = HexStringToUIColor().getUIColor(hex: "4F4F4F")
                    }
                    
                    switch listViewStyleState{
                    case .grid:
                        cell = cells[0]
                        break
                    case .list:
                        cell = cells[2]
                        break
                    }
                    cell.layer.shadowColor = UIColor.lightGray.cgColor
                    cell.layer.shadowOffset = CGSize(width:0,height: 2.0)
                    cell.layer.shadowRadius = 1.0
                    cell.layer.shadowOpacity = 1.0
                    cell.layer.masksToBounds = false;
                    cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath
//                    print("devUuid : \(currentDevUuid), my : \(Util.getUuid())")
                } else {
                    cell3.lblSub.isHidden = false
                    cell2.lblMain.text = folderArray[indexPath.row].foldrNm
                    cell2.lblSub.text = folderArray[indexPath.row].amdDate
                    cell3.lblSub.text = folderArray[indexPath.row].amdDate
                    if(folderArray[indexPath.row].osCd != "nil"){
                        fromOsCd = folderArray[indexPath.row].osCd
                    }
                    if(folderArray[indexPath.row].devUuid != "nil"){
                        selectedDevUuid = folderArray[indexPath.row].devUuid
                    }
                    if(selectedDevUuid != Util.getUuid()){
                        if(folderArray[indexPath.row].fileNm != "nil"){
                            
                            if(fromOsCd != "S" && fromOsCd != "G"){
                                
                                //리모트 파일 셀 컨트롤
                                let cell4 = RemoteFileListCellController().getCell(indexPathRow: indexPath.row, folderArray: folderArray, multiCheckListState: multiCheckListState, collectionView: deviceCollectionView, parentView: self, viewState:viewState)
                                cell4.resetMultiCheck()
                                if (multiCheckListState == .active){
                                    
                                    cell4.btnMultiCheck.isHidden = false
                                    cell4.btnMultiCheckLeadingAnchor?.isActive = false
                                    cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: 25)
                                    cell4.btnMultiCheckLeadingAnchor?.isActive = true
                                    cell4.btnMultiCheck.tag = indexPath.row
                                    cell4.btnMultiCheck.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnMultiCheckClicked(sender:)), for: .touchUpInside)
                                    cell4.btnOption.isHidden = true
                                    
                                } else {
                                    cell4.btnMultiCheckLeadingAnchor?.isActive = false
                                    cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: -36)
                                    cell4.btnMultiCheckLeadingAnchor?.isActive = true
                                    cell4.btnOption.isHidden = false
                                    cell4.btnMultiCheck.isHidden = true
                                    cell4.btnMultiChecked = false
                                }
                                let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(cellRemoteFileSwipeToLeft(sender:)))
                                swipeLeft.direction = UISwipeGestureRecognizerDirection.left
                                cell4.btnOption.addGestureRecognizer(swipeLeft)
                                cell4.btnOption.tag = indexPath.row
                                cell4.btnOption.addTarget(self, action: #selector(btnRemoteFileOptionClicked(sender:)), for: .touchUpInside)
                                
                                let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(cellRemoteFileSwipeToLeft(sender:)))
                                rightSwipe.direction = UISwipeGestureRecognizerDirection.right
                                cell4.btnOptionRed.addGestureRecognizer(rightSwipe)
                                cell4.btnOptionRed.tag = indexPath.row
                                cell4.btnOptionRed.addTarget(self, action: #selector(btnRemoteFileOptionClicked(sender:)), for: .touchUpInside)
                                
                                cells.append(cell4)
                            } else {
                                print("NasFileCellController get cell")
                                //nas 파일 셀 컨트롤
                                let cell4 = NasFileCellController().getCell(indexPathRow: indexPath.row, folderArray: folderArray, multiCheckListState: multiCheckListState, collectionView: deviceCollectionView, parentView: self, deviceName:deviceName, viewState:viewState)
                                cell4.resetMultiCheck()
                                if (multiCheckListState == .active){
                                    cell4.btnMultiCheck.isHidden = false
                                    cell4.btnMultiCheckLeadingAnchor?.isActive = false
                                    cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: 25)
                                    cell4.btnMultiCheckLeadingAnchor?.isActive = true
                                    cell4.btnMultiCheck.tag = indexPath.row
                                    cell4.btnMultiCheck.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnMultiCheckClicked(sender:)), for: .touchUpInside)
                                    cell4.btnOption.isHidden = true

                                } else {
                                    cell4.btnMultiCheckLeadingAnchor?.isActive = false
                                    cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: -36)
                                    cell4.btnMultiCheckLeadingAnchor?.isActive = true
                                    cell4.btnOption.isHidden = false
                                    cell4.btnMultiCheck.isHidden = true
                                    cell4.btnMultiChecked = false
                                }
                                let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(cellNasFileSwipeToLeft(sender:)))
                                swipeLeft.direction = UISwipeGestureRecognizerDirection.left
                                cell4.btnOption.addGestureRecognizer(swipeLeft)
                                cell4.btnOption.tag = indexPath.row
                                cell4.btnOption.addTarget(self, action: #selector(btnNasOptionClicked(sender:)), for: .touchUpInside)
                                
                                let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(cellNasFileSwipeToLeft(sender:)))
                                rightSwipe.direction = UISwipeGestureRecognizerDirection.right
                                cell4.btnOptionRed.addGestureRecognizer(rightSwipe)
                                cell4.btnOptionRed.tag = indexPath.row
                                cell4.btnOptionRed.addTarget(self, action: #selector(btnNasOptionClicked(sender:)), for: .touchUpInside)
                                
                                cells.append(cell4)
                            }
                            
                            cell2.lblMain.text = folderArray[indexPath.row].fileNm
                            let imageString = Util.getFileImageString(fileExtension: folderArray[indexPath.row].etsionNm)
                            cell2.ivMain.image = UIImage(named: imageString)
                            cell2.ivSub.image = UIImage(named: imageString)
                            
                            let CollectionViewGridCell = deviceCollectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewGridCell", for: indexPath) as! CollectionViewGridCell
                            CollectionViewGridCell.lblMain.text = folderArray[indexPath.row].fileNm
                            let editedDate = folderArray[indexPath.row].amdDate.components(separatedBy: " ")[0]
                            CollectionViewGridCell.lblSub.text = "\(editedDate) | \(deviceName)"
                            CollectionViewGridCell.ivMain.image = UIImage(named: imageString)
                            CollectionViewGridCell.ivSub.image = UIImage(named: imageString)
                            if (multiCheckListState == .active){
                                CollectionViewGridCell.btnMultiCheck.isHidden = false
                                CollectionViewGridCell.btnMultiCheck.tag = indexPath.row
                                CollectionViewGridCell.btnMultiCheck.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnMultiCheckClicked(sender:)), for: .touchUpInside)
                            } else {
                                CollectionViewGridCell.btnMultiCheck.isHidden = true
                            }
                            cells.append(CollectionViewGridCell)
                            switch listViewStyleState{
                            case .grid:
                                cell = cells[4]
                                break
                            case .list:
                                cell = cells[3]
                                break
                            }
                        } else {
                            
                            if(fromOsCd != "S" && fromOsCd != "G"){
                                //리모트 폴더 셀 컨트롤
                                
                                let cell4 = RemoteFolderListCellController().getCell(indexPathRow: indexPath.row, folderArray: folderArray, multiCheckListState: multiCheckListState, collectionView: deviceCollectionView, parentView: self)
                                cell4.resetMultiCheck()
                                if (multiCheckListState == .active){
                                    
                                    cell4.btnMultiCheck.isHidden = true
                                    cell4.btnMultiCheckLeadingAnchor?.isActive = false
                                    cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: 25)
                                    cell4.btnMultiCheckLeadingAnchor?.isActive = true
                                    cell4.btnMultiCheck.tag = indexPath.row
                                    cell4.btnMultiCheck.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnMultiCheckClicked(sender:)), for: .touchUpInside)
                                    cell4.btnOption.isHidden = true
                                    
                                } else {
                                    cell4.btnMultiCheckLeadingAnchor?.isActive = false
                                    cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: -36)
                                    cell4.btnMultiCheckLeadingAnchor?.isActive = true
                                    cell4.btnOption.isHidden = true
                                    cell4.btnMultiCheck.isHidden = true
                                    cell4.btnMultiChecked = false
                                }
                                cells.append(cell4)
                                if(folderArray[indexPath.row].foldrNm == ".."){
                                    cell4.lblSub.isHidden = true
                                    cell4.btnOption.isHidden = true
                                    cell2.lblSub.isHidden = true
                                }
                            } else {
                                //nas 폴더 셀 컨트로
                                let cell4 = NasFolderListCellController().getCell(indexPathRow: indexPath.row, folderArray: folderArray, multiCheckListState: multiCheckListState, collectionView: deviceCollectionView, parentView: self)
                                cell4.resetMultiCheck()
                                if (multiCheckListState == .active){
                                    cell4.btnMultiCheck.isHidden = false
                                    cell4.btnMultiCheckLeadingAnchor?.isActive = false
                                    cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: 25)
                                    cell4.btnMultiCheckLeadingAnchor?.isActive = true
                                    cell4.btnMultiCheck.tag = indexPath.row
                                    cell4.btnMultiCheck.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnMultiCheckClicked(sender:)), for: .touchUpInside)
                                    cell4.btnOption.isHidden = true
                                } else {
                                    cell4.btnMultiCheckLeadingAnchor?.isActive = false
                                    cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: -36)
                                    cell4.btnMultiCheckLeadingAnchor?.isActive = true
                                    cell4.btnOption.isHidden = false
                                    cell4.btnMultiCheck.isHidden = true
                                    cell4.btnMultiChecked = false
                                }
                                let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(cellFolderSwipeToLeft(sender:)))
                                swipeLeft.direction = UISwipeGestureRecognizerDirection.left
                                cell4.btnOption.addGestureRecognizer(swipeLeft)
                                cell4.btnOption.tag = indexPath.row
                                cell4.btnOption.addTarget(self, action: #selector(btnNasFolderOptionClicked(sender:)), for: .touchUpInside)
                                
                                let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(cellFolderSwipeToLeft(sender:)))
                                rightSwipe.direction = UISwipeGestureRecognizerDirection.right
                                cell4.btnOptionRed.addGestureRecognizer(rightSwipe)
                                cell4.btnOptionRed.tag = indexPath.row
                                cell4.btnOptionRed.addTarget(self, action: #selector(btnNasFolderOptionClicked(sender:)), for: .touchUpInside)
                                
                                cells.append(cell4)
                                 if(folderArray[indexPath.row].foldrNm == ".."){
                                    cell4.lblSub.isHidden = true
                                    cell4.btnOption.isHidden = true
                                    
                                }
                            }
                            cell2.lblMain.text = folderArray[indexPath.row].foldrNm
                            cell2.ivMain.image = UIImage(named: "ico_folder")
                            cell2.ivSub.image = UIImage(named: "ico_folder")
                            let CollectionViewGridCell = deviceCollectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewGridCell", for: indexPath) as! CollectionViewGridCell
                            CollectionViewGridCell.lblMain.text = folderArray[indexPath.row].foldrNm
                            let editedDate = folderArray[indexPath.row].amdDate.components(separatedBy: " ")[0]                            
                            CollectionViewGridCell.lblSub.text = "\(editedDate) | \(deviceName)"
                            CollectionViewGridCell.ivMain.image = UIImage(named: "ico_folder")
                            CollectionViewGridCell.ivSub.image = UIImage(named: "ico_folder")
                            if (multiCheckListState == .active){
                                if(fromOsCd != "S" && fromOsCd != "G" && selectedDevUuid != Util.getUuid()){
                                    CollectionViewGridCell.btnMultiCheck.isHidden = true
                                } else {
                                    CollectionViewGridCell.btnMultiCheck.isHidden = false
                                    CollectionViewGridCell.btnMultiCheck.tag = indexPath.row
                                    CollectionViewGridCell.btnMultiCheck.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnMultiCheckClicked(sender:)), for: .touchUpInside)
                                }
                                
                            } else {
                                CollectionViewGridCell.btnMultiCheck.isHidden = true
                            }
                            cells.append(CollectionViewGridCell)
                            switch listViewStyleState{
                            case .grid:
                                cell = cells[4]
                                break
                            case .list:
                                cell = cells[3]
                                break
                            }
                        }
                        
                    } else {
                        //로컬 파일
                        if(folderArray[indexPath.row].fileNm != "nil"){
                            let cell4 = LocalFileListCellController().getCell(indexPathRow: indexPath.row, folderArray: folderArray, multiCheckListState: multiCheckListState, collectionView: deviceCollectionView, parentView: self, viewState:viewState)
                            cells.append(cell4)
                            cell4.resetMultiCheck()
                            
                            if (multiCheckListState == .active){
                                
                                cell4.btnMultiCheck.isHidden = false
                                cell4.btnMultiCheckLeadingAnchor?.isActive = false
                                cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: 25)
                                cell4.btnMultiCheckLeadingAnchor?.isActive = true
                                cell4.btnMultiCheck.tag = indexPath.row
                                cell4.btnMultiCheck.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnMultiCheckClicked(sender:)), for: .touchUpInside)
                                cell4.btnOption.isHidden = true
                            } else {
                                cell4.btnMultiCheckLeadingAnchor?.isActive = false
                                cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: -36)
                                cell4.btnMultiCheckLeadingAnchor?.isActive = true
                                cell4.btnOption.isHidden = false
                                cell4.btnMultiCheck.isHidden = true
                                cell4.btnMultiChecked = false
                            }
                            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(cellLocalFileSwipeToLeft(sender:)))
                            swipeLeft.direction = UISwipeGestureRecognizerDirection.left
                            cell4.btnOption.addGestureRecognizer(swipeLeft)
                            cell4.btnOption.tag = indexPath.row
                            cell4.btnOption.addTarget(self, action: #selector(btnLocalFileOptionClicked(sender:)), for: .touchUpInside)
                            
                            let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(cellLocalFileSwipeToLeft(sender:)))
                            rightSwipe.direction = UISwipeGestureRecognizerDirection.right
                            cell4.btnOptionRed.addGestureRecognizer(rightSwipe)
                            cell4.btnOptionRed.tag = indexPath.row
                            cell4.btnOptionRed.addTarget(self, action: #selector(btnLocalFileOptionClicked(sender:)), for: .touchUpInside)

                            cell2.lblMain.text = folderArray[indexPath.row].fileNm
                            let imageString = Util.getFileImageString(fileExtension: folderArray[indexPath.row].etsionNm)
                            cell2.ivMain.image = UIImage(named: imageString)
                            cell2.ivSub.image = UIImage(named: imageString)
                         
                            let CollectionViewGridCell = deviceCollectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewGridCell", for: indexPath) as! CollectionViewGridCell
                            CollectionViewGridCell.lblMain.text = folderArray[indexPath.row].fileNm
                            let editedDate = folderArray[indexPath.row].amdDate.components(separatedBy: " ")[0]
                            CollectionViewGridCell.lblSub.text = "\(editedDate) | \(deviceName)"
                            CollectionViewGridCell.ivMain.image = UIImage(named: imageString)
                            CollectionViewGridCell.ivSub.image = UIImage(named: imageString)
                            if (multiCheckListState == .active){
                                CollectionViewGridCell.btnMultiCheck.isHidden = false
                                CollectionViewGridCell.btnMultiCheck.tag = indexPath.row
                                CollectionViewGridCell.btnMultiCheck.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnMultiCheckClicked(sender:)), for: .touchUpInside)
                            } else {
                                CollectionViewGridCell.btnMultiCheck.isHidden = true
                            }
                            cells.append(CollectionViewGridCell)
                            switch listViewStyleState{
                            case .grid:
                                cell = cells[4]
                                break
                            case .list:
                                cell = cells[3]
                                break
                            }
                        } else {
                            //로컬 폴더
                            let cell4 = LocalFolderListCellController().getCell(indexPathRow: indexPath.row, folderArray: folderArray, multiCheckListState: multiCheckListState, collectionView: deviceCollectionView, parentView: self)
                            cells.append(cell4)
                            cell4.resetMultiCheck()
                            if (multiCheckListState == .active){
                                cell4.btnMultiCheck.isHidden = false
                                cell4.btnMultiCheckLeadingAnchor?.isActive = false
                                cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: 25)
                                cell4.btnMultiCheckLeadingAnchor?.isActive = true
                                cell4.btnMultiCheck.tag = indexPath.row
                                cell4.btnMultiCheck.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnMultiCheckClicked(sender:)), for: .touchUpInside)
                                cell4.btnOption.isHidden = true
                            } else {
                                cell4.btnMultiCheckLeadingAnchor?.isActive = false
                                cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: -36)
                                cell4.btnMultiCheckLeadingAnchor?.isActive = true
                                cell4.btnOption.isHidden = false
                                cell4.btnMultiCheck.isHidden = true
                                cell4.btnMultiChecked = false
                            }
                            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(cellLocalFolderSwipeToLeft(sender:)))
                            swipeLeft.direction = UISwipeGestureRecognizerDirection.left
                            cell4.btnOption.addGestureRecognizer(swipeLeft)
                            cell4.btnOption.tag = indexPath.row
                            cell4.btnOption.addTarget(self, action: #selector(btnLocalFolderOptionClicked(sender:)), for: .touchUpInside)
                            
                            let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(cellLocalFolderSwipeToLeft(sender:)))
                            rightSwipe.direction = UISwipeGestureRecognizerDirection.right
                            cell4.btnOptionRed.addGestureRecognizer(rightSwipe)
                            cell4.btnOptionRed.tag = indexPath.row
                            cell4.btnOptionRed.addTarget(self, action: #selector(btnLocalFolderOptionClicked(sender:)), for: .touchUpInside)
                            
                            cell2.lblMain.text = folderArray[indexPath.row].foldrNm
                            cell2.ivMain.image = UIImage(named: "ico_folder")
                            cell2.ivSub.image = UIImage(named: "ico_folder")
                            
                            if(folderArray[indexPath.row].foldrNm == ".."){
                                cell4.lblSub.isHidden = true
                                cell4.btnOption.isHidden = true
                            }
                            
                            let CollectionViewGridCell = deviceCollectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewGridCell", for: indexPath) as! CollectionViewGridCell
                            CollectionViewGridCell.lblMain.text = folderArray[indexPath.row].foldrNm
                            let editedDate = folderArray[indexPath.row].amdDate.components(separatedBy: " ")[0]
                            CollectionViewGridCell.lblSub.text = "\(editedDate) | \(deviceName)"
                            CollectionViewGridCell.ivMain.image = UIImage(named: "ico_folder")
                            CollectionViewGridCell.ivSub.image = UIImage(named: "ico_folder")
                            if (multiCheckListState == .active){
                                CollectionViewGridCell.btnMultiCheck.isHidden = false
                                CollectionViewGridCell.btnMultiCheck.tag = indexPath.row
                                CollectionViewGridCell.btnMultiCheck.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnMultiCheckClicked(sender:)), for: .touchUpInside)
                            } else {
                                CollectionViewGridCell.btnMultiCheck.isHidden = true
                            }
                            cells.append(CollectionViewGridCell)
                            switch listViewStyleState{
                            case .grid:
                                cell = cells[4]
                                break
                            case .list:
                                cell = cells[3]
                                break
                            }
                        }
                        
                    }
                    
                    
                }
                break
            case .googleDriveList :
                // 파일
                if(!driveFileArray[indexPath.row].mimeType.contains("folder")){
                    let cell4 = GDriveFileListCellController().getCell(indexPathRow: indexPath.row, folderArray: driveFileArray, multiCheckListState: multiCheckListState, collectionView: deviceCollectionView, parentView: self)
                    cells.append(cell4)
                    let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(cellGDriveFileSwipeToLeft(sender:)))
                    swipeLeft.direction = UISwipeGestureRecognizerDirection.left
                    cell4.btnOption.addGestureRecognizer(swipeLeft)
                    cell4.btnOption.tag = indexPath.row
                    cell4.btnOption.addTarget(self, action: #selector(btnGDriveFileOptionClicked(sender:)), for: .touchUpInside)
                    
                    let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(cellGDriveFileSwipeToLeft(sender:)))
                    rightSwipe.direction = UISwipeGestureRecognizerDirection.right
                    cell4.btnOptionRed.addGestureRecognizer(rightSwipe)
                    cell4.btnOptionRed.tag = indexPath.row
                    cell4.btnOptionRed.addTarget(self, action: #selector(btnGDriveFileOptionClicked(sender:)), for: .touchUpInside)
                    if (multiCheckListState == .active){
                        cell4.btnMultiCheck.isHidden = false
                        cell4.btnMultiCheckLeadingAnchor?.isActive = false
                        cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: 25)
                        cell4.btnMultiCheckLeadingAnchor?.isActive = true
                        cell4.btnMultiCheck.tag = indexPath.row
                        cell4.btnMultiCheck.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnGoogleDriveMultiCheckClicked(sender:)), for: .touchUpInside)
                        cell4.btnOption.isHidden = true
                    } else {
                        cell4.btnMultiCheckLeadingAnchor?.isActive = false
                        cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: -36)
                        cell4.btnMultiCheckLeadingAnchor?.isActive = true
                        cell4.btnOption.isHidden = false
                        cell4.btnMultiCheck.isHidden = true
                        cell4.btnMultiChecked = false
                    }
                    
                    cell2.lblMain.text = driveFileArray[indexPath.row].name
                    let imageString = Util.getFileImageString(fileExtension: driveFileArray[indexPath.row].mimeType)
                    cell2.ivMain.image = UIImage(named: imageString)
                    cell2.ivSub.image = UIImage(named: imageString)
                    
                } else {
                    // 폴더
                    let cell4 = GDriveFolderListCellController().getCell(indexPathRow: indexPath.row, folderArray: driveFileArray, multiCheckListState: multiCheckListState, collectionView: deviceCollectionView, parentView: self)
                    cells.append(cell4)
                    let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(cellGDriveFolderSwipeToLeft(sender:)))
                    swipeLeft.direction = UISwipeGestureRecognizerDirection.left
                    cell4.btnOption.addGestureRecognizer(swipeLeft)
                    cell4.btnOption.tag = indexPath.row
                    cell4.btnOption.addTarget(self, action: #selector(btnGDriveFolderOptionClicked(sender:)), for: .touchUpInside)
                    
                    let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(cellGDriveFolderSwipeToLeft(sender:)))
                    rightSwipe.direction = UISwipeGestureRecognizerDirection.right
                    cell4.btnOptionRed.addGestureRecognizer(rightSwipe)
                    cell4.btnOptionRed.tag = indexPath.row
                    cell4.btnOptionRed.addTarget(self, action: #selector(btnGDriveFolderOptionClicked(sender:)), for: .touchUpInside)
                    
                    if (multiCheckListState == .active){
                        cell4.btnMultiCheck.isHidden = false
                        cell4.btnMultiCheckLeadingAnchor?.isActive = false
                        cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: 25)
                        cell4.btnMultiCheckLeadingAnchor?.isActive = true
                        cell4.btnMultiCheck.tag = indexPath.row
                        cell4.btnMultiCheck.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnGoogleDriveMultiCheckClicked(sender:)), for: .touchUpInside)
                        cell4.btnOption.isHidden = true
                    } else {
                        cell4.btnMultiCheckLeadingAnchor?.isActive = false
                        cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: -36)
                        cell4.btnMultiCheckLeadingAnchor?.isActive = true
                        cell4.btnOption.isHidden = false
                        cell4.btnMultiCheck.isHidden = true
                        cell4.btnMultiChecked = false
                    }
                    
                    
                    cell2.lblMain.text = driveFileArray[indexPath.row].name
                    cell2.ivMain.image = UIImage(named: "ico_folder")
                    cell2.ivSub.image = UIImage(named: "ico_folder")
                    
                    if(driveFileArray[indexPath.row].name == ".."){
                        cell4.lblSub.isHidden = true
                        cell4.btnOption.isHidden = true
                    }
                }
                
                switch listViewStyleState{
                case .grid:
                    cell = cells[1]
                    break
                case .list:
                    cell = cells[3]
                    break
                }
                

                break
            }
        
       
         return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //        print("item : \(indexPath.row)")
        
        if(cellStyle == 1){
            
            let indexPathRow = ["indexPathRow":"\(indexPath.row)"]
            
            fromOsCd = DeviceArray[indexPath.row].osCd
            homeViewController?.fromOsCd = fromOsCd
            selectedDevUuid = DeviceArray[indexPath.row].devUuid
            selectedDevUserId = DeviceArray[indexPath.row].userId
            
            var state = HomeViewController.bottomListEnum.nasFileInfo
            if(fromOsCd == "G" || fromOsCd == "S"){
                state = HomeViewController.bottomListEnum.nasFileInfo
            } else if fromOsCd == "D" {
                state = HomeViewController.bottomListEnum.googleDrive
            }else {
                state = HomeViewController.bottomListEnum.remoteFileInfo
                if(selectedDevUuid == Util.getUuid()){
                    state = HomeViewController.bottomListEnum.localFileInfo
                }
            }
            if(viewState == .search){
                return
            }
            let stateDict = ["bottomState":"\(state)","fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":deviceName, "selectedDevUuid":selectedDevUuid, "fileNm":fileNm, "userId":userId, "foldrId":String(foldrId),"fromOsCd":fromOsCd, "cellStyle":"1", "currentFolderId":currentFolderId]
//            print(stateDict)
            NotificationCenter.default.post(name: Notification.Name("bottomStateFromContainer"), object: self, userInfo: stateDict)
            
            NotificationCenter.default.post(name: Notification.Name("clickDeviceItem"), object: self, userInfo: indexPathRow)
            
        } else if (cellStyle == 2){
            //            if(contextMenuState == .nas){
            if(multiCheckListState == .active){
                
            } else {
                if(flickState == .main) {
                    homeViewController?.inActiveMultiCheck()
                } else {
                    latelyUpdatedFileViewController?.inActiveMultiCheck()
                }
                
                print("2")
                let infoldrId = folderArray[indexPath.row].foldrId
                foldrId = String(infoldrId)
                selectedDevFoldrId = foldrId
                let fileId = folderArray[indexPath.row].fileId
                let folderNm = folderArray[indexPath.row].foldrNm
                fileNm = folderArray[indexPath.row].fileNm
                foldrWholePathNm = folderArray[indexPath.row].foldrWholePathNm
                print("foldrWholePathNm: \(foldrWholePathNm)")
                let intIndexPathRow = indexPath.row
                
                Vc.getFolderArrayFromContainer(getFolderArray:folderArray, getFolderArrayIndexPathRow:intIndexPathRow)
                if(fileId == 0){
                    
                    if(foldrId == "0") {
                        
                        // 리모트 디아비스 최상위 폴더
                        print("getRootFolder called")
                        cellStyle = 1
                        getRootFolder(userId: userId, devUuid: selectedDevUuid, deviceName: deviceName)
                    } else {
                        print("foldrId : \(foldrId)")
                        
                        var navTxt = "../ "
                        if(folderArray[indexPath.row].foldrNm == ".."){
                            
                            folderIdArray.remove(at: folderIdArray.count-1)
                            folderNameArray.remove(at: folderNameArray.count-1)
                        } else {
                            self.folderIdArray.append(infoldrId)
                            self.folderNameArray.append(folderNm)
                        }
                        print("folderIdArray.count:\(folderIdArray.count)")
                        var folderNameArrayCount = 0
                        var folderNameForSearchView = ""
                        if(folderNameArray.count > 0) {
                            folderNameArrayCount = folderNameArray.count-1
                            folderNameForSearchView = folderNameArray[folderNameArrayCount]
                            if(folderIdArray.count < 2) {
                                folderNameForSearchView = deviceName
                                navTxt = "> "
                            }
                        }
                        let folderName = ["folderName":"\(navTxt)\(folderNameForSearchView)","deviceName":deviceName, "devUuid":selectedDevUuid]
                        NotificationCenter.default.post(name: Notification.Name("setupFolderPathView"), object: self, userInfo: folderName)
                        self.showInsideList(userId: userId, devUuid: selectedDevUuid, foldrId: foldrId,deviceName: deviceName)
                        searchStepState = .folder
                        var state = HomeViewController.bottomListEnum.nasFileInfo
                        if(fromOsCd == "G" || fromOsCd == "S"){
                            state = HomeViewController.bottomListEnum.nasFileInfo
                        } else {
                            state = HomeViewController.bottomListEnum.remoteFileInfo
                            if(selectedDevUuid == Util.getUuid()){
                                state = HomeViewController.bottomListEnum.localFileInfo
                            }
                        }
                        Vc.dataFromContainer(containerData: indexPath.row, getStepState: searchStepState, getBottomListState: state, getStringId:id, getStringFolderPath: foldrWholePathNm, getCurrentDevUuid:selectedDevUuid, getCurrentFolderId : currentFolderId)
                    }
                    
                } else {
                    
                    print("selectedFileId : \(folderArray[indexPath.row].fileId)")
                    let fileId = "\(folderArray[indexPath.row].fileId)"
                    let foldrWholePathNm = "\(folderArray[indexPath.row].foldrWholePathNm)"
                    var state = HomeViewController.bottomListEnum.nasFileInfo
                    if(fromOsCd == "G" || fromOsCd == "S"){
                        state = HomeViewController.bottomListEnum.nasFileInfo
                    } else {
                        state = HomeViewController.bottomListEnum.remoteFileInfo
                        if(selectedDevUuid == Util.getUuid()){
                            state = HomeViewController.bottomListEnum.localFileInfo
                        }
                    }
                    
                    let stateDict = ["bottomState":"\(state)","fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":deviceName, "selectedDevUuid":selectedDevUuid, "fileNm":fileNm, "userId":userId, "foldrId":String(foldrId),"fromOsCd":fromOsCd, "currentFolderId":currentFolderId,"folderArray":folderArray,"selectedIndex":indexPath] as [String : Any]
                    print(stateDict)
                    NotificationCenter.default.post(name: Notification.Name("bottomStateFromContainer"), object: self, userInfo: stateDict)
                }
                // 0eun - start
                
                
            }
           
          
            
        } else if cellStyle == 3 { // 구글드라이브 폴더,파일 셀
            let mimeType = driveFileArray[indexPath.row].mimeType
            let fileId = driveFileArray[indexPath.row].fileId
            let name = driveFileArray[indexPath.row].name
            
            if mimeType.contains(".folder") { // 폴더
                

                let stringFoldrId = String(fileId)
                if driveFileArray[indexPath.row].name == ".." {
                    if(driveFolderIdArray[driveFolderIdArray.count - 1] == "root") {
                        currentFolderId = "root"
                    } else {
                        currentFolderId = driveFolderIdArray[driveFolderIdArray.count - 2]
                    }
                    
                    driveFolderIdArray.remove(at: driveFolderIdArray.count-1)
                    driveFolderNameArray.remove(at: driveFolderNameArray.count-1)
                    
                } else {
                    currentFolderId = fileId
                    self.driveFolderIdArray.append(fileId)
                    self.driveFolderNameArray.append(name)
                }
                var driveFolderNameArrayCount = 0
                if driveFolderNameArray.count < 1 {
                    
                } else {
                    driveFolderNameArrayCount = driveFolderNameArray.count - 1
                }
                let folderName = ["folderName":"\(driveFolderNameArray[driveFolderNameArrayCount])","deviceName":"Google Drive", "devUuid":"googleDrive"]
                NotificationCenter.default.post(name: Notification.Name("setupFolderPathView"), object: self, userInfo: folderName)
                
                self.showInsideListGDrive(userId: userId, devUuid: selectedDevUuid, foldrId: stringFoldrId, deviceName: deviceName)
                searchStepState = .folder
                let state = HomeViewController.bottomListEnum.googleDrive
                //수정 요망
                
                Vc.dataFromContainer(containerData: indexPath.row, getStepState: searchStepState, getBottomListState: state, getStringId:id, getStringFolderPath: foldrWholePathNm, getCurrentDevUuid: selectedDevUuid, getCurrentFolderId: currentFolderId)
            } else { // 파일
                print("selectedFileId : \(driveFileArray[indexPath.row].fileId)")
                let fileId = "\(driveFileArray[indexPath.row].fileId)"
                let foldrWholePathNm = "\(driveFileArray[indexPath.row].foldrWholePath)"
                var state = HomeViewController.bottomListEnum.googleDrive
                
                let stateDict = ["bottomState":"\(state)","fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":"Google Drive", "selectedDevUuid":selectedDevUuid, "fileNm":fileNm, "userId":userId, "foldrId":String(foldrId),"fromOsCd":fromOsCd, "currentFolderId":currentFolderId,"driveFileArray":driveFileArray,"selectedIndex":indexPath] as [String : Any]
                print(stateDict)
                NotificationCenter.default.post(name: Notification.Name("bottomStateFromContainer"), object: self, userInfo: stateDict)
            }
        }
        // 0eun - end
        
        
        collectionviewCellSpcing()
        deviceCollectionView.reloadData()
        
    }

    func getChildFolder() {
        
        if folderIdArray.count > 1 {
            var navTxt = "../ "
            folderIdArray.remove(at: folderIdArray.count-1)
            folderNameArray.remove(at: folderNameArray.count-1)
            
            var folderNameArrayCount = 0
            var folderNameForSearchView = ""
            
            folderNameArrayCount = folderNameArray.count-1
            folderNameForSearchView = folderNameArray[folderNameArrayCount]
            if(folderIdArray.count == 1) {
                folderNameForSearchView = deviceName
                navTxt = "> "
            }
            
            let upFoldrId = "\(folderIdArray[folderIdArray.count-1])"
            
            let folderName = ["folderName":"\(navTxt)\(folderNameForSearchView)","deviceName":deviceName, "devUuid":selectedDevUuid]
            NotificationCenter.default.post(name: Notification.Name("setupFolderPathView"), object: self, userInfo: folderName)
            self.showInsideList(userId: userId, devUuid: selectedDevUuid, foldrId: upFoldrId,deviceName: deviceName)
            searchStepState = .folder
            var state = HomeViewController.bottomListEnum.nasFileInfo
            if(fromOsCd == "G" || fromOsCd == "S"){
                state = HomeViewController.bottomListEnum.nasFileInfo
            } else {
                state = HomeViewController.bottomListEnum.remoteFileInfo
                if(selectedDevUuid == Util.getUuid()){
                    state = HomeViewController.bottomListEnum.localFileInfo
                }
            }
            Vc.dataFromContainer(containerData: 0, getStepState: searchStepState, getBottomListState: state, getStringId:id, getStringFolderPath: foldrWholePathNm, getCurrentDevUuid:selectedDevUuid, getCurrentFolderId : currentFolderId)
        }
        
    }

    //Nas 파일 컨텍스트 시작
    
    @objc func btnNasOptionClicked(sender:UIButton){
         showNasFileOption(tag:sender.tag)
    }
    
    @objc func cellNasFileSwipeToLeft(sender:UIGestureRecognizer){
        
        print("swipe to left")
        if let button = sender.view as? UIButton {
            // use button
            print("tag : \(button.tag)")
            showNasFileOption(tag:button.tag)
        }
    }

    
    func showNasFileOption(tag:Int){
        hideAllOptions(tag:tag)
        let buttonRow = tag
        let indexPath = IndexPath(row: buttonRow, section: 0)
        let cell = deviceCollectionView.cellForItem(at: indexPath) as! NasFileListCell
        if(cell.optionSHowCheck == 0){
            let width = App.Size.optionWidth
            let spacing = (width - 300) / 6
            cell.spacing = spacing
            cell.optionShow(spacing: spacing, style: 0)
            cell.optionSHowCheck = 1
        } else {
            cell.optionHide()
            cell.optionSHowCheck = 0
        }
        
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
    }
    
 
//nas file 컨텍스트 종료
// local file 컨텍스트 시작
    @objc func btnLocalFileOptionClicked(sender:UIButton){
        showLocalFileOption(tag:sender.tag)
    }
    
    
    @objc func cellLocalFileSwipeToLeft(sender:UIGestureRecognizer){
        if let button = sender.view as? UIButton {
            // use button
            print("tag : \(button.tag)")
            showLocalFileOption(tag:button.tag)
        }
    }
    
    
    func showLocalFileOption(tag:Int){
        hideAllOptions(tag:tag)
        let buttonRow = tag
        let indexPath = IndexPath(row: buttonRow, section: 0)
        let cell = deviceCollectionView.cellForItem(at: indexPath) as! LocalFileListCell
        if(cell.optionSHowCheck == 0){
            let width = App.Size.optionWidth
            let spacing = (width - 300) / 6
            cell.spacing = spacing
            cell.optionShow(spacing: spacing, style: 0)
            cell.optionSHowCheck = 1
        } else {
            cell.optionHide()
            cell.optionSHowCheck = 0
        }        
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func optionLocalFileShowClicked(sender:UIButton){
        let buttonRow = sender.tag
        let indexPath = IndexPath(row: buttonRow, section: 0)
        let cell = deviceCollectionView.cellForItem(at: indexPath) as! LocalFileListCell
//        self.localContextMenuCalled(cell: cell, indexPath: indexPath, sender:sender)
        LocalFileListCellController().localContextMenuCalled(cell: cell, indexPath: indexPath, sender: sender, folderArray: folderArray, deviceName: deviceName, parentView: "device", deviceView:self, userId: userId, fromOsCd: fromOsCd, currentDevUuid: selectedDevUuid, currentFolderId:  currentFolderId, viewState:viewState, containerView:containerViewController!)
    }
    
    //로컬 파일 컨텍스트 종료
    
    // local 폴더 컨텍스트 시작
    @objc func btnLocalFolderOptionClicked(sender:UIButton){
        showLocalFolderOption(tag:sender.tag)
    }
    @objc func cellLocalFolderSwipeToLeft(sender:UIGestureRecognizer){
        if let button = sender.view as? UIButton {
            // use button
            print("tag : \(button.tag)")
            showLocalFolderOption(tag:button.tag)
        }
    }
    func showLocalFolderOption(tag:Int){
        hideAllOptions(tag:tag)
        let buttonRow = tag
        let indexPath = IndexPath(row: buttonRow, section: 0)
        let cell = deviceCollectionView.cellForItem(at: indexPath) as! LocalFolderListCell
        if(cell.optionSHowCheck == 0){
            let width = App.Size.optionWidth
            let spacing = (width - 240) / 4
            cell.spacing = spacing
            cell.optionShow(spacing: spacing, style: 0)
            cell.optionSHowCheck = 1
        } else {
            cell.optionHide()
            cell.optionSHowCheck = 0
        }        
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
       
    }
    
    @objc func optionLocalFolderShowClicked(sender:UIButton){
        let buttonRow = sender.tag
        let indexPath = IndexPath(row: buttonRow, section: 0)
        let cell = deviceCollectionView.cellForItem(at: indexPath) as! LocalFolderListCell
        LocalFolderListCellController().LocalFolderContextMenuCalled(cell: cell, indexPath: indexPath, sender: sender, folderArray: folderArray, deviceName: deviceName, parentView: "device", deviceView:self, userId: userId, fromOsCd: fromOsCd, currentDevUuid: selectedDevUuid, selectedDevUserId: selectedDevUuid, currentFolderId:  currentFolderId, containerView: containerViewController!)
    }
    
    //로컬 폴더 컨텍스트 종료
    
    /* 0eun */
    // 구글드라이브 파일 컨텍스트 시작
    @objc func btnGDriveFileOptionClicked(sender:UIButton){
        showGDriveFileOption(tag:sender.tag)
    }
    
    @objc func cellGDriveFileSwipeToLeft(sender:UIGestureRecognizer){
        if let button = sender.view as? UIButton {
            print("tag : \(button.tag)")
            showGDriveFileOption(tag:button.tag)
        }
    }
    
    func showGDriveFileOption(tag:Int){
        hideAllOptions(tag:tag)
        let buttonRow = tag
        let indexPath = IndexPath(row: buttonRow, section: 0)
        let cell = deviceCollectionView.cellForItem(at: indexPath) as! GDriveFileListCell
        if(cell.optionSHowCheck == 0){
            let width = App.Size.optionWidth
            let spacing = (width - 300) / 6
            cell.spacing = spacing
            cell.optionShow(spacing: spacing, style: 0)
            cell.optionSHowCheck = 1
        } else {
            cell.optionHide()
            cell.optionSHowCheck = 0
        }
        
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func optionGDriveFileShowClicked(sender:UIButton){
        let buttonRow = sender.tag
        let indexPath = IndexPath(row: buttonRow, section: 0)
        let cell = deviceCollectionView.cellForItem(at: indexPath) as! GDriveFileListCell
        GDriveFileListCellController().localContextMenuCalled(cell: cell, indexPath: indexPath, sender: sender, folderArray: driveFileArray, deviceName: "Google Drive", parentView: "device", deviceView:self, userId: userId, fromOsCd: fromOsCd, currentDevUuid: selectedDevUuid, currentFolderId:  currentFolderId, containerView:containerViewController!)
    }
    
    //구글드라이브 파일 컨텍스트 종료
    // 구글드라이브 폴더 컨텍스트 시작
    @objc func btnGDriveFolderOptionClicked(sender:UIButton){
        showGDriveFolderOption(tag:sender.tag)
    }
    
    @objc func cellGDriveFolderSwipeToLeft(sender:UIGestureRecognizer){
        if let button = sender.view as? UIButton {
            // use button
            print("tag : \(button.tag)")
            showGDriveFolderOption(tag:button.tag)
        }
    }
    
    func showGDriveFolderOption(tag:Int){
        hideAllOptions(tag:tag)
        let buttonRow = tag
        let indexPath = IndexPath(row: buttonRow, section: 0)
        let cell = deviceCollectionView.cellForItem(at: indexPath) as! GDriveFolderListCell
        if(cell.optionSHowCheck == 0){
            let width = App.Size.optionWidth
            let spacing = (width - 240) / 4
            cell.spacing = spacing
            cell.optionShow(spacing: spacing, style: 0)
            cell.optionSHowCheck = 1
        } else {
            cell.optionHide()
            cell.optionSHowCheck = 0
        }
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
        
    }
    
    @objc func optionGDriveFolderShowClicked(sender:UIButton){
        let buttonRow = sender.tag
        let indexPath = IndexPath(row: buttonRow, section: 0)
        let cell = deviceCollectionView.cellForItem(at: indexPath) as! GDriveFolderListCell
        GDriveFolderListCellController().GdriveFolderContextMenuCalled(cell: cell, indexPath: indexPath, sender: sender, folderArray: driveFileArray, deviceName: "Google Drive", parentView: "device", deviceView:self, userId: userId, fromOsCd: fromOsCd, currentDevUuid: selectedDevUuid, selectedDevUserId: selectedDevUuid, currentFolderId:  currentFolderId)
    }
    //구글드라이브 폴더 컨텍스트 종료
    
    // 0eun - start
    func showInsideListGDrive(userId: String, devUuid: String, foldrId: String, deviceName:String){
        self.driveFileArray.removeAll()
        var param = ["userId": userId, "devUuid":devUuid, "foldrId":foldrId,"sortBy":sortBy]
        var googleEmail = UserDefaults.standard.string(forKey: "googleEmail")
        accessToken = DbHelper().getAccessToken(email: googleEmail!)
        if !accessToken.isEmpty {
            print("accessToken : \(accessToken)")
            print("showInsideParam : \(param)")
            
            if(driveFolderIdArray.count > 1){
                
                let upFolder = App.DriveFileStruct(device: ["id":driveFolderIdArray[driveFolderIdArray.count-2],"kind":"drive#file","mimeType":".folder","name":".."] as AnyObject, foldrWholePaths: driveFolderNameArray)
                self.driveFileArray.append(upFolder)
                if(driveFolderIdArray.count == 1){
                    param = ["userId": userId, "devUuid":devUuid]
                }
            }
            print("param : \(param)")
            
            var url = "https://www.googleapis.com/drive/v3/files?q='\(foldrId)' in parents and trashed=false&access_token=\(accessToken)" + App.URL.gDriveFileOption // 0eun
            url = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
            print(url)
            Alamofire.request(url,
                              method: .get,
                              encoding: JSONEncoding.default,
                              headers: nil).responseJSON { response in
                                switch response.result {
                                case .success(let value):
                                    let json = JSON(value)
                                    print("json : \(json)")
                                    let responseData = value as! NSDictionary
                                    let serverList:[AnyObject] = json["files"].arrayObject as! [AnyObject]
                                    for file in serverList {
                                        //                                    print("file : \(file)")
                                        let fileStruct = App.DriveFileStruct(device: file, foldrWholePaths: self.driveFolderNameArray)
                                        self.driveFileArray.append(fileStruct)
                                    }
                                    DbHelper().googleDriveToSqlite(getArray: self.driveFileArray)
                                    
                                    self.cellStyle = 3
                                    self.currentFolderId = foldrId
                                    
                                    self.collectionviewCellSpcing()
                                    self.deviceCollectionView.reloadData()
                                    self.deviceCollectionView.collectionViewLayout.invalidateLayout()
                                case .failure(let error):
                                    NSLog(error.localizedDescription)
                                }
            }
        }
        
    }
    // 0eun - end
    

    func uploadNasGDriveFile(fileId:String, mimeType:String, name:String) {
        if let googleEmail = UserDefaults.standard.string(forKey: "googleEmail"){
            
        accessToken = DbHelper().getAccessToken(email: googleEmail)
//        accessToken = UserDefaults.standard.string(forKey: "accessToken")!
        let stringUrl = "https://www.googleapis.com/drive/v3/files/\(fileId)/?alt=media&access_token=\(accessToken)"
        print("stringUrl : \(stringUrl)")
        
        let downloadUrl = URL(string: stringUrl)
        }
    }
    
    // 구글드라이브 파일 다운로드, 기가나스 보내기
    func downloadGDriveFile(fileId:String, mimeType:String, name:String) {
//        accessToken = UserDefaults.standard.string(forKey: "accessToken")!
        if let googleEmail = UserDefaults.standard.string(forKey: "googleEmail"){
            homeViewController?.homeViewToggleIndicator()
            accessToken = DbHelper().getAccessToken(email: googleEmail)
            print("fileId : \(fileId), mimeType : \(mimeType)")
            let stringUrl = "https://www.googleapis.com/drive/v3/files/\(fileId)/?alt=media&access_token=\(accessToken)"
            print("stringUrl : \(stringUrl)")
            
            let downloadUrl = URL(string: stringUrl)
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                
                // the name of the file here I kept is yourFileName with appended extension
                documentsURL.appendPathComponent("\(name)")
                return (documentsURL, [.removePreviousFile])
            }
            
            Alamofire.download(downloadUrl!, to: destination)
                .downloadProgress(closure: { (progress) in
                    print("download progress : \(progress.fractionCompleted)")
                })
                .response { response in
                    print("response : \(response)")
                    if response.destinationURL != nil {
                        print(response.destinationURL!)
                        SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
                        DispatchQueue.main.async {
                            let alertController = UIAlertController(title: nil, message: "다운로드를 성공하였습니다.", preferredStyle: .alert)
                            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel){
                                UIAlertAction in
                                self.homeViewController?.homeViewToggleIndicator()
                                
                            }
                            
                            alertController.addAction(yesAction)
                            self.present(alertController, animated: true)
                        }
                    }
            }
        }
    }
    
    // 구글드라이브 파일 구글드라이브로 보내기(카피)
    func gDriveSendGDrive() {
        
    }
    

    
    func finishedFileDownload(fetcher: GTMSessionFetcher, finishedWithData data: NSData, error: NSError?){
        if let error = error {
            //show an alert with the error message or something similar
            return
        }
        
        //do something with data (save it..)
    }
    @objc func optionNasFileShowClicked(sender:UIButton){
        
        let buttonRow = sender.tag
        let indexPath = IndexPath(row: buttonRow, section: 0)
        let cell = deviceCollectionView.cellForItem(at: indexPath) as! NasFileListCell
//        self.nasContextMenuCalled(cell: cell, indexPath: indexPath, sender:sender)
        NasFileCellController().nasContextMenuCalled(cell: cell, indexPath: indexPath, sender: sender, folderArray: folderArray, deviceName: deviceName, parentView: "device", deviceView:self, userId: userId, fromOsCd: fromOsCd, currentDevUuid: selectedDevUuid, selectedDevUserId: selectedDevUserId, currentFolderId:  currentFolderId, containerView: containerViewController!)
        
    }
    
    func hideAllOptions(tag:Int){
        var count = 0
        switch mainContentState {
        case .oneViewList:
            if cellStyle == 1{
                count = DeviceArray.count
            } else {
                count = folderArray.count
            }
            break
        case .googleDriveList:
            count = driveFileArray.count
            break
        }
        for row in 0 ..< count{
            print("count : \(count)")
            if(row != tag){
                let indexPath = IndexPath(row: row, section: 0)
    //            let cell = deviceCollectionView.cellForItem(at: indexPath)
                if let cell = deviceCollectionView.cellForItem(at: indexPath) as? NasFileListCell {
                    if(cell.optionSHowCheck != 0){
                        cell.optionHide()
                        cell.optionSHowCheck = 0
                    }
                    
                } else if let cell = deviceCollectionView.cellForItem(at: indexPath) as? NasFolderListCell {
                    if(cell.optionSHowCheck != 0){
                        cell.optionHide()
                        cell.optionSHowCheck = 0
                    }
                } else if let cell = deviceCollectionView.cellForItem(at: indexPath) as? CollectionViewGridCell {
                    
                } else if let cell = deviceCollectionView.cellForItem(at: indexPath) as? RemoteFileListCell {
                    if(cell.optionSHowCheck != 0){
                        cell.optionHide()
                        cell.optionSHowCheck = 0
                    }
                } else if let cell = deviceCollectionView.cellForItem(at: indexPath) as? LocalFileListCell {
                    if(cell.optionSHowCheck != 0){
                        cell.optionHide()
                        cell.optionSHowCheck = 0
                    }
                } else if let cell = deviceCollectionView.cellForItem(at: indexPath) as? LocalFolderListCell {
                    if(cell.optionSHowCheck != 0){
                        cell.optionHide()
                        cell.optionSHowCheck = 0
                    }
                } else if let cell = deviceCollectionView.cellForItem(at: indexPath) as? GDriveFileListCell {
                    if(cell.optionSHowCheck != 0){
                        cell.optionHide()
                        cell.optionSHowCheck = 0
                    }
                }  else if let cell = deviceCollectionView.cellForItem(at: indexPath) as? GDriveFolderListCell {
                    if(cell.optionSHowCheck != 0){
                        cell.optionHide()
                        cell.optionSHowCheck = 0
                    }
                }
            }
        }
    }
    
    @objc func btnMultiCheckClicked(sender:UIButton){
       
        MultiCheckFileListController().btnMultiCheckClicked(sender: sender, getHomeViewController: homeViewController!, parent: self)
    }
    
    @objc func btnGoogleDriveMultiCheckClicked(sender:UIButton){
        GdriveMultiCheckController().btnGoogleDriveMultiCheckClicked(sender: sender, getDriveArray:driveFileArray, getHomeViewController:homeViewController!, getFlisckState:flickState, parent: self)
    }
    
    func gDriveMultiCheckedFolderArray(indexPath:IndexPath, check:Bool, checkedFile:App.DriveFileStruct){
        if(check){
            self.gDriveMultiCheckedfolderArray.append(checkedFile)
        } else {
            if let removeIndex = gDriveMultiCheckedfolderArray.index(where: { $0.fileId == checkedFile.fileId && $0.parents == checkedFile.parents}) {
                print("removeIndex : \(removeIndex)")
                self.gDriveMultiCheckedfolderArray.remove(at: removeIndex)
            }
        }
        if(flickState == .main){
            homeViewController?.setMultiCountLabel(multiButtonChecked: true, count: gDriveMultiCheckedfolderArray.count)
        } else {
            latelyUpdatedFileViewController?.setMultiCountLabel(multiButtonChecked: true, count: multiCheckedfolderArray.count)
        }
        print("gDriveMultiCheckedfolderArray : \(gDriveMultiCheckedfolderArray)")
    }
    
    func cellMultiCheckClicked(indexPath:IndexPath){
        MultiCheckFileListController().cellMultiCheckClicked(indexPath:indexPath, parent: self, deviceCollectionView:deviceCollectionView)
       
    }
    
    func allMultiCheck(selectedAll:Bool){
        self.multiCheckedfolderArray.removeAll()
        var count = folderArray.count
        for row in 0 ..< count{
            print("count : \(count)")
            let indexPath = IndexPath(row: row, section: 0)
            if(!selectedAll) {
                if let cell = deviceCollectionView.cellForItem(at: indexPath) as? LocalFileListCell {
                    cell.btnMultiChecked = false
                    cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
                } else if let cell = deviceCollectionView.cellForItem(at: indexPath) as? CollectionViewGridCell {
                    cell.btnMultiChecked = false
                    cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
                } else if let cell = deviceCollectionView.cellForItem(at: indexPath) as? LocalFolderListCell {
                    cell.btnMultiChecked = false
                    cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
                }
            } else {
                if let cell = deviceCollectionView.cellForItem(at: indexPath) as? LocalFileListCell {
                    cell.btnMultiChecked = true
                    cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
                }else if let cell = deviceCollectionView.cellForItem(at: indexPath) as? CollectionViewGridCell {
                    cell.btnMultiChecked = true
                    cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
                } else if let cell = deviceCollectionView.cellForItem(at: indexPath) as? LocalFolderListCell {
                    cell.btnMultiChecked = true
                    cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
                }
                self.multiCheckedfolderArray.append(folderArray[row])
            }
            
        }
        if(flickState == .main){
            homeViewController?.setMultiCountLabel(multiButtonChecked: true, count: multiCheckedfolderArray.count)
        } else {
            latelyUpdatedFileViewController?.setMultiCountLabel(multiButtonChecked: true, count: multiCheckedfolderArray.count)
        }
        print("multiCheckedfolderArray : \(multiCheckedfolderArray)")
    }
    
    func multiCheckedFolderArray(indexPath:IndexPath, check:Bool){
        let getIndex = indexPath.row
        let checkedFolder = folderArray[getIndex]
        if(check){
            self.multiCheckedfolderArray.append(checkedFolder)
        } else {
            if let removeIndex = multiCheckedfolderArray.index(where: { $0.fileId == folderArray[getIndex].fileId && $0.foldrId == folderArray[getIndex].foldrId}) {
            self.multiCheckedfolderArray.remove(at: removeIndex)
            }
        }
        if(flickState == .main){
            homeViewController?.setMultiCountLabel(multiButtonChecked: true, count: multiCheckedfolderArray.count)
        } else {
            latelyUpdatedFileViewController?.setMultiCountLabel(multiButtonChecked: true, count: multiCheckedfolderArray.count)
        }
        print("multiCheckedfolderArray : \(multiCheckedfolderArray)")
    }
    
    @objc func handleMultiCheckFolderArray(fileDict:NSNotification) {
        if let getAction = fileDict.userInfo?["action"] as? String, let getFromOsCd = fileDict.userInfo?["fromOsCd"] as? String {
            print("getFromOsCd : \(getFromOsCd)")
            if(selectedDevUuid == Util.getUuid()){
                switch getAction {
                case "nas":
                    print("local to nas multi, fromUserId : \(selectedDevUserId)")
                    containerViewController?.getMultiFolderArray(getArray:multiCheckedfolderArray, toStorage:"local_nas_multi", fromUserId:selectedDevUserId, fromOsCd:fromOsCd,fromDevUuid:selectedDevUuid)
                    break
                case "gDrive":
                    print(" multi gDrive")
                    containerViewController?.getMultiFolderArray(getArray:multiCheckedfolderArray, toStorage:"local_gdrive_multi", fromUserId:selectedDevUserId, fromOsCd:fromOsCd,fromDevUuid:selectedDevUuid)
                    break
                    
                case "delete":
                    print("multi local delete, selectedDevFoldrId : \(selectedDevFoldrId)")
                    NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
                    MultiCheckFileListController().callMultiLocalDelete(getFolderArray: multiCheckedfolderArray, parent: self, fromUserId:selectedDevUserId, devUuid: selectedDevUuid, deviceName: deviceName, devFoldrId:selectedDevFoldrId)
                    break
                default:
                    
                    break
                }
            } else if getFromOsCd == "G" || getFromOsCd == "S" {
                // NAS 멀티 메뉴 핸들
                switch getAction {
                case "download":
                    print("다운로드 multi")
                    NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
                    MultiCheckFileListController().callDwonLoad(getFolderArray: multiCheckedfolderArray, parent: self, devUuid: selectedDevUuid, deviceName: deviceName)
                    break
                case "nas":
                    
                    print("multi nas, fromUserId : \(selectedDevUserId)")
                    print("multiCheckedfolderArray : \(multiCheckedfolderArray)")
                    containerViewController?.getMultiFolderArray(getArray:multiCheckedfolderArray, toStorage:"nas_multi", fromUserId:selectedDevUserId, fromOsCd:fromOsCd,fromDevUuid:selectedDevUuid)
                    
                    break
                case "gDrive":
                    print(" multi gDrive")
                    break
                    
                case "delete":
                    print("multi delete, selectedDevFoldrId : \(selectedDevFoldrId)")
                    NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
                    
                    MultiCheckFileListController().callMultiDelete(getFolderArray: multiCheckedfolderArray, parent: self, fromUserId:selectedDevUserId, devUuid: selectedDevUuid, deviceName: deviceName, devFoldrId:selectedDevFoldrId)
                    break
                default:
                    
                    break
                }
            } else if getFromOsCd == "multi" {
                containerViewController?.getMultiFolderArray(getArray:multiCheckedfolderArray, toStorage:"multi_nas_multi", fromUserId:selectedDevUserId, fromOsCd:fromOsCd,fromDevUuid:selectedDevUuid)
            } else if getFromOsCd == "D"{
                //gdrive 멀티 핸들
                switch getAction {
                    case "download":
                        print("다운로드 multi gDrive")
                        NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
                        GdriveMultiCheckController().callDwonLoad(getFolderArray: gDriveMultiCheckedfolderArray, parent: self)
                        
                        break
                    case "nas":
                        print("gdrive_nas_multi 보내기")
                        containerViewController?.getGDriveMultiFolderArray(getArray:gDriveMultiCheckedfolderArray, toStorage:"기", fromUserId:selectedDevUserId, fromOsCd:fromOsCd,fromDevUuid:selectedDevUuid)
                        break
                    
                    default:

                        break
                }
            } else {
                // 리모트 멀티 메뉴 핸들
                switch getAction {
                case "download":
                    print("다운로드 multi remote")
                    remoteMultiFileDownloadedCount = multiCheckedfolderArray.count
                    let remoteDownLoadStyle = "remoteDownLoadMulti"
                    UserDefaults.standard.setValue(remoteDownLoadStyle, forKey: "remoteDownLoadStyle")
                    UserDefaults.standard.synchronize()

                    NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
                    MultiCheckFileListController().remoteMultiDownloadRequest(getFolderArray: multiCheckedfolderArray, parent: self, fromUserId:selectedDevUserId, devUuid: selectedDevUuid, deviceName: deviceName, devFoldrId:selectedDevFoldrId, fromOsCd:fromOsCd)
                    
                    break
                case "nas":
                    print("nas multi remote")
                    let remoteDownLoadStyle = "remoteDownLoadNasMulti"
                    UserDefaults.standard.setValue(remoteDownLoadStyle, forKey: "remoteDownLoadStyle")
                    UserDefaults.standard.synchronize()

                    containerViewController?.getMultiFolderArray(getArray:multiCheckedfolderArray, toStorage:"remote_nas_multi", fromUserId:selectedDevUserId, fromOsCd:fromOsCd,fromDevUuid:selectedDevUuid)
                    break
                    
                default:
                    
                    break
                }
                
            }
            
        }
    }
    
    
    func handleMultiCheckFromLatelyView() {
        print("multi_nas_multi")
        let remoteDownLoadStyle = "remoteDownLoadNasMulti"
        UserDefaults.standard.setValue(remoteDownLoadStyle, forKey: "remoteDownLoadStyle")
        UserDefaults.standard.synchronize()

        containerViewController?.getMultiFolderArray(getArray:multiCheckedfolderArray, toStorage:"multi_nas_multi", fromUserId:selectedDevUserId, fromOsCd:fromOsCd,fromDevUuid:selectedDevUuid)
    }
    
    @objc func countRemoteDownloadFinished(){
        print("countRemoteDownloadFinished")
        remoteMultiFileDownloadedCount -= 1
        if(remoteMultiFileDownloadedCount > 0){            
            print("remoteMultiFileDownloadedCount : \(remoteMultiFileDownloadedCount)")
            return
        }
        SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
            let alertController = UIAlertController(title: nil, message: "멀티 파일 다운로드를 성공하였습니다.", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel)
            alertController.addAction(yesAction)
            self.present(alertController, animated: true)
            print("download Success")
            
            
        }
        
    }
    
    
    
    
    //리모트 파일 컨텍스트 시작
    
    @objc func btnRemoteFileOptionClicked(sender:UIButton){
        showRemoteFileOption(tag:sender.tag)
    }
    
    //current state
    @objc func cellRemoteFileSwipeToLeft(sender:UIGestureRecognizer){
        if let button = sender.view as? UIButton {
            // use button
            print("tag : \(button.tag)")
            showRemoteFileOption(tag:button.tag)
        }
    }
    
    
    func showRemoteFileOption(tag:Int){
        hideAllOptions(tag: tag)
        let buttonRow = tag
        let indexPath = IndexPath(row: buttonRow, section: 0)
        let cell = deviceCollectionView.cellForItem(at: indexPath) as! RemoteFileListCell
        if(cell.optionSHowCheck == 0){
            let width = App.Size.optionWidth
            let spacing = (width - 240) / 4
            cell.spacing = spacing
            cell.optionShow(spacing: spacing, style: 0)
            cell.optionSHowCheck = 1
        } else {
            cell.optionHide()
            cell.optionSHowCheck = 0
        }
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func optionRemoteFileShowClicked(sender:UIButton){
        let buttonRow = sender.tag
        let indexPath = IndexPath(row: buttonRow, section: 0)
        let cell = deviceCollectionView.cellForItem(at: indexPath) as! RemoteFileListCell
        
        RemoteFileListCellController().remoteFileContextMenuCalled(cell: cell, indexPath: indexPath, sender: sender, folderArray: folderArray, deviceName: deviceName, parentView: "device", deviceView:self, userId: userId, fromOsCd: fromOsCd, currentDevUuid: selectedDevUuid, selectedDevUserId:selectedDevUserId, currentFolderId:  currentFolderId)
    }
    
    
    //리모트 파일 컨텍스트 종료
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return localFileArray.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let path = localFileArray[index].savedPath
        let url:URL = URL.init(fileURLWithPath: path)
        print("name : \(localFileArray[index].fileNm)")
        
        return url as QLPreviewItem
    }
    
    func schemeAvailable(scheme: String) -> Bool {
        if let url = URL(string: scheme) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
   
    
    @objc func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){
        
        if (gestureRecognizer.state != UIGestureRecognizerState.began){
            return
        }
        
        let p = gestureRecognizer.location(in: self.deviceCollectionView)
        print("long pressed")
        let indexPath:IndexPath = (self.deviceCollectionView?.indexPathForItem(at: p))!
        print("\(indexPath.row) selected")
        if(cellStyle == 2){
            let fileId = folderArray[indexPath.row].fileId
            let devUuid = folderArray[indexPath.row].devUuid
            let fileNm = folderArray[indexPath.row].fileNm
            let amdDate = folderArray[indexPath.row].amdDate
            let foldrWholePathNm = folderArray[indexPath.row].foldrWholePathNm
            let foldrId = String(folderArray[indexPath.row].foldrId)
            print("fromOsCd : \(fromOsCd)")
            if(fileId == 0){
            } else {
                if(devUuid == Util.getUuid()){
                    //로컬 롱 터치
                } else if fromOsCd == "S" || fromOsCd == "G" {
                    //nas 롱 터치
                    print("selectedFileId : \(folderArray[indexPath.row].fileId)")
                    let fileNm = folderArray[indexPath.row].fileNm
                    let fileId = "\(folderArray[indexPath.row].fileId)"
                    let foldrWholePathNm = "\(folderArray[indexPath.row].foldrWholePathNm)"
                    let amdDate = folderArray[indexPath.row].amdDate
                    let createdPath:URL = ContextMenuWork().createLocalFolder(folderName: "AppPlay")!
                    self.downloadFromNasToExcute(name: fileNm, path: foldrWholePathNm, fileId:fileId, amdDate:amdDate)
                    print("download and excute")
                    
                } else {
                    // 리모트 롱 터치
                    homeViewController?.homeViewToggleIndicator()
                    let remoteDownLoadStyle = "remoteDownLoadToExcute"
                    UserDefaults.standard.setValue(remoteDownLoadStyle, forKey: "remoteDownLoadStyle")
                    UserDefaults.standard.synchronize()
                    print("remoteDownLoad: \(String(describing: UserDefaults.standard.string(forKey: "remoteDownLoadStyle")))")
                    print("folder : \(folderArray[indexPath.row])")
                    print("fileId: \(fileId) , fromUserId : \(userId), fromDevUuid : \(selectedDevUuid), fromFoldr : \(foldrWholePathNm)")
                    let createdPath:URL = ContextMenuWork().createLocalFolder(folderName: "AppPlay")!
                    ContextMenuWork().remoteDownloadRequest(fromUserId: userId, fromDevUuid: selectedDevUuid, fromOsCd: fromOsCd, fromFoldr: foldrWholePathNm, fromFileNm: fileNm, fromFileId: String(fileId))
                }
              
            }
        }
        print("\(indexPath.row) selected")
        if(cellStyle == 2){
            print("RemoteFileListCell long touch")
        }
        
    }
    
    
    
    
    
    
 
    func googleSignInCheck(name:String, path:String, fileDict:[String:String]){
        if let googleEmail = UserDefaults.standard.string(forKey: "googleEmail"){
            
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
                if(loginState == "login"){
                    print("get file")
                    containerViewController?.googleSignInSegueState = .loginForSend
                    GIDSignIn.sharedInstance().signInSilently()
                    let fileDict = ["fileId":fileId, "fileNm":fileNm, "oldFoldrWholePathNm":foldrWholePathNm,"toStorageState":"googleDrive", "fromUserId":userId,"fromOsCd":fromOsCd]
                    print("fileDict : \(fileDict)")
                    NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
                    
                } else {
                    
                    print("login called")
                    containerViewController?.googleSignInSegueState = .loginForSend
                    containerViewController?.googleSignInAlertShow()
                }
                
            } else {
                containerViewController?.googleSignInSegueState = .loginForSend
                containerViewController?.googleSignInAlertShow()
            }
        } else {
            print("google email")
            containerViewController?.googleSignInSegueState = .loginForSend
            containerViewController?.googleSignInAlertShow()
        }
//        if GIDSignIn.sharedInstance().hasAuthInKeychain() == true {
//            GIDSignIn.sharedInstance().signInSilently()
//            print("sign in silently")
//            let fileDict = ["fileId":fileId, "fileNm":fileNm, "oldFoldrWholePathNm":foldrWholePathNm,"toStorageState":"googleDrive", "fromUserId":userId,"fromOsCd":fromOsCd]
//            
//            NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
//            
////            downloadFromNasToDrive(name: name, path: path)
//        } else {
//            print("need login")
//            NotificationCenter.default.post(name: Notification.Name("googleSignInAlertShow"), object: self)
//        }
    }
   
   
  
  
    func downloadFromNas(name:String, path:String, fileId:String){
//        NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
        homeViewController?.homeViewToggleIndicator()
        containerViewController?.showHalfBlackView(getContextMenuWork:contextMenuWork!)
        contextMenuWork?.downloadFromNas(userId:userId, fileNm:name, path:path, fileId:fileId){ responseObject, error in
            if let success = responseObject {
                print(success)
                if(success == "success"){
                    
                    DispatchQueue.main.async {
                        if(self.homeViewController?.indicatorAnimating)! {
                            self.homeViewController?.homeViewToggleIndicator()
                        }
//                        NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
                        let alertController = UIAlertController(title: nil, message: "파일 다운로드를 성공하였습니다.", preferredStyle: .alert)
                        let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel)
                        self.containerViewController?.alamofireCompleted()
                        SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
                        alertController.addAction(yesAction)
                        self.present(alertController, animated: true)
                    }
                } else {
//                    NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
                    if(self.homeViewController?.indicatorAnimating)! {
                        self.homeViewController?.homeViewToggleIndicator()
                    }
                    
                }
            }
            
            return
        }
    }
    
    
    
    
    func downloadFromNasToExcute(name:String, path:String, fileId:String, amdDate:String){
        ContextMenuWork().downloadFromNasToExcute(userId:userId, fileNm:name, path:path, fileId:fileId){ responseObject, error in
            if let success = responseObject {
                print(success)
                if(success.isEmpty){
                } else {
                    print("localUrl : \(success)")
                    let url:URL = URL(string: success)!
//                    self.documentController = UIDocumentInteractionController(url: url)
//                    self.documentController.presentOptionsMenu(from: CGRect.zero, in: self.view, animated: true)
                    let urlDict = ["url":url]
                    NotificationCenter.default.post(name: Notification.Name("openDocument"), object: self, userInfo: urlDict)
                    
                }
                
            }
            return
        }
    }
    
    
    func downloadFromRemote(userId:String, name:String, path:String, fileId:String){
        ContextMenuWork().downloadFromRemote(userId:userId, fileNm:name, path:path, fileId:fileId){ responseObject, error in
            if let success = responseObject {
                print(success)
                if(success == "success"){
                    SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: nil, message: "파일 다운로드를 성공하였습니다.", preferredStyle: .alert)
                        let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel)
                        alertController.addAction(yesAction)
                        print("download Success")
                        
                        
                    }
                }
            }
            return
        }
    }
    
   
    func deleteNasFile(param:[String:Any], foldrId:String){
        print(param)
        NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
        ContextMenuWork().deleteNasFile(parameters:param){ responseObject, error in
            if let obj = responseObject {
                print(obj)
                let json = JSON(obj)
                let message = obj.object(forKey: "message")
                print("\(message), \(json["statusCode"].int)")
                if let statusCode = json["statusCode"].int, statusCode == 100 {
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
                        self.showInsideList(userId: param["userId"] as! String, devUuid: param["devUuid"] as! String, foldrId: foldrId, deviceName:self.deviceName)
                        let alertController = UIAlertController(title: nil, message: "파일 삭제가 완료 되었습니다.", preferredStyle: .alert)
                        let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel)
                        alertController.addAction(yesAction)
                        self.present(alertController, animated: true)
                    }
                } else {
                    NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
                }
            }
            return
        }
    }
    
    
    
    
    
    func removeFile(path:String){
        let fileManager = FileManager.default        
        do {
            try fileManager.removeItem(atPath: path)
            
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }

 
    
    @objc func clickDeviceItem(stringIndexPathRow: NSNotification){
        
        if let stringIndexPathRow = stringIndexPathRow.userInfo?["indexPathRow"] as? String {
            if let indexPathRow = Int(stringIndexPathRow) {
                if(DeviceArray[indexPathRow].osCd == "D"){
                    mainContentState = .googleDriveList
                    cellStyle = 3
                    homeViewController?.cellStyle = 3
                    currentFolderId = "root"
                    homeViewController?.currentFolderId = currentFolderId
                    fromOsCd = "D"
                    homeViewController?.fromOsCd = "D"                    
                    print("google drive clicked")
                    
//                    let fileDict = ["state":"loginForList"]
//                    NotificationCenter.default.post(name: Notification.Name("googleSignInSegue"), object: self, userInfo: fileDict)
                    if let googleEmail = UserDefaults.standard.string(forKey: "googleEmail"){
                        
                        var accessToken = DbHelper().getAccessToken(email: googleEmail)
                        let getTokenTime = DbHelper().getTokenTime(email: googleEmail)
                        print("deviceclick item accessToken : \(accessToken), getTokenTime : \(getTokenTime)")
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
                            if(loginState == "login"){
                                print("get file")
                                containerViewController?.googleSignInSegueState = .loginForList
                                GIDSignIn.sharedInstance().signInSilently()
                            
                            } else {
                                
                                print("login called")
                                containerViewController?.googleSignInSegueState = .loginForList
                                containerViewController?.googleSignInAlertShow()
                            }

                        } else {
                            print("google email")
                            containerViewController?.googleSignInSegueState = .loginForList
                            containerViewController?.googleSignInAlertShow()
                        }
                    } else {
                        print("google email")
                        containerViewController?.googleSignInSegueState = .loginForList
                        containerViewController?.googleSignInAlertShow()
                    }

                    
                } else {
                    cellStyle = 2
                    homeViewController?.cellStyle = 2
                    mainContentState = .oneViewList
                    selectedDevUuid = DeviceArray[indexPathRow].devUuid
                    if(selectedDevUuid == Util.getUuid()){
                        contextMenuState = .local
                        print("contextMenuState local")
                    } else {
                        contextMenuState = .nas
                        print("contextMenuState nas")
                    }
                    userId = DeviceArray[indexPathRow].userId
                    selectedDevUserId = DeviceArray[indexPathRow].userId
                    deviceName = DeviceArray[indexPathRow].devNm
                    print("userId:\(userId)")
                    if(viewState == .home){
                        getRootFolder(userId:userId, devUuid: selectedDevUuid, deviceName:deviceName)
                    }
                    
                    let folderName = ["folderName":"\(DeviceArray[indexPathRow].devNm)","deviceName":deviceName, "devUuid":selectedDevUuid]
                    if(viewState == .home){
                        NotificationCenter.default.post(name: Notification.Name("setupFolderPathView"), object: self, userInfo: folderName)
                    }
                    searchStepState = .device
                    foldrWholePathNm = ""
                    fromOsCd = DeviceArray[indexPathRow].osCd
                    homeViewController?.fromOsCd = fromOsCd
                    homeViewController?.currentFolderId = currentFolderId
                    var state = HomeViewController.bottomListEnum.nasFileInfo
                    if(fromOsCd == "G" || fromOsCd == "S"){
                        state = HomeViewController.bottomListEnum.nasFileInfo
                    } else {
                        state = HomeViewController.bottomListEnum.remoteFileInfo
                        if(selectedDevUuid == Util.getUuid()){
                            state = HomeViewController.bottomListEnum.localFileInfo
                        }
                    }
                    Vc.dataFromContainer(containerData: indexPathRow, getStepState: searchStepState, getBottomListState: state, getStringId:id, getStringFolderPath: foldrWholePathNm, getCurrentDevUuid: selectedDevUuid, getCurrentFolderId: currentFolderId)
                    
                }
                
            }
        }
    }

    
   
    func getRootFolder(userId: String, devUuid: String, deviceName:String){
        self.folderIdArray.removeAll()
        self.folderNameArray.removeAll()
        self.localFileArray.removeAll()
        self.folderArray.removeAll()
         GetListFromServer().getFoldrList(devUuid: devUuid, userId:userId, deviceName:deviceName){ responseObject, error in
                if let obj = responseObject{
                    let json = JSON(obj)
                    if(json["listData"].exists()){
                        let serverList:[AnyObject] = json["listData"].arrayObject! as [AnyObject]
                        print("nasfolderList :\(serverList)")
                        for rootFolder in serverList{
                            
                            let foldrId = rootFolder["foldrId"] as? Int ?? 0
                            let stringFoldrId = String(foldrId)
                            let foldrNm = rootFolder["foldrNm"] as? String ?? "nil"
                            
                            let stringFoldrNm = String(foldrNm)
                            self.selectedDevFoldrId = stringFoldrId
                            let childCnt = rootFolder["childCnt"] as? Int ?? 0
                            let osCd = rootFolder["osCd"] as? String ?? "nil"
                            if (self.fromOsCd == "G"){
                                if stringFoldrNm != "Mobile"{
                                    self.folderIdArray.append(foldrId)
                                    self.folderNameArray.append(stringFoldrNm)
                                    self.showInsideList(userId: userId, devUuid: devUuid, foldrId: stringFoldrId, deviceName:deviceName)
                                }
                            } else if (self.fromOsCd == "W"){
                                let folder = App.FolderStruct(data: rootFolder as AnyObject)
                                print("folder : \(folder)")
                                self.folderIdArray.append(0)
                                self.folderNameArray.append(stringFoldrNm)
                                self.folderArray.append(folder)
                                self.cellStyle = 2
                                self.homeViewController?.cellStyle = 2
                                self.collectionviewCellSpcing()
                                self.currentFolderId = String(foldrId)
                                self.deviceCollectionView.reloadData()
                                self.deviceCollectionView.collectionViewLayout.invalidateLayout()
                                
                                
                            } else {
                                self.folderIdArray.append(foldrId)
                                self.folderNameArray.append(stringFoldrNm)
                                self.showInsideList(userId: userId, devUuid: devUuid, foldrId: stringFoldrId, deviceName:deviceName)
                            }
                            
                        }
                    }
                }
            
                return
            }
        
    }
   
    
    @objc func sortFolderList(sortState: NSNotification){
        if let getState = sortState.userInfo?["sortState"] as? String {
            
            print("getState: \(getState)")
            sortBy = getState
            showInsideList(userId: userId, devUuid: selectedDevUuid, foldrId: currentFolderId, deviceName: deviceName)
            
        }
    }
    
    @objc func refreshInsideList(folderIdDict:NSNotification){
        if let getfolderId = folderIdDict.userInfo?["foldrId"] as? String {
            if(mainContentState == .oneViewList) {
                print("refreshInsideList userId: \(self.userId), devUuid: \(self.selectedDevUuid), foldrId:\(getfolderId), deviceName : \(self.deviceName)")
                if(getfolderId == "0" || getfolderId.isEmpty) {
                    
                    // 리모트 디아비스 최상위 폴더
                    print("getRootFolder called")
                    cellStyle = 1
                    getRootFolder(userId: userId, devUuid: selectedDevUuid, deviceName: deviceName)
                }  else {
                    self.showInsideList(userId: self.userId, devUuid: selectedDevUuid, foldrId: getfolderId, deviceName:self.deviceName)
                }
            } else {
                showInsideListGDrive(userId: self.userId, devUuid: selectedDevUuid, foldrId: getfolderId, deviceName: self.deviceName)
            }
            
        }
    }
    
    func refreshSearchList(){
        homeViewController?.searchInAllCategory()
        
    }
    
  
    
    func showInsideList(userId: String, devUuid: String, foldrId: String, deviceName:String){
        self.folderArray.removeAll()
        var param = ["userId": userId, "devUuid":devUuid, "foldrId":foldrId,"sortBy":sortBy]
        print("showInsideParam : \(param)")
        if(folderIdArray.count > 1){
            let upFolder = App.FolderStruct(data: ["foldrNm":"..","foldrId":folderIdArray[folderIdArray.count-2],"userId":userId,"childCnt":0,"devUuid":devUuid,"foldrWholePathNm":"up","cretDate":"cretDate"] as [String : Any])
            self.folderArray.append(upFolder)
            if(folderIdArray.count == 1){
                param = ["userId": userId, "devUuid":devUuid]
            }
        }
        print("param : \(param)")
        GetListFromServer().showInsideFoldrList(params: param, deviceName:deviceName){ responseObject, error in
            let json = JSON(responseObject as? Any)
            if(json["listData"].exists()){
                let serverList:[AnyObject] = json["listData"].arrayObject as! [AnyObject]
//                print("serverList :\(serverList)")
                for list in serverList{
                    let folder = App.FolderStruct(data: list as AnyObject)
                    self.folderArray.append(folder)
                }
            }
            self.cellStyle = 2
            self.homeViewController?.cellStyle = 2
            self.currentFolderId = foldrId
            self.getFileList(userId: userId, devUuid: devUuid, foldrId: foldrId)
            return
        }
    }
    
    func getFileList(userId: String, devUuid: String, foldrId: String){
        let param:[String : Any] = ["userId": userId, "devUuid":devUuid, "foldrId":foldrId,"page":1,"sortBy":sortBy]
        GetListFromServer().getFileList(params: param){ responseObject, error in
            let json = JSON(responseObject!)
//            let message = responseObject?.object(forKey: "message")
            if(json["listData"].exists()){
                var listData = json["listData"]
//                print("listData : \(listData)")
                var serverList:[AnyObject] = json["listData"].arrayObject! as [AnyObject]
                for list in serverList{
                    let folder = App.FolderStruct(data: list as AnyObject)
                    self.folderArray.append(folder)
                }
            }
//            print("final folderArray : \(self.folderArray)")
            self.cellStyle = 2
            self.homeViewController?.cellStyle = 2
            self.homeViewController?.folderArray = self.folderArray
            self.homeViewController?.currentFolderId = self.currentFolderId
            self.collectionviewCellSpcing()
            self.deviceCollectionView.reloadData()
            self.deviceCollectionView.collectionViewLayout.invalidateLayout()
            return
        }
     
    }

  
    @objc func btnNasFolderOptionClicked(sender:UIButton){
        showNasFolderOption(tag:sender.tag)
    }
    
    @objc func cellFolderSwipeToLeft(sender:UIGestureRecognizer){
        
        print("swipe to left")
        if let button = sender.view as? UIButton {
            // use button
            print("tag : \(button.tag)")
            showNasFolderOption(tag:button.tag)
        }
    }
    
    
    func showNasFolderOption(tag:Int){
        hideAllOptions(tag: tag)
        let buttonRow = tag
        let indexPath = IndexPath(row: buttonRow, section: 0)
        let cell = deviceCollectionView.cellForItem(at: indexPath) as! NasFolderListCell
        if(cell.optionSHowCheck == 0){
            let width = App.Size.optionWidth
            let spacing = (width - 300) / 6
            cell.spacing = spacing
            cell.optionShow(spacing: spacing, style: 0)
            cell.optionSHowCheck = 1
        } else {
            cell.optionHide()
            cell.optionSHowCheck = 0
        }
        
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func optionNasFolderShowClicked(sender:UIButton){
        let buttonRow = sender.tag
        let indexPath = IndexPath(row: buttonRow, section: 0)
        let cell = deviceCollectionView.cellForItem(at: indexPath) as! NasFolderListCell
        
        NasFolderListCellController().NasFolderContextMenuCalled(cell: cell, indexPath: indexPath, sender: sender, folderArray: folderArray, deviceName: deviceName, parentView: "device", deviceView:self, userId: userId, fromOsCd: fromOsCd, currentDevUuid: selectedDevUuid, selectedDevUserId: selectedDevUserId, currentFolderId:  currentFolderId, containerView:containerViewController!)
    }
    
    @objc func showAlert(messageDict: NSNotification){
        if let getMessage = messageDict.userInfo?["message"] as? String {
            let alertController = UIAlertController(title: nil, message: getMessage, preferredStyle: .alert)
            let noAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel)
            alertController.addAction(noAction)
            self.present(alertController, animated: true)
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
            if(mainContentState == .googleDriveList){
                print("home device view sign in work")
                let today = Date()
                let stToday = Util.date(text: today)
                
                print("stToday : \(stToday)")
                let check = DbHelper().googleEmailExistenceCheck(email: user.profile.email)
                if(check){
                    let expireDate = GIDSignIn.sharedInstance().currentUser.authentication.accessTokenExpirationDate
                    accessToken = GIDSignIn.sharedInstance().currentUser.authentication.accessToken
                    DbHelper().googleAccessTokenUpdate(getEmail: user.profile.email, getAccessToken: accessToken, getTime:stToday)
                } else {
                    accessToken = GIDSignIn.sharedInstance().currentUser.authentication.accessToken
                    let expireDate = GIDSignIn.sharedInstance().currentUser.authentication.accessTokenExpirationDate
                    DbHelper().googleEmailToSqlite(getEmail: user.profile.email, getAccessToken : accessToken, getTime:stToday)
                    
                }
                print("logedIn")
                containerViewController?.getFiles(accessToken: accessToken, root: "root")
                
            }
           
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("stPartentContainerView :\(stPartentContainerView)")
    }
}
