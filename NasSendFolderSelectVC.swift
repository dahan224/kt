//
//  NasSendFolderSelectVC.swift
//  KT
//
//  Created by 이다한 on 2018. 3. 5..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import GoogleSignIn

class NasSendFolderSelectVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIDocumentInteractionControllerDelegate {
    let g = DispatchGroup()
    let q1 = DispatchQueue(label: "queue1")
    let q2 = DispatchQueue(label: "queue2")
    var containerViewController:ContainerViewController?
    var contextMenuWork:ContextMenuWork?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var indicatorAnimating = false
    var jsonHeader:[String:String] = [
        "Content-Type": "application/json",
        "X-Auth-Token": UserDefaults.standard.string(forKey: "token")!,
        "Cookie": UserDefaults.standard.string(forKey: "cookie")!
    ]
    
    var nasArray:[String] = []
    var nasDevIdArray:[String] = []
    var nasUserIdArray:[String] = []
    var deviceImageArray =  ["ico_device_giganas_on", "ico_device_giganas_share_on", "ico_device_giganas_share_on"]
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var customView: UIView!
    
    var fileId = ""
    
    var foldrWholePathNm = ""
    var oldFoldrWholePathNm = ""
    var newFoldrId = ""
    var newFoldrWholePathNm = ""
    var folderChecked = 0
    var originalFileId = ""
    var originalFileName = ""
    var foldrId = ""
    var fileNm = ""
    var DeviceArray:[App.DeviceStruct] = []
    var deviceName = ""
    var folderIdArray = [Int]()
    var folderNameArray = [String]()
    var folderPathArray = [String]()
    var folderArray:[App.FolderStruct] = []
    var currentFolderId = ""
    var sortBy = ""
    var loginUserId = UserDefaults.standard.string(forKey: "userId")
    var toUserId = ""
    var fromUserId = ""
    var currentDevUuId = ""
    var fromOsCd = ""
    var toOsCd = ""
    var googleDriveFileIdPath = ""
    var googleDriveWholeFoldrNmPath = ""
    var amdDate = ""
    var fromDevUuid = ""
    var fromFoldr = ""
    var fromFoldrId = ""
    var mimeType = ""
    var etsionNm = ""
    enum toStorageKind:String {
        case nas = "nas"
        case nas_multi = "nas_multi"
        case remote_nas_multi = "remote_nas_multi"
        case local_nas_multi = "local_nas_multi"
        case local_gdrive_multi = "local_gdrive_multi"
        case multi_nas_multi = "multi_nas_multi"
        case gdrive_nas_multi = "gdrive_nas_multi"
        case nas_gdrive_multi = "nas_gdrive_multi"
        case googleDrive = "googleDrive"
        case search_nas_multi = "search_nas_multi"
        
    }
    
    var storageState = toStorageKind.nas
    
    enum listEnum {
        case deviceSelect
        case deviceRoot
        case folder
    }
    var listState = listEnum.deviceSelect
    
