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
    var searchedText = ""
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
    var selectedDevOsCd = ""
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
    var driveArrayFolder:[App.DriveFileStruct] = []
    var driveArrayWithoutUpfolder:[App.DriveFileStruct] = []
    var driveFolderIdArray:[String] = ["root"] // 0eun
    var driveFolderNameArray:[String] = ["Google"] // 수정
    var request: Alamofire.Request?
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var gDriveUpFolder:App.DriveFileStruct?
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
    var viewState : HomeViewController.viewStateEnum = .lately
    var tapGesture:UITapGestureRecognizer = UITapGestureRecognizer()
    let halfBlackView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.alpha = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view;
    }()
    var selectAllCheck = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("HomeDeviceCollectionVC did load")
        contextMenuWork = ContextMenuWork()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        
        print("viewstate : \(viewState)")
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
        
        
        
        
        loginCookie = UserDefaults.standard.string(forKey: "cookie")!
        loginToken = UserDefaults.standard.string(forKey: "token")!
        userId = UserDefaults.standard.string(forKey: "userId")!
        
//        print("deviceList: \(DeviceArray)")
        self.collectionviewCellSpcing()
        DispatchQueue.main.async {
            self.deviceCollectionView.reloadData()
        }
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sortFolderList),
                                               name: NSNotification.Name("sortFolderList"),
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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setMultiProgressFileDict),
                                               name: NSNotification.Name("setMultiProgressFileDict"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setGdriveMultiProgressFileDict),
                                               name: NSNotification.Name("setGdriveMultiProgressFileDict"),
                                               object: nil)
        
        
        

        FileManager.default.clearTmpDirectory()
        
    }
    @objc func setGdriveMultiProgressFileDict(fileDict:NSNotification) {
        if let getDriveMultiCheckedfolderArray = fileDict.userInfo?["getDriveMultiCheckedfolderArray"] as? [App.DriveFileStruct] {
            gDriveMultiCheckedfolderArray = getDriveMultiCheckedfolderArray
        }
        
        var fileIdArryStr = ""
        var fileSizeArryStr = ""
        var fileNmArryStr = ""
        var fileEtsionmArryStr = ""
        if gDriveMultiCheckedfolderArray.count > 0 {
            for arryIndex in 0...gDriveMultiCheckedfolderArray.count-1 {
                
                let id = gDriveMultiCheckedfolderArray[arryIndex].fileId
                let name = gDriveMultiCheckedfolderArray[arryIndex].name
                
                if arryIndex == gDriveMultiCheckedfolderArray.count-1 {
                    fileIdArryStr += "\(id)"
                    fileSizeArryStr += gDriveMultiCheckedfolderArray[arryIndex].size
                    fileNmArryStr += name
                    fileEtsionmArryStr += gDriveMultiCheckedfolderArray[arryIndex].fileExtension
                } else {
                    fileIdArryStr += "\(id):"
                    fileSizeArryStr += "\(gDriveMultiCheckedfolderArray[arryIndex].size):"
                    fileNmArryStr += "\(name):"
                    fileEtsionmArryStr += "\(gDriveMultiCheckedfolderArray[arryIndex].fileExtension):"
                }
            }
            let fileDict = ["fileIdArryStr":fileIdArryStr, "fileSizeArryStr":fileSizeArryStr,"fileNmArryStr":fileNmArryStr,"fileEtsionmArryStr":fileEtsionmArryStr]
            print("gdriveMultiProgressSegue fileDict : \(fileDict)")
            NotificationCenter.default.post(name: Notification.Name("multiProgressSegue"), object: self, userInfo: fileDict)
        }
        
    }
    
    @objc func setMultiProgressFileDict(fileDict:NSNotification) {
        if let getMultiCheckedfolderArray = fileDict.userInfo?["getMultiCheckedfolderArray"] as? [App.FolderStruct] {
            multiCheckedfolderArray = getMultiCheckedfolderArray
        }
        
        var fileIdArryStr = ""
        var fileSizeArryStr = ""
        var fileNmArryStr = ""
        var fileEtsionmArryStr = ""
        for arryIndex in 0...multiCheckedfolderArray.count-1 {
            
            var id = multiCheckedfolderArray[arryIndex].fileId
            var name = multiCheckedfolderArray[arryIndex].fileNm
            if id == 0 {
                id = multiCheckedfolderArray[arryIndex].foldrId
                name = multiCheckedfolderArray[arryIndex].foldrNm
            }
            
            if arryIndex == multiCheckedfolderArray.count-1 {
                fileIdArryStr += "\(id)"
                fileSizeArryStr += multiCheckedfolderArray[arryIndex].fileSize
                fileNmArryStr += name
                fileEtsionmArryStr += multiCheckedfolderArray[arryIndex].etsionNm
            } else {
                fileIdArryStr += "\(id):"
                fileSizeArryStr += "\(multiCheckedfolderArray[arryIndex].fileSize):"
                fileNmArryStr += "\(name):"
                fileEtsionmArryStr += "\(multiCheckedfolderArray[arryIndex].etsionNm):"
            }
        }
        let fileDict = ["fileIdArryStr":fileIdArryStr, "fileSizeArryStr":fileSizeArryStr,"fileNmArryStr":fileNmArryStr,"fileEtsionmArryStr":fileEtsionmArryStr]
        print("multiProgressSegue fileDict : \(fileDict)")
        NotificationCenter.default.post(name: Notification.Name("multiProgressSegue"), object: self, userInfo: fileDict)
    }
    
    

    
    
    @objc func changeListStyle(fileDict:NSNotification){
        if let getStyle = fileDict.userInfo?["style"] as? String , let getCellStyle = fileDict.userInfo?["cellStyle"] as? String {
            cellStyle = Int(getCellStyle)!
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
            DispatchQueue.main.async {
                self.deviceCollectionView.reloadData()
            }
            
            
        }
        
    }
    
    func changeListStyle2(getStyle:String, getCellStyle: Int){
        print("changeListStyle2 called")
            if(getStyle == "list"){
                self.listViewStyleState = .list
            } else {
                self.listViewStyleState = .grid
            }
            self.cellStyle = getCellStyle
        
            
            if(multiCheckListState == .active){
                if(flickState == .main){
                    homeViewController?.btnMulticlicked()
                } else {
                    latelyUpdatedFileViewController?.btnMulticlicked()
                }
            }
        collectionviewCellSpcing()
        DispatchQueue.main.async {
            self.deviceCollectionView.reloadData()
        }
        
        
    }
    
    
    func multiSelectActive(multiButtonActive:Bool){
//        if let getChecked = multiDict.userInfo?["multiChecked"] as? String {
            self.multiCheckedfolderArray.removeAll()
            self.gDriveMultiCheckedfolderArray.removeAll()
            print("viewState : \(viewState)")
            print("multiChecked : \(multiButtonActive)")
            if(multiButtonActive){
                self.multiCheckListState = .active
                if(viewState == .search){
                    cellStyle = 2
                }
                
                print("cellStyle in multiSelectActive : \(cellStyle)")
            } else {
                self.multiCheckListState = .inActive
                for (index, folder) in driveFileArray.enumerated() {
                    driveFileArray[index].checked = false
                }
                for (index, folder) in folderArray.enumerated() {
                    folderArray[index].checked = false
                }
            
                print("cellStyle in multiSelectActive : \(cellStyle)")
            }
        
        DispatchQueue.main.async {
            self.deviceCollectionView.reloadData()
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
            
//            self.deviceCollectionView.backgroundColor = UIColor.clear

            break
        case .list:
//            self.deviceCollectionView.backgroundColor = HexStringToUIColor().getUIColor(hex: "ffffff")

            cellWidth = width 
            height = 80.0
            minimumSpacing = 10
            if(cellStyle == 2 || flickState == .lately || viewState == .search || cellStyle == 3){
                height = 60.0
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
        print("didReceiveMemoryWarning called")
        request?.cancel()
        
        
        // Dispose of any resources that can be recreated.
    }
    func report_memory() {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            print("Memory used in bytes: \(taskInfo.resident_size)")
            if taskInfo.resident_size < 100000000 {
                print("request resuem")
                self.request?.resume()
            }
            
        }
        else {
            print("Error with task_info(): " +
                (String(cString: mach_error_string(kerr), encoding: String.Encoding.ascii) ?? "unknown error"))
        }
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
//        print("cellStyle : \(cellStyle)")
//        print("deviceName: \(deviceName)")
        switch mainContentState {
        case .oneViewList:
            if(cellStyle == 1){
                let imageString = Util.getDeviceImageString(osNm: DeviceArray[indexPath.row].osNm, onoff: DeviceArray[indexPath.row].onoff)
//                print("oneViewList cell : \(viewState)")
                cell1.deviceImage.image = UIImage(named: imageString)
                cell1.lblMain.text = DeviceArray[indexPath.row].devNm
                //cell1.lblSub.isHidden = true
                cell3.ivSub.image = UIImage(named: imageString)
                cell3.lblMain.text = DeviceArray[indexPath.row].devNm
                if(DeviceArray[indexPath.row].newFlag == "Y"){
                    cell3.ivFlagNew.isHidden = false
                    cell1.ivFlagNew.isHidden = false
                    
                } else {
                    cell3.ivFlagNew.isHidden = true
                    cell1.ivFlagNew.isHidden = true
                }
                if(DeviceArray[indexPath.row].osCd == "G" && DeviceArray[indexPath.row].logical != "nil"){
                    cell3.lblLogical.isHidden = false
                    cell3.lblLogical.text = "\(DeviceArray[indexPath.row].logical) 사용"
                    cell1.lblSub.isHidden = false
                    cell1.lblSub.text = "\(DeviceArray[indexPath.row].logical) 사용"
                } else {
                    cell3.lblLogical.isHidden = true
                    cell1.lblSub.isHidden = true
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
//                cell3.lblSub.isHidden = false
//                if indexPath.row < folderArray.count {
//
//                }
//                cell2.lblMain.text = folderArray[indexPath.row].foldrNm
//                cell2.lblSub.text = folderArray[indexPath.row].amdDate
//                cell3.lblSub.text = folderArray[indexPath.row].amdDate
                if indexPath.row < folderArray.count {
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
                                if listViewStyleState == .list {
                                    
                                    cell4.btnOption.isHidden = false
                                    cell4.btnShow.tag = indexPath.row
                                    cell4.btnShow.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionRemoteFileShowClicked(sender:)), for: .touchUpInside)
                                    cell4.btnAction.tag = indexPath.row
                                    cell4.btnAction.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionRemoteFileShowClicked(sender:)), for: .touchUpInside)
                                    cell4.btnDwnld.tag = indexPath.row
                                    cell4.btnDwnld.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionRemoteFileShowClicked(sender:)), for: .touchUpInside)
                                    cell4.btnNas.tag = indexPath.row
                                    cell4.btnNas.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionRemoteFileShowClicked(sender:)), for: .touchUpInside)
                                    cell4.btnGDrive.tag = indexPath.row
                                    cell4.btnGDrive.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionRemoteFileShowClicked(sender:)), for: .touchUpInside)
                                    cell4.btnDelete.tag = indexPath.row
                                    cell4.btnDelete.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionRemoteFileShowClicked(sender:)), for: .touchUpInside)
                                    
                                    if (multiCheckListState == .active){
                                        
                                        cell4.btnMultiCheck.isHidden = false
                                        cell4.btnMultiCheckLeadingAnchor?.isActive = false
                                        cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: 36)
                                        cell4.btnMultiCheckLeadingAnchor?.isActive = true
                                        cell4.btnMultiCheck.tag = indexPath.row
                                        cell4.btnMultiCheck.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnMultiCheckClicked(sender:)), for: .touchUpInside)
                                        cell4.btnOption.isHidden = true
                                        cell4.lblDevice.isHidden = true
                                    } else {
                                        cell4.resetMultiCheck()
                                        cell4.btnMultiCheckLeadingAnchor?.isActive = false
                                        cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: -36)
                                        cell4.btnMultiCheckLeadingAnchor?.isActive = true
                                        cell4.btnOption.isHidden = false
                                        cell4.btnMultiCheck.isHidden = true
                                        cell4.btnMultiChecked = false
                                        cell4.lblDevice.isHidden = false
                                    }
                                    cell4.lblMain.sizeToFit()
                                    cell4.lblDevice.sizeToFit()
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
                                }
                                cells.append(cell4)
                            } else {
                                
                                print("NasFileCellController get cell : \(viewState)")
                                //nas 파일 셀 컨트롤
                                let cell4 = NasFileCellController().getCell(indexPathRow: indexPath.row, folderArray: folderArray, multiCheckListState: multiCheckListState, collectionView: deviceCollectionView, parentView: self, deviceName:deviceName, viewState:viewState)
                                
                                if listViewStyleState == .list{
                                    
                                    cell4.btnOption.isHidden = false
                                    cell4.btnShow.tag = indexPath.row
                                    cell4.btnShow.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionNasFileShowClicked(sender:)), for: .touchUpInside)
                                    cell4.btnAction.tag = indexPath.row
                                    cell4.btnAction.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionNasFileShowClicked(sender:)), for: .touchUpInside)
                                    cell4.btnDwnld.tag = indexPath.row
                                    cell4.btnDwnld.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionNasFileShowClicked(sender:)), for: .touchUpInside)
                                    cell4.btnNas.tag = indexPath.row
                                    cell4.btnNas.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionNasFileShowClicked(sender:)), for: .touchUpInside)
                                    cell4.btnGDrive.tag = indexPath.row
                                    cell4.btnGDrive.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionNasFileShowClicked(sender:)), for: .touchUpInside)
                                    cell4.btnDelete.tag = indexPath.row
                                    cell4.btnDelete.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionNasFileShowClicked(sender:)), for: .touchUpInside)
                                    
                                    if (multiCheckListState == .active){
                                        cell4.btnMultiCheck.isHidden = false
                                        cell4.btnMultiCheckLeadingAnchor?.isActive = false
                                        cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: 36)
                                        cell4.btnMultiCheckLeadingAnchor?.isActive = true
                                        cell4.btnMultiCheck.tag = indexPath.row
                                        cell4.btnMultiCheck.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnMultiCheckClicked(sender:)), for: .touchUpInside)
                                        cell4.btnOption.isHidden = true
                                        cell4.lblDevice.isHidden = true
                                    } else {
                                        cell4.resetMultiCheck()
                                        cell4.btnMultiCheckLeadingAnchor?.isActive = false
                                        cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: -36)
                                        cell4.btnMultiCheckLeadingAnchor?.isActive = true
                                        cell4.btnOption.isHidden = false
                                        cell4.btnMultiCheck.isHidden = true
                                        cell4.btnMultiChecked = false
                                        cell4.lblDevice.isHidden = false
                                    }
                                    cell4.lblMain.sizeToFit()
                                    cell4.lblDevice.sizeToFit()
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
                                    
                                }
                                cells.append(cell4)
                            }
                            
                            let CollectionViewGridCell = GridCellController().getCell(indexPathRow: indexPath.row, folderArray: folderArray, multiCheckListState: multiCheckListState, collectionView: deviceCollectionView, parentView: self, deviceName:deviceName, viewState:viewState, driveFileArray:driveFileArray, mainContentState:mainContentState)
                            
                            if listViewStyleState == .grid {
                                if (multiCheckListState == .active){
                                    
                                    CollectionViewGridCell.btnMultiCheck.isHidden = false
                                    CollectionViewGridCell.btnMultiCheck.tag = indexPath.row
                                    CollectionViewGridCell.btnMultiCheck.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnMultiCheckClicked(sender:)), for: .touchUpInside)

                                    print("CollectionViewGridCell : \(indexPath.row), multi checked : \(CollectionViewGridCell.btnMultiChecked), selectAllCheck : \(selectAllCheck)")
                                    
                                } else {
                                    CollectionViewGridCell.resetMultiCheck()
                                    CollectionViewGridCell.btnMultiCheck.isHidden = true
                                    CollectionViewGridCell.btnMultiChecked = false
                                }
                                
                                CollectionViewGridCell.lblSub.isHidden = false
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
                                
                                if listViewStyleState == .list {
                                    if (multiCheckListState == .active){
                                        
                                        cell4.btnMultiCheck.isHidden = true
                                        cell4.btnMultiCheckLeadingAnchor?.isActive = false
                                        cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: 36)
                                        cell4.btnMultiCheckLeadingAnchor?.isActive = true
                                        cell4.btnMultiCheck.tag = indexPath.row
                                        cell4.btnMultiCheck.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnMultiCheckClicked(sender:)), for: .touchUpInside)
                                        cell4.btnOption.isHidden = true
                                        cell4.btnMultiCheck.isHidden = true
                                        
                                        
                                    } else {
                                        cell4.resetMultiCheck()
                                        cell4.btnMultiCheckLeadingAnchor?.isActive = false
                                        cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: -36)
                                        cell4.btnMultiCheckLeadingAnchor?.isActive = true
                                        cell4.btnOption.isHidden = true
                                        cell4.btnMultiCheck.isHidden = true
                                        cell4.btnMultiChecked = false
                                    }
                                    cell4.lblMain.sizeToFit()
                                }
                                if(folderArray[indexPath.row].foldrNm == ".."){
                                    cell4.lblSub.isHidden = true
                                    cell4.btnOption.isHidden = true
                                    cell2.lblSub.isHidden = true
                                } else {
                                    cell2.lblSub.isHidden = false
                                    cell4.lblSub.isHidden = false
                                }
                                cells.append(cell4)
                                
                            } else {
                                //nas 폴더 셀 컨트로
                                let cell4 = NasFolderListCellController().getCell(indexPathRow: indexPath.row, folderArray: folderArray, multiCheckListState: multiCheckListState, collectionView: deviceCollectionView, parentView: self)
                                //
                                
                                if listViewStyleState == .list {
                                    
                                    cell4.btnOption.isHidden = false
                                    cell4.btnShow.tag = indexPath.row
                                    cell4.btnShow.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionNasFolderShowClicked(sender:)), for: .touchUpInside)
                                    cell4.btnDwnld.tag = indexPath.row
                                    cell4.btnDwnld.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionNasFolderShowClicked(sender:)), for: .touchUpInside)
                                    cell4.btnNas.tag = indexPath.row
                                    cell4.btnNas.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionNasFolderShowClicked(sender:)), for: .touchUpInside)
                                    cell4.btnGDrive.tag = indexPath.row
                                    cell4.btnGDrive.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionNasFolderShowClicked(sender:)), for: .touchUpInside)
                                    cell4.btnDelete.tag = indexPath.row
                                    cell4.btnDelete.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionNasFolderShowClicked(sender:)), for: .touchUpInside)
                                    
                                    if (multiCheckListState == .active){
                                        cell4.btnMultiCheck.isHidden = false
                                        cell4.btnMultiCheckLeadingAnchor?.isActive = false
                                        cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: 36)
                                        cell4.btnMultiCheckLeadingAnchor?.isActive = true
                                        
                                        if(folderArray[indexPath.row].foldrNm == ".."){
                                            cell4.btnMultiCheck.isHidden = true
                                        } else {
                                            cell4.btnMultiCheck.isHidden = false
                                            cell4.btnMultiCheck.tag = indexPath.row
                                            cell4.btnMultiCheck.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnMultiCheckClicked(sender:)), for: .touchUpInside)
                                            
                                        }
                                      
                                        cell4.btnOption.isHidden = true
                                        
                                    } else {
                                        cell4.resetMultiCheck()
                                        cell4.btnMultiCheckLeadingAnchor?.isActive = false
                                        cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: -36)
                                        cell4.btnMultiCheckLeadingAnchor?.isActive = true
                                        cell4.btnOption.isHidden = false
                                        cell4.btnMultiCheck.isHidden = true
                                        cell4.btnMultiChecked = false
                                    }
                                    cell4.lblMain.sizeToFit()
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
                                    
                                }
                                
                                cells.append(cell4)
                                if(folderArray[indexPath.row].foldrNm == ".."){
                                    cell4.lblSub.isHidden = true
                                    cell4.btnOption.isHidden = true
                                    cell2.lblSub.isHidden = true
                                } else {
                                    cell2.lblSub.isHidden = false
                                    cell4.lblSub.isHidden = false
                                }
                                
                            }
