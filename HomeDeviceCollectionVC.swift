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

class HomeDeviceCollectionVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, QLPreviewControllerDataSource, QLPreviewControllerDelegate, UIGestureRecognizerDelegate {
    var homeViewController: HomeViewController?
    var containerViewController:ContainerViewController?
    private let service = GTLRDriveService() // 0eun
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
    
    
    var listViewStyleState = HomeViewController.listViewStyleEnum.grid
    var flickState = HomeViewController.flickEnum.main
    var mainContentState = HomeViewController.mainContentsStyleEnum.oneViewList
    var LatelyUpdatedFileArray:[App.LatelyUpdatedFileStruct] = []
    var driveFileArray:[App.DriveFileStruct] = []
    var driveFolderIdArray:[String] = ["root"] // 0eun
    var driveFolderNameArray:[String] = ["root"] // 0eun
    
    
    
    @IBOutlet weak var deviceCollectionView: UICollectionView!

    
    var DeviceArray:[App.DeviceStruct] = []
    var folderArray:[App.FolderStruct] = []
    var fileArrayToDownload:[App.FolderStruct] = []
    var localFileArray:[App.LocalFiles] = []
    var folderIdArray = [Int]()
    var folderNameArray = [String]()
    var folderStep = 0
    
    var multiCheckedfolderArray:[App.FolderStruct] = []
    
    
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
    
    
    var folderIdsToDownLoad:[Int] = []
    var folderPathToDownLoad:[String] = []
    var getFolderFinish = false
    var viewState : HomeViewController.viewStateEnum = .home
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("HomeDeviceCollectionVC did load")
        
