//
//  DeviceContainerVCB.swift
//  KT
//
//  Created by 김영은 on 2018. 2. 21..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class DeviceContainerVCB: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var lblMenu: UILabel!
    
    @IBOutlet weak var lblInfo: UILabel!
    
    var width:CGFloat = CGFloat()
    
    let imageCheck = [
        ["osNm": "GIGA Storage",  "image": "ico_device_giganas"],
        ["osNm": "SHARE GIGA Storage",  "image": "ico_device_giganas_share"],
        ["osNm": "Windows",  "image": "ico_device_pc"],
        ["osNm": "Android",  "image": "ico_device_mobile"],
        ["osNm": "iOS",  "image": "ico_device_mobile"],
        ]
    let menuNms:[String] = ["디바이스 이름 변경","폴더 설정","디바이스 제거"]
    let infoTitle = ["이름을 변경할 디바이스를 선택하면 팝업창이 나타납니다","변경할 폴더를 선택하여 주세요.","제거할 디바이스를 선택하세요."]
    var DeviceArray:[App.DeviceStruct] = []
    var menuNum = 0
    
    var loginCookie = ""
    var loginToken = ""
    var userId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginCookie = UserDefaults.standard.string(forKey: "cookie")!
        loginToken = UserDefaults.standard.string(forKey: "token")!
        userId = UserDefaults.standard.string(forKey: "userId")!
        
        width = UIScreen.main.bounds.width
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DeviceContainerBCell.self, forCellReuseIdentifier: "DeviceContainerBCell")
        getDeviceList()
        
        print(infoTitle[menuNum])
        lblInfo.text = infoTitle[menuNum]
        lblMenu.text = menuNms[menuNum]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getDeviceList(){
        
        DeviceArray.removeAll()
        let headers = [
            "Content-Type": "application/json",
            "X-Auth-Token": self.loginToken,
            "Cookie": self.loginCookie
        ]
        //모바일 폴더 동기화 리스트
        Alamofire.request(App.URL.server+"listOneview.json"
            , method: .post
            , parameters:["userId":userId]
            , encoding : JSONEncoding.default
            , headers: headers
            ).responseJSON { response in
                
                switch response.result {
                case .success(let value):
                    print("getDeviceList sync : \(response)")
                    let json = JSON(value)
                    let responseData = value as! NSDictionary
                    let listData = responseData.object(forKey: "listData")
                    if let statusCode = json["statusCode"].int, statusCode == 100 {
                        var serverList:[AnyObject] = json["listData"].arrayObject as! [AnyObject]
                        for device in serverList {
                            let devNm = device["devNm"] as! String ?? "nil"
                            let devUuid = device["devUuid"] as! String ?? "nil"
                            let mkngVndrNm = device["mkngVndrNm"] as? String ?? "nil"
                            let onoff = device["onoff"] as! String ?? "nil"
                            let osCd = device["osCd"] as! String ?? "nil"
                            let osDesc = device["osDesc"] as? String ?? "nil"
                            let osNm = device["osNm"] as! String ?? "nil"
                            let userId = device["userId"] as! String ?? "nil"
                            let userName = device["userName"] as! String ?? "nil"
                            let deviceStruct = App.DeviceStruct(devNm : devNm , devUuid : devUuid, mkngVndrNm : mkngVndrNm, onoff : onoff, osCd : osCd, osDesc : osDesc, osNm : osNm, userId : userId, userName : userName)
                            self.DeviceArray.append(deviceStruct)
                        }
                    }
                self.tableView.reloadData()
                case .failure(let error):
                    NSLog(error.localizedDescription)
                }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DeviceArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceContainerBCell") as! DeviceContainerBCell
        
        let imageString = Util.getDeviceImageString(osNm: DeviceArray[indexPath.row].osNm, onoff: DeviceArray[indexPath.row].onoff)
        cell.ivIcon.image = UIImage(named: imageString)
        cell.lblMain.text = DeviceArray[indexPath.row].devNm
        cell.lblSub.text = DeviceArray[indexPath.row].devNm
        /*cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width:0,height: 2.0)
        cell.layer.shadowRadius = 1.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false;
        cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath*/
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("item : \(indexPath.row)")
        
        switch menuNum {
        case 0:         // 디바이스 이름변경일 때
            let alertController = UIAlertController(title: nil, message: "", preferredStyle: .alert)
            
            alertController.addTextField { (textField) in
                textField.placeholder = self.DeviceArray[indexPath.row].devNm
                textField.keyboardType = .emailAddress
            }
            
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                //Do you Success button Stuff here
                let newDevNm = alertController.textFields?[0].text
                if newDevNm == "" {
                    return
                } else {
                    self.updateDev(devNm: alertController.textFields![0].text!, uuid: self.DeviceArray[indexPath.row].devUuid)
                }
            }
            
            let noAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel, handler:nil)
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            
            self.present(alertController, animated: true)
        case 2:        // 디바이스 제거일 때
            let alertController = UIAlertController(title: nil, message: "해당 디바이스를 삭제 하시겠습니까?", preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                UIAlertAction in
                //Do you Success button Stuff here
                self.deleteDev(uuid: self.DeviceArray[indexPath.row].devUuid)
            }
            
            let noAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel, handler:nil)
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            
            self.present(alertController, animated: true)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func getImageString(osNm:String) -> String {
        let result = imageCheck.filter({ $0["osNm"] == osNm})
        print("result  \(String(describing: result[0]["image"]))")
        return result[0]["image"]!
    }
    
    func updateDev(devNm:String, uuid:String) {
        
        let url = App.URL.server + "updDevNm.do"
        let headers = [
            "Content-Type": "application/json",
            "X-Auth-Token": self.loginToken,
            "Cookie": self.loginCookie
        ]
        
        Alamofire.request(url
            , method: .post
            , parameters: ["userId":userId, "devUuid":uuid, "devNm":devNm]
            , encoding: JSONEncoding.default
            , headers: headers
            ).responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if json["statusCode"].int == 100 {
                        print(json["message"].string)
                        self.getDeviceList()
                    } else {
                        
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    func deleteDev(uuid:String) {
        
        let url = App.URL.server + "devDataInita.do"
        let headers = [
            "Content-Type": "application/json",
            "X-Auth-Token": self.loginToken,
            "Cookie": self.loginCookie
        ]
        
        Alamofire.request(url
            , method: .post
            , parameters: ["userId":userId, "devUuid":uuid, "comnd":"N"]
            , encoding: JSONEncoding.default
            , headers: headers
            ).responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if json["statusCode"].int == 100 {
                        if(uuid == Util.getUuid()) {
                            print("본인 디바이스가 삭제되어 앱이 종료됩니다.")
                            exit(0)
                        } else {
                            self.getDeviceList()
                        }
                        print(json["message"].string)
                    } else {
                        
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
}
