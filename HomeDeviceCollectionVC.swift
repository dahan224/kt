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
   
let quickLookController = QLPreviewController()
    var loginCookie = ""
    var loginToken = ""
    var userId = ""
    var currentDevUuid = ""
    var fromOsCd = ""
    var folderPathToLabel = ""
    var foldrWholePathNm = ""
    var fileId = ""
    var foldrId = ""
    var fileNm = ""
    var deviceName = ""
    var devUuid = ""
    var test = ""
    var selectedDevUuid = ""
    var selectedDevUserId = ""
    var currentFolderId = ""
    var sortBy = ""
    
    var listViewStyleState = HomeViewController.listViewStyleEnum.grid
    var flickState = HomeViewController.flickEnum.main
    var mainContentState = HomeViewController.mainContentsStyleEnum.oneViewList
    var LatelyUpdatedFileArray:[App.LatelyUpdatedFileStruct] = []
    var driveFileArray:[App.DriveFileStruct] = []
  
    
    struct DeviceStruct:Codable {
        var devNm:String
        var devUuid:String
        var mkngVndrNm:String
        var onoff:String
        var osCd:String
        var osDesc:String
        var osNm:String
        var userId:String
        var userName:String
        
        init(devNm : String, devUuid : String, mkngVndrNm : String, onoff : String, osCd : String, osDesc : String, osNm : String, userId : String, userName : String) {
            self.devNm   = devNm
            self.devUuid   = devUuid
            self.mkngVndrNm   = mkngVndrNm
            self.onoff   = onoff
            self.osCd   = osCd
            self.osDesc   = osDesc
            self.osNm   = osNm
            self.userId   = userId
            self.userName   = userName
        }
        
    }
    
    
    
    @IBOutlet weak var deviceCollectionView: UICollectionView!

    
    var DeviceArray:[App.DeviceStruct] = []
    var folderArray:[App.FolderStruct] = []
    var localFileArray:[App.LocalFiles] = []
    var folderIdArray = [Int]()
    var folderNameArray = [String]()
    var folderStep = 0
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        quickLookController.dataSource = self
        quickLookController.delegate = self
        deviceCollectionView.delegate = self
        deviceCollectionView.dataSource = self
        
    
        deviceCollectionView.register(DeviceListCell.self, forCellWithReuseIdentifier: "HomeDeviceCell3")
        deviceCollectionView.register(FileListCell.self, forCellWithReuseIdentifier: "HomeDeviceCell4")
        deviceCollectionView.register(NasFileListCell.self, forCellWithReuseIdentifier: "NasFileListCell")
        deviceCollectionView.register(NasFolderListCell.self, forCellWithReuseIdentifier: "NasFolderListCell")
        deviceCollectionView.register(LocalFileListCell.self, forCellWithReuseIdentifier: "LocalFileListCell")
        
        let lpgr : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        
        self.deviceCollectionView?.addGestureRecognizer(lpgr)
        
        
        collectionviewCellSpcing()
        
        loginCookie = UserDefaults.standard.string(forKey: "cookie")!
        loginToken = UserDefaults.standard.string(forKey: "token")!
        userId = UserDefaults.standard.string(forKey: "userId")!
        
        currentDevUuid = Util.getUuid()
        
        
        print("deviceList: \(DeviceArray)")
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
                                               selector: #selector(refreshInsideList),
                                               name: NSNotification.Name("refreshInsideList"),
                                               object: nil)
        
        
        print("mainContentsStyleState : \((flickState))")
        print("LatelyUpdatedFileArray: \(LatelyUpdatedFileArray)")
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
        switch listViewStyleState {
        case .grid:
            
            break
        case .list:
            cellWidth = width
            height = 80.0
            minimumSpacing = 10
            if(cellStyle == 2 || flickState == .lately){
                minimumSpacing = 1
            }
            break
        }
        
        