//                            let CollectionViewGridCell = deviceCollectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewGridCell", for: indexPath) as! CollectionViewGridCell
                            let CollectionViewGridCell = GridCellController().getCell(indexPathRow: indexPath.row, folderArray: folderArray, multiCheckListState: multiCheckListState, collectionView: deviceCollectionView, parentView: self, deviceName:deviceName, viewState:viewState, driveFileArray:driveFileArray, mainContentState:mainContentState)
                            if listViewStyleState == .grid {
                                CollectionViewGridCell.ivBackground.isHidden = true
                                CollectionViewGridCell.ivMain.isHidden = false
                                CollectionViewGridCell.lblMain.text = folderArray[indexPath.row].foldrNm
                                let editedDate = folderArray[indexPath.row].amdDate.components(separatedBy: " ")[0]
                                CollectionViewGridCell.lblSub.text = "\(editedDate) | \(deviceName)"
                                
                                CollectionViewGridCell.ivMain.image = UIImage(named: "ico_folder")
                                CollectionViewGridCell.ivSub.image = UIImage(named: "ico_folder")
                                if (multiCheckListState == .active){
                                    if(fromOsCd != "S" && fromOsCd != "G"){
                                        CollectionViewGridCell.btnMultiCheck.isHidden = true
                                    } else if folderArray[indexPath.row].foldrNm == ".." {
                                        CollectionViewGridCell.btnMultiCheck.isHidden = true
                                    } else {
                                        CollectionViewGridCell.btnMultiCheck.isHidden = false
                                        CollectionViewGridCell.btnMultiCheck.tag = indexPath.row
                                        CollectionViewGridCell.btnMultiCheck.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnMultiCheckClicked(sender:)), for: .touchUpInside)
                                    }
                                    
                                } else {
                                    CollectionViewGridCell.resetMultiCheck()
                                    CollectionViewGridCell.btnMultiCheck.isHidden = true
                                }
                            }
                            
                            
                            cells.append(CollectionViewGridCell)
                            
                            if(folderArray[indexPath.row].foldrNm == ".."){
                                CollectionViewGridCell.lblSub.isHidden = true
                            } else {
                                CollectionViewGridCell.lblSub.isHidden = false
                            }
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
                            if listViewStyleState == .list {
                                
                                cell4.btnOption.isHidden = false
                                cell4.btnShow.tag = indexPath.row
                                cell4.btnShow.addTarget(self, action: #selector(optionLocalFileShowClicked(sender:)), for: .touchUpInside)
                                cell4.btnAction.tag = indexPath.row
                                cell4.btnAction.addTarget(self, action: #selector(optionLocalFileShowClicked(sender:)), for: .touchUpInside)
                                cell4.btnNas.tag = indexPath.row
                                cell4.btnNas.addTarget(self, action: #selector(optionLocalFileShowClicked(sender:)), for: .touchUpInside)
                                cell4.btnGDrive.tag = indexPath.row
                                cell4.btnGDrive.addTarget(self, action: #selector(optionLocalFileShowClicked(sender:)), for: .touchUpInside)
                                cell4.btnDelete.tag = indexPath.row
                                cell4.btnDelete.addTarget(self, action: #selector(optionLocalFileShowClicked(sender:)), for: .touchUpInside)

                                
                                if (multiCheckListState == .active){
                                    cell4.btnMultiCheck.isHidden = false
                                    cell4.btnMultiCheckLeadingAnchor?.isActive = false
                                    cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: 36)
                                    cell4.btnMultiCheckLeadingAnchor?.isActive = true
                                    cell4.btnMultiCheck.tag = indexPath.row
                                    cell4.btnMultiCheck.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnMultiCheckClicked(sender:)), for: .touchUpInside)
                                    cell4.btnOption.isHidden = true
                                    cell4.lblDevice.isHidden = true
                                } else {
                                    cell4.resetMultiCheck()
                                    cell4.btnMultiCheckLeadingAnchor?.isActive = false
                                    cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: -36)
                                    cell4.btnMultiCheckLeadingAnchor?.isActive = true
                                    cell4.btnOption.isHidden = false
                                    cell4.btnMultiCheck.isHidden = true
                                    cell4.btnMultiChecked = false
                                    cell4.lblDevice.isHidden = false
                                }
                                cell4.lblMain.sizeToFit()
                                cell4.lblDevice.sizeToFit()
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
                            }
                            
                            
                            
                            let CollectionViewGridCell = GridCellController().getCell(indexPathRow: indexPath.row, folderArray: folderArray, multiCheckListState: multiCheckListState, collectionView: deviceCollectionView, parentView: self, deviceName:deviceName, viewState:viewState, driveFileArray: driveFileArray, mainContentState: mainContentState)
                            
                            if listViewStyleState == .grid {
                                if (multiCheckListState == .active){
                                    CollectionViewGridCell.btnMultiCheck.isHidden = false
                                    CollectionViewGridCell.btnMultiCheck.tag = indexPath.row
                                    CollectionViewGridCell.btnMultiCheck.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnMultiCheckClicked(sender:)), for: .touchUpInside)
                                    
                                } else {
                                    CollectionViewGridCell.resetMultiCheck()
                                    CollectionViewGridCell.btnMultiCheck.isHidden = true
                                }
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
                            if listViewStyleState == .list {
                                
                                cell4.btnOption.isHidden = false
                                cell4.btnNas.tag = indexPath.row
                                cell4.btnNas.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionLocalFolderShowClicked(sender:)), for: .touchUpInside)
                                cell4.btnGDrive.tag = indexPath.row
                                cell4.btnGDrive.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionLocalFolderShowClicked(sender:)), for: .touchUpInside)
                                cell4.btnDelete.tag = indexPath.row
                                cell4.btnDelete.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionLocalFolderShowClicked(sender:)), for: .touchUpInside)
                                
                                if (multiCheckListState == .active){
                                    cell4.btnMultiCheck.isHidden = false
                                    cell4.btnMultiCheckLeadingAnchor?.isActive = false
                                    cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: 36)
                                    cell4.btnMultiCheckLeadingAnchor?.isActive = true
                                    cell4.btnOption.isHidden = true
                                    if(folderArray[indexPath.row].foldrNm == ".."){
                                        cell4.btnMultiCheck.isHidden = true
                                    } else {
                                        cell4.btnMultiCheck.isHidden = false
                                        cell4.btnMultiCheck.tag = indexPath.row
                                        cell4.btnMultiCheck.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnMultiCheckClicked(sender:)), for: .touchUpInside)
                                        
                                    }
                                } else {
                                    cell4.resetMultiCheck()
                                    cell4.btnMultiCheckLeadingAnchor?.isActive = false
                                    cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: -36)
                                    cell4.btnMultiCheckLeadingAnchor?.isActive = true
                                    cell4.btnOption.isHidden = false
                                    cell4.btnMultiCheck.isHidden = true
                                    cell4.btnMultiChecked = false
                                }
                                cell4.lblMain.sizeToFit()
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
                            }
                            
                            
                            cell2.lblMain.text = folderArray[indexPath.row].foldrNm
                            cell2.ivMain.image = UIImage(named: "ico_folder")
                            cell2.ivSub.image = UIImage(named: "ico_folder")
                            
                            if(folderArray[indexPath.row].foldrNm == ".."){
                                cell4.lblSub.isHidden = true
                                cell4.btnOption.isHidden = true
                                cell2.lblSub.isHidden = true
                            } else {
                                cell2.lblSub.isHidden = false
                                cell4.lblSub.isHidden = false
                            }
                            
                             let CollectionViewGridCell = GridCellController().getCell(indexPathRow: indexPath.row, folderArray: folderArray, multiCheckListState: multiCheckListState, collectionView: deviceCollectionView, parentView: self, deviceName:deviceName, viewState:viewState, driveFileArray: driveFileArray, mainContentState: mainContentState)
                            
                            if listViewStyleState == .grid {
                                CollectionViewGridCell.ivBackground.isHidden = true
                                CollectionViewGridCell.ivMain.isHidden = false
                                CollectionViewGridCell.lblMain.text = folderArray[indexPath.row].foldrNm
                                let editedDate = folderArray[indexPath.row].amdDate.components(separatedBy: " ")[0]
                                CollectionViewGridCell.lblSub.text = "\(editedDate) | \(deviceName)"
                                
                                CollectionViewGridCell.ivMain.image = UIImage(named: "ico_folder")
                                CollectionViewGridCell.ivSub.image = UIImage(named: "ico_folder")
                                if (multiCheckListState == .active){
                                    if folderArray[indexPath.row].foldrNm == ".." {
                                        CollectionViewGridCell.btnMultiCheck.isHidden = true
                                    } else {
                                        CollectionViewGridCell.btnMultiCheck.isHidden = false
                                        CollectionViewGridCell.btnMultiCheck.tag = indexPath.row
                                        CollectionViewGridCell.btnMultiCheck.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnMultiCheckClicked(sender:)), for: .touchUpInside)
                                    }
                                    
                                } else {
                                    CollectionViewGridCell.resetMultiCheck()
                                    CollectionViewGridCell.btnMultiCheck.isHidden = true
                                }
                                
                                
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
                
            }
            break
        case .googleDriveList :
            deviceName = "Google Drive"
            // 파일
            if(!driveFileArray[indexPath.row].mimeType.contains("folder")){
                let cell4 = GDriveFileListCellController().getCell(indexPathRow: indexPath.row, folderArray: driveFileArray, multiCheckListState: multiCheckListState, collectionView: deviceCollectionView, parentView: self)
                cells.append(cell4)
                if listViewStyleState == .list {
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
                    
                    cell4.btnOption.isHidden = false
                    cell4.btnShow.tag = indexPath.row
                    cell4.btnShow.addTarget(self, action: #selector(optionGDriveFileShowClicked(sender:)), for: .touchUpInside)
                    cell4.btnDwnld.tag = indexPath.row
                    cell4.btnDwnld.addTarget(self, action: #selector(optionGDriveFileShowClicked(sender:)), for: .touchUpInside)
                    cell4.btnNas.tag = indexPath.row
                    cell4.btnNas.addTarget(self, action: #selector(optionGDriveFileShowClicked(sender:)), for: .touchUpInside)
                    cell4.btnGDrive.tag = indexPath.row
                    cell4.btnGDrive.addTarget(self, action: #selector(optionGDriveFileShowClicked(sender:)), for: .touchUpInside)
                    cell4.btnDelete.tag = indexPath.row
                    cell4.btnDelete.addTarget(self, action: #selector(optionGDriveFileShowClicked(sender:)), for: .touchUpInside)
                    
                    
                    if (multiCheckListState == .active){
                        cell4.btnMultiCheck.isHidden = false
                        cell4.btnMultiCheckLeadingAnchor?.isActive = false
                        cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: 36)
                        cell4.btnMultiCheckLeadingAnchor?.isActive = true
                        cell4.btnMultiCheck.tag = indexPath.row
                        cell4.btnMultiCheck.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnGoogleDriveMultiCheckClicked(sender:)), for: .touchUpInside)
                        cell4.btnOption.isHidden = true
                        cell4.lblDevice.isHidden = true
                    } else {
                        cell4.resetMultiCheck()
                        cell4.btnMultiCheckLeadingAnchor?.isActive = false
                        cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: -36)
                        cell4.btnMultiCheckLeadingAnchor?.isActive = true
                        cell4.btnOption.isHidden = false
                        cell4.btnMultiCheck.isHidden = true
                        cell4.btnMultiChecked = false
                        cell4.lblDevice.isHidden = false
                    }
                    cell4.lblMain.sizeToFit()
                    cell4.lblDevice.sizeToFit()
                }
                
                
//                cell2.lblMain.text = driveFileArray[indexPath.row].name
                //let etsionFromMimeType = Util.getEtsionFromMimetype(mimeType: driveFileArray[indexPath.row].mimeType)
                let imageString = Util.getFileImageString(fileExtension: driveFileArray[indexPath.row].fileExtension)
//                cell2.ivMain.image = UIImage(named: imageString)
//                cell2.ivSub.image = UIImage(named: imageString)
                
//                let CollectionViewGridCell = deviceCollectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewGridCell", for: indexPath) as! CollectionViewGridCell
                let CollectionViewGridCell = GridCellController().getCell(indexPathRow: indexPath.row, folderArray: folderArray, multiCheckListState: multiCheckListState, collectionView: deviceCollectionView, parentView: self, deviceName:deviceName, viewState:viewState, driveFileArray: driveFileArray, mainContentState: mainContentState)
                
                if listViewStyleState == .grid {
                    CollectionViewGridCell.lblMain.text = driveFileArray[indexPath.row].name
                    let editedDate = driveFileArray[indexPath.row].modifiedTime.components(separatedBy: "T")[0]
                    CollectionViewGridCell.lblSub.text = "\(editedDate) | \(deviceName)"
                    
                    let url = driveFileArray[indexPath.row].thumbnailLink
                    if url == "nil" {
                        CollectionViewGridCell.ivBackground.isHidden = true
                        CollectionViewGridCell.ivMain.isHidden = false
                    } else {
                        CollectionViewGridCell.ivBackground.isHidden = false
                        CollectionViewGridCell.ivMain.isHidden = true
                        CollectionViewGridCell.ivBackground.af_setImage(withURL: URL(string:url)!)
                    }
                    
                    CollectionViewGridCell.ivMain.image = UIImage(named:imageString)
                    CollectionViewGridCell.ivSub.image = UIImage(named: imageString)
                    
                    print(">> \(indexPath.row) , \(url) , \(driveFileArray[indexPath.row].fileExtension) , \(driveFileArray[indexPath.row].name)")
                    
                    //CollectionViewGridCell.ivMain.af_setImage(withURL: url!, placeholderImage: UIImage(named:imageString), filter: nil, imageTransition: .crossDissolve(0.5), runImageTransitionIfCached: true, completion: nil)
                    
                    
                    if (multiCheckListState == .active){
                        CollectionViewGridCell.btnMultiCheck.isHidden = false
                        CollectionViewGridCell.btnMultiCheck.tag = indexPath.row
                        CollectionViewGridCell.btnMultiCheck.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnGoogleDriveMultiCheckClicked(sender:)), for: .touchUpInside)
                        
                    } else {
                        CollectionViewGridCell.resetMultiCheck()
                        CollectionViewGridCell.btnMultiCheck.isHidden = true
                    }
                }
                cells.append(CollectionViewGridCell)
                
            } else {
                // 폴더
                let cell4 = GDriveFolderListCellController().getCell(indexPathRow: indexPath.row, folderArray: driveFileArray, multiCheckListState: multiCheckListState, collectionView: deviceCollectionView, parentView: self)
                cells.append(cell4)
                if listViewStyleState == .list {
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
                    
                    cell4.btnOption.isHidden = false
                    cell4.btnDwnld.tag = indexPath.row
                    cell4.btnDwnld.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionGDriveFolderShowClicked(sender:)), for: .touchUpInside)
                    cell4.btnNas.tag = indexPath.row
                    cell4.btnNas.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionGDriveFolderShowClicked(sender:)), for: .touchUpInside)
                    cell4.btnDelete.tag = indexPath.row
                    cell4.btnDelete.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionGDriveFolderShowClicked(sender:)), for: .touchUpInside)
                    
                    
                    if (multiCheckListState == .active){
                        cell4.btnMultiCheckLeadingAnchor?.isActive = false
                        cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: 36)
                        cell4.btnMultiCheckLeadingAnchor?.isActive = true
                        
                        if driveFileArray[indexPath.row].name == ".." {
                            cell4.btnMultiCheck.isHidden = true
                        } else {
                            cell4.btnMultiCheck.isHidden = false
                            cell4.btnMultiCheck.tag = indexPath.row
                            cell4.btnMultiCheck.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnGoogleDriveMultiCheckClicked(sender:)), for: .touchUpInside)
                            cell4.btnOption.isHidden = true
                            
                            
                            if(driveFileArray[indexPath.row].name == ".."){
                                cell4.btnMultiCheck.isHidden = true
                            } else {
                                cell4.btnMultiCheck.isHidden = false
                                cell4.btnMultiCheck.tag = indexPath.row
                                cell4.btnMultiCheck.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnMultiCheckClicked(sender:)), for: .touchUpInside)
                                
                            }
                           
                        }
                    } else {
                        cell4.resetMultiCheck()
                        cell4.btnMultiCheckLeadingAnchor?.isActive = false
                        cell4.btnMultiCheckLeadingAnchor = cell4.btnMultiCheck.leadingAnchor.constraint(equalTo: cell4.leadingAnchor, constant: -36)
                        cell4.btnMultiCheckLeadingAnchor?.isActive = true
                        cell4.btnOption.isHidden = false
                        cell4.btnMultiCheck.isHidden = true
                        cell4.btnMultiChecked = false
                    }
                    cell4.lblMain.sizeToFit()
                }
                
                
                cell2.lblMain.text = driveFileArray[indexPath.row].name
                cell2.ivMain.image = UIImage(named: "ico_folder")
                cell2.ivSub.image = UIImage(named: "ico_folder")
                
                if(driveFileArray[indexPath.row].name == ".."){
                    cell4.lblSub.isHidden = true
                    cell4.btnOption.isHidden = true
                    cell2.lblSub.isHidden = true
                } else {
                    cell2.lblSub.isHidden = false
                    cell4.lblSub.isHidden = false
                }
                