    var foldrSelectStep = 0
    var nasDevId:String = ""
    var storageDevId:String = ""
    var driveFileArray:[App.DriveFileStruct] = []
    var accessToken:String = ""
    var multiCheckedfolderArray:[App.FolderStruct] = []
    var gDriveMultiCheckedfolderArray:[App.DriveFileStruct] = []
    var remoteMultiFileDownloadedCount = 0
    var driveFolderIdArray:[String] = ["root"] // 0eun
    var driveFolderNameArray:[String] = ["root"] // 0eun
    var checkedButtonRow = 0
    let halfBlackView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        //        view.alpha = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view;
    }()
    
    var tapGesture:UITapGestureRecognizer = UITapGestureRecognizer()
    var request: Alamofire.Request?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("fromDevUuid : \(fromDevUuid), fromFoldrId: \(fromFoldrId), oldFoldrWholePathNm : \(oldFoldrWholePathNm), originalFileId : \(originalFileId), storageState : \(storageState), gDriveMultiCheckedfolderArray : \(gDriveMultiCheckedfolderArray.count)")
        
        contextMenuWork = ContextMenuWork()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(callSendToNasFromLocal(fileDict:)),
                                               name: NSNotification.Name("callSendToNasFromLocal"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(NasSendFolderSelectVCToggleIndicator),
                                               name: NSNotification.Name("NasSendFolderSelectVCToggleIndicator"),
                                               object: nil)
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(downloadFromRemoteToNas(fileDict:)),
                                               name: NSNotification.Name("downloadFromRemoteToNas"),
                                               object: nil)
        
        remoteMultiFileDownloadedCount = multiCheckedfolderArray.count
        switch storageState {
        case .googleDrive:
            nasArray = ["내 드라이브"]
            if let googleEmail = UserDefaults.standard.string(forKey: "googleEmail"){
                tableView.isHidden = true
                activityIndicator.startAnimating()
//                accessToken = DbHelper().getAccessToken(email: googleEmail)
                accessToken = UserDefaults.standard.string(forKey: "googleAccessToken")!
//                let getTokenTime = DbHelper().getTokenTime(email: googleEmail)
                //accessToken = GIDSignIn.sharedInstance().currentUser.authentication.accessToken
                self.getFilesFromGoogleDrive(accessToken: accessToken, root: "root", parent: "root")
            }
            
            break
        case .local_gdrive_multi:
            nasArray = ["내 드라이브"]
            if let googleEmail = UserDefaults.standard.string(forKey: "googleEmail"){
                tableView.isHidden = true
                activityIndicator.startAnimating()
                accessToken = UserDefaults.standard.string(forKey: "googleAccessToken")!
//                let getTokenTime = DbHelper().getTokenTime(email: googleEmail)
                self.getFilesFromGoogleDrive(accessToken: accessToken, root: "root", parent: "root")
            }
            
            break
            
        case .nas_gdrive_multi :
            nasArray = ["내 드라이브"]
//            if let googleEmail = UserDefaults.standard.string(forKey: "googleEmail"){
                tableView.isHidden = true
                activityIndicator.startAnimating()
                accessToken = UserDefaults.standard.string(forKey: "googleAccessToken")!
                self.getFilesFromGoogleDrive(accessToken: accessToken, root: "root", parent: "root")
//            }
            break
        default:
            let DeviceArray:[App.DeviceStruct] = DbHelper().listSqlite(sortBy: .none)
            for device in DeviceArray {
                if(device.osCd == "S" || device.osCd == "G"){
                    nasDevIdArray.append(device.devUuid)
                    nasUserIdArray.append(device.userId)
                    nasArray.append(device.devNm)
                }
            }
            break
        }
        
        
        //        print("originalFileId : \(originalFileId), oldFoldrWholePathNm: \(oldFoldrWholePathNm)")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        tableView.register(SendFolderSelectCell.self, forCellReuseIdentifier: "SendFolderSelectCell")
        tableView.reloadData()
        tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = nasArray.count
        
        if(storageState == .googleDrive || storageState == .local_gdrive_multi || storageState == .nas_gdrive_multi){
            switch listState {
            case .deviceSelect:
                count = nasArray.count
                break
            case .deviceRoot:
                count = driveFileArray.count
                break
            case .folder:
                count = folderArray.count
                break
            }
        } else {
            switch listState {
            case .deviceSelect:
                count = nasArray.count
                break
            case .deviceRoot:
                count = folderNameArray.count
                break
            case .folder:
                count = folderArray.count
                break
            }
        }
        
        
        return count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SendFolderSelectCell") as! SendFolderSelectCell
        switch storageState {
            
        case .googleDrive:
            switch listState {
            case .deviceSelect:
                var imageString = "ico_device_giganas_share_on"
                if indexPath.row == 0 {
                    imageString = "ico_device_giganas_on"
                }
                cell.ivIcon.image = UIImage(named: imageString)
                cell.lblMain.text = nasArray[indexPath.row]
                cell.checkButton.isHidden = false
                cell.checkButton.tag = indexPath.row
                cell.checkButton.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                cell.checkButton.addTarget(self, action: #selector(btnChekced(sender:)), for: .touchUpInside)
                break
            case .deviceRoot:
                
                cell.ivIcon.image = UIImage(named: "ico_folder")
                cell.lblMain.text = driveFileArray[indexPath.row].name
                cell.checkButton.isHidden = false
                if(indexPath.row == 0){
                    cell.checkButton.isHidden = true
                } else {
                    cell.checkButton.isHidden = false
                }
                cell.checkButton.tag = indexPath.row
                cell.checkButton.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                cell.checkButton.addTarget(self, action: #selector(btnChekced(sender:)), for: .touchUpInside)
                break
            case .folder:
                cell.ivIcon.image = UIImage(named: "ico_folder")
                cell.lblMain.text = folderArray[indexPath.row].foldrNm
                if(indexPath.row == 0){
                    cell.checkButton.isHidden = true
                } else {
                    cell.checkButton.isHidden = false
                }
                cell.checkButton.tag = indexPath.row
                cell.btnChecked = 0
                cell.checkButton.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                cell.checkButton.addTarget(self, action: #selector(btnChekced(sender:)), for: .touchUpInside)
                break
            }
            break
        case .local_gdrive_multi:
            switch listState {
            case .deviceSelect:
                var imageString = "ico_device_giganas_share_on"
                if indexPath.row == 0 {
                    imageString = "ico_device_giganas_on"
                }
                cell.ivIcon.image = UIImage(named: imageString)
                cell.lblMain.text = nasArray[indexPath.row]
                cell.checkButton.isHidden = false
                cell.checkButton.tag = indexPath.row
                cell.checkButton.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                cell.checkButton.addTarget(self, action: #selector(btnChekced(sender:)), for: .touchUpInside)
                break
            case .deviceRoot:
                
                cell.ivIcon.image = UIImage(named: "ico_folder")
                cell.lblMain.text = driveFileArray[indexPath.row].name
                if(indexPath.row == 0){
                    cell.checkButton.isHidden = true
                } else {
                    cell.checkButton.isHidden = false
                }
                cell.checkButton.tag = indexPath.row
                cell.checkButton.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                cell.checkButton.addTarget(self, action: #selector(btnChekced(sender:)), for: .touchUpInside)
                break
            case .folder:
                cell.ivIcon.image = UIImage(named: "ico_folder")
                cell.lblMain.text = folderArray[indexPath.row].foldrNm
                if(indexPath.row == 0){
                    cell.checkButton.isHidden = true
                } else {
                    cell.checkButton.isHidden = false
                }
                cell.checkButton.tag = indexPath.row
                cell.btnChecked = 0
                cell.checkButton.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                cell.checkButton.addTarget(self, action: #selector(btnChekced(sender:)), for: .touchUpInside)
                break
            }
            break
        case .nas_gdrive_multi:
            switch listState {
            case .deviceSelect:
                var imageString = "ico_device_giganas_share_on"
                if indexPath.row == 0 {
                    imageString = "ico_device_giganas_on"
                }
                cell.ivIcon.image = UIImage(named: imageString)
                cell.lblMain.text = nasArray[indexPath.row]
                cell.checkButton.isHidden = false
                cell.checkButton.tag = indexPath.row
                cell.checkButton.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                cell.checkButton.addTarget(self, action: #selector(btnChekced(sender:)), for: .touchUpInside)
                break
            case .deviceRoot:
                
                cell.ivIcon.image = UIImage(named: "ico_folder")
                cell.lblMain.text = driveFileArray[indexPath.row].name
                if(indexPath.row == 0){
                    cell.checkButton.isHidden = true
                } else {
                    cell.checkButton.isHidden = false
                }
                cell.checkButton.tag = indexPath.row
                cell.checkButton.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                cell.checkButton.addTarget(self, action: #selector(btnChekced(sender:)), for: .touchUpInside)
                break
            case .folder:
                cell.ivIcon.image = UIImage(named: "ico_folder")
                cell.lblMain.text = folderArray[indexPath.row].foldrNm
                if(indexPath.row == 0){
                    cell.checkButton.isHidden = true
                } else {
                    cell.checkButton.isHidden = false
                }
                cell.checkButton.tag = indexPath.row
                cell.btnChecked = 0
                cell.checkButton.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                cell.checkButton.addTarget(self, action: #selector(btnChekced(sender:)), for: .touchUpInside)
                break
            }
            break
        default :
            switch listState {
            case .deviceSelect:
                var imageString = "ico_device_giganas_share_on"
                if indexPath.row == 0 {
                    imageString = "ico_device_giganas_on"
                }
                cell.ivIcon.image = UIImage(named: imageString)
                cell.lblMain.text = nasArray[indexPath.row]
                cell.checkButton.isHidden = true
                
                break
            case .deviceRoot:
                cell.ivIcon.image = UIImage(named: "ico_folder")
                cell.lblMain.text = folderNameArray[indexPath.row]
                if(indexPath.row == 0){
                    cell.checkButton.isHidden = false
                } else {
                    cell.checkButton.isHidden = true
                }
                cell.checkButton.tag = indexPath.row
                cell.checkButton.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                cell.checkButton.addTarget(self, action: #selector(btnChekced(sender:)), for: .touchUpInside)
                break
            case .folder:
                cell.ivIcon.image = UIImage(named: "ico_folder")
                cell.lblMain.text = folderArray[indexPath.row].foldrNm
                if(indexPath.row == 0){
                    cell.checkButton.isHidden = true
                } else {
                    cell.checkButton.isHidden = false
                }
                cell.checkButton.tag = indexPath.row
                cell.btnChecked = 0
                cell.checkButton.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                cell.checkButton.addTarget(self, action: #selector(btnChekced(sender:)), for: .touchUpInside)
                break
            }
            break
            
        }
        
        
        return cell
    }
    
    @objc func btnChekced(sender:UIButton){
        let buttonRow = sender.tag
        checkedButtonRow = buttonRow
        let indexPath = IndexPath(row: buttonRow, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! SendFolderSelectCell
//        print("checked drive directory : \(driveFileArray[checkedButtonRow])")
        switch storageState {
        case .googleDrive:
            switch listState {
            case .deviceSelect :
                googleDriveFileIdPath = "root"
                googleDriveWholeFoldrNmPath = "root"
                print("googleDriveFileIdPath : \(googleDriveFileIdPath)")
                print("googleDriveWholeFoldrNmPath : \(googleDriveWholeFoldrNmPath)")
                newFoldrId = "root"
                newFoldrWholePathNm = "root"
                print("newId : \(newFoldrId), newPath : \(newFoldrWholePathNm)")
                if(cell.btnChecked == 0){
                    for index in 0..<nasArray.count{
                        let indexPath = IndexPath(row: index, section: 0)
                        if let removeCheckCell = tableView.cellForRow(at: indexPath) as? SendFolderSelectCell {
                            removeCheckCell.btnChecked = 0
                            removeCheckCell.checkButton.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                        }
                        
                    }
                    sender.setImage(#imageLiteral(resourceName: "ico_24dp_done").withRenderingMode(.alwaysOriginal), for: .normal)
                    cell.btnChecked = 1
                    folderChecked = 1
                } else {
                    sender.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                    cell.btnChecked = 0
                    folderChecked = 0
                }
                break
            default:
                
                if(cell.btnChecked == 0){
                    for index in 0..<driveFileArray.count{
                        let indexPath = IndexPath(row: index, section: 0)
                        if let removeCheckCell = tableView.cellForRow(at: indexPath) as? SendFolderSelectCell {
                            removeCheckCell.btnChecked = 0
                            removeCheckCell.checkButton.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                        }
                        
                    }
                    sender.setImage(#imageLiteral(resourceName: "ico_24dp_done").withRenderingMode(.alwaysOriginal), for: .normal)
                    cell.btnChecked = 1
                    folderChecked = 1
                } else {
                    sender.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                    cell.btnChecked = 0
                    folderChecked = 0
                }
                break
            }
            break
        case .local_gdrive_multi:
            switch listState {
            case .deviceSelect :
                googleDriveFileIdPath = "root"
                googleDriveWholeFoldrNmPath = "root"
                newFoldrId = "root"
                newFoldrWholePathNm = "root"
                print("newId : \(newFoldrId), newPath : \(newFoldrWholePathNm)")
                if(cell.btnChecked == 0){
                    for index in 0..<nasArray.count{
                        let indexPath = IndexPath(row: index, section: 0)
                        if let removeCheckCell = tableView.cellForRow(at: indexPath) as? SendFolderSelectCell{
                            removeCheckCell.btnChecked = 0
                            removeCheckCell.checkButton.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                        }
                        
                    }
                    sender.setImage(#imageLiteral(resourceName: "ico_24dp_done").withRenderingMode(.alwaysOriginal), for: .normal)
                    cell.btnChecked = 1
                    folderChecked = 1
                } else {
                    sender.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                    cell.btnChecked = 0
                    folderChecked = 0
                }
                break
            default:
                googleDriveFileIdPath = "\(driveFileArray[buttonRow].fileId)"
                googleDriveWholeFoldrNmPath += "/\(driveFileArray[buttonRow].name)"
                if(cell.btnChecked == 0){
                    for index in 0..<driveFileArray.count{
                        let indexPath = IndexPath(row: index, section: 0)
                        if let removeCheckCell = tableView.cellForRow(at: indexPath) as? SendFolderSelectCell {
                            removeCheckCell.btnChecked = 0
                            removeCheckCell.checkButton.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                        }
                        
                    }
                    sender.setImage(#imageLiteral(resourceName: "ico_24dp_done").withRenderingMode(.alwaysOriginal), for: .normal)
                    cell.btnChecked = 1
                    folderChecked = 1
                } else {
                    sender.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                    cell.btnChecked = 0
                    folderChecked = 0
                }
                break
            }
            break
        case .nas_gdrive_multi:
            switch listState {
            case .deviceSelect :
                googleDriveFileIdPath = "root"
                googleDriveWholeFoldrNmPath = "root"
                newFoldrId = "root"
                newFoldrWholePathNm = "root"
                print("newId : \(newFoldrId), newPath : \(newFoldrWholePathNm)")
                if(cell.btnChecked == 0){
                    for index in 0..<nasArray.count{
                        let indexPath = IndexPath(row: index, section: 0)
                        if let removeCheckCell = tableView.cellForRow(at: indexPath) as? SendFolderSelectCell {
                            removeCheckCell.btnChecked = 0
                            removeCheckCell.checkButton.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                        }
                        
                    }
                    sender.setImage(#imageLiteral(resourceName: "ico_24dp_done").withRenderingMode(.alwaysOriginal), for: .normal)
                    cell.btnChecked = 1
                    folderChecked = 1
                } else {
                    sender.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                    cell.btnChecked = 0
                    folderChecked = 0
                }
                break
            default:
                googleDriveFileIdPath = "\(driveFileArray[buttonRow].fileId)"
                googleDriveWholeFoldrNmPath += "/\(driveFileArray[buttonRow].name)"
                if(cell.btnChecked == 0){
                    for index in 0..<driveFileArray.count{
                        let indexPath = IndexPath(row: index, section: 0)
                        if let removeCheckCell = tableView.cellForRow(at: indexPath) as? SendFolderSelectCell {
                            removeCheckCell.btnChecked = 0
                            removeCheckCell.checkButton.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                        }
                        
                    }
                    sender.setImage(#imageLiteral(resourceName: "ico_24dp_done").withRenderingMode(.alwaysOriginal), for: .normal)
                    cell.btnChecked = 1
                    folderChecked = 1
                } else {
                    sender.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                    cell.btnChecked = 0
                    folderChecked = 0
                }
                break
            }
            break
            
        default:
            switch listState {
            case .deviceRoot:
                newFoldrId = String(folderIdArray[sender.tag])
                newFoldrWholePathNm = folderPathArray[sender.tag]
                print("newId : \(newFoldrId), newPath : \(newFoldrWholePathNm)")
                if(cell.btnChecked == 0){
                    for index in 0..<folderIdArray.count{
                        let indexPath = IndexPath(row: index, section: 0)
                        if let removeCheckCell = tableView.cellForRow(at: indexPath) as? SendFolderSelectCell{
                            removeCheckCell.btnChecked = 0
                            removeCheckCell.checkButton.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                        }
                        
                    }
                    sender.setImage(#imageLiteral(resourceName: "ico_24dp_done").withRenderingMode(.alwaysOriginal), for: .normal)
                    cell.btnChecked = 1
                    folderChecked = 1
                } else {
                    sender.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                    cell.btnChecked = 0
                    folderChecked = 0
                }
                break
                
            default:
                fileId = String(folderArray[buttonRow].fileId)
                newFoldrId = String(folderArray[sender.tag].foldrId)
                newFoldrWholePathNm = folderArray[sender.tag].foldrWholePathNm
                print("newId : \(newFoldrId), newPath : \(newFoldrWholePathNm)")
                if(cell.btnChecked == 0){
                    for index in 0..<folderArray.count{
                        let indexPath = IndexPath(row: index, section: 0)
//                        print("array count : \(folderArray.count), index: \(index)")
                        if let removeCheckCell = tableView.cellForRow(at: indexPath) as? SendFolderSelectCell {
                            removeCheckCell.btnChecked = 0
                            removeCheckCell.checkButton.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                        }
                        
                    }
                    sender.setImage(#imageLiteral(resourceName: "ico_24dp_done").withRenderingMode(.alwaysOriginal), for: .normal)
                    cell.btnChecked = 1
                    folderChecked = 1
                } else {
                    sender.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                    cell.btnChecked = 0
                    folderChecked = 0
                    break
                }
            }
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        switch storageState {
        case .googleDrive:
            switch listState {
            case .deviceSelect:
                tableView.deselectRow(at: indexPath, animated: true)
                self.driveFolderIdArray.removeAll()
                self.driveFolderIdArray.append("root") // 0eun
                self.driveFolderNameArray.removeAll()
                self.driveFolderNameArray.append("root") // 0eun
                self.listState = .deviceRoot
                //                self.deviceName = nasArray[indexPath.row]
                self.getFilesFromGoogleDrive(accessToken: accessToken, root: "root", parent: "root")
                break
            default:
                tableView.deselectRow(at: indexPath, animated: true)
                var root = driveFileArray[indexPath.row].fileId
                var rootFolder = driveFileArray[indexPath.row].name
                print("rootFolder : \(rootFolder)")
                var parent = "root"
                if driveFileArray[indexPath.row].name == ".." {
                    if(driveFolderIdArray[driveFolderIdArray.count - 1] == "root") {
                        self.listState = .deviceSelect
                        root = "root"
                        
                        parent = "root"
                    } else {
                        root = driveFolderIdArray[driveFolderIdArray.count - 2]
                        parent = driveFileArray[indexPath.row].parents
                        driveFolderIdArray.remove(at: driveFolderIdArray.count-1)
                        driveFolderNameArray.remove(at: driveFolderNameArray.count-1)
                    }
                } else {
                    self.driveFolderIdArray.append(root)
                    self.driveFolderNameArray.append(rootFolder)
                    
                }
                
                print("root : \(root), idArray : \(driveFolderIdArray)")
                self.getFilesFromGoogleDrive(accessToken: accessToken, root: root, parent: parent)
                break
            }
            
            break
        case .local_gdrive_multi:
            switch listState {
            case .deviceSelect:
                self.driveFolderIdArray.removeAll()
                self.driveFolderIdArray.append("root") // 0eun
                self.driveFolderNameArray.removeAll()
                self.driveFolderNameArray.append("root") // 0eun
                
                self.listState = .deviceRoot
                //                self.deviceName = nasArray[indexPath.row]
                self.getFilesFromGoogleDrive(accessToken: accessToken, root: "root", parent: "root")
                break
            default:
                var root = driveFileArray[indexPath.row].fileId
                var rootFolder = driveFileArray[indexPath.row].name
                var parent = "root"
                if driveFileArray[indexPath.row].name == ".." {
                    if(driveFolderIdArray[driveFolderIdArray.count - 1] == "root") {
                        self.listState = .deviceSelect
                        root = "root"
                        
                        parent = "root"
                    } else {
                        root = driveFolderIdArray[driveFolderIdArray.count - 2]
                        parent = driveFileArray[indexPath.row].parents
                        driveFolderIdArray.remove(at: driveFolderIdArray.count-1)
                        driveFolderNameArray.remove(at: driveFolderNameArray.count-1)
                    }
                } else {
                    self.driveFolderIdArray.append(root)
                    self.driveFolderNameArray.append(rootFolder)
                    
                }
                
                print("root : \(root), idArray : \(driveFolderIdArray)")
                self.getFilesFromGoogleDrive(accessToken: accessToken, root: root, parent: parent)
                break
            }
            
            break
            
        case .nas_gdrive_multi:
            switch listState {
            case .deviceSelect:
                self.driveFolderIdArray.removeAll()
                self.driveFolderIdArray.append("root") // 0eun
                self.driveFolderNameArray.removeAll()
                self.driveFolderNameArray.append("root") // 0eun
                
                self.listState = .deviceRoot
                //                self.deviceName = nasArray[indexPath.row]
                self.getFilesFromGoogleDrive(accessToken: accessToken, root: "root", parent: "root")
                break
            default:
                var root = driveFileArray[indexPath.row].fileId
                var rootFolder = driveFileArray[indexPath.row].name
                var parent = "root"
                if driveFileArray[indexPath.row].name == ".." {
                    if(driveFolderIdArray[driveFolderIdArray.count - 1] == "root") {
                        self.listState = .deviceSelect
                        root = "root"
                        
                        parent = "root"
                    } else {
                        root = driveFolderIdArray[driveFolderIdArray.count - 2]
                        parent = driveFileArray[indexPath.row].parents
                        driveFolderIdArray.remove(at: driveFolderIdArray.count-1)
                        driveFolderNameArray.remove(at: driveFolderNameArray.count-1)
                    }
                } else {
                    self.driveFolderIdArray.append(root)
                    self.driveFolderNameArray.append(rootFolder)
                    
                }
                
                print("root : \(root), idArray : \(driveFolderIdArray)")
                self.getFilesFromGoogleDrive(accessToken: accessToken, root: root, parent: parent)
                break
            }
            break
            
        default:
            switch listState {
            case .deviceSelect:
                self.listState = .deviceRoot
                self.deviceName = nasArray[indexPath.row]
                toUserId = nasUserIdArray[indexPath.row]
                currentDevUuId = nasDevIdArray[indexPath.row]
                
                self.getRootFolder(userId: toUserId, devUuid: currentDevUuId, deviceName: nasArray[indexPath.row])
                break
                
            case .deviceRoot:
                self.listState = .folder
                self.getRootFolder(userId: toUserId, devUuid: currentDevUuId, deviceName: deviceName)
                break
            default:
                let foldrId = folderArray[indexPath.row].foldrId
                let folderNm = folderArray[indexPath.row].foldrNm
                let stringFoldrId = String(foldrId)
                //                print("foldrId : \(stringFoldrId)")
                if(folderArray[indexPath.row].foldrNm == ".."){
                    if(folderArray[indexPath.row].foldrId == 0){
                        self.listState = .deviceRoot
                        self.getRootFolder(userId: toUserId, devUuid: currentDevUuId, deviceName: deviceName)
                        return
                    } else {
                        folderIdArray.remove(at: folderIdArray.count-1)
                        folderNameArray.remove(at: folderNameArray.count-1)
                    }
                    
                } else {
                    self.folderIdArray.append(foldrId)
                    self.folderNameArray.append(folderNm)
                }
                var folderNameArrayCount = 0
                if(folderNameArray.count < 1){
                    
                } else {
                    folderNameArrayCount = folderNameArray.count-1
                }
                self.showInsideList(userId: toUserId, devUuid: currentDevUuId, foldrId: stringFoldrId,deviceName: deviceName)
                break
            }
            
            
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    
    
    @IBAction func selectFinish(_ sender: UIButton) {
        
        let accessToken:String = UserDefaults.standard.string(forKey: "googleAccessToken") ?? ""
            toOsCd = "G"
            if(toUserId != UserDefaults.standard.string(forKey: "userId")){
                toOsCd = "S"
            }
        
            if(folderChecked == 1){
                switch storageState {
                case .nas:
                    
                    NasSendController().handleNasSend(getToOsCd: toOsCd, getToUserId: toUserId, getOriginalFileName: originalFileName, getAmdDate: amdDate, getOriginalFileId: originalFileId, oldFoldrWholePathNm: oldFoldrWholePathNm, newFoldrWholePathNm: newFoldrWholePathNm, multiCheckedfolderArray: multiCheckedfolderArray, etsionNm:etsionNm, storageState:storageState, listState: listState, driveFileArray: driveFileArray, checkedButtonRow: checkedButtonRow, driveFolderNameArray: driveFolderNameArray, driveFolderIdArray: driveFolderIdArray, fromOsCd: fromOsCd, fromDevUuid: fromDevUuid, accessToken: accessToken, googleDriveFileIdPath: googleDriveFileIdPath, deviceName:deviceName, fromUserId:fromUserId, containerViewController:containerViewController!, currentDevUuId:currentDevUuId, newFoldrId:newFoldrId, fromFoldrId:fromFoldrId, mimeType:mimeType, gDriveMultiCheckedfolderArray:gDriveMultiCheckedfolderArray)
                    
                    DispatchQueue.main.async {
                        Util().dismissFromLeft(vc: self)
                    }
                    
                    
                    break
                case .googleDrive:
                    
                    NasSendController().handleNasSend(getToOsCd: toOsCd, getToUserId: toUserId, getOriginalFileName: originalFileName, getAmdDate: amdDate, getOriginalFileId: originalFileId, oldFoldrWholePathNm: oldFoldrWholePathNm, newFoldrWholePathNm: newFoldrWholePathNm, multiCheckedfolderArray: multiCheckedfolderArray, etsionNm:etsionNm, storageState:storageState, listState: listState, driveFileArray: driveFileArray, checkedButtonRow: checkedButtonRow, driveFolderNameArray: driveFolderNameArray, driveFolderIdArray: driveFolderIdArray, fromOsCd: fromOsCd, fromDevUuid: fromDevUuid, accessToken: accessToken, googleDriveFileIdPath: googleDriveFileIdPath, deviceName:deviceName, fromUserId:fromUserId, containerViewController:containerViewController!, currentDevUuId: currentDevUuId, newFoldrId: newFoldrId, fromFoldrId:fromFoldrId, mimeType:mimeType, gDriveMultiCheckedfolderArray:gDriveMultiCheckedfolderArray)
                    
                    DispatchQueue.main.async {
                        Util().dismissFromLeft(vc: self)
                    }
                    
                    break
                case .nas_multi:
                    
                    print("multi ans to nas")
                    print("multiCheckedfolderArray : \(multiCheckedfolderArray)")
                    //                startMultiFolderNasToNas()
                    NasSendController().handleNasSend(getToOsCd: toOsCd, getToUserId: toUserId, getOriginalFileName: originalFileName, getAmdDate: amdDate, getOriginalFileId: originalFileId, oldFoldrWholePathNm: oldFoldrWholePathNm, newFoldrWholePathNm: newFoldrWholePathNm, multiCheckedfolderArray: multiCheckedfolderArray, etsionNm:etsionNm, storageState:storageState, listState: listState, driveFileArray: driveFileArray, checkedButtonRow: checkedButtonRow, driveFolderNameArray: driveFolderNameArray, driveFolderIdArray: driveFolderIdArray, fromOsCd: fromOsCd, fromDevUuid: fromDevUuid, accessToken: accessToken, googleDriveFileIdPath: googleDriveFileIdPath, deviceName:deviceName, fromUserId:fromUserId, containerViewController:containerViewController!, currentDevUuId: currentDevUuId, newFoldrId: newFoldrId, fromFoldrId:fromFoldrId, mimeType:mimeType, gDriveMultiCheckedfolderArray:gDriveMultiCheckedfolderArray)
                    let fileDict = ["getMultiCheckedfolderArray":multiCheckedfolderArray]
                    NotificationCenter.default.post(name: Notification.Name("setMultiProgressFileDict"), object:self, userInfo:fileDict)
                    
                    Util().dismissFromLeft(vc: self)
                    
                    break
                case .remote_nas_multi:
                    print("multi remote to nas")
                    print("multiCheckedfolderArray : \(multiCheckedfolderArray), oldFoldrWholePathNm : \(oldFoldrWholePathNm)")
                    NasSendController().handleNasSend(getToOsCd: toOsCd, getToUserId: toUserId, getOriginalFileName: originalFileName, getAmdDate: amdDate, getOriginalFileId: originalFileId, oldFoldrWholePathNm: oldFoldrWholePathNm, newFoldrWholePathNm: newFoldrWholePathNm, multiCheckedfolderArray: multiCheckedfolderArray, etsionNm:etsionNm, storageState:storageState, listState: listState, driveFileArray: driveFileArray, checkedButtonRow: checkedButtonRow, driveFolderNameArray: driveFolderNameArray, driveFolderIdArray: driveFolderIdArray, fromOsCd: fromOsCd, fromDevUuid: fromDevUuid, accessToken: accessToken, googleDriveFileIdPath: googleDriveFileIdPath, deviceName:deviceName, fromUserId:fromUserId, containerViewController:containerViewController!, currentDevUuId: currentDevUuId, newFoldrId: newFoldrId, fromFoldrId:fromFoldrId, mimeType:mimeType, gDriveMultiCheckedfolderArray:gDriveMultiCheckedfolderArray)
                    
                    Util().dismissFromLeft(vc: self)
                    break
                case .local_nas_multi:
                    print("multi local to nas")
                    //                startMultiLocalToNas()
                    NasSendController().handleNasSend(getToOsCd: toOsCd, getToUserId: toUserId, getOriginalFileName: originalFileName, getAmdDate: amdDate, getOriginalFileId: originalFileId, oldFoldrWholePathNm: oldFoldrWholePathNm, newFoldrWholePathNm: newFoldrWholePathNm, multiCheckedfolderArray: multiCheckedfolderArray, etsionNm:etsionNm, storageState:storageState, listState: listState, driveFileArray: driveFileArray, checkedButtonRow: checkedButtonRow, driveFolderNameArray: driveFolderNameArray, driveFolderIdArray: driveFolderIdArray, fromOsCd: fromOsCd, fromDevUuid: fromDevUuid, accessToken: accessToken, googleDriveFileIdPath: googleDriveFileIdPath, deviceName:deviceName, fromUserId:fromUserId, containerViewController:containerViewController!, currentDevUuId: currentDevUuId, newFoldrId: newFoldrId, fromFoldrId:fromFoldrId, mimeType:mimeType, gDriveMultiCheckedfolderArray:gDriveMultiCheckedfolderArray)
                    let fileDict = ["getMultiCheckedfolderArray":multiCheckedfolderArray]
                    NotificationCenter.default.post(name: Notification.Name("setMultiProgressFileDict"), object:self, userInfo:fileDict)
                    Util().dismissFromLeft(vc: self)
                    //                print("multiCheckedfolderArray : \(multiCheckedfolderArray)")
                    break
                case .multi_nas_multi:
                    print("multi file in lately view to nas")
                    NasSendController().handleNasSend(getToOsCd: toOsCd, getToUserId: toUserId, getOriginalFileName: originalFileName, getAmdDate: amdDate, getOriginalFileId: originalFileId, oldFoldrWholePathNm: oldFoldrWholePathNm, newFoldrWholePathNm: newFoldrWholePathNm, multiCheckedfolderArray: multiCheckedfolderArray, etsionNm:etsionNm, storageState:storageState, listState: listState, driveFileArray: driveFileArray, checkedButtonRow: checkedButtonRow, driveFolderNameArray: driveFolderNameArray, driveFolderIdArray: driveFolderIdArray, fromOsCd: fromOsCd, fromDevUuid: fromDevUuid, accessToken: accessToken, googleDriveFileIdPath: googleDriveFileIdPath, deviceName:deviceName, fromUserId:fromUserId, containerViewController:containerViewController!, currentDevUuId: currentDevUuId, newFoldrId: newFoldrId, fromFoldrId:fromFoldrId, mimeType:mimeType, gDriveMultiCheckedfolderArray:gDriveMultiCheckedfolderArray)
                    Util().dismissFromLeft(vc: self)
                    break
                case .local_gdrive_multi:
                    print("multi local to gdrive")
                    //                startMultiLocalToGdrive()
                    NasSendController().handleNasSend(getToOsCd: toOsCd, getToUserId: toUserId, getOriginalFileName: originalFileName, getAmdDate: amdDate, getOriginalFileId: originalFileId, oldFoldrWholePathNm: oldFoldrWholePathNm, newFoldrWholePathNm: newFoldrWholePathNm, multiCheckedfolderArray: multiCheckedfolderArray, etsionNm:etsionNm, storageState:storageState, listState: listState, driveFileArray: driveFileArray, checkedButtonRow: checkedButtonRow, driveFolderNameArray: driveFolderNameArray, driveFolderIdArray: driveFolderIdArray, fromOsCd: fromOsCd, fromDevUuid: fromDevUuid, accessToken: accessToken, googleDriveFileIdPath: googleDriveFileIdPath, deviceName:deviceName, fromUserId:fromUserId, containerViewController:containerViewController!, currentDevUuId: currentDevUuId, newFoldrId: newFoldrId, fromFoldrId:fromFoldrId, mimeType:mimeType, gDriveMultiCheckedfolderArray:gDriveMultiCheckedfolderArray)
                    let fileDict = ["getMultiCheckedfolderArray":multiCheckedfolderArray]
                    NotificationCenter.default.post(name: Notification.Name("setMultiProgressFileDict"), object:self, userInfo:fileDict)
                    Util().dismissFromLeft(vc: self)
                    
                    break
                case .gdrive_nas_multi:
                    print("multi gDrive to nas")
                    //                startMultiGdriveToNas()
                    NasSendController().handleNasSend(getToOsCd: toOsCd, getToUserId: toUserId, getOriginalFileName: originalFileName, getAmdDate: amdDate, getOriginalFileId: originalFileId, oldFoldrWholePathNm: oldFoldrWholePathNm, newFoldrWholePathNm: newFoldrWholePathNm, multiCheckedfolderArray: multiCheckedfolderArray, etsionNm:etsionNm, storageState:storageState, listState: listState, driveFileArray: driveFileArray, checkedButtonRow: checkedButtonRow, driveFolderNameArray: driveFolderNameArray, driveFolderIdArray: driveFolderIdArray, fromOsCd: fromOsCd, fromDevUuid: fromDevUuid, accessToken: accessToken, googleDriveFileIdPath: googleDriveFileIdPath, deviceName:deviceName, fromUserId:fromUserId, containerViewController:containerViewController!, currentDevUuId: currentDevUuId, newFoldrId: newFoldrId, fromFoldrId:fromFoldrId, mimeType:mimeType, gDriveMultiCheckedfolderArray:gDriveMultiCheckedfolderArray)
                    let filedict = ["getDriveMultiCheckedfolderArray":gDriveMultiCheckedfolderArray]
                    
                    NotificationCenter.default.post(name: Notification.Name("setGdriveMultiProgressFileDict"), object:self, userInfo:filedict)

                    Util().dismissFromLeft(vc: self)
                    break
                case .nas_gdrive_multi:
                    print("multi nas to gdrive")
                    //multicheck call download - > start
                    NasSendController().handleNasSend(getToOsCd: toOsCd, getToUserId: toUserId, getOriginalFileName: originalFileName, getAmdDate: amdDate, getOriginalFileId: originalFileId, oldFoldrWholePathNm: oldFoldrWholePathNm, newFoldrWholePathNm: newFoldrWholePathNm, multiCheckedfolderArray: multiCheckedfolderArray, etsionNm:etsionNm, storageState:storageState, listState: listState, driveFileArray: driveFileArray, checkedButtonRow: checkedButtonRow, driveFolderNameArray: driveFolderNameArray, driveFolderIdArray: driveFolderIdArray, fromOsCd: fromOsCd, fromDevUuid: fromDevUuid, accessToken: accessToken, googleDriveFileIdPath: googleDriveFileIdPath, deviceName:deviceName, fromUserId:fromUserId, containerViewController:containerViewController!, currentDevUuId: currentDevUuId, newFoldrId: newFoldrId, fromFoldrId:fromFoldrId, mimeType:mimeType, gDriveMultiCheckedfolderArray:gDriveMultiCheckedfolderArray)
                    
                    let fileDict = ["getMultiCheckedfolderArray":multiCheckedfolderArray]
                    NotificationCenter.default.post(name: Notification.Name("setMultiProgressFileDict"), object:self, userInfo:fileDict)

                    Util().dismissFromLeft(vc: self)
                    
                    break
               
                case .search_nas_multi:
                    print("multi search to nas")
                    NasSendController().handleNasSend(getToOsCd: toOsCd, getToUserId: toUserId, getOriginalFileName: originalFileName, getAmdDate: amdDate, getOriginalFileId: originalFileId, oldFoldrWholePathNm: oldFoldrWholePathNm, newFoldrWholePathNm: newFoldrWholePathNm, multiCheckedfolderArray: multiCheckedfolderArray, etsionNm:etsionNm, storageState:storageState, listState: listState, driveFileArray: driveFileArray, checkedButtonRow: checkedButtonRow, driveFolderNameArray: driveFolderNameArray, driveFolderIdArray: driveFolderIdArray, fromOsCd: fromOsCd, fromDevUuid: fromDevUuid, accessToken: accessToken, googleDriveFileIdPath: googleDriveFileIdPath, deviceName:deviceName, fromUserId:fromUserId, containerViewController:containerViewController!, currentDevUuId: currentDevUuId, newFoldrId: newFoldrId, fromFoldrId:fromFoldrId, mimeType:mimeType, gDriveMultiCheckedfolderArray:gDriveMultiCheckedfolderArray)
                    DispatchQueue.main.async {
                        Util().dismissFromLeft(vc: self)
                    }
                    
                    break
                }
            
            }
    }
    
    
  
    
    
    // startMultiGdriveToNas
    func startMultiGdriveToNas(){
        if(gDriveMultiCheckedfolderArray.count > 0){
            let index = gDriveMultiCheckedfolderArray.count - 1
            let originalFileId = String(gDriveMultiCheckedfolderArray[index].fileId)
            let fromFoldrId = String(gDriveMultiCheckedfolderArray[index].fileId)
            originalFileName = gDriveMultiCheckedfolderArray[index].name
            let oldFoldrWholePathNm = gDriveMultiCheckedfolderArray[index].foldrWholePath
            let mimeType = gDriveMultiCheckedfolderArray[index].mimeType
            var toOsCd = "G"
            if(toUserId != UserDefaults.standard.string(forKey: "userId")){
                toOsCd = "S"
            }
            if(mimeType != Util.getGoogleMimeType(etsionNm: "folder")){
                GoogleWork().downloadGDriveFile(fileId: originalFileId, mimeType: mimeType, name: originalFileName, startByte: 0, endByte: 102400) { responseObject, error in
                    if let fileUrl = responseObject {
                        print("fileUrl : \(fileUrl), name : \(self.originalFileName), toOsCd : \(self.toOsCd), fileId : \(self.originalFileId)")
                        SyncLocalFilleToNas().callSyncFomNasSend(view: "NasSendFolderSelectVC", parent: self)
                    }
                }
            } else {
                if let googleEmail = UserDefaults.standard.string(forKey: "googleEmail"){
//                    accessToken = DbHelper().getAccessToken(email: googleEmail)
                    accessToken = UserDefaults.standard.string(forKey: "googleAccessToken")!
//                    SendMultiToNasFromGDrive().downloadFolderFromGDrive(foldrId: originalFileId, getAccessToken: accessToken, fileId: originalFileId, downloadRootFolderName:originalFileName, parent:self)
                }
            }
            return
        }
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: nil, message: "NAS로 내보내기 성공", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                //Do you Success button Stuff here
                SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
                self.activityIndicator.stopAnimating()
                Util().dismissFromLeft(vc: self)
            }
            alertController.addAction(yesAction)
            self.present(alertController, animated: true)
            
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
    
    
    //get noti from sync
    func notifiedSyncFinish(rootFolder:String){
        GetListFromServer().getMobileFileLIst(devUuid: Util.getUuid(), userId:loginUserId!, deviceName:"sdf"){ responseObject, error in
            let json = JSON(responseObject!)
            if(json["listData"].exists()){
                let serverList:[AnyObject] = json["listData"].arrayObject! as [AnyObject]
                print("serverList : \(serverList)")
                for serverFile in serverList{
                    let serverFileNm = serverFile["fileNm"] as? String ?? "nil"
                    let serverFilePath = serverFile["foldrWholePathNm"] as? String ?? "nil"
                    let serverFileAmdDate = serverFile["amdDate"] as? String ?? "nil"
                    print("serverFileNm : \(serverFileNm), serverFilePath : \(serverFilePath)")
                    print("fromFoldrId : \(self.fromFoldrId)")
                    self.toOsCd = "G"
                    if(self.toUserId != self.loginUserId){
                        self.toOsCd = "S"
                    }
                    if(rootFolder.isEmpty){
                        if(serverFileNm == self.originalFileName && serverFilePath == "/Mobile"){
                            print("fromFoldrId : \(self.fromFoldrId), originalFileName:\(self.originalFileName)")
                            if(self.fromFoldrId.isEmpty){
                                //파일 업로드 to nas
                                if self.storageState == .gdrive_nas_multi {
                                    if(serverFilePath == "/Mobile"){
                                        let getFileID = serverFile["fileId"] as? Int ?? 0
                                        print("getFileID : \(getFileID)")
                                        //                                        let fileUrl:URL = FileUtil().getFileUrl(fileNm: self.originalFileName, amdDate: self.amdDate)!
                                        let fileUrl:URL = FileUtil().getFileUrlWithFoldr(fileNm: self.originalFileName, foldrWholePathNm: "/Mobile", amdDate: self.amdDate)!
                                        
                                        
                                        self.sendToNasFromLocal(url: fileUrl, name: self.originalFileName, toOsCd:self.toOsCd, fileId: String(getFileID))
                                        break
                                    }
                                    
                                } else {
                                    let getFileID = serverFile["fileId"] as? Int ?? 0
                                    //                                      let fileUrl:URL = FileUtil().getFileUrl(fileNm: self.originalFileName, amdDate: self.amdDate)!
                                    let filePath:String = FileUtil().getFilePathWithFoldr(fileNm: self.originalFileName, foldrWholePathNm: "/Mobile", amdDate: self.amdDate)
                                    
                                    
                                    if(FileManager.default.fileExists(atPath: filePath)){
                                        let fileUrl:URL = FileUtil().getFileUrlWithFoldr(fileNm: self.originalFileName, foldrWholePathNm: "/Mobile", amdDate: self.amdDate)!
                                        print("getFileID : \(getFileID), self.originalFileName: \(self.originalFileName), self.toOsCd: \(self.toOsCd)")
                                        print("fileUrl : \(fileUrl)")
                                        
                                        self.sendToNasFromLocal(url: fileUrl, name: self.originalFileName, toOsCd:self.toOsCd, fileId: String(getFileID))
                                        break
                                    }
                                    
                                }
                                
                                
                            }
                        }
                    } else {
                        
                        let folderNmArray = serverFilePath.components(separatedBy: "/")
                        let lastName = folderNmArray[folderNmArray.count - 1]
                        print("rootFolder : \(rootFolder), lastName : \(lastName)")
                        if serverFilePath == rootFolder {
                            //폴더 업로드 to nas
                            print("upload path : \(self.newFoldrWholePathNm)")
                            print("oldFoldrWholePathNm : \(self.oldFoldrWholePathNm)")
                            if(self.storageState == .gdrive_nas_multi){
//                                ToNasFromLocalFomGDriveFolder().readyCreatFolders(getToUserId:self.toUserId, getNewFoldrWholePathNm:self.newFoldrWholePathNm, getOldFoldrWholePathNm:serverFilePath, getMultiArray:self.gDriveMultiCheckedfolderArray, parent:self.containerViewController!)
                                
                            } else {
                                ToNasFromLocalFolder().readyCreatFolders(getToUserId:self.toUserId, getNewFoldrWholePathNm:self.newFoldrWholePathNm, getOldFoldrWholePathNm:serverFilePath, getMultiArray:self.multiCheckedfolderArray, parent:self.containerViewController!, toOsCd: self.toOsCd)
                                
                            }
                            
                        }
                        
                    }
                    
                }
            } else {
                print("no file")
            }
            
        }
    }
    
    
    
    func startMultiLatelyToNas(){
        if(multiCheckedfolderArray.count > 0){
            let index = multiCheckedfolderArray.count - 1
            let originalFileId = String(multiCheckedfolderArray[index].fileId)
            let fromFoldrId = String(multiCheckedfolderArray[index].foldrId)
            let originalFileName = multiCheckedfolderArray[index].fileNm
            let oldFoldrWholePathNm = multiCheckedfolderArray[index].foldrWholePathNm
            let etsionNm = multiCheckedfolderArray[index].etsionNm
            let amdDate = multiCheckedfolderArray[index].amdDate
            let fromOsCdFromMultiArray = multiCheckedfolderArray[index].osCd
            let currentDevUuId = multiCheckedfolderArray[index].devUuid
            let fromUserId = multiCheckedfolderArray[index].userId
            var toOsCd = "G"
            if(toUserId != loginUserId){
                toOsCd = "S"
            }
            
            if(currentDevUuId == Util.getUuid()){
                print("local to nas")
                let fileUrl:URL = FileUtil().getFileUrl(fileNm: originalFileName, amdDate: amdDate)!
                sendToNasFromLocal(url: fileUrl, name: originalFileName, toOsCd:toOsCd,fileId: originalFileId)
            } else if (fromOsCdFromMultiArray == "S" || fromOsCdFromMultiArray == "G") {
                if(fromOsCdFromMultiArray == "G"){
                    print("deviceName : \(deviceName)")
                    if(toUserId != loginUserId){
                        let param = ["userId":fromUserId,"toUserId":toUserId,"devUuid":currentDevUuId,"fileId":originalFileId,"fileNm":originalFileName, "foldrId":newFoldrId,"foldrWholePathNm":newFoldrWholePathNm,"oldfoldrWholePathNm":oldFoldrWholePathNm,"osCd":"G","toOsCd":"S"]
                        print("from g to s param : \(param)")
                        self.sendNasToShareNas(params: param)
                    } else {
                        let param = ["userId":toUserId, "devUuid": currentDevUuId,"fileId":originalFileId,"fileNm":originalFileName,"foldrId":newFoldrId,"foldrWholePathNm":newFoldrWholePathNm,"oldfoldrWholePathNm":oldFoldrWholePathNm]
                        print("from s to s param : \(param), \(deviceName)")
                        self.sendNasToNas(params: param)
                    }
                    
                } else if (fromOsCdFromMultiArray == "S") {
                    if(toUserId != loginUserId){
                        let param = ["userId":fromUserId,"toUserId":toUserId,"devUuid":currentDevUuId,"fileId":originalFileId,"fileNm":originalFileName, "foldrId":newFoldrId,"foldrWholePathNm":newFoldrWholePathNm,"oldfoldrWholePathNm":oldFoldrWholePathNm,"osCd":"S","toOsCd":"S"]
                        print("param : \(param)")
                        //shared to shared
                        self.sendShareNasToNas(params: param)
                    } else {
                        let param = ["userId":fromUserId,"toUserId":toUserId,"devUuid":currentDevUuId,"fileId":originalFileId,"fileNm":originalFileName, "foldrId":newFoldrId,"foldrWholePathNm":newFoldrWholePathNm,"oldfoldrWholePathNm":oldFoldrWholePathNm,"osCd":"S","toOsCd":"G"]
                        print("param : \(param) to G")
                        self.sendShareNasToNas(params: param)
                    }
                }
            } else {
                remoteDownloadRequest(fromUserId: fromUserId, fromDevUuid: currentDevUuId, fromOsCd: fromOsCdFromMultiArray, fromFoldr: oldFoldrWholePathNm, fromFileNm: originalFileName, fromFileId: originalFileId)
            }
            return
        }
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: nil, message: "NAS로 내보내기 성공", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                //Do you Success button Stuff here
                self.activityIndicator.stopAnimating()
                Util().dismissFromLeft(vc: self)
            }
            alertController.addAction(yesAction)
            self.present(alertController, animated: true)
            
        }
        
    }
    
    
   
  
    func startMultiFolderNasToNas(){
        if(multiCheckedfolderArray.count > 0){
            let index = multiCheckedfolderArray.count - 1
            let originalFileId = String(multiCheckedfolderArray[index].fileId)
            let fromFoldrId = String(multiCheckedfolderArray[index].foldrId)
            let originalFileName = multiCheckedfolderArray[index].fileNm
            let oldFoldrWholePathNm = multiCheckedfolderArray[index].foldrWholePathNm
            let etsionNm = multiCheckedfolderArray[index].etsionNm
            var toOsCd = "G"
            if(toUserId != loginUserId){
                toOsCd = "S"
            }
            if(etsionNm != "nil"){
                // nas 보내기 파일
                if(fromOsCd == "G"){
                    print("deviceName : \(deviceName)")
                    if(toUserId != loginUserId){
                        let param = ["userId":fromUserId,"toUserId":toUserId,"devUuid":currentDevUuId,"fileId":originalFileId,"fileNm":originalFileName, "foldrId":newFoldrId,"foldrWholePathNm":newFoldrWholePathNm,"oldfoldrWholePathNm":oldFoldrWholePathNm,"osCd":"G","toOsCd":"S"]
                        print("from g to s param : \(param)")
                        self.sendNasToShareNas(params: param)
                    } else {
                        let param = ["userId":toUserId, "devUuid": currentDevUuId,"fileId":originalFileId,"fileNm":originalFileName,"foldrId":newFoldrId,"foldrWholePathNm":newFoldrWholePathNm,"oldfoldrWholePathNm":oldFoldrWholePathNm]
                        print("from s to s param : \(param), \(deviceName)")
                        self.sendNasToNas(params: param)
                    }
                    
                } else if (fromOsCd == "S") {
                    if(toUserId != loginUserId){
                        let param = ["userId":fromUserId,"toUserId":toUserId,"devUuid":currentDevUuId,"fileId":originalFileId,"fileNm":originalFileName, "foldrId":newFoldrId,"foldrWholePathNm":newFoldrWholePathNm,"oldfoldrWholePathNm":oldFoldrWholePathNm,"osCd":"S","toOsCd":"S"]
                        print("param : \(param)")
                        //shared to shared
                        self.sendShareNasToNas(params: param)
                    } else {
                        let param = ["userId":fromUserId,"toUserId":toUserId,"devUuid":currentDevUuId,"fileId":originalFileId,"fileNm":originalFileName, "foldrId":newFoldrId,"foldrWholePathNm":newFoldrWholePathNm,"oldfoldrWholePathNm":oldFoldrWholePathNm,"osCd":"S","toOsCd":"G"]
                        print("param : \(param) to G")
                        self.sendShareNasToNas(params: param)
                    }
                } else {
                    let fileUrl:URL = FileUtil().getFileUrl(fileNm: originalFileName, amdDate: amdDate)!
                    sendToNasFromLocal(url: fileUrl, name: originalFileName, toOsCd:toOsCd, fileId: originalFileId)
                    
                }
            } else {
                // nas 보내기 폴더
                var toOsCd = "G"
                if(toUserId != loginUserId){
                    toOsCd = "S"
                }
                let param = ["userId":fromUserId,"toUserId":toUserId, "foldrId":fromFoldrId,"foldrWholePathNm":newFoldrWholePathNm,"oldfoldrWholePathNm":oldFoldrWholePathNm,"osCd":fromOsCd,"toOsCd":toOsCd]
                if(fromOsCd == "S" || toOsCd == "S"){
                    print("copyShareNasFolder param : \(param)")
                    self.copyShareNasFolder(params: param)
                } else {
                    print("fromOsCd: \(fromOsCd), toOsCd :  \(toOsCd)")
                    print("copyNasFolder param : \(param)")
                    self.copyNasFolder(params: param)
                }
                
            }
            return
        }
//        print("count : \(multiCheckedfolderArray.count)")
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: nil, message: "NAS로 내보내기 성공", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                //Do you Success button Stuff here
                self.activityIndicator.stopAnimating()
                Util().dismissFromLeft(vc: self)
            }
            alertController.addAction(yesAction)
            self.present(alertController, animated: true)
            
        }
    }
    
    
   
    
    
    func getFilesFromGoogleDrive(accessToken:String, root:String, parent:String){
        
        var url = "https://www.googleapis.com/drive/v3/files?q='\(root)' in parents and trashed=false and mimeType='application/vnd.google-apps.folder'&access_token=\(accessToken)" + App.URL.gDriveFileOption
        url = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        Alamofire.request(url,
                          method: .get,
                          encoding: JSONEncoding.default,
                          headers: nil).responseJSON { response in
                            switch response.result {
                            case .success(let value):
                                let json = JSON(value)
                                //                    print("json : \(json)")
                                //                    let responseData = value as! NSDictionary
                                if(json["files"].exists()){
                                    let serverList:[AnyObject] = json["files"].arrayObject! as [AnyObject]
                                    if (serverList.count > 0) {
                                        self.driveFileArray.removeAll()
                                        
                                        let upFolder = App.DriveFileStruct(fileId : root, kind : "d", mimeType : "d", name : "..", createdTime:"String", modifiedTime:"String", parents:parent, fileExtension:"String", size:"String", foldrWholePath:"String", thumbnailLink:"String", checked:false)
                                        
                                        self.driveFileArray.append(upFolder)
                                        
                                        for file in serverList {
                                            if file["trashed"] as? Int == 0 && file["starred"] as? Int == 0 && file["shared"] as? Int == 0 {
                                                let fileStruct = App.DriveFileStruct(device:file, foldrWholePaths:["sd"])
                                                
                                                self.driveFileArray.append(fileStruct)
                                            }
                                            
                                        }
                                        self.tableView.reloadData()
                                        self.tableView.isHidden = false
                                        self.activityIndicator.stopAnimating()
                                        print("driveFileArraycount : \(self.driveFileArray.count)")
                                    } else {
                                        if(self.listState == .deviceSelect) {
                                            self.tableView.isHidden = false
                                            self.activityIndicator.stopAnimating()
                                        } else {
                                            DispatchQueue.main.async {
                                                if(self.driveFolderIdArray.count > 1){
                                                    self.driveFolderIdArray.remove(at: self.driveFolderIdArray.count - 1)
                                                    self.driveFolderNameArray.remove(at: self.driveFolderNameArray.count - 1)
                                                } else {
                                                    self.listState = .deviceSelect
                                                }
                                                self.tableView.isHidden = false
                                                self.activityIndicator.stopAnimating()
                                                let alertController = UIAlertController(title: nil, message: "더 이상 하위폴더가 없습니다.", preferredStyle: .alert)
                                                let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel)
                                                
                                                alertController.addAction(yesAction)
                                                
                                                self.present(alertController, animated: true)
                                            }
                                        }
                                        
                                    }
                                }
                                break
                            case .failure(let error):
                                NSLog(error.localizedDescription)
                                
                                break
                            }
                            
        }
    }
    
    func getRootFolder(userId: String, devUuid: String, deviceName:String){
        
        self.folderIdArray.removeAll()
        self.folderNameArray.removeAll()
        self.folderPathArray.removeAll()
        
        GetListFromServer().getFoldrList(devUuid: devUuid, userId:userId, deviceName: deviceName){ responseObject, error in
            if let response = responseObject {
                let json = JSON(response)
                if(json["listData"].exists()){
                    let serverList:[AnyObject] = json["listData"].arrayObject! as [AnyObject]
                    print("serverList : \(serverList)")
                    for rootFolder in serverList{
                        let foldrId = rootFolder["foldrId"] as? Int ?? 0
                        let stringFoldrId = String(foldrId)
                        self.currentFolderId = stringFoldrId
                        let froldrNm = rootFolder["foldrNm"] as? String ?? "nil"
                        let stringFroldrNm = String(froldrNm)
                        self.folderIdArray.append(foldrId)
                        self.folderNameArray.append(stringFroldrNm)
                        self.folderPathArray.append(rootFolder["foldrWholePathNm"] as? String ?? "nil")
                        if(self.listState == .folder){
                            
                            self.showInsideList(userId: userId, devUuid: devUuid, foldrId: stringFoldrId, deviceName:deviceName)
                        } else {
                            self.tableView.reloadData()
                        }
                        
                    }
                }
            } else {
                print("error : \(error)")
            }
          
            
            return
        }
    }
    
    
    func showInsideList(userId: String, devUuid: String, foldrId: String, deviceName:String){
        self.listState = .folder
        self.folderArray.removeAll()
        var param = ["userId": userId, "devUuid":devUuid, "foldrId":foldrId,"sortBy":sortBy]
        if(folderIdArray.count > 1){
            let upFolder = App.FolderStruct(data: ["foldrNm":"..","foldrId":folderIdArray[folderIdArray.count-2],"userId":userId,"childCnt":0,"devUuid":devUuid,"foldrWholePathNm":"up","cretDate":"cretDate"] as [String : Any])
            self.folderArray.append(upFolder)
            if(folderIdArray.count == 1){
                param = ["userId": userId, "devUuid":devUuid]
            }
        } else {
            let upFolder = App.FolderStruct(data: ["foldrNm":"..","foldrId":0,"userId":userId,"childCnt":0,"devUuid":devUuid,"foldrWholePathNm":"up","cretDate":"cretDate"] as [String : Any])
            self.folderArray.append(upFolder)
        }
        
        print("param : \(param)")
        GetListFromServer().showInsideFoldrList(params: param, deviceName:deviceName){ responseObject, error in
            let json = JSON(responseObject!)
            if(json["listData"].exists()){
                let serverList:[AnyObject] = json["listData"].arrayObject as! [AnyObject]
                print("insideList \(serverList)" )
                for list in serverList{
                    let folder = App.FolderStruct(data: (list as AnyObject) as! [String : Any])
                    self.folderArray.append(folder)
                }
            }
            self.currentFolderId = foldrId
            self.tableView.reloadData()
        }
        
        
    }
    
    func sendNasToNas(params:[String:Any]){
        activityIndicator.startAnimating()
        self.showHalfBlackView()
        ContextMenuWork().fromNasToNas(parameters: params){ responseObject, error in
            if let obj = responseObject {
                let json = JSON(obj)
                let message = json["message"].string
                if let statusCode = json["statusCode"].int, statusCode == 100 {
                    if(self.storageState == .nas){
                        DispatchQueue.main.async {
                            let alertController = UIAlertController(title: nil, message: "NAS로 내보내기 성공", preferredStyle: .alert)
                            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                                UIAlertAction in
                                //Do you Success button Stuff here
                                self.activityIndicator.stopAnimating()
                                Util().dismissFromLeft(vc: self)
                            }
                            alertController.addAction(yesAction)
                            self.present(alertController, animated: true)
                        }
                    } else if (self.storageState == .nas_multi) {
                        let lastIndex = self.multiCheckedfolderArray.count - 1
                        self.multiCheckedfolderArray.remove(at: lastIndex)
                        self.startMultiFolderNasToNas()
                    }  else if (self.storageState == .multi_nas_multi){
                        let lastIndex = self.multiCheckedfolderArray.count - 1
                        self.multiCheckedfolderArray.remove(at: lastIndex)
                        self.startMultiLatelyToNas()
                    }
                    
                } else {
                    let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        //Do you Success button Stuff here
                        self.activityIndicator.stopAnimating()
                        Util().dismissFromLeft(vc: self)
                    }
                    alertController.addAction(yesAction)
                    self.present(alertController, animated: true)
                }
            }
            
            
            return
        }
    }
    func sendShareNasToNas(params:[String:Any]){
        activityIndicator.startAnimating()
        ContextMenuWork().fromNasToStorage(parameters: params){ responseObject, error in
            let json = JSON(responseObject)
            let message = json["message"].string
            if let statusCode = json["statusCode"].int, statusCode == 100 {
                
                if(self.storageState == .nas){
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: nil, message: "NAS로 내보내기 성공", preferredStyle: .alert)
                        let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                            UIAlertAction in
                            //Do you Success button Stuff here
                            self.activityIndicator.stopAnimating()
                            Util().dismissFromLeft(vc: self)
                        }
                        alertController.addAction(yesAction)
                        self.present(alertController, animated: true)
                        
                    }
                } else if(self.storageState == .nas_multi) {
                    let lastIndex = self.multiCheckedfolderArray.count - 1
                    self.multiCheckedfolderArray.remove(at: lastIndex)
                    self.startMultiFolderNasToNas()
                } else if (self.storageState == .multi_nas_multi){
                    let lastIndex = self.multiCheckedfolderArray.count - 1
                    self.multiCheckedfolderArray.remove(at: lastIndex)
                    self.startMultiLatelyToNas()
                }
                
            } else {
                print(error?.localizedDescription as Any)
                let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    //Do you Success button Stuff here
                    self.activityIndicator.stopAnimating()
                    Util().dismissFromLeft(vc: self)
                    
                }
                alertController.addAction(yesAction)
                self.present(alertController, animated: true)
            }
            
            return
        }
    }

    
    
    func sendNasToShareNas(params:[String:Any]){
        activityIndicator.startAnimating()
        ContextMenuWork().fromNasToStorage(parameters: params){ responseObject, error in
            let json = JSON(responseObject)
            let message = json["message"].string
            if let statusCode = json["statusCode"].int, statusCode == 100 {
                if(self.storageState == .nas){
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: nil, message: "NAS로 내보내기 성공", preferredStyle: .alert)
                        let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                            UIAlertAction in
                            //Do you Success button Stuff here
                            self.activityIndicator.stopAnimating()
                            Util().dismissFromLeft(vc: self)
                            
                        }
                        alertController.addAction(yesAction)
                        self.present(alertController, animated: true)
                        
                    }
                } else if(self.storageState == .nas_multi) {
                    let lastIndex = self.multiCheckedfolderArray.count - 1
                    self.multiCheckedfolderArray.remove(at: lastIndex)
                    self.startMultiFolderNasToNas()
                } else if (self.storageState == .multi_nas_multi){
                    let lastIndex = self.multiCheckedfolderArray.count - 1
                    self.multiCheckedfolderArray.remove(at: lastIndex)
                    self.startMultiLatelyToNas()
                }
                
            } else {
                print(error?.localizedDescription as Any)
                let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    //Do you Success button Stuff here
                    self.activityIndicator.stopAnimating()
                    Util().dismissFromLeft(vc: self)
                    
                }
                alertController.addAction(yesAction)
                self.present(alertController, animated: true)
            }
            
            return
        }
    }
    
    func copyNasFolder(params:[String:Any]){
        activityIndicator.startAnimating()
        ContextMenuWork().copyNasFolder(parameters: params){ responseObject, error in
            let json = JSON(responseObject)
            let message = responseObject?.object(forKey: "message") as? String
            print("\(message), \(String(describing: json["statusCode"].int))")
            if let statusCode = json["statusCode"].int, statusCode == 100 {
                if(self.storageState == .nas){
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                        let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                            UIAlertAction in
                            //Do you Success button Stuff here
                            self.activityIndicator.stopAnimating()
                            Util().dismissFromLeft(vc: self)
                        }
                        alertController.addAction(yesAction)
                        self.present(alertController, animated: true)
                    }
                } else if(self.storageState == .nas_multi) {
                    let lastIndex = self.multiCheckedfolderArray.count - 1
                    self.multiCheckedfolderArray.remove(at: lastIndex)
                    self.startMultiFolderNasToNas()
                }
                
            } else {
                print(error?.localizedDescription as Any)
            }
            
            return
        }
    }
    
    func copyShareNasFolder(params:[String:Any]){
        activityIndicator.startAnimating()
        ContextMenuWork().copyShareNasFolder(parameters: params){ responseObject, error in
            let json = JSON(responseObject)
            let message = responseObject?.object(forKey: "message") as? String
            print("\(message), \(String(describing: json["statusCode"].int))")
            if let statusCode = json["statusCode"].int, statusCode == 100 {
                
                if(self.storageState == .nas){
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                        let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                            UIAlertAction in
                            //Do you Success button Stuff here
                            self.activityIndicator.stopAnimating()
                            Util().dismissFromLeft(vc: self)
                            
                        }
                        alertController.addAction(yesAction)
                        self.present(alertController, animated: true)
                        
                    }
                } else if(self.storageState == .nas_multi) {
                    let lastIndex = self.multiCheckedfolderArray.count - 1
                    self.multiCheckedfolderArray.remove(at: lastIndex)
                    self.startMultiFolderNasToNas()
                }
                
            } else {
                print(error?.localizedDescription as Any)
            }
            
            return
        }
    }
    
    
    @objc func callSendToNasFromLocal(fileDict:NSNotification){
        print("callSendToNasFromLocal")
        let fileUrl:URL = FileUtil().getFileUrl(fileNm: originalFileName, amdDate: amdDate)!
        sendToNasFromLocal(url: fileUrl, name: originalFileName, toOsCd:toOsCd, fileId: originalFileId)
    }
    
    func sendToNasFromLocal(url:URL, name:String, toOsCd:String, fileId:String){
        
        self.showHalfBlackView()
        let userId:String = toUserId
        let password:String = UserDefaults.standard.string(forKey: "userPassword")!
        
        
        print("loginUserId : \(String(describing: loginUserId!))")
        let credentialData = "\(App.nasFoldrFrontNm)\(String(describing: loginUserId!)):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        
        let decodedData = Data(base64Encoded: base64Credentials)!
        let decodedString = String(data: decodedData, encoding: .utf8)!
        print("decodedString : \(decodedString)")
        
        var headers = [
            "Authorization": "Basic \(base64Credentials)",
            "x-isi-ifs-target-type":"object"
            
        ]
        if(toOsCd != "G"){
            headers = [
                "Authorization": "Basic \(base64Credentials)",
                "x-isi-ifs-target-type":"object",
                "x-isi-ifs-access-control":"770"
                
            ]
        }
        print("headers : \(headers)")
        var stringUrl = "\(App.URL.nasServer)\(App.nasFoldrFrontNm)\(userId)/\(userId)-gs\(newFoldrWholePathNm)/\(name)?overwrite=true"
        stringUrl =  stringUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print("stringUrl : \(stringUrl)" )
        
        let filePath = url.path
        let fileExtension = url.pathExtension
        print("fileExtension : \(fileExtension)")
        print("file path : \(filePath)")
        
        
        //되는 거
        print("fileId : \(fileId)")
        do {
            var fileSize = 0.0
            do {
                let attribute = try FileManager.default.attributesOfItem(atPath: filePath)
                if let size = attribute[FileAttributeKey.size] as? NSNumber {
                    fileSize =  size.doubleValue / 1000000.0
                }
            } catch {
                print("Error: \(error)")
            }
            print("FILE Yes AVAILABLE")
            print("stream upload, fileSize : \(fileSize)")
            
            let stream:InputStream = InputStream(url: url)!
            let newName = name.precomposedStringWithCanonicalMapping
            Alamofire.upload(multipartFormData: { multipartFormData in
                //                    multipartFormData.append(url, withName: encodedSavedFileName)
                multipartFormData.append(stream, withLength: UInt64(fileSize), name: "file", fileName: newName, mimeType: fileExtension)
                
            }, usingThreshold: UInt64.init(), to: stringUrl, method: .put, headers: headers,
               encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    self.request = upload.responseJSON { response in
                        let statusCode = (response.response?.statusCode)! //example : 200
                        if(statusCode == 200) {
                            self.notifyNasUploadFinish(name: newName, toOsCd:toOsCd, fileId:fileId)
                        }
                    }
                    break
                case .failure(let encodingError):
                    print(encodingError.localizedDescription)
                    self.activityIndicator.stopAnimating()
                    break
                }
            })
        } catch {
            print("Unable to load data: \(error)")
            self.activityIndicator.stopAnimating()
        }
        
        //        Alamofire.upload(url, to: stringUrl, method: .put, headers: headers)
        //            .uploadProgress { progress in // main queue by default
        //                print("Upload Progress: \(progress.fractionCompleted)")
        //
        //            }
        //            .downloadProgress { progress in // main queue by default
        ////                print("Download Progress: \(progress.fractionCompleted)")
        //            }
        //            .responseString { response in
        //                print("Success: \(response.result.isSuccess)")
        //                print("Response String: \(response)")
        //                if let alamoError = response.result.error {
        //                    let alamoCode = alamoError._code
        //                    let statusCode = (response.response?.statusCode)!
        //                } else { //no errors
        //                    let statusCode = (response.response?.statusCode)! //example : 200
        //                    print("statusCode : \(statusCode)")
        //                    if(statusCode == 200) {
        //                        self.notifyNasUploadFinish(name: name, toOsCd:toOsCd, fileId:fileId)
        //                    }
        //                }
        //        }
    }
    
    
    
    func notifyNasUploadFinish(name:String, toOsCd:String, fileId:String){
        let urlString = App.URL.hostIpServer+"nasUpldCmplt.do"
        
        
        let paramas:[String : Any] = ["userId":toUserId,"fileId":fileId,"toFoldr":newFoldrWholePathNm,"toFileNm":name,"toOsCd":toOsCd]
        print("notifyNasUploadFinish param : \(paramas)")
        Alamofire.request(urlString,
                          method: .post,
                          parameters: paramas,
                          encoding : JSONEncoding.default,
                          headers: jsonHeader).responseJSON { response in
                            switch response.result {
                            case .success(let JSON):
                                
                                print(response.result.value)
                                let responseData = JSON as! NSDictionary
                                let message = responseData.object(forKey: "message")
                                print("message : \(message)")
                                if(self.storageState == .remote_nas_multi) {
                                    self.countRemoteDownloadFinished()
                                } else if self.storageState == .local_nas_multi {
                                    
                                    let lastIndex = self.multiCheckedfolderArray.count - 1
                                    self.multiCheckedfolderArray.remove(at: lastIndex)
//                                    self.start()
                                    
                                } else if self.storageState == .multi_nas_multi {
                                    
                                    let lastIndex = self.multiCheckedfolderArray.count - 1
                                    self.multiCheckedfolderArray.remove(at: lastIndex)
                                    self.startMultiLatelyToNas()
                                } else if self.storageState == .gdrive_nas_multi {
                                    let lastIndex = self.gDriveMultiCheckedfolderArray.count - 1
                                    self.gDriveMultiCheckedfolderArray.remove(at: lastIndex)
                                    self.startMultiGdriveToNas()
                                } else {
                                    // 보내기용 다운 파일 삭제
                                    if(self.storageState == .nas && self.fromOsCd != "S" && self.fromOsCd != "G" && self.fromOsCd == "gDrive") {
                                        let pathForRemove:String = FileUtil().getFilePath(fileNm: "tmp", amdDate: "amdDate")
                                        print("pathForRemove : \(pathForRemove)")
                                        if(pathForRemove.isEmpty){
                                            
                                        } else {
                                            FileUtil().removeFile(path: pathForRemove)
                                        }
                                    }
                                    DispatchQueue.main.async {
                                        let alertController = UIAlertController(title: nil, message: "NAS로 내보내기 성공", preferredStyle: .alert)
                                        let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                                            UIAlertAction in
                                            //Do you Success button Stuff here
                                            Util().dismissFromLeft(vc: self)
                                        }
                                        alertController.addAction(yesAction)
                                        self.present(alertController, animated: true)
                                        
                                    }
                                }
                                
                                break
                            case .failure(let error):
                                
                                print(error.localizedDescription)
                            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        DispatchQueue.main.async {
            print("btnBackClicked called")
            Util().dismissFromLeft(vc: self)
        }
        
    }
    
    @objc func NasSendFolderSelectVCToggleIndicator(){
        if(indicatorAnimating){
            activityIndicator.stopAnimating()
            indicatorAnimating = false
        } else {
            activityIndicator.startAnimating()
            indicatorAnimating = true
        }
    }
    
    func NasSendFolderSelectVCAlert(title:String){
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: nil, message: title, preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                //Do you Success button Stuff here
                SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
                
                Util().dismissFromLeft(vc: self)
            }
            alertController.addAction(yesAction)
            self.present(alertController, animated: true)
            
        }
    }
    
    
    func remoteDownloadRequest(fromUserId:String, fromDevUuid:String, fromOsCd:String, fromFoldr:String, fromFileNm:String, fromFileId:String){
        activityIndicator.startAnimating()
        let urlString = App.URL.hostIpServer+"reqFileDown.do"
        let comnd = "R\(fromOsCd)L\(toOsCd)"
        print("comnd : \(comnd)")
        
        let paramas = ["fromUserId":fromUserId,"fromDevUuid":fromDevUuid,"fromOsCd":fromOsCd,"fromFoldr":oldFoldrWholePathNm,"fromFileNm":fromFileNm,"fromFileId":fromFileId,"toUserId":toUserId,"toDevUuid":currentDevUuId,"toOsCd":toOsCd,"toFoldr":newFoldrWholePathNm,"toFileNm":fromFileNm,"comndOsCd":"I","comndDevUuid":Util.getUuid(),"comnd":comnd]
        
        
        print("param : \(paramas)")
        Alamofire.request(urlString,
                          method: .post,
                          parameters: paramas,
                          encoding : JSONEncoding.default,
                          headers: jsonHeader).responseJSON { response in
                            switch response.result {
                            case .success(let responseObject):
                                print(response.result.value)
                                
                                let json = JSON(responseObject)
                                let message = json["message"].string
                                let statusCode = json["statusCode"].int
                                
                                if statusCode == 100 {
                                    let data = json["data"]
                                    let queId = String(describing: data["queId"])
                                    
                                    print("json : \(json)")
                                    print("remoteDownloadRequest : \(message), queId: \(queId), data: \(data)")
                                    
                                    if self.storageState == .multi_nas_multi {
                                        let lastIndex = self.multiCheckedfolderArray.count - 1
                                        self.multiCheckedfolderArray.remove(at: lastIndex)
                                        self.startMultiLatelyToNas()
                                    } else {
                                        DispatchQueue.main.async {
                                            let alertController = UIAlertController(title: nil, message: "NAS 보내기 요청 성공", preferredStyle: .alert)
                                            let yesAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                                                UIAlertAction in
                                                
                                                Util().dismissFromLeft(vc: self)
                                            }
                                            alertController.addAction(yesAction)
                                            self.present(alertController, animated: true, completion: nil)
                                        }
                                    }
                                } else {
                                    let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                                    let yesAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                                        UIAlertAction in
                                        
                                        Util().dismissFromLeft(vc: self)
                                    }
                                    alertController.addAction(yesAction)
                                    self.present(alertController, animated: true, completion: nil)
                                }
                                
                                break
                            case .failure(let error):
                                print(error.localizedDescription)
                                let alertController = UIAlertController(title: nil, message: "요청처리에 실패하였습니다.", preferredStyle: .alert)
                                let yesAction = UIKit.UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                                    UIAlertAction in
                                    
                                    Util().dismissFromLeft(vc: self)
                                }
                                alertController.addAction(yesAction)
                                self.present(alertController, animated: true, completion: nil)
                            }
        }
    }
    

    
    
    
    @objc func downloadFromRemoteToNas(fileDict:NSNotification){
        if let getFromUserId = fileDict.userInfo?["fromUserId"] as? String, let getFromFileId = fileDict.userInfo?["fromFileId"] as? String, let getFromFoldr = fileDict.userInfo?["fromFoldr"] as? String, let getFromFileNm = fileDict.userInfo?["fromFileNm"] as? String, let getFromDevUuid = fileDict.userInfo?["fromDevUuid"] as? String{
            
            let path = "\(getFromDevUuid)\(getFromFoldr)"
            originalFileId = getFromFileId
            print("getFromFileId : \(getFromFileId)")
            
            self.downloadFromRemoteToSend(userId: getFromUserId, name: getFromFileNm, path: path, fileId: getFromFileId)
        }
    }
    
    
    func downloadFromRemoteToSend(userId:String, name:String, path:String, fileId:String){
        ContextMenuWork().downloadFromRemoteToSend(userId:userId, fileNm:name, path:path, fileId:fileId){ responseObject, error in
            if let success = responseObject {
                print(success)
                if(!success.isEmpty){
                    let fileUrl:URL = URL(string: success)!
                    self.sendToNasFromLocal(url: fileUrl, name: name, toOsCd:self.toOsCd, fileId:fileId)
                    
                    
                }
            }
            return
        }
    }
    
    
    
    func countRemoteDownloadFinished(){
        
        remoteMultiFileDownloadedCount -= 1
        print("remoteMultiFileToNasdCount : \(remoteMultiFileDownloadedCount)")
        if(remoteMultiFileDownloadedCount > 0){
            return
        }
        print("countRemoteToNasFinished")
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: nil, message: "NAS로 내보내기 성공", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                SyncLocalFilleToNas().sync(view: "", getFoldrId: "")
                
                //Do you Success button Stuff here
                Util().dismissFromLeft(vc: self)
            }
            alertController.addAction(yesAction)
            self.present(alertController, animated: true)
            
        }
        
    }
    func showHalfBlackView(){
        view.addSubview(self.halfBlackView)
        halfBlackView.alpha = 0.3
        halfBlackView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        halfBlackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        halfBlackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        halfBlackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(finishLoading))
        tapGesture.cancelsTouchesInView = false
        halfBlackView.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func finishLoading(){
        
        if(self.activityIndicator.isAnimating){
            self.activityIndicator.stopAnimating()
        }
        halfBlackView.removeGestureRecognizer(tapGesture)
        self.halfBlackView.removeFromSuperview()
        //        request?.cancel()
        //
        //        let alertController = UIAlertController(title: "작업이 취소되었습니다.",message: "", preferredStyle: UIAlertControllerStyle.alert)
        //        let okAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default){ (action: UIAlertAction) in
        //
        //        }
        //        alertController.addAction(okAction)
        //        self.present(alertController,animated: true,completion: nil)
        
    }
    func alamofireCompleted(){
        halfBlackView.removeGestureRecognizer(tapGesture)
        self.halfBlackView.removeFromSuperview()
        //        request?.cancel()
    }
}