//        print("width : \(width)")
//        print("deviceCollectionViewWidth : \(cellWidth)")
        layout.sectionInset = UIEdgeInsets(top: 5, left: 15, bottom: 0, right: 15)
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
            switch mainContentState {
            case .oneViewList:
                if(cellStyle == 1){
                    let imageString = Util.getDeviceImageString(osNm: DeviceArray[indexPath.row].osNm, onoff: DeviceArray[indexPath.row].onoff)
                    cell1.deviceImage.image = UIImage(named: imageString)
                    cell1.lblMain.text = DeviceArray[indexPath.row].devNm
                    cell1.lblSub.isHidden = true
                    
                    cell3.ivSub.image = UIImage(named: imageString)
                    cell3.lblMain.text = DeviceArray[indexPath.row].devNm
                    
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
                    
                    if(selectedDevUuid != Util.getUuid()){
                        if(folderArray[indexPath.row].fileNm != "nil"){
                            let cell4 = NasFileListCellController(indexPathRow: indexPath.row)
                            cells.append(cell4)
                            cell2.lblMain.text = folderArray[indexPath.row].fileNm
                            let imageString = Util.getFileImageString(fileExtension: folderArray[indexPath.row].etsionNm)
                            cell2.ivMain.image = UIImage(named: imageString)
                            cell2.ivSub.image = UIImage(named: imageString)
                            
                        } else {
                            let cell4 = NasFolderListCellController(indexPathRow: indexPath.row)
                            cells.append(cell4)
                            
                            cell2.lblMain.text = folderArray[indexPath.row].foldrNm
                            cell2.ivMain.image = UIImage(named: "ico_folder")
                            cell2.ivSub.image = UIImage(named: "ico_folder")
                            
                            if(folderArray[indexPath.row].foldrNm == "..."){
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
                        
                    } else {
                        if(folderArray[indexPath.row].fileNm != "nil"){
                            let cell4 = LocalFileListCellController(indexPathRow: indexPath.row)
                            cells.append(cell4)
                            cell2.lblMain.text = folderArray[indexPath.row].fileNm
                            let imageString = Util.getFileImageString(fileExtension: folderArray[indexPath.row].etsionNm)
                            cell2.ivMain.image = UIImage(named: imageString)
                            cell2.ivSub.image = UIImage(named: imageString)
                            
                        } else {
                            let cell4 = NasFolderListCellController(indexPathRow: indexPath.row)
                            cells.append(cell4)
                            
                            cell2.lblMain.text = folderArray[indexPath.row].foldrNm
                            cell2.ivMain.image = UIImage(named: "ico_folder")
                            cell2.ivSub.image = UIImage(named: "ico_folder")
                            
                            if(folderArray[indexPath.row].foldrNm == "..."){
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
                    cell4.btnOption.addTarget(self, action: #selector(btnOptionClicked(sender:)), for: .touchUpInside)
                    cell4.btnOptionRed.tag = indexPath.row
                    cell4.btnOptionRed.addTarget(self, action: #selector(btnOptionClicked(sender:)), for: .touchUpInside)
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
            devUuid = DeviceArray[indexPath.row].devUuid
            fromOsCd = DeviceArray[indexPath.row].osCd
            selectedDevUuid = devUuid
            selectedDevUserId = DeviceArray[indexPath.row].userId
            NotificationCenter.default.post(name: Notification.Name("clickDeviceItem"), object: self, userInfo: indexPathRow)
            
        } else if (cellStyle == 2){
            //            if(contextMenuState == .nas){
            print("2")
            let foldrId = folderArray[indexPath.row].foldrId
            let fileId = folderArray[indexPath.row].fileId
            let folderNm = folderArray[indexPath.row].foldrNm
            fileNm = folderArray[indexPath.row].fileNm
            id = currentDevUuid
            foldrWholePathNm = folderArray[indexPath.row].foldrWholePathNm
            print("foldrWholePathNm: \(foldrWholePathNm)")
            
            if(fileId == 0){
                
                let stringFoldrId = String(foldrId)
                //                print("foldrId : \(stringFoldrId)")
                if(folderArray[indexPath.row].foldrNm == "..."){
                    folderIdArray.remove(at: folderIdArray.count-1)
                    folderNameArray.remove(at: folderNameArray.count-1)
                } else {
                    self.folderIdArray.append(foldrId)
                    self.folderNameArray.append(folderNm)
                }
                var folderNameArrayCount = 0
                if(folderNameArray.count < 1){
                    
                } else {
                    folderNameArrayCount = folderNameArray.count-1
                }
                let folderName = ["folderName":"\(folderNameArray[folderNameArrayCount])","deviceName":deviceName]
                NotificationCenter.default.post(name: Notification.Name("setupFolderPathView"), object: self, userInfo: folderName)
                self.showInsideList(userId: userId, devUuid: currentDevUuid, foldrId: stringFoldrId,deviceName: deviceName)
                searchStepState = .folder
                
                Vc.dataFromContainer(containerData: indexPath.row, getStepState: searchStepState, getStringId:id, getStringFolderPath: foldrWholePathNm)
            } else {
                //                    if(listViewStyleState == .list){
                //
                //                    } else {
                print("selectedFileId : \(folderArray[indexPath.row].fileId)")
                let fileId = "\(folderArray[indexPath.row].fileId)"
                let foldrWholePathNm = "\(folderArray[indexPath.row].foldrWholePathNm)"
                
                let stateDict = ["bottomState":"\(HomeViewController.bottomListEnum.fileInfo)","fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":deviceName, "selectedDevUuid":selectedDevUuid, "fileNm":fileNm, "userId":userId, "foldrId":String(foldrId),"fromOsCd":fromOsCd]
                print(stateDict)
                NotificationCenter.default.post(name: Notification.Name("bottomStateFromContainer"), object: self, userInfo: stateDict)
                //                    }
                
            }
            //            }
        }
        
        collectionviewCellSpcing()
        deviceCollectionView.reloadData()
        
    }
    
    
    
    @objc func btnOptionClicked(sender:UIButton){
//        print("optionSHow")
        
        showOptionMenu(sender: sender, style:0)
    }
    
    @objc func btnOptionFolderClicked(sender:UIButton){
        //        print("optionSHow")
        
        showOptionMenu(sender: sender, style:1)
    }
    @objc func btnOptionLocalClicked(sender:UIButton){
        //        print("optionSHow")
        
        showOptionMenu(sender: sender, style:2)
    }
    func showOptionMenu(sender:UIButton, style:Int){
        
        let buttonRow = sender.tag
        let indexPath = IndexPath(row: buttonRow, section: 0)
        let cell = deviceCollectionView.cellForItem(at: indexPath) as! FileListCell
        if(cell.optionSHowCheck == 0){
            if(style == 0) {
                let width = App.Size.optionWidth
                let spacing = (width - 300) / 6
                cell.spacing = spacing
                cell.optionShow(spacing: spacing, style: style)
            } else if style == 1{
                let width = App.Size.optionWidth
                let spacing = (width - 240) / 5
                cell.optionShow(spacing: spacing, style:style)
            } else {
                let width = App.Size.optionWidth
                let spacing = (width - 180) / 5
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
    
    @objc func btnNasOptionClicked(sender:UIButton){
         showNasFileOption(tag:sender.tag)
    }
    
    @objc func cellSwipeToLeft(sender:UIGestureRecognizer){
        
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
    
 

    @objc func btnLocalFileOptionClicked(sender:UIButton){
        showLocalFileOption(tag:sender.tag)
    }
    
    
    
    //current state
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
        self.localContextMenuCalled(cell: cell, indexPath: indexPath, sender:sender)
    }
    
    func localContextMenuCalled(cell:LocalFileListCell, indexPath:IndexPath, sender:UIButton){
        fileNm = folderArray[indexPath.row].fileNm
        let etsionNm = folderArray[indexPath.row].etsionNm
        let amdDate = folderArray[indexPath.row].amdDate
        foldrWholePathNm = folderArray[indexPath.row].foldrWholePathNm
        fileId = String(folderArray[indexPath.row].fileId)
        var btn = "show"
        switch sender {
        case cell.btnShow:
            btn = "show"
            var fileId:String = ""
            var foldrWholePathNm:String = ""
            if(mainContentState == .oneViewList){
                fileId = "\(folderArray[indexPath.row].fileId)"
                foldrWholePathNm = "\(folderArray[indexPath.row].foldrWholePathNm)"
            }
            print("fileId: \(fileId)")
            let fileIdDict = ["fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":deviceName]
            NotificationCenter.default.post(name: Notification.Name("getFileIdFromBtnShow"), object: self, userInfo: fileIdDict)
            break
        case cell.btnAction:

                let url:URL = FileUtil().getFileUrl(fileNm: fileNm, amdDate: amdDate)
                documentController = UIDocumentInteractionController(url: url)
                documentController.presentOptionsMenu(from: CGRect.zero, in: self.view, animated: true)
                print("btnActino called")
                break
               
        case cell.btnNas:
            
                let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"state":"local","fromUserId":userId, "fromOsCd":fromOsCd]
                print("fileDict : \(fileDict)")
                NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
                showLocalFileOption(tag: sender.tag)
            break
            
        case cell.btnGDrive:
            self.googleSignInCheck(name: fileNm, path: foldrWholePathNm)
            showLocalFileOption(tag: sender.tag)
            break
        case cell.btnDelete:
            let alertController = UIAlertController(title: nil, message: "해당 파일을 삭제 하시겠습니까?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                let pathForRemove:String = FileUtil().getFilePath(fileNm: self.fileNm, amdDate: amdDate)
                self.removeFile(path: pathForRemove)
                SyncLocalFilleToNas().sync()
                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    let alertController = UIAlertController(title: nil, message: "파일 삭제가 완료 되였습니다.", preferredStyle: .alert)
                    let yesAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        
                        self.showInsideList(userId: self.userId, devUuid: self.currentDevUuid, foldrId: self.currentFolderId, deviceName: self.deviceName)
                        
                    }
                    alertController.addAction(yesAction)
                    self.present(alertController, animated: true)
                })
                
            }
            let noAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel)
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            self.present(alertController, animated: true)
            break
        default:
            break
        }
    }
    
    
    
    @objc func optionShowClicked(sender:UIButton){
        let buttonRow = sender.tag
        let indexPath = IndexPath(row: buttonRow, section: 0)
        let cell = deviceCollectionView.cellForItem(at: indexPath) as! FileListCell
//        self.NasFolderContextMenuCalled(cell: cell, indexPath: indexPath, sender:sender)
    }
    
    @objc func optionNasFileShowClicked(sender:UIButton){
        let buttonRow = sender.tag
        let indexPath = IndexPath(row: buttonRow, section: 0)
        let cell = deviceCollectionView.cellForItem(at: indexPath) as! NasFileListCell
        self.nasContextMenuCalled(cell: cell, indexPath: indexPath, sender:sender)
    }
    
    @objc func btnMultiCheckClicked(sender:UIButton){
        let buttonRow = sender.tag
        let indexPath = IndexPath(row: buttonRow, section: 0)
        let cell = deviceCollectionView.cellForItem(at: indexPath) as! FileListCell
        if(cell.btnMultiChecked){
            cell.btnMultiChecked = false
            cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_off").withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            cell.btnMultiChecked = true
            cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on").withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        
    }
    
    func getFolderIdsToDownload(foldrId:Int, foldrWholePathNm:String) {
        print("get folders")
        folderIdsToDownLoad.append(foldrId)
        folderPathToDownLoad.append(foldrWholePathNm)
        
        var param = ["userId": userId, "devUuid":devUuid, "foldrId":String(foldrId),"sortBy":sortBy]
        print("param : \(param)")
        GetListFromServer().showInsideFoldrList(params: param, deviceName:deviceName) { responseObject, error in
            let json = JSON(responseObject!)
            if(json["listData"].exists()){
                let serverList:[AnyObject] = json["listData"].arrayObject as! [AnyObject]
                print("serverList :\(serverList)")
                if (serverList.count > 0){
                    for list in serverList{
                        let folder = App.FolderStruct(data: list as AnyObject)
                        
                        if (self.folderIdsToDownLoad.contains(folder.foldrId)){
                            return
                        } else {
                            print("folder : \(folder.foldrId)")
                            self.folderIdsToDownLoad.append(folder.foldrId)
                            self.folderPathToDownLoad.append(folder.foldrWholePathNm)
                            let foldrLevel = list["foldrLevel"] as? Int ?? 0
                            if(foldrLevel > 0){
                                self.getFolderIdsToDownload(foldrId: folder.foldrId, foldrWholePathNm: folder.foldrWholePathNm)
                                return
                            }
                        }
                    }
                }
                self.printFolderPath()
            }
        }
      
    }
    
    func printFolderPath(){
        print("folderPathToDownLoad: \(folderPathToDownLoad)")
        for name in folderPathToDownLoad {
            let fullNameArr = name.components(separatedBy: "/")
            var folderName = ""
                for (index, name) in fullNameArr.enumerated() {
                    print("name : \(name), index : \(index)")
                    if(1 < index && index < fullNameArr.count ){
                        folderName += "/\(fullNameArr[index])"
                    }
                }
            print("folderName : \(folderName)")
            let createdPath:URL = self.createLocalFolder(folderName: folderName)!
            }

        
    }
  
    func createLocalFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = documentDirectory.appendingPathComponent(folderName)
            if !fileManager.fileExists(atPath: filePath.path) {
                do {
                    try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error.localizedDescription)
                    
                    return nil
                }
            }
            
            return filePath
        } else {
            return nil
        }
    }
    
    func NasFolderContextMenuCalled(cell:NasFolderListCell, indexPath:IndexPath, sender:UIButton){
        let foldrNm = folderArray[indexPath.row].foldrNm
        let etsionNm = folderArray[indexPath.row].etsionNm
        let amdDate = folderArray[indexPath.row].amdDate
        foldrWholePathNm = folderArray[indexPath.row].foldrWholePathNm
        fileId = String(folderArray[indexPath.row].fileId)
        let foldrId = folderArray[indexPath.row].foldrId
        switch sender {
        case cell.btnDwnld:
            folderIdsToDownLoad.removeAll()
            folderPathToDownLoad.removeAll()
            getFolderFinish = false
            
            getFolderIdsToDownload(foldrId: foldrId, foldrWholePathNm: foldrWholePathNm)
            
            
           
            
            
            
            
            break
        case cell.btnNas:
            print(deviceName)
            switch(flickState){
            case .main :
                switch mainContentState {
                case .oneViewList:
                    let fileDict = ["fileId":fileId, "fileNm":fileNm,"amdDate":amdDate, "oldFoldrWholePathNm":foldrWholePathNm,"state":"local","fromUserId":userId]
                    print("fileDict : \(fileDict)")
                    NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
                    showOptionMenu(sender: sender, style: 0)
                    
                case .googleDriveList:
                    break
                }
                break
            case .lately:
                break
            }
            break
            
        case cell.btnGDrive:
            
            self.googleSignInCheck(name: fileNm, path: foldrWholePathNm)
            showOptionMenu(sender: sender, style: 0)
            break
        case cell.btnDelete:
            let alertController = UIAlertController(title: nil, message: "해당 파일을 삭제 하시겠습니까?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                let pathForRemove:String = FileUtil().getFilePath(fileNm: self.fileNm, amdDate: amdDate)
                self.removeFile(path: pathForRemove)
                SyncLocalFilleToNas().sync()
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: nil, message: "파일 삭제가 완료 되였습니다.", preferredStyle: .alert)
                    let noAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel, handler:nil)
                    //                        self.deviceCollectionView.reloadData()
                    alertController.addAction(noAction)
                    self.present(alertController, animated: true)
                }
                
            }
            let noAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel)
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            self.present(alertController, animated: true)
            break
        default:
            break
        }
    }
    
    
  
    
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
    
    func nasContextMenuCalled(cell:NasFileListCell, indexPath:IndexPath, sender:UIButton){
        fileNm = folderArray[indexPath.row].fileNm
        let etsionNm = folderArray[indexPath.row].etsionNm
        foldrWholePathNm = folderArray[indexPath.row].foldrWholePathNm
        fileId = String(folderArray[indexPath.row].fileId)
        foldrId = String(folderArray[indexPath.row].foldrId)
        
        var btn = "show"
        switch sender {
        case cell.btnShow:
            btn = "show"
            var fileId:String = ""
            var foldrWholePathNm:String = ""
            if(mainContentState == .oneViewList){
                fileId = "\(folderArray[indexPath.row].fileId)"
                foldrWholePathNm = "\(folderArray[indexPath.row].foldrWholePathNm)"
            } else {
                fileId = "\(LatelyUpdatedFileArray[indexPath.row].fileId)"
                foldrWholePathNm = "\(LatelyUpdatedFileArray[indexPath.row].foldrWholePathNm)"
            }
            //            print("fileId: \(fileId)")
            let fileIdDict = ["fileId":fileId,"foldrWholePathNm":foldrWholePathNm,"deviceName":deviceName]
            NotificationCenter.default.post(name: Notification.Name("getFileIdFromBtnShow"), object: self, userInfo: fileIdDict)
            
            break
        case cell.btnDwnld:
            btn = "btnDwnld"
            switch(flickState){
            case .main :
                switch mainContentState{
                case .oneViewList:
                    //            print("fileNm : \(fileNm), filePaht : \(foldrWholePathNm)")
                    self.downloadFromNas(name: fileNm, path: foldrWholePathNm, fileId:fileId)
                    break
                case .googleDriveList:
                    let fileId = driveFileArray[indexPath.row].fileId
                    let mimeType = driveFileArray[indexPath.row].mimeType
                    let name = driveFileArray[indexPath.row].name
                    downloadFromDrive(fileId: fileId, mimeType:mimeType, name:name)
                    break
                }
                break
            case .lately:
                
                break
                
            }
            
            
            
        case cell.btnNas:
            print(deviceName)
            switch(flickState){
            case .main :
                switch mainContentState {
                case .oneViewList:
                    switch fromOsCd {
                    case "S":
                        fileId = "\(folderArray[indexPath.row].fileId)"
                        let fileDict = ["fileId":fileId, "fileNm":fileNm, "oldFoldrWholePathNm":foldrWholePathNm,"state":"nas","fromUserId":userId, "fromOsCd":fromOsCd]
                        NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
                        showNasFileOption(tag: sender.tag)
                        break
                    case "G":
                        fileId = "\(folderArray[indexPath.row].fileId)"
                        let fileDict = ["fileId":fileId, "fileNm":fileNm, "oldFoldrWholePathNm":foldrWholePathNm,"state":"nas","fromUserId":userId, "fromOsCd":fromOsCd]
                        NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
                        showNasFileOption(tag: sender.tag)
                        break
                    default:
                        fileId = "\(folderArray[indexPath.row].fileId)"
                        let fileDict = ["fileId":fileId, "fileNm":fileNm, "oldFoldrWholePathNm":foldrWholePathNm,"state":"local","fromUserId":userId, "fromOsCd":fromOsCd]
                        NotificationCenter.default.post(name: Notification.Name("nasFolderSelectSegue"), object: self, userInfo: fileDict)
                        showNasFileOption(tag: sender.tag)
                        break
                    }
                case .googleDriveList:
                    break
                }
                break
            case .lately:
                break
            }
            break
            
        case cell.btnGDrive:
            self.googleSignInCheck(name: fileNm, path: foldrWholePathNm)
            showNasFileOption(tag: sender.tag)
            
            break
        case cell.btnDelete:
            let alertController = UIAlertController(title: nil, message: "해당 파일을 삭제 하시겠습니까?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                //Do you Success button Stuff here
                let params = ["userId":self.userId,"devUuid":self.devUuid,"fileId":self.fileId,"fileNm":self.fileNm,"foldrWholePathNm":self.foldrWholePathNm]
                self.deleteNasFile(param: params, foldrId:self.foldrId)
            }
            let noAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel)
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            self.present(alertController, animated: true)
            break
        default:
            break
        }
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
    
    
 
    func googleSignInCheck(name:String, path:String){
        if GIDSignIn.sharedInstance().hasAuthInKeychain() == true {
            GIDSignIn.sharedInstance().signInSilently()
            print("sign in silently")
            let fileDict = ["fileId":fileId, "fileNm":fileNm, "oldFoldrWholePathNm":foldrWholePathNm,"state":"googleDrive", "fromUserId":userId,"fromOsCd":fromOsCd]
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
//                        self.sendToNasFromLocal(fileURL: response.destinationURL!, name:name)
                    }
                }
        
    }
    
  
    
    
    func downloadFromNas(name:String, path:String, fileId:String){
        ContextMenuWork().downloadFromNas(userId:userId, fileNm:name, path:path, fileId:fileId){ responseObject, error in
            if let success = responseObject {
                print(success)
                if(success == "success"){
                    SyncLocalFilleToNas().sync()
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: nil, message: "파일 다운로드를 성공하였습니다.", preferredStyle: .alert)
                        let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel)
                        alertController.addAction(yesAction)
                        self.present(alertController, animated: true)
                    }
                    
                    
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
                    
                    let url:URL = FileUtil().getFileUrl(fileNm: name, amdDate: amdDate)
                    self.documentController = UIDocumentInteractionController(url: url)
                    self.documentController.presentOptionsMenu(from: CGRect.zero, in: self.view, animated: true)
                    
                }
                
            }
            return
        }
    }
    
   
    func deleteNasFile(param:[String:Any], foldrId:String){
        print(param)
        ContextMenuWork().deleteNasFile(parameters:param){ responseObject, error in
            if let obj = responseObject {
                print(obj)
                let json = JSON(obj)
                let message = obj.object(forKey: "message")
                print("\(message), \(json["statusCode"].int)")
                if let statusCode = json["statusCode"].int, statusCode == 100 {
                    DispatchQueue.main.async {
                        self.showInsideList(userId: param["userId"] as! String, devUuid: param["devUuid"] as! String, foldrId: foldrId, deviceName:self.deviceName)
                        let alertController = UIAlertController(title: nil, message: "파일 삭제가 완료 되었습니다.", preferredStyle: .alert)
                        let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel)
                        
                        alertController.addAction(yesAction)
                        self.present(alertController, animated: true)
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

    
    @objc func clickDeviceItem(stringIndexPathRow: NSNotification){
        
        if let stringIndexPathRow = stringIndexPathRow.userInfo?["indexPathRow"] as? String {
            if let indexPathRow = Int(stringIndexPathRow) {
                if(indexPathRow == DeviceArray.count-1){
                    print("google drive clicked")
                    let fileDict = ["state":"loginForList"]
                    NotificationCenter.default.post(name: Notification.Name("googleSignInSegue"), object: self, userInfo: fileDict)
                } else {
                    
                    currentDevUuid = DeviceArray[indexPathRow].devUuid
                    if(currentDevUuid == Util.getUuid()){
                        contextMenuState = .local
                        print("contextMenuState local")
                    } else {
                        contextMenuState = .nas
                        print("contextMenuState nas")
                    }
                    userId = DeviceArray[indexPathRow].userId
                    deviceName = DeviceArray[indexPathRow].devNm
                    print("userId:\(userId)")
                    getRootFolder(userId:userId, devUuid: currentDevUuid, deviceName:deviceName)
                    let folderName = ["folderName":"\(DeviceArray[indexPathRow].devNm)","deviceName":deviceName]
                    NotificationCenter.default.post(name: Notification.Name("setupFolderPathView"), object: self, userInfo: folderName)
                    searchStepState = .device
                    id = currentDevUuid
                    foldrWholePathNm = ""
                    Vc.dataFromContainer(containerData: indexPathRow, getStepState: searchStepState, getStringId:id, getStringFolderPath: foldrWholePathNm)
                    
                }
                
            }
        }
    }

    
   
    func getRootFolder(userId: String, devUuid: String, deviceName:String){
        self.folderIdArray.removeAll()
        self.folderNameArray.removeAll()
        self.localFileArray.removeAll()
         GetListFromServer().getFoldrList(devUuid: devUuid, userId:userId, deviceName:deviceName){ responseObject, error in
                if let obj = responseObject{
                    let json = JSON(obj)
                    if(json["listData"].exists()){
                        let serverList:[AnyObject] = json["listData"].arrayObject! as [AnyObject]
                        print("nasfolderList :\(serverList)")
                        for rootFolder in serverList{
                            let foldrId = rootFolder["foldrId"] as? Int ?? 0
                            let stringFoldrId = String(foldrId)
                            let froldrNm = rootFolder["foldrNm"] as? String ?? "nil"
                            let stringFroldrNm = String(froldrNm)
                            self.folderIdArray.append(foldrId)
                            self.folderNameArray.append(stringFroldrNm)
                            self.showInsideList(userId: userId, devUuid: devUuid, foldrId: stringFoldrId, deviceName:deviceName)
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
            showInsideList(userId: userId, devUuid: currentDevUuid, foldrId: currentFolderId, deviceName: deviceName)
            
        }
    }
    
    @objc func refreshInsideList(){
        let params = ["userId":self.userId,"devUuid":self.devUuid,"foldrId":self.foldrId,"fileNm":self.fileNm,"foldrWholePathNm":self.foldrWholePathNm]
        print("refreshParam : \(params)")
        self.showInsideList(userId: self.userId, devUuid: self.devUuid, foldrId: foldrId, deviceName:self.deviceName)
        
    }
    
    
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
                print("serverList :\(serverList)")
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
        var param:[String : Any] = ["userId": userId, "devUuid":devUuid, "foldrId":foldrId,"page":1,"sortBy":sortBy]
      
        let urlString = App.URL.server+"listFile.json"
        let headers = [
            "Content-Type": "application/json",
            "X-Auth-Token": self.loginToken,
            "Cookie": self.loginCookie
        ]
        Alamofire.request(urlString,
                          method: .post,
                          parameters: param,
                          encoding : JSONEncoding.default,
                          headers: headers).responseJSON{ (response) in
                            switch response.result {
                            case .success(let value):
                                let json = JSON(value)
                                let responseData = value as! NSDictionary
                                let message = responseData.object(forKey: "message")
                                //                                print("showFolderInfo json : \(json)")
                                if(json["listData"].exists()){
                                    var listData = json["listData"]
                                    //                                    print("showFolderInfoData : \(listData)")
                                    var serverList:[AnyObject] = json["listData"].arrayObject as! [AnyObject]
                                    for list in serverList{
                                        var folder = App.FolderStruct(data: list as AnyObject)
                                        self.folderArray.append(folder)
                                        
                                    }
                                    
                                }
                                break
                            case .failure(let error):
                                NSLog(error.localizedDescription)
                                break
                            default:
                                print(response)
                                break
                            }
                            
                            print("final folderArray : \(self.folderArray)")
                            self.cellStyle = 2
                            self.collectionviewCellSpcing()
                            self.deviceCollectionView.reloadData()
                            self.deviceCollectionView.collectionViewLayout.invalidateLayout()
                            
        }
    }

    
    
    
    func fileListCellController(indexPathRow:Int) -> FileListCell {
        let indexPath = IndexPath(row: indexPathRow, section: 0)
        let cell = deviceCollectionView.dequeueReusableCell(withReuseIdentifier: "HomeDeviceCell4", for: indexPath) as! FileListCell
        
        if (multiCheckListState == .active){
            cell.btnMultiCheck.isHidden = false
            cell.btnMultiCheck.tag = indexPath.row
            cell.btnMultiCheck.addTarget(self, action: #selector(btnMultiCheckClicked(sender:)), for: .touchUpInside)
            cell.btnOption.isHidden = true
            
        } else {
            cell.btnOption.isHidden = false
            cell.btnMultiCheck.isHidden = true
        }
        if(contextMenuState == .local)  {
            
            let imageString = Util.getFileImageString(fileExtension: folderArray[indexPath.row].etsionNm)
            cell.optionSHowCheck = 0
            cell.optionHide()
            cell.ivSub.image = UIImage(named: imageString)
            cell.lblMain.text = folderArray[indexPath.row].fileNm
            cell.lblSub.text = folderArray[indexPath.row].amdDate
            cell.btnOption.tag = indexPath.row
            cell.btnOption.addTarget(self, action: #selector(btnOptionLocalClicked(sender:)), for: .touchUpInside)
            cell.btnOptionRed.tag = indexPath.row
            cell.btnOptionRed.addTarget(self, action: #selector(btnOptionLocalClicked(sender:)), for: .touchUpInside)
            
            
            
            
        } else {
            let imageString = Util.getFileImageString(fileExtension: folderArray[indexPath.row].etsionNm)
            
            if(folderArray[indexPath.row].fileNm != "nil"){
                cell.ivSub.image = UIImage(named: imageString)
                cell.optionSHowCheck = 0
                cell.optionHide()
                cell.lblMain.text = folderArray[indexPath.row].fileNm
                cell.lblSub.text = folderArray[indexPath.row].amdDate
                let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(cellSwipeToLeft(sender:)))
                swipeLeft.direction = UISwipeGestureRecognizerDirection.left
                cell.btnOption.addGestureRecognizer(swipeLeft)
                cell.btnOption.tag = indexPath.row
                cell.btnOption.addTarget(self, action: #selector(btnOptionClicked(sender:)), for: .touchUpInside)
                
                let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(cellSwipeToLeft(sender:)))
                rightSwipe.direction = UISwipeGestureRecognizerDirection.right
                cell.btnOptionRed.addGestureRecognizer(rightSwipe)
                cell.btnOptionRed.tag = indexPath.row
                cell.btnOptionRed.addTarget(self, action: #selector(btnOptionClicked(sender:)), for: .touchUpInside)
                
                
                
            } else {
                cell.optionSHowCheck = 0
                cell.optionHide()
                cell.ivSub.image = UIImage(named: "ico_folder")
                cell.lblMain.text = folderArray[indexPath.row].foldrNm
                cell.lblSub.text = folderArray[indexPath.row].amdDate
                cell.btnOption.tag = indexPath.row
                cell.btnOption.addTarget(self, action: #selector(btnOptionFolderClicked(sender:)), for: .touchUpInside)
                cell.btnOptionRed.tag = indexPath.row
                cell.btnOptionRed.addTarget(self, action: #selector(btnOptionFolderClicked(sender:)), for: .touchUpInside)
                
                
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
    
    
    func NasFileListCellController(indexPathRow:Int) -> NasFileListCell {
        let indexPath = IndexPath(row: indexPathRow, section: 0)
        let cell = deviceCollectionView.dequeueReusableCell(withReuseIdentifier: "NasFileListCell", for: indexPath) as! NasFileListCell
        
        if (multiCheckListState == .active){
            cell.btnMultiCheck.isHidden = false
            cell.btnMultiCheck.tag = indexPath.row
            cell.btnMultiCheck.addTarget(self, action: #selector(btnMultiCheckClicked(sender:)), for: .touchUpInside)
            cell.btnOption.isHidden = true
            
        } else {
            cell.btnOption.isHidden = false
            cell.btnMultiCheck.isHidden = true
        }
        if(folderArray[indexPath.row].foldrNm == "..."){
            cell.btnOption.isHidden = true
        }
        let imageString = Util.getFileImageString(fileExtension: folderArray[indexPath.row].etsionNm)
        
        cell.ivSub.image = UIImage(named: imageString)
        cell.optionSHowCheck = 0
        cell.optionHide()
        cell.lblMain.text = folderArray[indexPath.row].fileNm
        cell.lblSub.text = folderArray[indexPath.row].amdDate
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(cellSwipeToLeft(sender:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        cell.btnOption.addGestureRecognizer(swipeLeft)
        cell.btnOption.tag = indexPath.row
        cell.btnOption.addTarget(self, action: #selector(btnNasOptionClicked(sender:)), for: .touchUpInside)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(cellSwipeToLeft(sender:)))
        rightSwipe.direction = UISwipeGestureRecognizerDirection.right
        cell.btnOptionRed.addGestureRecognizer(rightSwipe)
        cell.btnOptionRed.tag = indexPath.row
        cell.btnOptionRed.addTarget(self, action: #selector(btnNasOptionClicked(sender:)), for: .touchUpInside)
        
        
        cell.btnOption.isHidden = false
        cell.btnShow.tag = indexPath.row
        cell.btnShow.addTarget(self, action: #selector(optionNasFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnAction.tag = indexPath.row
        cell.btnAction.addTarget(self, action: #selector(optionNasFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnDwnld.tag = indexPath.row
        cell.btnDwnld.addTarget(self, action: #selector(optionNasFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnNas.tag = indexPath.row
        cell.btnNas.addTarget(self, action: #selector(optionNasFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnGDrive.tag = indexPath.row
        cell.btnGDrive.addTarget(self, action: #selector(optionNasFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(optionNasFileShowClicked(sender:)), for: .touchUpInside)
        return cell
    }
    
    
    func NasFolderListCellController(indexPathRow:Int) -> NasFolderListCell {
        let indexPath = IndexPath(row: indexPathRow, section: 0)
        let cell = deviceCollectionView.dequeueReusableCell(withReuseIdentifier: "NasFolderListCell", for: indexPath) as! NasFolderListCell
        
        if (multiCheckListState == .active){
            cell.btnMultiCheck.isHidden = false
            cell.btnMultiCheck.tag = indexPath.row
            cell.btnMultiCheck.addTarget(self, action: #selector(btnMultiCheckClicked(sender:)), for: .touchUpInside)
            cell.btnOption.isHidden = true
            
        } else {
            cell.btnOption.isHidden = false
            cell.btnMultiCheck.isHidden = true
        }
        if(folderArray[indexPath.row].foldrNm == "..."){
            cell.btnOption.isHidden = true
        }
        
        cell.ivSub.image = UIImage(named: "ico_folder")
        cell.optionSHowCheck = 0
        cell.optionHide()
        cell.lblMain.text = folderArray[indexPath.row].foldrNm
        cell.lblSub.text = folderArray[indexPath.row].amdDate
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(cellFolderSwipeToLeft(sender:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        cell.btnOption.addGestureRecognizer(swipeLeft)
        cell.btnOption.tag = indexPath.row
        cell.btnOption.addTarget(self, action: #selector(btnNasFolderOptionClicked(sender:)), for: .touchUpInside)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(cellFolderSwipeToLeft(sender:)))
        rightSwipe.direction = UISwipeGestureRecognizerDirection.right
        cell.btnOptionRed.addGestureRecognizer(rightSwipe)
        cell.btnOptionRed.tag = indexPath.row
        cell.btnOptionRed.addTarget(self, action: #selector(btnNasFolderOptionClicked(sender:)), for: .touchUpInside)
        
        
        cell.btnOption.isHidden = false
        cell.btnShow.tag = indexPath.row
        cell.btnShow.addTarget(self, action: #selector(optionNasFolderShowClicked(sender:)), for: .touchUpInside)
        cell.btnDwnld.tag = indexPath.row
        cell.btnDwnld.addTarget(self, action: #selector(optionNasFolderShowClicked(sender:)), for: .touchUpInside)
        cell.btnNas.tag = indexPath.row
        cell.btnNas.addTarget(self, action: #selector(optionNasFolderShowClicked(sender:)), for: .touchUpInside)
        cell.btnGDrive.tag = indexPath.row
        cell.btnGDrive.addTarget(self, action: #selector(optionNasFolderShowClicked(sender:)), for: .touchUpInside)
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(optionNasFolderShowClicked(sender:)), for: .touchUpInside)
        return cell
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
        self.NasFolderContextMenuCalled(cell: cell, indexPath: indexPath, sender:sender)
    }
    
    func LocalFileListCellController(indexPathRow:Int) -> LocalFileListCell {
        let indexPath = IndexPath(row: indexPathRow, section: 0)
        let cell = deviceCollectionView.dequeueReusableCell(withReuseIdentifier: "LocalFileListCell", for: indexPath) as! LocalFileListCell
        
        if (multiCheckListState == .active){
            cell.btnMultiCheck.isHidden = false
            cell.btnMultiCheck.tag = indexPath.row
            cell.btnMultiCheck.addTarget(self, action: #selector(btnMultiCheckClicked(sender:)), for: .touchUpInside)
            cell.btnOption.isHidden = true
            
        } else {
            cell.btnOption.isHidden = false
            cell.btnMultiCheck.isHidden = true
        }
        if(folderArray[indexPath.row].foldrNm == "..."){
            cell.btnOption.isHidden = true
        }
        
        let imageString = Util.getFileImageString(fileExtension: folderArray[indexPath.row].etsionNm)
        cell.ivSub.image = UIImage(named: imageString)
        cell.optionSHowCheck = 0
        cell.optionHide()
        cell.lblMain.text = folderArray[indexPath.row].fileNm
        cell.lblSub.text = folderArray[indexPath.row].amdDate
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(cellLocalFileSwipeToLeft(sender:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        cell.btnOption.addGestureRecognizer(swipeLeft)
        cell.btnOption.tag = indexPath.row
        cell.btnOption.addTarget(self, action: #selector(btnLocalFileOptionClicked(sender:)), for: .touchUpInside)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(cellLocalFileSwipeToLeft(sender:)))
        rightSwipe.direction = UISwipeGestureRecognizerDirection.right
        cell.btnOptionRed.addGestureRecognizer(rightSwipe)
        cell.btnOptionRed.tag = indexPath.row
        cell.btnOptionRed.addTarget(self, action: #selector(btnLocalFileOptionClicked(sender:)), for: .touchUpInside)
        
        
        cell.btnOption.isHidden = false
        cell.btnShow.tag = indexPath.row
        cell.btnShow.addTarget(self, action: #selector(optionLocalFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnAction.tag = indexPath.row
        cell.btnAction.addTarget(self, action: #selector(optionLocalFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnNas.tag = indexPath.row
        cell.btnNas.addTarget(self, action: #selector(optionLocalFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnGDrive.tag = indexPath.row
        cell.btnGDrive.addTarget(self, action: #selector(optionLocalFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(optionLocalFileShowClicked(sender:)), for: .touchUpInside)
        return cell
    }
    
}