//                let CollectionViewGridCell = deviceCollectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewGridCell", for: indexPath) as! CollectionViewGridCell
                let CollectionViewGridCell = GridCellController().getCell(indexPathRow: indexPath.row, folderArray: folderArray, multiCheckListState: multiCheckListState, collectionView: deviceCollectionView, parentView: self, deviceName:deviceName, viewState:viewState, driveFileArray:driveFileArray, mainContentState:mainContentState)
                
                if listViewStyleState == .grid {
                    CollectionViewGridCell.ivBackground.isHidden = true
                    CollectionViewGridCell.ivMain.isHidden = false
                    CollectionViewGridCell.lblMain.text = driveFileArray[indexPath.row].name
                    let editedDate = driveFileArray[indexPath.row].modifiedTime.components(separatedBy: "T")[0]
                    CollectionViewGridCell.lblSub.text = "\(editedDate) | \(deviceName)"
                    
                    CollectionViewGridCell.ivMain.image = UIImage(named: "ico_folder")
                    CollectionViewGridCell.ivSub.image = UIImage(named: "ico_folder")
                    
                    if (multiCheckListState == .active){
                        CollectionViewGridCell.btnMultiCheck.isHidden = false
                        CollectionViewGridCell.btnMultiCheck.tag = indexPath.row
                        CollectionViewGridCell.btnMultiCheck.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnGoogleDriveMultiCheckClicked(sender:)), for: .touchUpInside)
                        if(driveFileArray[indexPath.row].name == ".."){
                            CollectionViewGridCell.btnMultiCheck.isHidden = true
                            
                        } else {
                            
                            CollectionViewGridCell.btnMultiCheck.isHidden = false
                        }
                        
                    } else {
                        
                        CollectionViewGridCell.resetMultiCheck()
                        CollectionViewGridCell.btnMultiCheck.isHidden = true
                    }
                    
                    if(driveFileArray[indexPath.row].name == ".."){
                        CollectionViewGridCell.lblSub.isHidden = true
                    } else {
                        CollectionViewGridCell.lblSub.isHidden = false
                    }
                }
                
                
                cells.append(CollectionViewGridCell)
            }
            
            switch listViewStyleState{
            case .grid:
                cell = cells[4]
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
//            let indexPathRow = ["indexPathRow":"\(indexPath.row)"]
            
            fromOsCd = DeviceArray[indexPath.row].osCd
            homeViewController?.fromOsCd = fromOsCd
            selectedDevUuid = DeviceArray[indexPath.row].devUuid
            selectedDevUserId = DeviceArray[indexPath.row].userId
            selectedDevOsCd = DeviceArray[indexPath.row].osCd
            
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
            print(stateDict)
            //서치에서 돌아올 때 라벨 설정
            
            
            NotificationCenter.default.post(name: Notification.Name("bottomStateFromContainer"), object: self, userInfo: stateDict)
            clickDeviceItem2(indexPathRow: indexPath.row)
            
        } else if (cellStyle == 2){
            
            //            if(contextMenuState == .nas){
            if(multiCheckListState == .active){
                
                if listViewStyleState == .list { // 리스트뷰
                    switch mainContentState {
                    case .oneViewList:
                        if flickState == .lately {
                            selectedDevUuid = folderArray[indexPath.row].devUuid
                            selectedDevOsCd = folderArray[indexPath.row].osCd
                        }
                        if(selectedDevUuid != Util.getUuid()){
                            if(folderArray[indexPath.row].fileNm != "nil"){ // 파일
                                if(fromOsCd != "S" && fromOsCd != "G"){ // 원격
                                    let currentItem = collectionView.cellForItem(at: indexPath) as! RemoteFileListCell
                                    currentItem.btnMultiCheck.tag = indexPath.row
                                    btnMultiCheckClicked(sender: currentItem.btnMultiCheck)
                                } else { // 나스
                                    let currentItem = collectionView.cellForItem(at: indexPath) as! NasFileListCell
                                    currentItem.btnMultiCheck.tag = indexPath.row
                                    btnMultiCheckClicked(sender: currentItem.btnMultiCheck)
                                }
                            } else { // 폴더
                                if(fromOsCd != "S" && fromOsCd != "G"){ // 원격
                                    
                                } else { // 나스
                                    if(!(folderArray[indexPath.row].foldrNm == "..")){
                                        let currentItem = collectionView.cellForItem(at: indexPath) as! NasFolderListCell
                                        currentItem.btnMultiCheck.tag = indexPath.row
                                        btnMultiCheckClicked(sender: currentItem.btnMultiCheck)
                                    }
                                }
                            }
                        } else { // 로컬
                            if(folderArray[indexPath.row].fileNm != "nil"){ // 파일
                                let currentItem = collectionView.cellForItem(at: indexPath) as! LocalFileListCell
                                currentItem.btnMultiCheck.tag = indexPath.row
                                btnMultiCheckClicked(sender: currentItem.btnMultiCheck)
                            } else { // 폴더
                                if(!(folderArray[indexPath.row].foldrNm == "..")){
                                    let currentItem = collectionView.cellForItem(at: indexPath) as! LocalFolderListCell
                                    currentItem.btnMultiCheck.tag = indexPath.row
                                    btnMultiCheckClicked(sender: currentItem.btnMultiCheck)
                                }
                            }
                        }
                    case .googleDriveList:
                        if(!driveFileArray[indexPath.row].mimeType.contains("folder")){ // 파일
                            let currentItem = collectionView.cellForItem(at: indexPath) as! GDriveFileListCell
                            currentItem.btnMultiCheck.tag = indexPath.row
                            btnGoogleDriveMultiCheckClicked(sender: currentItem.btnMultiCheck)
                        } else { // 폴더
                            let currentItem = collectionView.cellForItem(at: indexPath) as! GDriveFolderListCell
                            currentItem.btnMultiCheck.tag = indexPath.row
                            btnGoogleDriveMultiCheckClicked(sender: currentItem.btnMultiCheck)
                        }
                    }
                } else { // 카드뷰
                    switch mainContentState {
                        case .oneViewList:
                        if flickState == .lately {
                        selectedDevUuid = folderArray[indexPath.row].devUuid
                        selectedDevOsCd = folderArray[indexPath.row].osCd
                        }
                        if folderArray[indexPath.row].fileNm == "nil" { // 폴더
                        if fromOsCd == "S" || fromOsCd == "G" || selectedDevUuid == Util.getUuid() {
                        let currentItem = collectionView.cellForItem(at: indexPath) as! CollectionViewGridCell
                        currentItem.btnMultiCheck.tag = indexPath.row
                        btnMultiCheckClicked(sender: currentItem.btnMultiCheck)
                        }
                        } else { // 파일
                        let currentItem = collectionView.cellForItem(at: indexPath) as! CollectionViewGridCell
                        currentItem.btnMultiCheck.tag = indexPath.row
                        btnMultiCheckClicked(sender: currentItem.btnMultiCheck)
                        }
                        case .googleDriveList:
                        let currentItem = collectionView.cellForItem(at: indexPath) as! CollectionViewGridCell
                        currentItem.btnMultiCheck.tag = indexPath.row
                        btnMultiCheckClicked(sender: currentItem.btnMultiCheck)
                    }
                }
                
                return
            } else {
                if(flickState == .main) {
                    homeViewController?.inActiveMultiCheck()
                } else {
                    latelyUpdatedFileViewController?.inActiveMultiCheck()
                }
                
//                print("2")
                
                if folderArray.count > 0 {
                    let infoldrId = folderArray[indexPath.row].foldrId
                    foldrId = String(infoldrId)
                    selectedDevFoldrId = foldrId
                    let fileId = folderArray[indexPath.row].fileId
                    let folderNm = folderArray[indexPath.row].foldrNm
                    fileNm = folderArray[indexPath.row].fileNm
                    foldrWholePathNm = folderArray[indexPath.row].foldrWholePathNm
                    //                print("foldrWholePathNm: \(foldrWholePathNm)")
                    let intIndexPathRow = indexPath.row
                    
                    if (viewState == .home) {
                    Vc.getFolderArrayFromContainer(getFolderArray:folderArray, getFolderArrayIndexPathRow:intIndexPathRow)
                    }
                    
                    if(fileId == 0){
                        
                        if(foldrId == "0") {
                            
                            // 리모트 디아비스 최상위 폴더
                            print("getRootFolder called")
                            cellStyle = 1
                            getRootFolder(userId: userId, devUuid: selectedDevUuid, deviceName: deviceName)
                            let folderName = ["folderName":deviceName,"deviceName":deviceName, "devUuid":selectedDevUuid]
                            NotificationCenter.default.post(name: Notification.Name("setupFolderPathView"), object: self, userInfo: folderName)
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
                                    
                                    navTxt = ""
                                }
                            }
                            homeViewController?.completeFolderNameForSearchView = "\(navTxt)\(folderNameForSearchView)"
                            let folderName = ["folderName":"\(navTxt)\(folderNameForSearchView)","deviceName":deviceName, "devUuid":selectedDevUuid]
                            NotificationCenter.default.post(name: Notification.Name("setupFolderPathView"), object: self, userInfo: folderName)
                            self.showInsideList(userId: userId, devUuid: selectedDevUuid, foldrId: foldrId,deviceName: deviceName)
                            searchStepState = .folder
                            homeViewController?.searchStepState = searchStepState
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
                        
                        fromOsCd = folderArray[indexPath.row].osCd
                        selectedDevUuid = folderArray[indexPath.row].devUuid
                        let stateDict = ["bottomState":"\(state)","fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":deviceName, "selectedDevUuid":selectedDevUuid, "fileNm":fileNm, "userId":userId, "foldrId":String(foldrId),"fromOsCd":fromOsCd, "currentFolderId":currentFolderId,"folderArray":folderArray,"selectedIndex":indexPath] as [String : Any]
                        //                        print(stateDict)
                        if (latelyUpdatedFileViewController == nil){
                            print("click file for home")
                            NotificationCenter.default.post(name: Notification.Name("bottomStateFromContainer"), object: self, userInfo: stateDict)
                        } else {
                            print("click file for lately updated file")
                            latelyUpdatedFileViewController?.getFolderArrayFromContainer(getFolderArray:folderArray, getFolderArrayIndexPathRow:intIndexPathRow)
                            latelyUpdatedFileViewController?.bottomStateFromContainer(fileDict: stateDict)
                            
                        }
                        
                    }
                    // 0eun - start
                    
                }
            }
               
           
          
            
        } else if cellStyle == 3 { // 구글드라이브 폴더,파일 셀
            if driveFileArray.count > 0 {
                let mimeType = driveFileArray[indexPath.row].mimeType
                let fileId = driveFileArray[indexPath.row].fileId
                let name = driveFileArray[indexPath.row].name
                if(multiCheckListState == .active){
                    if listViewStyleState == .list { // 리스트뷰
                        if(!driveFileArray[indexPath.row].mimeType.contains("folder")){ // 파일
                            let currentItem = collectionView.cellForItem(at: indexPath) as! GDriveFileListCell
                            currentItem.btnMultiCheck.tag = indexPath.row
                            btnGoogleDriveMultiCheckClicked(sender: currentItem.btnMultiCheck)
                        } else { // 폴더
                            let currentItem = collectionView.cellForItem(at: indexPath) as! GDriveFolderListCell
                            currentItem.btnMultiCheck.tag = indexPath.row
                            btnGoogleDriveMultiCheckClicked(sender: currentItem.btnMultiCheck)
                        }
                    } else { // 카드뷰
                        let currentItem = collectionView.cellForItem(at: indexPath) as! CollectionViewGridCell
                        currentItem.btnMultiCheck.tag = indexPath.row
                        btnGoogleDriveMultiCheckClicked(sender: currentItem.btnMultiCheck)
                    }
                    return
                    
                } else {
                    if mimeType.contains(".folder") { // 폴더
                        
                        
                        let stringFoldrId = String(fileId)
                        if driveFileArray[indexPath.row].name == ".." {
                            mainContentState = .googleDriveList
                            homeViewController?.mainContentState = .googleDriveList
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
                        //                let folderName = ["folderName":"\(driveFolderNameArray[driveFolderNameArrayCount])","deviceName":"Google Drive", "devUuid":"googleDrive"]
                        var driveFoldrNm = driveFolderNameArray[driveFolderNameArrayCount]
                        if driveFolderNameArrayCount > 0 {
                            driveFoldrNm = "../ \(driveFoldrNm)"
                        }
                        let folderName = ["folderName":"\(driveFoldrNm)","deviceName":"Google Drive", "devUuid":"googleDrive"]
                        
                        homeViewController?.completeFolderNameForSearchView = "> Google Drive"
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
            }
            

            
        }
        // 0eun - end
        
        
//        collectionviewCellSpcing()
//        deviceCollectionView.reloadData()
        
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
                navTxt = ""
            }
            let upFoldrId = "\(folderIdArray[folderIdArray.count-1])"
            let folderName = ["folderName":"\(navTxt)\(folderNameForSearchView)","deviceName":deviceName, "devUuid":selectedDevUuid]
            
            homeViewController?.completeFolderNameForSearchView = "\(navTxt)\(folderNameForSearchView)"
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
        } else {
            if driveFolderIdArray.count > 1 {
                
                let gDriveUpFoldrId = driveFolderIdArray[driveFolderIdArray.count-2]
                
                if(driveFolderIdArray[driveFolderIdArray.count - 1] == "root") {
                    currentFolderId = "root"
                } else {
                    currentFolderId = driveFolderIdArray[driveFolderIdArray.count - 2]
                }
                
                driveFolderIdArray.remove(at: driveFolderIdArray.count-1)
                driveFolderNameArray.remove(at: driveFolderNameArray.count-1)
                
                let driveFolderNameArrayCount = driveFolderNameArray.count - 1
                var foldrName = driveFolderNameArray[driveFolderNameArrayCount]
                if driveFolderNameArrayCount > 0 {
                    foldrName = "../ \(foldrName)"
                }
                
                let folderName = ["folderName":"\(foldrName)","deviceName":"Google Drive", "devUuid":"googleDrive"]
                homeViewController?.completeFolderNameForSearchView = "> Google Drive"
                NotificationCenter.default.post(name: Notification.Name("setupFolderPathView"), object: self, userInfo: folderName)
                
                self.showInsideListGDrive(userId: userId, devUuid: selectedDevUuid, foldrId: gDriveUpFoldrId, deviceName: deviceName)
                searchStepState = .folder
                let state = HomeViewController.bottomListEnum.googleDrive
                //수정 요망
                
                Vc.dataFromContainer(containerData: 0, getStepState: searchStepState, getBottomListState: state, getStringId:id, getStringFolderPath: foldrWholePathNm, getCurrentDevUuid: selectedDevUuid, getCurrentFolderId: currentFolderId)
                
            }
        }
        
    }
    //Nas 파일 컨텍스트 시작
    
    @objc func btnNasOptionClicked(sender:UIButton){
        print("btnNasOptionClicked")
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
        print("optionLocalFileShowClicked lately, tag : \(sender.tag), indexpath.row : \(indexPath.row)")
        if flickState == .main {
            LocalFileListCellController().localContextMenuCalled(cell: cell, indexPath: indexPath, sender: sender, folderArray: folderArray, parentView: "device", deviceView:self, userId: userId, currentFolderId:  currentFolderId, viewState:viewState, containerView:containerViewController!, deviceName:deviceName)
        } else {
            
            LocalFileListCellController().localContextMenuCalledLately(cell: cell, indexPath: indexPath, sender: sender, folderArray: folderArray, parentView: "device", deviceView:self, userId: userId, currentFolderId:  currentFolderId, viewState:viewState, containerView:containerViewController!, deviceName:deviceName, latelyView:latelyUpdatedFileViewController!)
        }
        
        
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
        GDriveFileListCellController().ContextMenuCalled(cell: cell, indexPath: indexPath, sender: sender, folderArray: driveFileArray, deviceName: "Google Drive", parentView: "device", deviceView:self, userId: userId, fromOsCd: fromOsCd, currentDevUuid: selectedDevUuid, currentFolderId:  currentFolderId, containerView:containerViewController!)
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
        GDriveFolderListCellController().GdriveFolderContextMenuCalled(cell: cell, indexPath: indexPath, sender: sender, folderArray: driveFileArray, deviceName: "Google Drive", parentView: "device", deviceView:self, userId: userId, fromOsCd: fromOsCd, currentDevUuid: selectedDevUuid, selectedDevUserId: selectedDevUuid, currentFolderId:  currentFolderId, containerViewController:containerViewController!)
    }
    //구글드라이브 폴더 컨텍스트 종료
    
    // 0eun - start
    func showInsideListGDrive(userId: String, devUuid: String, foldrId: String, deviceName:String){
        self.driveFileArray.removeAll()
        self.driveArrayWithoutUpfolder.removeAll()
        self.driveArrayFolder.removeAll()
        var param = ["userId": userId, "devUuid":devUuid, "foldrId":foldrId,"sortBy":sortBy]
        var googleEmail = UserDefaults.standard.string(forKey: "googleEmail")
//        accessToken = DbHelper().getAccessToken(email: googleEmail!)
        accessToken = UserDefaults.standard.string(forKey: "googleAccessToken")!
        if !accessToken.isEmpty {
            if(driveFolderIdArray.count > 1){
                gDriveUpFolder = App.DriveFileStruct(device: ["id":driveFolderIdArray[driveFolderIdArray.count-2],"kind":"drive#file","mimeType":".folder","name":"..", "modifiedTime":"modifiedTime", "cretDate":"cretDate"] as AnyObject, foldrWholePaths: driveFolderNameArray)
                self.driveFileArray.append(gDriveUpFolder!)
                if(driveFolderIdArray.count == 1){
                    param = ["userId": userId, "devUuid":devUuid]
                }
            }
//            print("param : \(param)")
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
                                    if json["files"].exists() {
                                        let serverList:[AnyObject] = json["files"].arrayObject as! [AnyObject]
                                        for file in serverList {
                                            if file["trashed"] as? Int == 0 && file["starred"] as? Int == 0 && file["shared"] as? Int == 0 {
                                                
                                                let fileStruct = App.DriveFileStruct(device: file, foldrWholePaths: self.driveFolderNameArray)
                                                if fileStruct.mimeType.contains("folder"){
                                                    self.driveArrayFolder.append(fileStruct)
                                                } else {
                                                    if fileStruct.fileExtension == "nil" {
                                                        continue
                                                    }
                                                    self.driveArrayWithoutUpfolder.append(fileStruct)
                                                }
                                                
                                                self.driveFileArray.append(fileStruct)
                                            }
                                        }
                                        self.cellStyle = 3
                                        self.currentFolderId = foldrId
                                        self.collectionviewCellSpcing()
                                        self.deviceCollectionView.collectionViewLayout.invalidateLayout()
//                                        DispatchQueue.main.async {
                                        
                                            self.deviceCollectionView.reloadData()
                                            self.containerViewController?.finishLoading()
//                                        }
                                        
                                    } else {
                                        
                                        self.cellStyle = 3
                                        self.currentFolderId = foldrId
                                        self.collectionviewCellSpcing()
                                        self.deviceCollectionView.collectionViewLayout.invalidateLayout()
                                            self.deviceCollectionView.reloadData()
                                            self.containerViewController?.finishLoading()
                                    }
                                    
                                case .failure(let error):
                                    NSLog(error.localizedDescription)
                                }
            }
        }
        
    }
    // 0eun - end
    


    
    // 구글드라이브 파일 다운로드, 기가나스 보내기
    func downloadGDriveFile(fileId:String, mimeType:String, name:String) {

            GoogleWork().downloadGDriveFile(fileId: fileId, mimeType: mimeType, name: name, startByte: 0, endByte: 102400) { responseObject, error in
                if let fileUrl = responseObject {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: nil, message: "다운로드를 성공하였습니다.", preferredStyle: .alert)
                        let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel){
                            UIAlertAction in
                            self.containerViewController?.finishLoading()
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
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: nil, message: "다운로드를 실패하였습니다.", preferredStyle: .alert)
                        let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel){
                            UIAlertAction in
                            self.containerViewController?.finishLoading()
                        }
                        alertController.addAction(yesAction)
                        self.present(alertController, animated: true)
                    }

                }
            }
            
        
            
            
         
