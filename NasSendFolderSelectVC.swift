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

class NasSendFolderSelectVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var nasArray = ["GIGA NAS", "GIGA Storage"]
    var nasDevIdArray:[String] = []
    var nasUserIdArray:[String] = []
    var deviceImageArray =  ["ico_device_giganas_on", "ico_device_giganas_share_on"]
    
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
    
    var toUserId = ""
    var fromUserId = ""
    var currentDevUuId = ""
    var fromOsCd = ""
    var googleDriveFileIdPath = ""
    var amdDate = ""
    enum storageKind:String {
        case nas = "nas"
        case googleDrive = "googleDrive"
        case local = "local"
    }
    var storageState = storageKind.nas
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch storageState {
        case .nas:
            nasDevId = UserDefaults.standard.string(forKey: "nasDevId")!
            storageDevId = UserDefaults.standard.string(forKey: "storageDevId")!
            
            nasDevIdArray.append(nasDevId)
            nasDevIdArray.append(storageDevId)
            
            let nasUserId:String = UserDefaults.standard.string(forKey: "nasUserId")!
            let storageUserId:String = UserDefaults.standard.string(forKey: "storageUserId")!
            nasUserIdArray.append(nasUserId)
            nasUserIdArray.append(storageUserId)
            nasArray = ["GIGA NAS", "GIGA Storage"]
            break
            
        case .local :
            nasDevId = UserDefaults.standard.string(forKey: "nasDevId")!
            storageDevId = UserDefaults.standard.string(forKey: "storageDevId")!
            
            nasDevIdArray.append(nasDevId)
            nasDevIdArray.append(storageDevId)
            
            let nasUserId:String = UserDefaults.standard.string(forKey: "nasUserId")!
            let storageUserId:String = UserDefaults.standard.string(forKey: "storageUserId")!
            nasUserIdArray.append(nasUserId)
            nasUserIdArray.append(storageUserId)
            nasArray = ["GIGA NAS", "GIGA Storage"]
            print("local")
            break
        default:
            nasArray = ["내 드라이브"]
            break
        }
        
        
        print("originalFileId : \(originalFileId), oldFoldrWholePathNm: \(oldFoldrWholePathNm)")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        tableView.register(SendFolderSelectCell.self, forCellReuseIdentifier: "SendFolderSelectCell")
        tableView.reloadData()
        tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = nasArray.count
        
        if(storageState == .nas || storageState == .local){
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
        } else {
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
        }
        
        
        return count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SendFolderSelectCell") as! SendFolderSelectCell
        switch storageState {
        case .nas:
            switch listState {
                case .deviceSelect:
                    let imageString = deviceImageArray[indexPath.row]
                    cell.ivIcon.image = UIImage(named: imageString)
                    cell.lblMain.text = nasArray[indexPath.row]
                    cell.checkButton.isHidden = true
                    
                    break
                case .deviceRoot:
                    cell.ivIcon.image = UIImage(named: "ico_folder")
                    cell.lblMain.text = folderNameArray[indexPath.row]
                    cell.checkButton.isHidden = false
//                    if(indexPath.row == 0){
//                        cell.checkButton.isHidden = false
//                    }
                    cell.checkButton.isHidden = false
                    cell.checkButton.tag = indexPath.row
                    cell.checkButton.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                    cell.checkButton.addTarget(self, action: #selector(btnChekced(sender:)), for: .touchUpInside)
                    break
                case .folder:
                    cell.ivIcon.image = UIImage(named: "ico_folder")
                    cell.lblMain.text = folderArray[indexPath.row].foldrNm
                    cell.checkButton.isHidden = false
                    if(indexPath.row == 0){
                        cell.checkButton.isHidden = true
                    }
                    cell.checkButton.tag = indexPath.row
                    cell.btnChecked = 0
                    cell.checkButton.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                    cell.checkButton.addTarget(self, action: #selector(btnChekced(sender:)), for: .touchUpInside)
                    break
            }
            break
            
        case .local:
            switch listState {
            case .deviceSelect:
                let imageString = deviceImageArray[indexPath.row]
                cell.ivIcon.image = UIImage(named: imageString)
                cell.lblMain.text = nasArray[indexPath.row]
                cell.checkButton.isHidden = true
                
                break
            case .deviceRoot:
                cell.ivIcon.image = UIImage(named: "ico_folder")
                cell.lblMain.text = folderNameArray[indexPath.row]
                cell.checkButton.isHidden = false
                if(indexPath.row == 0){
                    cell.checkButton.isHidden = true
                }
                cell.checkButton.isHidden = false
                cell.checkButton.tag = indexPath.row
                cell.checkButton.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                cell.checkButton.addTarget(self, action: #selector(btnChekced(sender:)), for: .touchUpInside)
                break
            case .folder:
                cell.ivIcon.image = UIImage(named: "ico_folder")
                cell.lblMain.text = folderArray[indexPath.row].foldrNm
                cell.checkButton.isHidden = false
                if(indexPath.row == 0){
                    cell.checkButton.isHidden = true
                }
                cell.checkButton.tag = indexPath.row
                cell.btnChecked = 0
                cell.checkButton.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                cell.checkButton.addTarget(self, action: #selector(btnChekced(sender:)), for: .touchUpInside)
                break
            }
            break
            
        default:
            switch listState {
            case .deviceSelect:
                cell.ivIcon.image = UIImage(named: "ico_folder")
                cell.lblMain.text = nasArray[indexPath.row]
                cell.checkButton.isHidden = false
                cell.checkButton.tag = indexPath.row
                cell.checkButton.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                cell.checkButton.addTarget(self, action: #selector(btnChekced(sender:)), for: .touchUpInside)
                
                break
            default:
                cell.ivIcon.image = UIImage(named: "ico_folder")
                cell.lblMain.text = driveFileArray[indexPath.row].name
                cell.checkButton.isHidden = false
                if(indexPath.row == 0){
                    cell.checkButton.isHidden = true
                }
                cell.checkButton.tag = indexPath.row
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
        let indexPath = IndexPath(row: buttonRow, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! SendFolderSelectCell
        switch storageState {
        case .nas:
            switch listState {
            case .deviceRoot:
                newFoldrId = String(folderIdArray[sender.tag])
                newFoldrWholePathNm = folderPathArray[sender.tag]
                print("newId : \(newFoldrId), newPath : \(newFoldrWholePathNm)")
                if(cell.btnChecked == 0){
                    for index in 0..<folderIdArray.count{
                        let indexPath = IndexPath(row: index, section: 0)
                        let removeCheckCell = tableView.cellForRow(at: indexPath) as! SendFolderSelectCell
                        removeCheckCell.btnChecked = 0
                        removeCheckCell.checkButton.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
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
                        let removeCheckCell = tableView.cellForRow(at: indexPath) as! SendFolderSelectCell
                        removeCheckCell.btnChecked = 0
                        removeCheckCell.checkButton.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                    }
                    sender.setImage(#imageLiteral(resourceName: "ico_24dp_done").withRenderingMode(.alwaysOriginal), for: .normal)
                    cell.btnChecked = 1
                    folderChecked = 1
                } else {
                    sender.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                    cell.btnChecked = 0
                    folderChecked = 0
                }
                
                
            }
            break
        case .local :
            switch listState {
            case .deviceRoot:
                newFoldrId = String(folderIdArray[sender.tag])
                newFoldrWholePathNm = folderPathArray[sender.tag]
                print("newId : \(newFoldrId), newPath : \(newFoldrWholePathNm)")
                if(cell.btnChecked == 0){
                    for index in 0..<folderIdArray.count{
                        let indexPath = IndexPath(row: index, section: 0)
                        let removeCheckCell = tableView.dequeueReusableCell(withIdentifier: "SendFolderSelectCell", for: indexPath) as! SendFolderSelectCell
                        removeCheckCell.btnChecked = 0
                        removeCheckCell.checkButton.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
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
                        let removeCheckCell = tableView.dequeueReusableCell(withIdentifier: "SendFolderSelectCell", for: indexPath) as! SendFolderSelectCell
                            removeCheckCell.btnChecked = 0
                            removeCheckCell.checkButton.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                    }
                    sender.setImage(#imageLiteral(resourceName: "ico_24dp_done").withRenderingMode(.alwaysOriginal), for: .normal)
                    cell.btnChecked = 1
                    folderChecked = 1
                } else {
                    sender.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                    cell.btnChecked = 0
                    folderChecked = 0
                }
                
                
            }
            break
           
        case .googleDrive:
            switch listState {
            case .deviceSelect :
                googleDriveFileIdPath = ""
                if(cell.btnChecked == 0){
                    for index in 0..<nasArray.count{
                        let indexPath = IndexPath(row: index, section: 0)
                        let removeCheckCell = tableView.cellForRow(at: indexPath) as! SendFolderSelectCell
                        removeCheckCell.btnChecked = 0
                        removeCheckCell.checkButton.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
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
                if(cell.btnChecked == 0){
                    for index in 0..<driveFileArray.count{
                        let indexPath = IndexPath(row: index, section: 0)
                        let removeCheckCell = tableView.cellForRow(at: indexPath) as! SendFolderSelectCell
                        removeCheckCell.btnChecked = 0
                        removeCheckCell.checkButton.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                    }
                    sender.setImage(#imageLiteral(resourceName: "ico_24dp_done").withRenderingMode(.alwaysOriginal), for: .normal)
                    cell.btnChecked = 1
                    folderChecked = 1
                } else {
                    sender.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
                    cell.btnChecked = 0
                    folderChecked = 0
                }
                
                
            }
            break
        }
       
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch storageState {
        case .nas:
            switch listState {
            case .deviceSelect:
                self.listState = .deviceRoot
                self.deviceName = nasArray[indexPath.row]
                toUserId = nasUserIdArray[indexPath.row]
                currentDevUuId = nasDevIdArray[indexPath.row]
                print("currentDevUuId : \(currentDevUuId)")
                
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
                if(folderArray[indexPath.row].foldrNm == "..."){
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
        case .local :
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
                if(folderArray[indexPath.row].foldrNm == "..."){
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
        case .googleDrive:
            let accessToken:String = GIDSignIn.sharedInstance().currentUser.authentication.accessToken
            switch listState {
            case .deviceSelect:
                self.listState = .deviceRoot
                self.deviceName = nasArray[indexPath.row]
                self.getFilesFromGoogleDrive(accessToken: accessToken, root: "root")
                break
            default:
                 var root = "root"
                if(indexPath.row == 0){
                    root = "root"
                    self.listState = .deviceSelect
                } else {
                    root = driveFileArray[indexPath.row].fileId
                    
                }
                
                
                self.getFilesFromGoogleDrive(accessToken: accessToken, root: root)
                break
            }

            break
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    @IBAction func selectFinish(_ sender: UIButton) {
        if(folderChecked == 1){
            switch storageState {
            case .nas:
                if(fromOsCd == "G"){
                    print("deviceName : \(deviceName)")
                    if(toUserId != App.defaults.userId){
                        let param = ["userId":fromUserId,"toUserId":toUserId,"devUuid":currentDevUuId,"fileId":originalFileId,"fileNm":originalFileName, "foldrId":newFoldrId,"foldrWholePathNm":newFoldrWholePathNm,"oldfoldrWholePathNm":oldFoldrWholePathNm,"osCd":"G","toOsCd":"S"]
                        print("from g to s param : \(param)")
                        self.sendNasToStorage(params: param)
                        
                    } else {
                        let param = ["userId":toUserId, "devUuid": currentDevUuId,"fileId":originalFileId,"fileNm":originalFileName,"foldrId":newFoldrId,"foldrWholePathNm":newFoldrWholePathNm,"oldfoldrWholePathNm":oldFoldrWholePathNm]
                        print("from s to s param : \(param), \(deviceName)")
                        self.sendNasToNas(params: param)
                    }
                    
                } else{
                    if(toUserId != App.defaults.userId){
                        let param = ["userId":fromUserId,"toUserId":toUserId,"devUuid":currentDevUuId,"fileId":originalFileId,"fileNm":originalFileName, "foldrId":newFoldrId,"foldrWholePathNm":newFoldrWholePathNm,"oldfoldrWholePathNm":oldFoldrWholePathNm,"osCd":"S","toOsCd":"S"]
                        print("param : \(param)")
                        //shared to shared
                        self.sendStorageToNas(params: param)
                    } else {
                        let param = ["userId":fromUserId,"toUserId":toUserId,"devUuid":currentDevUuId,"fileId":originalFileId,"fileNm":originalFileName, "foldrId":newFoldrId,"foldrWholePathNm":newFoldrWholePathNm,"oldfoldrWholePathNm":oldFoldrWholePathNm,"osCd":"S","toOsCd":"G"]
                        print("param : \(param) to G")
                        self.sendStorageToNas(params: param)
                    }
                }
                
                break
                
            case .local:
                let param = ["userId":fromUserId,"toUserId":toUserId,"devUuid":currentDevUuId,"fileId":originalFileId,"fileNm":originalFileName, "foldrId":newFoldrId,"foldrWholePathNm":newFoldrWholePathNm,"oldfoldrWholePathNm":oldFoldrWholePathNm,"osCd":"I","toOsCd":"G"]
                print("param : \(param)")
                let fileUrl:URL = FileUtil().getFileUrl(fileNm: originalFileName, amdDate: amdDate)
                sendToNasFromLocal(url: fileUrl, name: originalFileName)
                
                break
                
                
            case .googleDrive:
                print("googleDriveFileIdPath : \(googleDriveFileIdPath)")
                    self.downloadFromNasToDrive(name: originalFileName, path: oldFoldrWholePathNm, fileId: googleDriveFileIdPath)
                break
            }
                
           
            
        }
    }
   
    
    
    func downloadFromNasToDrive(name:String, path:String, fileId:String){
        ContextMenuWork().downloadFromNasToSend(userId:fromUserId, fileNm:name, path:path){ responseObject, error in
            if let success = responseObject {
                if(success.isEmpty){
                } else {
                    print("localUrl : \(success)")
                    let fileURL:URL = URL(string: success)!
                    var fileSize:Double = 0
                    do {
                        let attribute = try FileManager.default.attributesOfItem(atPath: (fileURL.path))
                        if let size = attribute[FileAttributeKey.size] as? NSNumber {
                            fileSize = size.doubleValue
                            print("fileSzie : \(fileSize)")
                        }
                    } catch {
                        print("Error: \(error)")
                    }
                    let accessToken = UserDefaults.standard.string(forKey: "accessToken")!
                    let stringUrl = "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart"
                    let headers = [
                        "Authorization": "Bearer \(accessToken)",
                        "Content-type": "multipart/related; boundary=foo_bar_baz",
                        "Content-Length": "\(fileSize)"
                    ]
                    var addParents = ""
                    if (fileId.isEmpty){
                        
                    } else {
                        addParents = ",'parents' : [ '\(fileId)' ]"
                    }
                    do {
                        let data = try Data(contentsOf: fileURL as URL)
                        Alamofire.upload(multipartFormData: { multipartFormData in
                            multipartFormData.append("{'name':'\(name)'\(addParents) }".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName :"foo_bar_baz", mimeType: "application/json; charset=UTF-8")
                            
                            multipartFormData.append(data, withName: "foo_bar_baz", fileName: name, mimeType: "image/jpeg")
                            
                        }, usingThreshold: UInt64.init(), to: stringUrl, method: .post, headers: headers,
                           encodingCompletion: { encodingResult in
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.responseJSON { response in
                                    print("response:: \(response)")
                                    let fileManager = FileManager.default
                                    do {
                                        try fileManager.removeItem(atPath: fileURL.path)
                                        let alertController = UIAlertController(title: nil, message: "파일 업로드에 성공 하였습니다.", preferredStyle: .alert)
                                        let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel)  {
                                            UIAlertAction in
                                            Util().dismissFromLeft(vc: self)
                                        }
                                        alertController.addAction(yesAction)
                                        self.present(alertController, animated: true)
                                    }
                                    catch let error as NSError {
                                        print("Ooops! Something went wrong: \(error)")
                                    }
                                    
                                }
                                break
                            case .failure(let encodingError):
                                print(encodingError.localizedDescription)
                                break
                            }
                        })
                    } catch {
                        print("Unable to load data: \(error)")
                    }
                    //
                    //
                    
                    
                }
                
            }
            return
        }
    }
    func getFilesFromGoogleDrive(accessToken:String, root:String){
        self.driveFileArray.removeAll()
        var upFolder = App.DriveFileStruct(fileId: "root", kind: "d", mimeType: "d", name: "...")
        self.driveFileArray.append(upFolder)
        
        var url = "https://www.googleapis.com/drive/v3/files?q='\(root)' in parents and trashed=false and mimeType='application/vnd.google-apps.folder'&access_token=\(accessToken)"
        url = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        Alamofire.request(url,
                          method: .get,
            encoding: JSONEncoding.default,
            headers: nil).responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("json : \(json)")
                    let responseData = value as! NSDictionary
                    if(json["files"].exists()){
                        let serverList:[AnyObject] = json["files"].arrayObject as! [AnyObject]
                        if (serverList.count > 0) {
                            for file in serverList {
                                print("file : \(file)")
                                let fileStruct = App.DriveFileStruct(device: file)
                                self.driveFileArray.append(fileStruct)
                            }
                            self.tableView.reloadData()
                        } else {
                            DispatchQueue.main.async {
                                let alertController = UIAlertController(title: nil, message: "더 이상 하위폴더가 없습니다.", preferredStyle: .alert)
                                let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel)
                                alertController.addAction(yesAction)
                                self.present(alertController, animated: true)
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
            let json = JSON(responseObject!)
          
            
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
            
            return
        }
    }
    
    
    func showInsideList(userId: String, devUuid: String, foldrId: String, deviceName:String){
        self.listState = .folder
        self.folderArray.removeAll()
        var param = ["userId": userId, "devUuid":devUuid, "foldrId":foldrId,"sortBy":sortBy]
        if(folderIdArray.count > 1){
            let upFolder = App.FolderStruct(data: ["foldrNm":"...","foldrId":folderIdArray[folderIdArray.count-2],"userId":userId,"childCnt":0,"devUuid":devUuid,"foldrWholePathNm":"up","cretDate":"cretDate"] as [String : Any])
            self.folderArray.append(upFolder)
            if(folderIdArray.count == 1){
                param = ["userId": userId, "devUuid":devUuid]
            }
        } else {
            let upFolder = App.FolderStruct(data: ["foldrNm":"...","foldrId":0,"userId":userId,"childCnt":0,"devUuid":devUuid,"foldrWholePathNm":"up","cretDate":"cretDate"] as [String : Any])
            self.folderArray.append(upFolder)
        }
        
        print("param : \(param)")
        GetListFromServer().showInsideFoldrList(params: param, deviceName:deviceName){ responseObject, error in
            let json = JSON(responseObject!)
            if(json["listData"].exists()){
                let serverList:[AnyObject] = json["listData"].arrayObject as! [AnyObject]
                print("insideList \(serverList)" )
                for list in serverList{
                    let folder = App.FolderStruct(data: list as AnyObject)
                    self.folderArray.append(folder)
                }
            }
            self.currentFolderId = foldrId
            self.tableView.reloadData()
        }
        
        
    }
    
    func sendNasToNas(params:[String:Any]){
         ContextMenuWork().fromNasToNas(parameters: params){ responseObject, error in
            if let obj = responseObject {
                let json = JSON(obj)
                let message = obj.object(forKey: "message")
                print("\(message), \(json["statusCode"].int)")
                if let statusCode = json["statusCode"].int, statusCode == 100 {
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
            }
            
            
            return
        }
    }
    func sendStorageToNas(params:[String:Any]){
        ContextMenuWork().fromNasToStorage(parameters: params){ responseObject, error in
            let json = JSON(responseObject)
            let message = responseObject?.object(forKey: "message")
            print("\(message), \(json["statusCode"].int)")
            if let statusCode = json["statusCode"].int, statusCode == 100 {
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
            } else {
                print(error?.localizedDescription)
            }
            
            return
        }
    }
    
    
    func sendNasToStorage(params:[String:Any]){
        ContextMenuWork().fromNasToStorage(parameters: params){ responseObject, error in
            let json = JSON(responseObject)
            let message = responseObject?.object(forKey: "message")
            print("\(message), \(json["statusCode"].int)")
            if let statusCode = json["statusCode"].int, statusCode == 100 {
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
            } else {
                print(error?.localizedDescription)
            }
            
            return
        }
    }
    
    func sendToNasFromLocal(url:URL, name:String){
        
        let userId = App.defaults.userId
        let password = "1234"
        
        let credentialData = "gs-\(userId):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        let headers = [
            "Authorization": "Basic \(base64Credentials)",
            "x-isi-ifs-target-type":"object"
            
        ]
        var stringUrl = "https://araise.iptime.org/namespace/ifs/home/gs-\(userId)/\(userId)-gs\(newFoldrWholePathNm)/\(name)?overwrite=true"
        print("stringUrl : \(stringUrl)" )
        
        let filePath = url.path
        let fileExtension = url.pathExtension
        print("fileExtension : \(fileExtension)")
        print("file path : \(filePath)")
        
        
      //되는 거
        print("fileId : \(originalFileId)")
        Alamofire.upload(url, to: stringUrl, method: .put, headers: headers)
            .uploadProgress { progress in // main queue by default
                print("Upload Progress: \(progress.fractionCompleted)")
                
            }
            .downloadProgress { progress in // main queue by default
                print("Download Progress: \(progress.fractionCompleted)")
            }
            .responseString { response in
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response)")
                if let alamoError = response.result.error {
                    let alamoCode = alamoError._code
                    let statusCode = (response.response?.statusCode)!
                } else { //no errors
                    let statusCode = (response.response?.statusCode)! //example : 200
                    self.notifyNasUploadFinish(name: name)
                    
                }
        }
    }
    
 
    
    func notifyNasUploadFinish(name:String){
        let urlString = App.URL.server+"nasUpldCmplt.do"
        let inFileId:Int = Int(originalFileId)!
        let size = Decimal(inFileId)
        let test = pow(size, 2) - 1
        let result = NSDecimalNumber(decimal: test)
        print(Int(result)) // testing the cast to Int
        let decimalFileId:Decimal = Decimal.init(inFileId)

        let paramas:[String : Any] = ["userId":App.defaults.userId,"fileId":originalFileId,"toFoldr":newFoldrWholePathNm,"toFileNm":name]
        print("notifyNasUploadFinish param : \(paramas)")
        Alamofire.request(urlString,
                          method: .post,
                          parameters: paramas,
                          encoding : JSONEncoding.default,
                          headers: App.Headrs.jsonHeader).responseJSON { response in
                            switch response.result {
                            case .success(let JSON):
                                
                                print(response.result.value)
                                let responseData = JSON as! NSDictionary
                                let message = responseData.object(forKey: "message")
                                print("message : \(message)")
                                
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
        Util().dismissFromLeft(vc: self)
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