        if(viewState == .search){
            
            cellStyle = 2
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
                                               selector: #selector(multiSelectActive(multiDict:)),
                                               name: NSNotification.Name("multiSelectActive"),
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
            
            deviceCollectionView.reloadData()
            
        }
        
    }
    
    
    @objc func multiSelectActive(multiDict:NSNotification){
        if let getChecked = multiDict.userInfo?["multiChecked"] as? String {
            self.multiCheckedfolderArray.removeAll()
            print("multiChecked : \(getChecked)")
            if(getChecked == "true"){
                self.multiCheckListState = .active
            } else {
                self.multiCheckListState = .inActive
            }
            deviceCollectionView.reloadData()
            
        }
        
    }
    
    func collectionviewCellSpcing(){
        let width = UIScreen.main.bounds.width
        var cellWidth = (width - 35) / 2
        var height = cellWidth
        var minimumSpacing:CGFloat = 5
        let edgieInsets = UIEdgeInsets(top: 5, left: 15, bottom: 0, right: 15)
        switch listViewStyleState {
        case .grid:
            break
        case .list:
            cellWidth = width 
            height = 80.0
            minimumSpacing = 10
            if(cellStyle == 2 || flickState == .lately || viewState == .search){
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
                    }
                    if(DeviceArray[indexPath.row].osCd == "G" && DeviceArray[indexPath.row].logical != "nil"){
                        cell3.lblLogical.isHidden = false
                        cell3.lblLogical.text = "\(DeviceArray[indexPath.row].logical) 사용"
                    }
                    if(DeviceArray[indexPath.row].devUuid == Util.getUuid()){
                        cell3.lblMain.textColor = HexStringToUIColor().getUIColor(hex: "ff0000")
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
                    print("fromOsCd : \(fromOsCd)")
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
                                    cell4.btnOption.isHidden = false
                                    cell4.btnMultiCheck.isHidden = true
                                    cell4.btnMultiChecked = false
                                }
                                cells.append(cell4)
                                if(folderArray[indexPath.row].foldrNm == "..."){
                                    cell4.lblSub.isHidden = true
                                    cell4.btnOption.isHidden = true
                                    cell2.lblSub.isHidden = true
                                }
                            } else {
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
                                 if(folderArray[indexPath.row].foldrNm == "..."){
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
                            
                            if(folderArray[indexPath.row].foldrNm == "..."){
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
                    let imageString = Util.getGoogleImageString(mimeType: driveFileArray[indexPath.row].mimeType)
                    print("imageString : \(imageString), \(driveFileArray[indexPath.row].mimeType)")
                    cell2.lblMain.text = driveFileArray[indexPath.row].name
                    cell2.lblSub.text = driveFileArray[indexPath.row].name
                    cell2.ivMain.image = UIImage(named: imageString)
                    cell2.ivSub.image = UIImage(named: imageString)
                    let cell4 = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeDeviceCell4", for: indexPath) as! FileListCell
                    cell4.optionSHowCheck = 0
                    cell4.optionHide()
                    cells.append(cell4)
                    
                    cell4.lblMain.text = driveFileArray[indexPath.row].name
                    cell4.lblSub.text = driveFileArray[indexPath.row].name
                    cell4.ivSub.image = UIImage(named: imageString)
                    cell4.btnOption.isHidden = false
                    cell4.btnOption.tag = indexPath.row
                    cell4.btnOption.addTarget(self, action: #selector(btnNasOptionClicked(sender:)), for: .touchUpInside)
                    cell4.btnOptionRed.tag = indexPath.row
                    cell4.btnOptionRed.addTarget(self, action: #selector(btnNasOptionClicked(sender:)), for: .touchUpInside)
                    cell4.btnShow.tag = indexPath.row
                    cell4.btnShow.addTarget(self, action: #selector(optionShowClicked(sender:)), for: .touchUpInside)
                    cell4.btnDwnld.tag = indexPath.row
                    cell4.btnDwnld.addTarget(self, action: #selector(optionShowClicked(sender:)), for: .touchUpInside)
                    
                    cell4.btnNas.tag = indexPath.row
                    cell4.btnNas.addTarget(self, action: #selector(optionShowClicked(sender:)), for: .touchUpInside)
                    
                    cell4.btnGDrive.tag = indexPath.row
                    cell4.btnGDrive.addTarget(self, action: #selector(optionShowClicked(sender:)), for: .touchUpInside)
                    
                    
                    cell4.btnDelete.tag = indexPath.row
                    cell4.btnDelete.addTarget(self, action: #selector(optionShowClicked(sender:)), for: .touchUpInside)
                    
                    
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
            NotificationCenter.default.post(name: Notification.Name("clickDeviceItem"), object: self, userInfo: indexPathRow)
            
            var state = HomeViewController.bottomListEnum.nasFileInfo
            if(fromOsCd == "G" || fromOsCd == "S"){
                state = HomeViewController.bottomListEnum.nasFileInfo
            } else {
                state = HomeViewController.bottomListEnum.remoteFileInfo
                if(selectedDevUuid == Util.getUuid()){
                    state = HomeViewController.bottomListEnum.localFileInfo
                }
            }
            let stateDict = ["bottomState":"\(state)","fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":deviceName, "selectedDevUuid":selectedDevUuid, "fileNm":fileNm, "userId":userId, "foldrId":String(foldrId),"fromOsCd":fromOsCd, "cellStyle":"1", "currentFolderId":currentFolderId]
            print(stateDict)
            NotificationCenter.default.post(name: Notification.Name("bottomStateFromContainer"), object: self, userInfo: stateDict)
            
        } else if (cellStyle == 2){
            //            if(contextMenuState == .nas){
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
                    if(folderArray[indexPath.row].foldrNm == "..."){
                        folderIdArray.remove(at: folderIdArray.count-1)
                        folderNameArray.remove(at: folderNameArray.count-1)
                    } else {
                        self.folderIdArray.append(infoldrId)
                        self.folderNameArray.append(folderNm)
                    }
                    var folderNameArrayCount = 0
                    if(folderNameArray.count < 1){
                        
                    } else {
                        folderNameArrayCount = folderNameArray.count-1
                    }
                    let folderName = ["folderName":"\(folderNameArray[folderNameArrayCount])","deviceName":deviceName]
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
            
        } else if cellStyle == 3 { // 구글드라이브 폴더,파일 셀
            let mimeType = driveFileArray[indexPath.row].mimeType
            let fileId = driveFileArray[indexPath.row].fileId
            let name = driveFileArray[indexPath.row].name
            
            if mimeType.contains(".folder") { // 폴더
                
                let stringFoldrId = String(fileId)
                if driveFileArray[indexPath.row].name == ".." {
                    driveFolderIdArray.remove(at: driveFolderIdArray.count-1)
                    driveFolderNameArray.remove(at: driveFolderNameArray.count-1)
                } else {
                    self.driveFolderIdArray.append(fileId)
                    self.driveFolderNameArray.append(name)
                }
                var driveFolderNameArrayCount = 0
                if driveFolderNameArray.count < 1 {
                    
                } else {
                    driveFolderNameArrayCount = driveFolderNameArray.count - 1
                }
                let folderName = ["folderName":"\(driveFolderNameArray[driveFolderNameArrayCount])","deviceName":deviceName]
                NotificationCenter.default.post(name: Notification.Name("setupFolderPathView"), object: self, userInfo: folderName)
                self.showInsideListGDrive(userId: userId, devUuid: selectedDevUuid, foldrId: stringFoldrId, deviceName: deviceName)
                searchStepState = .folder
                let state = HomeViewController.bottomListEnum.localFileInfo
                //수정 요망
                Vc.dataFromContainer(containerData: indexPath.row, getStepState: searchStepState, getBottomListState: state, getStringId:id, getStringFolderPath: foldrWholePathNm, getCurrentDevUuid: selectedDevUuid, getCurrentFolderId: currentFolderId)
            } else { // 파일
                
            }
        }
        // 0eun - end
        
        
        collectionviewCellSpcing()
        deviceCollectionView.reloadData()
        
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
        LocalFileListCellController().localContextMenuCalled(cell: cell, indexPath: indexPath, sender: sender, folderArray: folderArray, deviceName: deviceName, parentView: "device", deviceView:self, userId: userId, fromOsCd: fromOsCd, currentDevUuid: selectedDevUuid, currentFolderId:  currentFolderId)
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
        LocalFolderListCellController().LocalFolderContextMenuCalled(cell: cell, indexPath: indexPath, sender: sender, folderArray: folderArray, deviceName: deviceName, parentView: "device", deviceView:self, userId: userId, fromOsCd: fromOsCd, currentDevUuid: selectedDevUuid, selectedDevUserId: selectedDevUuid, currentFolderId:  currentFolderId)
    }
    
    //로컬 폴더 컨텍스트 종료
    
    
    @objc func optionShowClicked(sender:UIButton){
        let buttonRow = sender.tag
        let indexPath = IndexPath(row: buttonRow, section: 0)
        let cell = deviceCollectionView.cellForItem(at: indexPath) as! FileListCell
         self.gDriveContextMenuCalled(cell: cell, indexPath: indexPath, sender:sender)
    }
    // 0eun - start
    func gDriveContextMenuCalled(cell:FileListCell, indexPath:IndexPath, sender:UIButton){
        
        fileId = String(driveFileArray[indexPath.row].fileId)
        
        var btn = "show"
        switch sender {
        case cell.btnShow:
            btn = "show"
        case cell.btnAction:
            btn = "btnAction"
            let mailURL = URL(string: "photos-redirect://")!
            if UIApplication.shared.canOpenURL(mailURL) {
                UIApplication.shared.openURL(mailURL)
            }
        case cell.btnDwnld:
            let fileId = driveFileArray[indexPath.row].fileId
            let mimeType = driveFileArray[indexPath.row].mimeType
            let name = driveFileArray[indexPath.row].name
            downloadGDriveFile(fileId: fileId, mimeType:mimeType, name:name)
        case cell.btnNas:
            let fileId = driveFileArray[indexPath.row].fileId
            let mimeType = driveFileArray[indexPath.row].mimeType
            let name = driveFileArray[indexPath.row].name
            
            let fileDict = ["fileId":fileId, "fileNm":name,"amdDate":"", "oldFoldrWholePathNm":foldrWholePathNm,"state":"googleDrive","fromUserId":userId, "fromOsCd":fromOsCd]
            print("fileDict : \(fileDict)")
            NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
            //showLocalFileOption(tag: sender.tag)
            
            uploadNasGDriveFile(fileId: fileId, mimeType:mimeType, name:name)
        case cell.btnGDrive:
            btn = ""
        case cell.btnDelete:
            let alertController = UIAlertController(title: nil, message: "해당 파일을 삭제 하시겠습니까?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) { UIAlertAction in
                self.deleteGDriveFile(fileId: self.fileId)
                // 싱크 필요~
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    let alertController = UIAlertController(title: nil, message: "파일 삭제가 완료 되였습니다.", preferredStyle: .alert)
                    let yesAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        
                        self.showInsideList(userId: self.userId, devUuid: self.selectedDevUuid, foldrId: self.currentFolderId, deviceName: self.deviceName)
                        
                    }
                    alertController.addAction(yesAction)
                    self.present(alertController, animated: true)
                })
            }
            let noAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel)
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            
            self.present(alertController, animated: true)
            
        default:
            break
        }
    }
    
    func uploadNasGDriveFile(fileId:String, mimeType:String, name:String) {
        accessToken = UserDefaults.standard.string(forKey: "accessToken")!
        let stringUrl = "https://www.googleapis.com/drive/v3/files/\(fileId)/?alt=media&access_token=\(accessToken)"
        print("stringUrl : \(stringUrl)")
        
        let downloadUrl = URL(string: stringUrl)
    }
    
    // 구글드라이브 파일 다운로드, 기가나스 보내기
    func downloadGDriveFile(fileId:String, mimeType:String, name:String) {
        accessToken = UserDefaults.standard.string(forKey: "accessToken")!
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
                }
        }
    }
    
    // 구글드라이브 파일 구글드라이브로 보내기(카피)
    func gDriveSendGDrive() {
        
    }
    
    // 구글드라이브 파일 삭제
    func deleteGDriveFile(fileId:String) {
        accessToken = UserDefaults.standard.string(forKey: "accessToken")!
        let url = "https://www.googleapis.com/drive/v3/files/\(fileId)"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + accessToken
        ]
        Alamofire.request(url,
                          method: .delete,
                          //parameters: {},
            encoding : JSONEncoding.default,
            headers:headers
            ).responseJSON{ (response) in
                print(response)
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if (json["code"].string != nil) {
                        print(json["code"])
                    } else {
                        print("파일을 삭제하였습니다.")
                        
                        self.deviceCollectionView.reloadData()
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    // 0eun - end
    
    func finishedFileDownload(fetcher: GTMSessionFetcher, finishedWithData data: NSData, error: NSError?){
        if let error = error {
            //show an alert with the error message or something similar
            return
        }
        
        //do something with data (save it...)
    }
    @objc func optionNasFileShowClicked(sender:UIButton){
        let buttonRow = sender.tag
        let indexPath = IndexPath(row: buttonRow, section: 0)
        let cell = deviceCollectionView.cellForItem(at: indexPath) as! NasFileListCell
//        self.nasContextMenuCalled(cell: cell, indexPath: indexPath, sender:sender)
        NasFileCellController().nasContextMenuCalled(cell: cell, indexPath: indexPath, sender: sender, folderArray: folderArray, deviceName: deviceName, parentView: "device", deviceView:self, userId: userId, fromOsCd: fromOsCd, currentDevUuid: selectedDevUuid, selectedDevUserId: selectedDevUserId, currentFolderId:  currentFolderId)
        
    }
    
    @objc func btnMultiCheckClicked(sender:UIButton){
        let buttonRow = sender.tag
        let indexPath = IndexPath(row: buttonRow, section: 0)
//        print("superview : \(sender.superview?.superview)")
        if let superView = sender.superview as? NasFileListCell {
            let cell = deviceCollectionView.cellForItem(at: indexPath) as! NasFileListCell
            if(cell.btnMultiChecked){
                cell.btnMultiChecked = false
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                cell.btnMultiChecked = true
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            }
            multiCheckedFolderArray(indexPath:indexPath, check:cell.btnMultiChecked)
        } else if let superView = sender.superview as? NasFolderListCell {
            let cell = deviceCollectionView.cellForItem(at: indexPath) as! NasFolderListCell
            if(cell.btnMultiChecked){
                cell.btnMultiChecked = false
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                cell.btnMultiChecked = true
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            }
            multiCheckedFolderArray(indexPath:indexPath, check:cell.btnMultiChecked)
        } else if let superView = sender.superview as? CollectionViewGridCell {
            let cell = deviceCollectionView.cellForItem(at: indexPath) as! CollectionViewGridCell
            if(cell.btnMultiChecked){
                cell.btnMultiChecked = false
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                cell.btnMultiChecked = true
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            }
            multiCheckedFolderArray(indexPath:indexPath, check:cell.btnMultiChecked)
        } else if let superView = sender.superview as? RemoteFileListCell {
            let cell = deviceCollectionView.cellForItem(at: indexPath) as! RemoteFileListCell
            if(cell.btnMultiChecked){
                cell.btnMultiChecked = false
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                cell.btnMultiChecked = true
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            }
            multiCheckedFolderArray(indexPath:indexPath, check:cell.btnMultiChecked)
        } else if let superView = sender.superview as? LocalFileListCell {
            let cell = deviceCollectionView.cellForItem(at: indexPath) as! LocalFileListCell
            if(cell.btnMultiChecked){
                cell.btnMultiChecked = false
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                cell.btnMultiChecked = true
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            }
            multiCheckedFolderArray(indexPath:indexPath, check:cell.btnMultiChecked)
        } else if let superView = sender.superview as? LocalFolderListCell {
            let cell = deviceCollectionView.cellForItem(at: indexPath) as! LocalFolderListCell
            if(cell.btnMultiChecked){
                cell.btnMultiChecked = false
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                cell.btnMultiChecked = true
                cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
            }
            multiCheckedFolderArray(indexPath:indexPath, check:cell.btnMultiChecked)
        }
        
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
       
        
        homeViewController?.setMultiCountLabel(multiButtonChecked: true, count: multiCheckedfolderArray.count)
        print("multiCheckedfolderArray : \(multiCheckedfolderArray)")
    }
    
    @objc func handleMultiCheckFolderArray(fileDict:NSNotification) {
        if let getAction = fileDict.userInfo?["action"] as? String, let getFromOsCd = fileDict.userInfo?["fromOsCd"] as? String {
            if(selectedDevUuid == Util.getUuid()){
                switch getAction {
                case "nas":
                    print("local to nas multi, fromUserId : \(selectedDevUserId)")
                    containerViewController?.getMultiFolderArray(getArray:multiCheckedfolderArray, toStorage:"local_nas_multi", fromUserId:selectedDevUserId, fromOsCd:fromOsCd,fromDevUuid:selectedDevUuid)
                    break
                case "gDrive":
                    print(" multi gDrive")
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
    
    
    @objc func countRemoteDownloadFinished(){
        print("countRemoteDownloadFinished")
        remoteMultiFileDownloadedCount -= 1
        if(remoteMultiFileDownloadedCount > 0){            
            print("remoteMultiFileDownloadedCount : \(remoteMultiFileDownloadedCount)")
            return
        }
        SyncLocalFilleToNas().sync()
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
        
        if let indexPath : NSIndexPath = (self.deviceCollectionView?.indexPathForItem(at: p))! as NSIndexPath{
            //do whatever you need to do
            print("\(indexPath.row) selected")
            if(cellStyle == 2){
                let fileId = folderArray[indexPath.row].fileId
                
                if(fileId == 0){
                } else {
                    print("selectedFileId : \(folderArray[indexPath.row].fileId)")
                    let fileNm = folderArray[indexPath.row].fileNm
                    let fileId = "\(folderArray[indexPath.row].fileId)"
                    let foldrWholePathNm = "\(folderArray[indexPath.row].foldrWholePathNm)"
                    let amdDate = folderArray[indexPath.row].amdDate
                    self.downloadFromNasToExcute(name: fileNm, path: foldrWholePathNm, fileId:fileId, amdDate:amdDate)
                    print("download and excute")
                }
            }
        }
        
    }
    
    
    
    
    
 
    func googleSignInCheck(name:String, path:String, fileDict:[String:String]){
        if GIDSignIn.sharedInstance().hasAuthInKeychain() == true {
            GIDSignIn.sharedInstance().signInSilently()
            print("sign in silently")
//            let fileDict = ["fileId":fileId, "fileNm":fileNm, "oldFoldrWholePathNm":foldrWholePathNm,"toStorageState":"googleDrive", "fromUserId":userId,"fromOsCd":fromOsCd]
            
            NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
            
//            downloadFromNasToDrive(name: name, path: path)
        } else {
            print("need login")
            NotificationCenter.default.post(name: Notification.Name("googleSignInAlertShow"), object: self)
        }
    }
   
   
    func downloadFromDrive(fileId:String, mimeType:String, name:String){
        accessToken = UserDefaults.standard.string(forKey: "accessToken")!
        print("fileId : \(fileId), mimeType : \(mimeType)")
        let stringUrl = "https://www.googleapis.com/drive/v3/files/\(fileId)/?alt=media&access_token=\(accessToken)"
        print("stringUrl : \(stringUrl)")
        var saveFileNm = ""
        saveFileNm = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let downloadUrl = URL(string: stringUrl)
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            // the name of the file here I kept is yourFileName with appended extension
            documentsURL.appendPathComponent("\(saveFileNm)")
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
//                        self.sendToNasFromLocal(fileURL: response.destinationURL!, name:name)
                    }
                }
        
    }
    
  
    func downloadFromNas(name:String, path:String, fileId:String){
        NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
        ContextMenuWork().downloadFromNas(userId:userId, fileNm:name, path:path, fileId:fileId){ responseObject, error in
            if let success = responseObject {
                print(success)
                if(success == "success"){
                    
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
                        let alertController = UIAlertController(title: nil, message: "파일 다운로드를 성공하였습니다.", preferredStyle: .alert)
                        let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel)
                        
                        SyncLocalFilleToNas().sync()
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
    
    func downloadFromNasToExcute(name:String, path:String, fileId:String, amdDate:String){
        ContextMenuWork().downloadFromNas(userId:userId, fileNm:name, path:path, fileId:fileId){ responseObject, error in
            if let success = responseObject {
                print(success)
                if(success == "success"){
                    SyncLocalFilleToNas().sync()
                    
                    let url:URL = FileUtil().getFileUrl(fileNm: name, amdDate: amdDate)!
                    self.documentController = UIDocumentInteractionController(url: url)
                    self.documentController.presentOptionsMenu(from: CGRect.zero, in: self.view, animated: true)
                    
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
                    SyncLocalFilleToNas().sync()
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
                if(indexPathRow == DeviceArray.count-1){
                    print("google drive clicked")
                    let fileDict = ["state":"loginForList"]
                    NotificationCenter.default.post(name: Notification.Name("googleSignInSegue"), object: self, userInfo: fileDict)
                } else {
                    
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
                    getRootFolder(userId:userId, devUuid: selectedDevUuid, deviceName:deviceName)
                    let folderName = ["folderName":"\(DeviceArray[indexPathRow].devNm)","deviceName":deviceName]
                    NotificationCenter.default.post(name: Notification.Name("setupFolderPathView"), object: self, userInfo: folderName)
                    searchStepState = .device
                    foldrWholePathNm = ""
                    fromOsCd = DeviceArray[indexPathRow].osCd
                    homeViewController?.fromOsCd = fromOsCd
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
            print("refreshInsideList userId: \(self.userId), devUuid: \(self.selectedDevUuid), foldrId:\(getfolderId), deviceName : \(self.deviceName)")
            self.showInsideList(userId: self.userId, devUuid: selectedDevUuid, foldrId: getfolderId, deviceName:self.deviceName)
        }
        
        
    }
    
    // 0eun - start
    func showInsideListGDrive(userId: String, devUuid: String, foldrId: String, deviceName:String){
        self.driveFileArray.removeAll()
        var param = ["userId": userId, "devUuid":devUuid, "foldrId":foldrId,"sortBy":sortBy]
        accessToken = UserDefaults.standard.string(forKey: "accessToken")!
        print("showInsideParam : \(param)")
        
        if(driveFolderIdArray.count > 1){
            
            let upFolder = App.DriveFileStruct(device: ["id":driveFolderIdArray[driveFolderIdArray.count-2],"kind":"drive#file","mimeType":".folder","name":".."] as AnyObject)
            self.driveFileArray.append(upFolder)
            if(driveFolderIdArray.count == 1){
                param = ["userId": userId, "devUuid":devUuid]
            }
        }
        print("param : \(param)")
        
        var url = "https://www.googleapis.com/drive/v3/files?q='\(foldrId)' in parents and trashed=false&access_token=\(accessToken)&orderBy=folder,createdTime desc"
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
                                    print("file : \(file)")
                                    let fileStruct = App.DriveFileStruct(device: file)
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
    // 0eun - end
    
    func showInsideList(userId: String, devUuid: String, foldrId: String, deviceName:String){
        self.folderArray.removeAll()
        var param = ["userId": userId, "devUuid":devUuid, "foldrId":foldrId,"sortBy":sortBy]
        print("showInsideParam : \(param)")
        if(folderIdArray.count > 1){
            let upFolder = App.FolderStruct(data: ["foldrNm":"...","foldrId":folderIdArray[folderIdArray.count-2],"userId":userId,"childCnt":0,"devUuid":devUuid,"foldrWholePathNm":"up","cretDate":"cretDate"] as [String : Any])
            self.folderArray.append(upFolder)
            if(folderIdArray.count == 1){
                param = ["userId": userId, "devUuid":devUuid]
            }
        }
        print("param : \(param)")
        GetListFromServer().showInsideFoldrList(params: param, deviceName:deviceName){ responseObject, error in
            let json = JSON(responseObject!)
            if(json["listData"].exists()){
                let serverList:[AnyObject] = json["listData"].arrayObject as! [AnyObject]
//                print("serverList :\(serverList)")
                for list in serverList{
                    let folder = App.FolderStruct(data: list as AnyObject)
                    self.folderArray.append(folder)
                }
            }
            self.cellStyle = 2
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
        
        NasFolderListCellController().NasFolderContextMenuCalled(cell: cell, indexPath: indexPath, sender: sender, folderArray: folderArray, deviceName: deviceName, parentView: "device", deviceView:self, userId: userId, fromOsCd: fromOsCd, currentDevUuid: selectedDevUuid, selectedDevUserId: selectedDevUserId, currentFolderId:  currentFolderId)
    }
    
    @objc func showAlert(messageDict: NSNotification){
        if let getMessage = messageDict.userInfo?["message"] as? String {
            let alertController = UIAlertController(title: nil, message: getMessage, preferredStyle: .alert)
            let noAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel)
            alertController.addAction(noAction)
            self.present(alertController, animated: true)
        }
    }
    
    
}