//            accessToken = UserDefaults.standard.string(forKey: "googleAccessToken")!
//            print("fileId : \(fileId), mimeType : \(mimeType)")
//            let stringUrl = "https://www.googleapis.com/drive/v3/files/\(fileId)/?alt=media&range='bytes=0-80'&access_token=\(accessToken)"
//
//            let downloadUrl = URL(string: stringUrl)
//            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
//                var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//
//                // the name of the file here I kept is yourFileName with appended extension
//                documentsURL.appendPathComponent("\(name)")
//                return (documentsURL, [.removePreviousFile])
//            }
//
//            

//             request = Alamofire.download(downloadUrl!, method: .get, headers:nil, to: destination)
//                    .downloadProgress(closure: { (progress) in
//                        DispatchQueue.main.async() {
////                        print("Total bytes read on main queue: \(totalBytesRead)")
//                            print("download progress : \(progress.fractionCompleted)")
//                            if(self.getMemoryUsage() > 150){
//                                URLCache.shared.removeAllCachedResponses()
//
//                            }
//                        }
//                    })
//                    .response {  response in
//                        print("response : \(response)")
//                        if response.destinationURL != nil {
//                            print(response.destinationURL!)
//                            DispatchQueue.main.async {
//
//                                let alertController = UIAlertController(title: nil, message: "다운로드를 성공하였습니다.", preferredStyle: .alert)
//                                let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel){
//                                    UIAlertAction in
//
//                                    self.containerViewController?.finishLoading()
//                                    if let syncOngoing:Bool = UserDefaults.standard.bool(forKey: "syncOngoing"), syncOngoing == true {
//                                        print("aleady Syncing")
//
//                                    } else {
//                                        SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
//                                    }
//                                }
//                                alertController.addAction(yesAction)
//                                self.present(alertController, animated: true)
//                            }
//                        }
//                }
//////
//        }
        
          
    }
    
    func getMemoryUsage() -> UInt64 {
        
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        if kerr == KERN_SUCCESS {
            let usedMegabytes = taskInfo.resident_size/1000000
            print("usedMegabytes : \(usedMegabytes)")
            return usedMegabytes
            
        } else {
            print("Error with task_info(): " +
                (String(cString: mach_error_string(kerr), encoding: String.Encoding.ascii) ?? "unknown error"))
            return 0
        }
        
    }
    
    func finishedFileDownload(fetcher: GTMSessionFetcher, finishedWithData data: NSData, error: NSError?){
        if let error = error {
            //show an alert with the error message or something similar
            return
        }
        
        //do something with data (save it..)
    }
    @objc func optionNasFileShowClicked(sender:UIButton){
        print("optionNasFileShowClicked")
        if viewState == .home {
            let buttonRow = sender.tag
            let indexPath = IndexPath(row: buttonRow, section: 0)
            let cell = deviceCollectionView.cellForItem(at: indexPath) as! NasFileListCell
            //        self.nasContextMenuCalled(cell: cell, indexPath: indexPath, sender:sender)
            print("home optionNasFileShowhomeClicked")
            
            if flickState == .main {
                NasFileCellController().nasContextMenuCalled(cell: cell, indexPath: indexPath, sender: sender, folderArray: folderArray, deviceName: deviceName, parentView: "device", deviceView:self, userId: userId, currentFolderId:  currentFolderId, containerView: containerViewController!)
                
            } else if flickState == .lately {
                NasFileCellController().nasContextMenuCalledFromLately(cell: cell, indexPath: indexPath, sender: sender, folderArray: folderArray, deviceName: deviceName, parentView: "device", deviceView:latelyUpdatedFileViewController!, userId: userId, currentFolderId:  currentFolderId, containerView: containerViewController!)
                
            }
            
        } else {
            let buttonRow = sender.tag
            let indexPath = IndexPath(row: buttonRow, section: 0)
            let cell = deviceCollectionView.cellForItem(at: indexPath) as! NasFileListCell
            //        self.nasContextMenuCalled(cell: cell, indexPath: indexPath, sender:sender)
            print("search optionNasFileShowClicked")
            NasFileCellController().nasContextMenuCalled(cell: cell, indexPath: indexPath, sender: sender, folderArray: folderArray, deviceName: deviceName, parentView: "device", deviceView:self, userId: userId, currentFolderId:  currentFolderId, containerView: containerViewController!)
            
        }
        
    }
    func hideSelectedOptions(tag:Int){

            let indexPath = IndexPath(row: tag, section: 0)
            //            let cell = deviceCollectionView.cellForItem(at: indexPath)
            if let cell = deviceCollectionView.cellForItem(at: indexPath) as? NasFileListCell {
                print("hide nas file option")
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
                print("hide local file option")
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
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
        
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
//            print("count : \(count)")
            if(row != tag){
                let indexPath = IndexPath(row: row, section: 0)
    //            let cell = deviceCollectionView.cellForItem(at: indexPath)
                if let cell = deviceCollectionView.cellForItem(at: indexPath) as? NasFileListCell {
                    print("hide nas file option")
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
                    print("hide local file option")
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
       
        
        MultiCheckFileListController().btnMultiCheckClicked(sender: sender, parent: self, folderArray:folderArray)
        
        
    }
    
    @objc func btnGoogleDriveMultiCheckClicked(sender:UIButton){
        GdriveMultiCheckController().btnGoogleDriveMultiCheckClicked(sender: sender, getDriveArray:driveFileArray, getHomeViewController:homeViewController!, getFlisckState:flickState, parent: self)
    }
    
    func gDriveMultiCheckedFolderArray(indexPath:IndexPath, check:Bool, checkedFile:App.DriveFileStruct, getDriveFileArray:[App.DriveFileStruct]){
        let getIndex = indexPath.row
        let checkedFolder = driveFileArray[getIndex]
        
        if(check){
            
            driveFileArray[getIndex].checked = true
            self.gDriveMultiCheckedfolderArray.append(checkedFolder)
        } else {
            driveFileArray[getIndex].checked = false
            if let removeIndex = gDriveMultiCheckedfolderArray.index(where: { $0.fileId == driveFileArray[getIndex].fileId && $0.parents == driveFileArray[getIndex].parents}) {
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
    func gDriveMultiCheckedFolderArrayGrid(indexPath:IndexPath, check:Bool, checkedFile:App.DriveFileStruct, getFolderArray:[App.DriveFileStruct]){
        let getIndex = indexPath.row
        let checkedFolder = driveFileArray[getIndex]
        driveFileArray = getFolderArray
        if(check){
            driveFileArray[getIndex].checked = true
            self.gDriveMultiCheckedfolderArray.append(checkedFolder)
        } else {
            driveFileArray[getIndex].checked = false
            if let removeIndex = gDriveMultiCheckedfolderArray.index(where: { $0.fileId == driveFileArray[getIndex].fileId && $0.parents == driveFileArray[getIndex].parents}) {
//                print("removeIndex : \(removeIndex)")
                self.gDriveMultiCheckedfolderArray.remove(at: removeIndex)
            }
        }
        if(flickState == .main){
            homeViewController?.setMultiCountLabel(multiButtonChecked: true, count: gDriveMultiCheckedfolderArray.count)
        } else {
            latelyUpdatedFileViewController?.setMultiCountLabel(multiButtonChecked: true, count: multiCheckedfolderArray.count)
        }
        print("gDriveMultiCheckedfolderArray : \(gDriveMultiCheckedfolderArray.count)")
        
    }
    
    func allMultiCheck(selectedAll:Bool){
        selectAllCheck = selectedAll
        print("selectAllCheck : \(selectAllCheck), selectedDevOsCd : \(selectedDevOsCd)")
        
        if mainContentState == .googleDriveList {
            self.gDriveMultiCheckedfolderArray.removeAll()
        } else {
            self.multiCheckedfolderArray.removeAll()
        }
        if(selectAllCheck) {
            for (index, _) in driveFileArray.enumerated() {
                driveFileArray[index].checked = true
            }
            
            if mainContentState == .googleDriveList {
                self.gDriveMultiCheckedfolderArray = driveFileArray
                if self.gDriveMultiCheckedfolderArray[0].name == ".." {
                    self.gDriveMultiCheckedfolderArray.remove(at: 0)
                }
                
            } else {
                for (index, _) in folderArray.enumerated() {
                    folderArray[index].checked = true
                }
                
                if(folderArray.count > 0){
                    self.multiCheckedfolderArray = folderArray
                    print("multiCheckedfolderArray 0 : \(multiCheckedfolderArray[0])")
                    if multiCheckedfolderArray[0].foldrNm == ".." {
                        self.multiCheckedfolderArray.remove(at: 0)
                    }
                    
                    if selectedDevOsCd != "S" && selectedDevOsCd != "G" {
                        if (selectedDevUuid != Util.getUuid()){
                            for (index, folder) in multiCheckedfolderArray.enumerated().reversed() {
                                print("folder. etion : \(folder.etsionNm)")
                                if(multiCheckedfolderArray[index].etsionNm == "nil"){
                                    self.multiCheckedfolderArray.remove(at: index)
                                }
                            }
                        }
                    }
                } else {
                    
                }
                

                
            }
        } else {
            if mainContentState == .googleDriveList {
                self.gDriveMultiCheckedfolderArray.removeAll()
                for (index, _) in driveFileArray.enumerated() {
                    driveFileArray[index].checked = false
                }
            } else {
                self.multiCheckedfolderArray.removeAll()
                for (index, _) in folderArray.enumerated() {
                    folderArray[index].checked = false
                }
            }
            
            
            
            
        }
        var count = multiCheckedfolderArray.count
        if mainContentState == .googleDriveList {
            count = gDriveMultiCheckedfolderArray.count
        }
        
        
        
        deviceCollectionView.reloadData()

        if(flickState == .main){
            homeViewController?.setMultiCountLabel(multiButtonChecked: true, count: count)
        } else {
            latelyUpdatedFileViewController?.setMultiCountLabel(multiButtonChecked: true, count: count)
            
        }
//        print("multiCheckedfolderArray : \(multiCheckedfolderArray)")
//        print("gDriveMultiCheckedfolderArray : \(gDriveMultiCheckedfolderArray)")
    }
    
    func multiCheckedFolderArray(indexPath:IndexPath, check:Bool){
        let getIndex = indexPath.row
        let checkedFolder = folderArray[getIndex]
        
        if(check){
            folderArray[getIndex].checked = true
            self.multiCheckedfolderArray.append(checkedFolder)
        } else {
            folderArray[getIndex].checked = false
            if let removeIndex = multiCheckedfolderArray.index(where: { $0.fileId == folderArray[getIndex].fileId && $0.foldrId == folderArray[getIndex].foldrId}) {
            self.multiCheckedfolderArray.remove(at: removeIndex)
            }
        }
        if(flickState == .main){
            homeViewController?.setMultiCountLabel(multiButtonChecked: true, count: multiCheckedfolderArray.count)
        } else {
            latelyUpdatedFileViewController?.setMultiCountLabel(multiButtonChecked: true, count: multiCheckedfolderArray.count)
//            latelyUpdatedFileViewController?.multiCheckedfolderArray = multiCheckedfolderArray
            print("multiCheckedfolderArray : \(multiCheckedfolderArray)")
        }
    }
    
    func multiCheckedFolderArrayGrid(indexPath:IndexPath, check:Bool, getFolderArray:[App.FolderStruct]){
        let getIndex = indexPath.row
        let checkedFolder = folderArray[getIndex]
        self.folderArray = getFolderArray
        if(check){
            folderArray[getIndex].checked = true
            self.multiCheckedfolderArray.append(checkedFolder)
        } else {
            folderArray[getIndex].checked = false
            if let removeIndex = multiCheckedfolderArray.index(where: { $0.fileId == folderArray[getIndex].fileId && $0.foldrId == folderArray[getIndex].foldrId}) {

                self.multiCheckedfolderArray.remove(at: removeIndex)
                
            }
        }
        if(flickState == .main){
            homeViewController?.setMultiCountLabel(multiButtonChecked: true, count: multiCheckedfolderArray.count)
        } else {
            latelyUpdatedFileViewController?.setMultiCountLabel(multiButtonChecked: true, count: multiCheckedfolderArray.count)
            //            latelyUpdatedFileViewController?.multiCheckedfolderArray = multiCheckedfolderArray
            print("multiCheckedfolderArray : \(multiCheckedfolderArray)")
        }
    }
    
    
    
    @objc func handleMultiCheckFolderArray(fileDict:[String:Any]) {
    
        if let getAction = fileDict["action"] as? String, let getFromOsCd = fileDict["fromOsCd"] as? String {
            if getAction == "nasfromSearchView" {
                print("nas From searchView")
                containerViewController?.getMultiFolderArray(getArray:multiCheckedfolderArray, toStorage:"search_nas_multi", fromUserId:selectedDevUserId, fromOsCd:fromOsCd,fromDevUuid:selectedDevUuid, foldrWholePathNm:foldrWholePathNm)
                
            } else {
                print("getFromOsCd : \(getFromOsCd)")
                if(selectedDevUuid == Util.getUuid()){
                    switch getAction {
                    case "nas":
                        print("local to nas multi, fromUserId : \(selectedDevUserId)")
                        containerViewController?.getMultiFolderArray(getArray:multiCheckedfolderArray, toStorage:"local_nas_multi", fromUserId:selectedDevUserId, fromOsCd:fromOsCd,fromDevUuid:selectedDevUuid, foldrWholePathNm:foldrWholePathNm)
                        //                    homeViewController?.inActiveMultiCheck()
                        break
                    case "gDrive":
                        print("multi to  gDrive")
                        let fileDict = ["fileId":"fileId", "fileNm":"fileNm","amdDate":"amdDate", "oldFoldrWholePathNm":foldrWholePathNm,"fromDevUuid":selectedDevUuid, "toStorage":"local_gdrive_multi","fromUserId":selectedDevUserId, "fromOsCd":selectedDevOsCd]
                        
                        containerViewController?.googleSignInCheckForMulti(fileDict: fileDict, getMultiArray:multiCheckedfolderArray)
                        //                    containerViewController?.getMultiFolderArray(getArray:multiCheckedfolderArray, toStorage:"local_gdrive_multi", fromUserId:selectedDevUserId, fromOsCd:fromOsCd,fromDevUuid:selectedDevUuid,foldrWholePathNm:foldrWholePathNm)
                        break
                        
                    case "delete":
                        print("multi local delete, selectedDevFoldrId : \(selectedDevFoldrId)")
                        DispatchQueue.main.async {
                            self.containerViewController?.showIndicator()
                            self.homeViewController?.initMultiCheckFalseView()
                        }
                        
                        MultiCheckFileListController().callMultiLocalDelete(getFolderArray: multiCheckedfolderArray, parent: self, fromUserId:selectedDevUserId, devUuid: selectedDevUuid, deviceName: deviceName, devFoldrId:selectedDevFoldrId, containerViewController:containerViewController!)
                        
                        
                        break
                    default:
                        
                        break
                    }
                } else if getFromOsCd == "G" || getFromOsCd == "S" {
                    // NAS 멀티 메뉴 핸들
                    switch getAction {
                    case "download":
                        print("다운로드 multi, selectedDevUuid : \(selectedDevUserId)")
                        
                        NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
                        MultiCheckFileListController().callDwonLoad(getFolderArray: multiCheckedfolderArray, parent: self, devUuid: selectedDevUuid, deviceName: deviceName, devUserId:selectedDevUserId)
                        
                        var fileIdArryStr = ""
                        var fileSizeArryStr = ""
                        var fileNmArryStr = ""
                        var fileEtsionmArryStr = ""
                        for arryIndex in 0...multiCheckedfolderArray.count-1 {
                            
                            var id = multiCheckedfolderArray[arryIndex].fileId
                            var name = multiCheckedfolderArray[arryIndex].fileNm
                            if id == 0 {
                                id = multiCheckedfolderArray[arryIndex].foldrId
                                name = multiCheckedfolderArray[arryIndex].foldrNm
                            }
                            
                            if arryIndex == multiCheckedfolderArray.count-1 {
                                fileIdArryStr += "\(id)"
                                fileSizeArryStr += multiCheckedfolderArray[arryIndex].fileSize
                                fileNmArryStr += name
                                fileEtsionmArryStr += multiCheckedfolderArray[arryIndex].etsionNm
                            } else {
                                fileIdArryStr += "\(id):"
                                fileSizeArryStr += "\(multiCheckedfolderArray[arryIndex].fileSize):"
                                fileNmArryStr += "\(name):"
                                fileEtsionmArryStr += "\(multiCheckedfolderArray[arryIndex].etsionNm):"
                            }
                        }
                        let fileDict = ["fileIdArryStr":fileIdArryStr, "fileSizeArryStr":fileSizeArryStr,"fileNmArryStr":fileNmArryStr,"fileEtsionmArryStr":fileEtsionmArryStr]
                        print("multiProgressSegue fileDict : \(fileDict)")
                        NotificationCenter.default.post(name: Notification.Name("multiProgressSegue"), object: self, userInfo: fileDict)
                        
                        break
                    case "nas":
                        
                        print("multi nas, fromUserId : \(selectedDevUserId)")
                        print("multiCheckedfolderArray : \(multiCheckedfolderArray)")
                        containerViewController?.getMultiFolderArray(getArray:multiCheckedfolderArray, toStorage:"nas_multi", fromUserId:selectedDevUserId, fromOsCd:fromOsCd,fromDevUuid:selectedDevUuid,foldrWholePathNm:foldrWholePathNm)
                        
                        break
                    case "gDrive":
                        print("multi gDrive, folder : \(foldrWholePathNm)")
                        let fileDict = ["fileId":"fileId", "fileNm":"fileNm","amdDate":"amdDate", "oldFoldrWholePathNm":foldrWholePathNm,"fromDevUuid":selectedDevUuid, "toStorage":"googleDriveMulti","fromUserId":selectedDevUserId, "fromOsCd":selectedDevOsCd]
                        
                        containerViewController?.googleSignInCheckForMulti(fileDict: fileDict, getMultiArray:multiCheckedfolderArray)
                        //                    containerViewController?.getMultiFolderArray(getArray:multiCheckedfolderArray, toStorage:"nas_gdrive_multi", fromUserId:selectedDevUserId, fromOsCd:fromOsCd,fromDevUuid:selectedDevUuid,foldrWholePathNm:foldrWholePathNm)
                        
                        break
                        
                    case "delete":
                        
//                        NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
                        print("multi local delete, selectedDevFoldrId : \(selectedDevFoldrId)")
                        DispatchQueue.main.async {
                            self.containerViewController?.showIndicator()
                            self.homeViewController?.initMultiCheckFalseView()
                        }
                        MultiCheckFileListController().callMultiDelete(getFolderArray: multiCheckedfolderArray, parent: self, fromUserId:selectedDevUserId, devUuid: selectedDevUuid, deviceName: deviceName, devFoldrId:selectedDevFoldrId)
                       
                        break
                    default:
                        
                        break
                    }
                } else if getFromOsCd == "multi" {
                    containerViewController?.getMultiFolderArray(getArray:multiCheckedfolderArray, toStorage:"multi_nas_multi", fromUserId:selectedDevUserId, fromOsCd:fromOsCd,fromDevUuid:selectedDevUuid,foldrWholePathNm:foldrWholePathNm)
                } else if getFromOsCd == "D"{
                    //gdrive 멀티 핸들
                    switch getAction {
                    case "download":
                        print("다운로드 multi gDrive")
                        NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
                        GdriveMultiCheckController().callDwonLoad(getFolderArray: gDriveMultiCheckedfolderArray, parent: self)
                        
                        var fileIdArryStr = ""
                        var fileSizeArryStr = ""
                        var fileNmArryStr = ""
                        var fileEtsionmArryStr = ""
                        for arryIndex in 0...gDriveMultiCheckedfolderArray.count-1 {
                            
                            var id = gDriveMultiCheckedfolderArray[arryIndex].fileId
                            var name = gDriveMultiCheckedfolderArray[arryIndex].name
                            var fileExtension = gDriveMultiCheckedfolderArray[arryIndex].fileExtension
                            
                            if arryIndex == gDriveMultiCheckedfolderArray.count-1 {
                                fileIdArryStr += "\(id)"
                                fileSizeArryStr += gDriveMultiCheckedfolderArray[arryIndex].size
                                fileNmArryStr += name
                                fileEtsionmArryStr += gDriveMultiCheckedfolderArray[arryIndex].fileExtension
                            } else {
                                fileIdArryStr += "\(id):"
                                fileSizeArryStr += "\(gDriveMultiCheckedfolderArray[arryIndex].size):"
                                fileNmArryStr += "\(name):"
                                fileEtsionmArryStr += "\(gDriveMultiCheckedfolderArray[arryIndex].fileExtension):"
                            }
                        }
                        let fileDict = ["fileIdArryStr":fileIdArryStr, "fileSizeArryStr":fileSizeArryStr,"fileNmArryStr":fileNmArryStr,"fileEtsionmArryStr":fileEtsionmArryStr]
                        print("multiProgressSegue fileDict : \(fileDict)")
                        NotificationCenter.default.post(name: Notification.Name("multiProgressSegue"), object: self, userInfo: fileDict)
                        homeViewController?.inActiveMultiCheck()
                        break
                    case "nas":
                        print("gdrive_nas_multi 보내기")
                        containerViewController?.getGDriveMultiFolderArray(getArray:gDriveMultiCheckedfolderArray, toStorage:"gdrive_nas_multi", fromUserId:selectedDevUserId, fromOsCd:fromOsCd,fromDevUuid:selectedDevUuid)
                        break
                    
                    case "delete":
                        print("gdrive_nas_multi 삭제")
                        DispatchQueue.main.async {
                            self.containerViewController?.showIndicator()
                            self.homeViewController?.initMultiCheckFalseView()
                        }

                        print("currentFolderId : \(currentFolderId)")
                        GdriveMultiCheckController().callMultiDelete(getFolderArray: gDriveMultiCheckedfolderArray, parent: self, fromUserId: selectedDevUserId, devUuid: selectedDevUuid, deviceName: deviceName, devFoldrId: currentFolderId, containerView:containerViewController!)
                        homeViewController?.inActiveMultiCheck()
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
                        foldrWholePathNm = multiCheckedfolderArray[0].foldrWholePathNm
                        print("foldrWholePathNm : \(foldrWholePathNm)")
                        
                        containerViewController?.getMultiFolderArray(getArray:multiCheckedfolderArray, toStorage:"remote_nas_multi", fromUserId:selectedDevUserId, fromOsCd:fromOsCd,fromDevUuid:selectedDevUuid, foldrWholePathNm:foldrWholePathNm)
                        
                        break
                        
                    default:
                        
                        break
                    }
                    
                }
                
            }
           
        }
       
    }
    
 
    
    func handleMultiCheckFromLatelyView() {
        print("multi_nas_multi")
        let remoteDownLoadStyle = "remoteDownLoadNasMulti"
        UserDefaults.standard.setValue(remoteDownLoadStyle, forKey: "remoteDownLoadStyle")
        UserDefaults.standard.synchronize()
        print("multiCheckedfolderArray : \(multiCheckedfolderArray)")
        containerViewController?.getMultiFolderArray(getArray:multiCheckedfolderArray, toStorage:"multi_nas_multi", fromUserId:selectedDevUserId, fromOsCd:fromOsCd,fromDevUuid:selectedDevUuid, foldrWholePathNm: foldrWholePathNm)
    }
    
    @objc func countRemoteDownloadFinished(){
        print("countRemoteDownloadFinished")
        remoteMultiFileDownloadedCount -= 1
        if(remoteMultiFileDownloadedCount > 0){            
            print("remoteMultiFileDownloadedCount : \(remoteMultiFileDownloadedCount)")
            return
        }
        DispatchQueue.main.async {
            print("multi download sync called")
            
            NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
            let alertController = UIAlertController(title: nil, message: "멀티 파일 다운로드를 성공하였습니다.", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel) {
                UIAlertAction in
                if let syncOngoing:Bool = UserDefaults.standard.bool(forKey: "syncOngoing"), syncOngoing == true {
                    print("aleady Syncing")
                    
                } else {
                    SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
                }
                self.delegate.notificationOnGoing = false
                
            }
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
//        print("name : \(localFileArray[index].fileNm)")
        
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
            print("fromOsCd : \(fromOsCd), devUuid : \(devUuid)")
            if(fileId == 0){
            } else {
                if(devUuid == Util.getUuid()){
                    //로컬 롱 터치
                    let fileUrl:URL = FileUtil().getFileUrlWithFoldr(fileNm: fileNm, foldrWholePathNm: foldrWholePathNm, amdDate: amdDate)!
                    let urlDict = ["url":fileUrl]
                    if flickState == .main {
                        NotificationCenter.default.post(name: Notification.Name("openDocument"), object: self, userInfo: urlDict)
                    } else {
                        latelyUpdatedFileViewController?.openDocument(getUrl:fileUrl)
                    }
                    
                } else if fromOsCd == "S" || fromOsCd == "G" {
                    //nas 롱 터치
                    print("selectedFileId : \(folderArray[indexPath.row].fileId)")
//                    containerViewController?.activityIndicator.startAnimating()
                    containerViewController?.showIndicator()
                    let fileNm = folderArray[indexPath.row].fileNm
                    let fileId = "\(folderArray[indexPath.row].fileId)"
                    let foldrWholePathNm = "\(folderArray[indexPath.row].foldrWholePathNm)"
                    let amdDate = folderArray[indexPath.row].amdDate
                    let createdPath:URL = ContextMenuWork().createLocalFolder(folderName: "AppPlay")!
                    self.downloadFromNasToExcute(name: fileNm, path: foldrWholePathNm, fileId:fileId, amdDate:amdDate)
                    print("download and excute")
                    
                } else {
                    // 리모트 롱 터치
//                    homeViewController?.homeViewToggleIndicator()
                    containerViewController?.showIndicator()
                    let remoteDownLoadStyle = "remoteDownLoadToExcute"
                    UserDefaults.standard.setValue(remoteDownLoadStyle, forKey: "remoteDownLoadStyle")
                    UserDefaults.standard.synchronize()
//                    print("remoteDownLoad: \(String(describing: UserDefaults.standard.string(forKey: "remoteDownLoadStyle")))")
                    print("folder : \(folderArray[indexPath.row])")
                    print("fileId: \(fileId) , fromUserId : \(userId), fromDevUuid : \(selectedDevUuid), fromFoldr : \(foldrWholePathNm)")
                    let createdPath:URL = ContextMenuWork().createLocalFolder(folderName: "AppPlay")!
                    let AppPlayYn:String = "Y"
                    ContextMenuWork().remoteDownloadRequest(fromUserId: userId, fromDevUuid: selectedDevUuid, fromOsCd: fromOsCd, fromFoldr: foldrWholePathNm, fromFileNm: fileNm, fromFileId: String(fileId), AppPlayYn:AppPlayYn)
                }
              
            }
        } else if cellStyle == 3 {
            if driveFileArray.count > 0{
                containerViewController?.showIndicator()
                let mimeType = driveFileArray[indexPath.row].mimeType
                if(mimeType == "application/vnd.google-apps.folder"){
                } else {
                    let fileId = driveFileArray[indexPath.row].fileId
                    let name = driveFileArray[indexPath.row].name
                    let createdPath:URL = ContextMenuWork().createLocalFolder(folderName: "AppPlay")!
                    GoogleWork().downloadGDriveFileToExcute(fileId: fileId, mimeType: mimeType, name: name, startByte: 0, endByte: 102400) { responseObject, error in
                        if error == nil {
                            if let fileUrl = responseObject, fileUrl != nil {
                                let urlDict = ["url":fileUrl]
                                print("urlDict : \(urlDict)")
                                NotificationCenter.default.post(name: Notification.Name("openDocument"), object: self, userInfo: urlDict)
                            } else {
                                DispatchQueue.main.async {
                                    let alertController = UIAlertController(title: nil, message: "다운로드를 실패하였습니다.", preferredStyle: .alert)
                                    let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel){
                                        UIAlertAction in
                                        self.containerViewController?.finishLoading()
                                    }
                                    alertController.addAction(yesAction)
                                    self.present(alertController, animated: true)
                                }
                                
                            }
                        }
                        
                    }
                    
                    
                }
            }
            
        }
        print("\(indexPath.row) selected")
        if(cellStyle == 2){
            print("RemoteFileListCell long touch")
        }
        
    }
    
    
    
    
    
  
    func downloadFromNas(name:String, path:String, fileId:String, devUserId:String){

        print("downloadFromNas : userId : \(userId), selectedDevUuid : \(selectedDevUuid), selectedDevUserId : \(selectedDevUserId), devUserId : \(devUserId)")
        containerViewController?.showIndicator()
//        var downloadUserId = userId
        contextMenuWork?.downloadFromNas(userId:devUserId, fileNm:name, path:path, fileId:fileId){ responseObject, error in
            if let success = responseObject {
                print(success)
                if(success == "success"){
                    DispatchQueue.main.async {
                        self.containerViewController?.finishLoading()
                        let alertController = UIAlertController(title: nil, message: "파일 다운로드를 성공하였습니다.", preferredStyle: .alert)
                        let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel)
                        self.containerViewController?.finishLoading()
                        if let syncOngoing:Bool = UserDefaults.standard.bool(forKey: "syncOngoing"), syncOngoing == true {
//                            print("aleady Syncing")
                        } else {
                            SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
                        }
                        alertController.addAction(yesAction)
                        self.present(alertController, animated: true)
                    }
                } else {
                    self.containerViewController?.finishLoading()
//                    NotificationCenter.default.post(name: Notification.Name("homeViewToggleIndicator"), object: self, userInfo: nil)
                    let alertController = UIAlertController(title: nil, message: "파일 다운로드를 실패하였습니다.", preferredStyle: .alert)
                    let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel)                    
                    alertController.addAction(yesAction)
                    self.present(alertController, animated: true)
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
                    if self.flickState == .main {
                        NotificationCenter.default.post(name: Notification.Name("openDocument"), object: self, userInfo: urlDict)
                    } else {
                        self.latelyUpdatedFileViewController?.openDocument(getUrl: url)
                    }
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
                    if let syncOngoing:Bool = UserDefaults.standard.bool(forKey: "syncOngoing"), syncOngoing == true {
                        print("aleady Syncing")
                        
                    } else {
                        SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
                    }
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
        if flickState == .main {
            self.containerViewController?.showIndicator()
        } else {
            self.latelyUpdatedFileViewController?.showIndicator()
        }
        
        ContextMenuWork().deleteNasFile(parameters:param){ responseObject, error in
            if let obj = responseObject {
                print(obj)
                let json = JSON(obj)
//                let message = obj.object(forKey: "message")
//                print("\(message), \(json["statusCode"].int)")
                if let statusCode = json["statusCode"].int, statusCode == 100 {
                    DispatchQueue.main.async {
                        
                        if self.flickState == .main {
                            self.containerViewController?.finishLoading()
                        } else {
                            self.latelyUpdatedFileViewController?.finishLoading()
                        }
                        if self.viewState == .home {
                            self.showInsideList(userId: param["userId"] as! String, devUuid: param["devUuid"] as! String, foldrId: foldrId, deviceName:self.deviceName)
                        } else {
                            
                            self.refreshSearchList()
                        }
                        
                        let alertController = UIAlertController(title: nil, message: "파일 삭제가 완료 되었습니다.", preferredStyle: .alert)
                        let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel)
                        alertController.addAction(yesAction)
                        self.present(alertController, animated: true)
                    }
                } else {
                    if self.flickState == .main {
                        self.containerViewController?.finishLoading()
                    } else {
                        self.latelyUpdatedFileViewController?.finishLoading()
                    }
                    
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
    

    
    func clickDeviceItem2(indexPathRow: Int){
        
//                print("devid : \(DeviceArray[indexPathRow].devUuid), myid : \(Util.getUuid())")
                if indexPathRow < DeviceArray.count {
                    if(DeviceArray[indexPathRow].osCd == "D"){
                        self.fromOsCd = "D"
                        homeViewController?.fromOsCd = "D"
                        containerViewController?.showIndicator()
//                        print("google drive clicked")
                        let accessToken = UserDefaults.standard.string(forKey: "googleAccessToken") ?? ""
                        let getTokenTime:String = UserDefaults.standard.string(forKey: "googleLoginTime") ?? ""
                        print("deviceclick item accessToken : \(accessToken), getTokenTime : \(getTokenTime)")
                        let now = Date()
                        if !getTokenTime.isEmpty {
                            let dateGetTokenTime = Util.stringToDate(text: getTokenTime)
                            var userCalendar = Calendar.current
                            userCalendar.timeZone = TimeZone.current
                            let requestedComponent: Set<Calendar.Component> = [.hour,.minute,.second]
                            let timeDifference = userCalendar.dateComponents(requestedComponent, from: dateGetTokenTime, to: now)
                            let hour = timeDifference.hour
                            let minute = timeDifference.minute
                            print("token minute difference : \(minute)")
                            if(hour! < 1 && minute! < 50) {
                                let loginState = UserDefaults.standard.string(forKey: "googleDriveLoginState")
                                print("loginState : \(loginState)")
                                if(loginState == "login"){
                                    print("get file")
                                    containerViewController?.googleSignInSegueState = .loginForList
                                    GIDSignIn.sharedInstance().signInSilently()
                                    containerViewController?.getFiles(accessToken: accessToken, root: "root")
                                } else {
    //                                        print("login called")
                                    containerViewController?.googleSignInSegueState = .loginForList
                                    containerViewController?.googleSignInAlertShow()
                                }
                            } else {
    //                                    print("google email")
                                containerViewController?.googleSignInSegueState = .loginForList
                                containerViewController?.googleSignInAlertShow()
                            }
                        } else {
                            containerViewController?.googleSignInSegueState = .loginForList
                            containerViewController?.googleSignInAlertShow()
                        }

             

                    } else {
                    
                        cellStyle = 2
                        mainContentState = .oneViewList
                        selectedDevUuid = DeviceArray[indexPathRow].devUuid

                        if(selectedDevUuid == Util.getUuid()){
                            contextMenuState = .local
//                            print("contextMenuState local")
                        } else {
                            contextMenuState = .nas
//                            print("contextMenuState nas")
                        }
                        userId = DeviceArray[indexPathRow].userId
                        
                        selectedDevUserId = DeviceArray[indexPathRow].userId
                        
                        selectedDevOsCd = DeviceArray[indexPathRow].osCd
                        deviceName = DeviceArray[indexPathRow].devNm

//                        print("userId:\(userId), viewState : \(viewState), deviceName : \(deviceName)")
                      
                        searchStepState = .device
                        foldrWholePathNm = ""
                        fromOsCd = DeviceArray[indexPathRow].osCd
                        
                        var state = HomeViewController.bottomListEnum.nasFileInfo
                        if(fromOsCd == "G" || fromOsCd == "S"){
                            state = HomeViewController.bottomListEnum.nasFileInfo
                        } else {
                            state = HomeViewController.bottomListEnum.remoteFileInfo
                            if(selectedDevUuid == Util.getUuid()){
                                state = HomeViewController.bottomListEnum.localFileInfo
                            }
                        }
                        homeViewController?.searchStepState = searchStepState
                        homeViewController?.searchId = id
                        homeViewController?.foldrWholePathNm = foldrWholePathNm
                        homeViewController?.bottomListState = state
                        homeViewController?.currentDevUuid = selectedDevUuid
                        homeViewController?.currentFolderId = currentFolderId
                        homeViewController?.fromOsCd = fromOsCd
                        homeViewController?.cellStyle = 2
                        homeViewController?.userId = userId
                        homeViewController?.selectedDevUserId = selectedDevUserId
                        homeViewController?.deviceName = deviceName
                        homeViewController?.viewState = viewState
                        homeViewController?.selectedDevUuid = selectedDevUuid
                        if(viewState == .home){
                            
//                            DispatchQueue.main.async {
                            let folderName = ["folderName":"\(self.DeviceArray[indexPathRow].devNm)","deviceName":self.deviceName, "devUuid":self.selectedDevUuid]
                            self.homeViewController?.completeFolderNameForSearchView = "\(self.DeviceArray[indexPathRow].devNm)"
                            NotificationCenter.default.post(name: Notification.Name("setupFolderPathView"), object: self, userInfo: folderName)
                                self.getRootFolder(userId:self.userId, devUuid: self.selectedDevUuid, deviceName:self.deviceName)
                            
//                            }
                            
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
//                        print("nasfolderList :\(serverList)")
                        if serverList.count > 0 {
                            for rootFolder in serverList{
                                
                                let foldrId = rootFolder["foldrId"] as? Int ?? 0
                                let stringFoldrId = String(foldrId)
                                let foldrNm = rootFolder["foldrNm"] as? String ?? "nil"
                                
                                let stringFoldrNm = String(foldrNm)
                                self.selectedDevFoldrId = stringFoldrId
                                //                            let childCnt = rootFolder["childCnt"] as? Int ?? 0
                                //                            let osCd = rootFolder["osCd"] as? String ?? "nil"
                                if (self.fromOsCd == "W"){
                                    var folder = App.FolderStruct(data: rootFolder as AnyObject)
                                    folder.devNm = deviceName
                                    folder.osCd = self.selectedDevOsCd
                                    folder.userId = self.selectedDevUserId
                                    folder.userId = self.selectedDevUserId
                                    //                                print("deviceName : \(deviceName)")
                                    //                                print("folder : \(folder)")
                                    self.folderIdArray.append(0)
                                    self.folderNameArray.append(stringFoldrNm)
                                    self.folderArray.append(folder)
                                    self.cellStyle = 2
                                    self.homeViewController?.cellStyle = 2
                                    
                                    self.currentFolderId = String(foldrId)
                                    self.collectionviewCellSpcing()
                                    
                                    //                                DispatchQueue.main.async {
                                    self.deviceCollectionView.collectionViewLayout.invalidateLayout()
                                    self.deviceCollectionView.reloadData()
                                    self.containerViewController?.finishLoading()
                                    //                                }
                                    
                                } else {
                                    self.folderIdArray.append(foldrId)
                                    self.folderNameArray.append(stringFoldrNm)
                                    self.showInsideList(userId: userId, devUuid: devUuid, foldrId: stringFoldrId, deviceName:deviceName)
                                }
                                
                            }
                        } else {
                            self.deviceCollectionView.collectionViewLayout.invalidateLayout()
                            self.deviceCollectionView.reloadData()
                            self.containerViewController?.finishLoading()
                        }

                    } else {
                        self.deviceCollectionView.collectionViewLayout.invalidateLayout()
                        self.deviceCollectionView.reloadData()
                        self.containerViewController?.finishLoading()
                    }
                }
            
                return
            }
        
    }
   
    
    @objc func sortFolderList(sortState: NSNotification){
        if let getState = sortState.userInfo?["sortState"] as? String {
            
            print("getState: \(getState)")
            sortBy = getState
            if(mainContentState == .oneViewList) {
                showInsideList(userId: userId, devUuid: selectedDevUuid, foldrId: currentFolderId, deviceName: deviceName)
            } else if mainContentState == .googleDriveList {
                driveFileArray.removeAll()
                if(driveFolderIdArray.count > 1){
                    driveFileArray.append(self.gDriveUpFolder!)
                }
                switch getState {
                case "new":
                    driveArrayFolder.sort(by: { $0.modifiedTime > $1.modifiedTime })
                    driveArrayWithoutUpfolder.sort(by: {$0.modifiedTime > $1.modifiedTime})
                    driveFileArray = driveFileArray + driveArrayFolder + driveArrayWithoutUpfolder
                    deviceCollectionView.reloadData()                    
                    break
                case "old":
                    driveArrayFolder.sort(by: { $0.modifiedTime < $1.modifiedTime })
                    driveArrayWithoutUpfolder.sort(by: {$0.modifiedTime < $1.modifiedTime})
                    driveFileArray = driveFileArray + driveArrayFolder + driveArrayWithoutUpfolder
                      deviceCollectionView.reloadData()
                    break
                case "asc":
                    driveArrayFolder.sort(by: { $0.name < $1.name })
                    driveArrayWithoutUpfolder.sort(by: {$0.name < $1.name})
                    driveFileArray = driveFileArray + driveArrayFolder + driveArrayWithoutUpfolder
                      deviceCollectionView.reloadData()
                    break
                case "desc":
                    driveArrayFolder.sort(by: { $0.name > $1.name })
                    driveArrayWithoutUpfolder.sort(by: {$0.name > $1.name})
                    driveFileArray = driveFileArray + driveArrayFolder + driveArrayWithoutUpfolder
                      deviceCollectionView.reloadData()
                    break
                case "none":
                    driveArrayFolder.sort(by: { $0.name < $1.name })
                    driveArrayWithoutUpfolder.sort(by: {$0.name < $1.name})
                    driveFileArray = driveFileArray + driveArrayFolder + driveArrayWithoutUpfolder
                      deviceCollectionView.reloadData()
                    break
                default:
                    break
                }
                
              
              
            }
        }
    }
    
    @objc func refreshInsideList(folderIdDict:NSNotification){
        
        multiCheckListState = .inActive
        
        if self.selectedDevUuid == Util.getUuid(){
            self.userId = UserDefaults.standard.string(forKey: "userId")!
        }
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
        print("refreshSearchList called")
//        homeViewController?.searchInAllCategory(sortBy: sortBy, searchGubun: "", selectedDevUuid: selectedDevUuid, searchedText: searchedText, foldrWholePathNm: foldrWholePathNm)
        homeViewController?.refershSearchList()
        
    }
    
    
  
    
    func showInsideList(userId: String, devUuid: String, foldrId: String, deviceName:String){
        self.folderArray.removeAll()
        var param = ["userId": userId, "devUuid":devUuid, "foldrId":foldrId,"sortBy":sortBy]
//        print("showInsideParam : \(param)")
        if(folderIdArray.count > 1){
            let upFolder = App.FolderStruct(data: (["foldrNm":"..","foldrId":folderIdArray[folderIdArray.count-2],"userId":userId,"childCnt":0,"devUuid":devUuid,"foldrWholePathNm":"up","cretDate":"cretDate", "checked":false, "devNm":deviceName] as? [String:Any])!)
            self.folderArray.append(upFolder)
            if(folderIdArray.count == 1){
                param = ["userId": userId, "devUuid":devUuid]
            }
        } else { // pc경우
            if foldrId == "0" {
                param = ["userId": userId, "devUuid":devUuid]
            }

        }
//        print("param : \(param)")
        GetListFromServer().showInsideFoldrList(params: param, deviceName:deviceName){ responseObject, error in
            let json = JSON(responseObject as? Any)
            if(json["listData"].exists()){
                let serverList:[AnyObject] = json["listData"].arrayObject! as [AnyObject]
//                print("serverList :\(serverList)")
                for list in serverList{
                    var folder = App.FolderStruct(data: list as AnyObject)
                    folder.devUuid = devUuid
                    folder.devNm = deviceName
                    folder.userId = self.selectedDevUserId
                    folder.osCd = self.selectedDevOsCd
                    folder.userId = self.selectedDevUserId
//                    print("folderUserId: \(folder.userId)")
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
//                let listData = json["listData"]
//                print("getFileList listData : \(listData)")
                let serverList:[AnyObject] = json["listData"].arrayObject! as [AnyObject]
                if serverList.count > 0 {
                    for list in serverList{
                        
                        var folder = App.FolderStruct(data: list as AnyObject)
                        folder.devUuid = devUuid
                        folder.userId = self.selectedDevUserId
                        folder.devNm = self.deviceName
                        folder.osCd = self.selectedDevOsCd
                        folder.userId = self.selectedDevUserId
                        //                    print("list : \(list), folder:\(folder)")
                        self.folderArray.append(folder)
                    }
                    self.cellStyle = 2
                    self.homeViewController?.cellStyle = 2
                    self.homeViewController?.folderArray = self.folderArray
                    self.homeViewController?.currentFolderId = self.currentFolderId
                    self.collectionviewCellSpcing()
                    //                DispatchQueue.main.async {
                    self.deviceCollectionView.collectionViewLayout.invalidateLayout()
                    self.deviceCollectionView.reloadData()
                    self.deviceCollectionView.setContentOffset(CGPoint(x:0,y:0), animated: true)
                    self.containerViewController?.finishLoading()
                    
                    //                }
                } else {
                    self.cellStyle = 2
                    self.homeViewController?.cellStyle = 2
                    self.homeViewController?.folderArray = self.folderArray
                    self.homeViewController?.currentFolderId = self.currentFolderId
                    self.collectionviewCellSpcing()
                    //                DispatchQueue.main.async {
                    self.deviceCollectionView.collectionViewLayout.invalidateLayout()
                    self.deviceCollectionView.reloadData()
                    self.deviceCollectionView.setContentOffset(CGPoint(x:0,y:0), animated: true)
                    self.containerViewController?.finishLoading()
                }
                
            } else {
                self.cellStyle = 2
                self.homeViewController?.cellStyle = 2
                self.homeViewController?.folderArray = self.folderArray
                self.homeViewController?.currentFolderId = self.currentFolderId
                self.collectionviewCellSpcing()
                //                DispatchQueue.main.async {
                self.deviceCollectionView.collectionViewLayout.invalidateLayout()
                self.deviceCollectionView.reloadData()
                self.deviceCollectionView.setContentOffset(CGPoint(x:0,y:0), animated: true)
                self.containerViewController?.finishLoading()
            }
//            print("final folderArray : \(self.folderArray)")
            
            
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
//            if(mainContentState == .googleDriveList){
            if containerViewController?.googleSignInSegueState == .loginForList {
//                print("home device view sign in work")
                accessToken = GIDSignIn.sharedInstance().currentUser.authentication.accessToken
                print("logedIn")
                containerViewController?.getFiles(accessToken: accessToken, root: "root")
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("stPartentContainerView :\(stPartentContainerView), HomeDeviceCollectionVC  will disappear")
        
    }
}

extension FileManager {
    func clearTmpDirectory() {
        do {
            let tmpDirectory = try contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach {[unowned self] file in
                let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
                try self.removeItem(atPath: path)
            }
        } catch {
            print(error)
        }
    }
}
