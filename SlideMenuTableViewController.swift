//
//  SlideMenuTableViewController.swift
//  KT
//
//  Created by 이다한 on 2018. 1. 22..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SlideMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
    @IBOutlet weak var lblUserId: UILabel!
    let hexStringToUIColor = HexStringToUIColor()
    var containViewController:ContainerViewController?
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var collectionVIew: UICollectionView!
    
    var collectionViewWidth:CGFloat = CGFloat()
    enum TableSection: Int {
        case device=0, manage, info, total
    }
    
    let SectionHeaderHeight: CGFloat = 8
    var data = [TableSection: [[String: String]]]()
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!

    @IBOutlet weak var tableView: UITableView!
    var DeviceArray:[App.DeviceStruct] = []
    
    let rawData = [
        ["title": "GiGA NAS",  "image": "ico_device_giganas_on", "kind": "device"],
        ["title": "GiGA NAS",  "image": "ico_device_giganas_on", "kind": "device"],
        ["title": "GiGA NAS",  "image": "ico_device_giganas_on", "kind": "device"],
        ["title": "YOUNGIK",  "image": "ico_device_pc_on", "kind": "device"],
        ["title": "GiGA NAS",  "image": "ico_device_giganas_on", "kind": "device"],
        ["title": "JUN-PC",  "image": "ico_device_pc_on", "kind": "device"],
        ["title": "YOUNGIK",  "image": "ico_device_pc_on", "kind": "device"],
        ["title": "JUN-PC",  "image": "ico_device_pc_on", "kind": "device"],
        ["title": "JUN-PC",  "image": "ico_device_pc_on", "kind": "device"],
        ["title": "YOUNGIK",  "image": "ico_device_pc_on", "kind": "device"],
        ["title": "JUN-PC",  "image": "ico_device_pc_on", "kind": "device"],
        ["title": "iPhone 6",  "image": "ico_device_mobile_on", "kind": "device"],
        
        ["title": "디바이스 관리", "image": "setting","button":"page_back", "kind": "manage"],
        ["title": "사용자 설정", "image": "setting", "button":"page_back", "kind": "manage"],
        ["title": "버전정보", "kind": "info"],
        ["title": "개인정보 처리방침", "kind": "info"],
        ["title": "오픈 라이센스", "kind": "info"]
    ]
        
    func sortData() {
        data[.device] = rawData.filter({ $0["kind"] == "device" })
        data[.manage] = rawData.filter({ $0["kind"] == "manage" })
        data[.info] = rawData.filter({ $0["kind"] == "info" })
    }
    
    var userId = ""
    var userPassword = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(tableScrollTop),
                                               name: NSNotification.Name("tableScrollTop"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadSlideDev),
                                               name: NSNotification.Name("reloadSlideDev") ,
                                               object: nil)
        
        print("slide view called")
        screenSize = self.view.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        lblUserId.text = UserDefaults.standard.string(forKey: "userId")
        let swipeLeft = UISwipeGestureRecognizer(target: self,
                                                 action: #selector(SlideMenuViewController.swipedLeft))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        tableView.backgroundColor = HexStringToUIColor().getUIColor(hex: "333333")
        
        tableView.delegate = self
        tableView.dataSource = self
       
        tableView.estimatedRowHeight = 80;
        tableView.rowHeight = UITableViewAutomaticDimension;
        
        
//        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewWidth = UIScreen.main.bounds.width
        self.DeviceArray = DbHelper().listSqlite(sortBy: DbHelper.sortByEnum.none)
        self.sortData()
        self.tableView.reloadData()
        
      
    }
    
    
 
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func btnLogout(_ sender: UIButton) {
        let alertController = UIAlertController(title: "로그아웃 하시겠습니까?",message: "", preferredStyle: UIAlertControllerStyle.alert)

        let okAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default){ (action: UIAlertAction) in
           self.logout()
        }
        let cancelButton = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelButton)
        self.present(alertController,animated: true,completion: nil)

    }
    
    func deviceOff(){
        let cookie:String = UserDefaults.standard.string(forKey: "cookie")!
        let token:String = UserDefaults.standard.string(forKey: "token")!
        let urlString = App.URL.server+"devStatusUpdate.do"
        let headers = [
            "Content-Type": "application/json",
            "X-Auth-Token": token,
            "Cookie": cookie
        ]
        let params:[String:Any] = ["userId": App.defaults.userId, "devUuid":Util.getUuid(), "onoff":"N"]
        print("cookie: \(cookie), token : \(token)")
        Alamofire.request(urlString,
                          method: .post,
                          parameters : params,
                          encoding : JSONEncoding.default,
                          headers: headers).responseJSON { response in
                            switch response.result {
                            case .success(let JSON):
                                
                                print(response.result.value as Any)
                                let responseData = JSON as! NSDictionary
                                let message = responseData.object(forKey: "message")
                                print("message : \(String(describing: message))")
                                
                                NotificationCenter.default.post(name: NSNotification.Name("dismissContainerView"), object: nil)
                                UserDefaults.standard.set(false, forKey: "autoLoginCheck")
                                break
                            case .failure(let error):
                                
                                print(error)
                            }
        }
        

    }
    
    func logout(){
        let cookie:String = UserDefaults.standard.string(forKey: "cookie")!
        let token:String = UserDefaults.standard.string(forKey: "token")!
        let urlString = App.URL.server+"logout.do"
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded",
            "X-Auth-Token": token,
            "Cookie": cookie
        ]
        print("cookie: \(cookie), token : \(token)")
        Alamofire.request(urlString,
                          method: .post,
                          encoding : JSONEncoding.default,
                          headers: headers).responseJSON { response in
                            switch response.result {
                            case .success(let JSON):
                                print(response.result.value as Any)
                                let responseData = JSON as! NSDictionary
                                let message = responseData.object(forKey: "message")
                                 print("message : \(String(describing: message))")
                                //기기 상태 off
                                self.deviceOff()
                                break
                            case .failure(let error):
                                
                                print(error)
                            }
        }
        

    }
    
   
    @objc func swipedLeft() {
        NotificationCenter.default.post(name: NSNotification.Name("toggleSideMenu"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnSlideClose(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name("toggleSideMenu"), object: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return TableSection.total.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Using Swift's optional lookup we first check if there is a valid section of table.
        // Then we check that for the section there is data that goes with.
        if let tableSection = TableSection(rawValue: section), let data = data[tableSection] {
            if tableSection.rawValue == 0 {
                return 1
            }
            return data.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // If we wanted to always show a section header regardless of whether or not there were rows in it,
        // then uncomment this line below:
        //return SectionHeaderHeight
        // First check if there is a valid section of table.
        // Then we check that for the section there is more than 1 row.
        if let tableSection = TableSection(rawValue: section), let movieData = data[tableSection], movieData.count > 0 {
            return SectionHeaderHeight
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: SectionHeaderHeight))
        view.backgroundColor = hexStringToUIColor.getUIColor(hex: "000000")
  
        return view
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? SlideMenuCell1 else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(dataSource: self, forRow: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "MenuCell1") as! SlideMenuCell1
        let cell2 = tableView.dequeueReusableCell(withIdentifier: "MenuCell2") as! SlideMenuCell2
        let cell3 = tableView.dequeueReusableCell(withIdentifier: "MenuCell3") as! SlideMenuCell3
        let cells = [cell1, cell2, cell3]
        var cell = cells[0]
        // Similar to above, first check if there is a valid section of table.
        // Then we check that for the section there is a row.
        let clearView = UIView()
        if let tableSection = TableSection(rawValue: indexPath.section), let data = data[tableSection]?[indexPath.row] {
            cell = cells[indexPath.section]
            switch(indexPath.section){
            case (0) :
                clearView.backgroundColor = UIColor.clear
                cell1.selectedBackgroundView = clearView
                
                break
            case (1) :
                clearView.backgroundColor = UIColor.clear
                cell2.selectedBackgroundView = clearView
                cell2.ivManage.image = UIImage(named: data["image"]!)
                cell2.lblManage.text = data["title"]
                cell2.btnManage.setImage(UIImage(named: data["button"]!), for: .normal)
                cell2.btnManage.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                cell2.btnManage.tag = indexPath.row
                cell2.btnManage.addTarget(self, action: #selector(clickBtn(_:)), for: .touchUpInside)

                break
                
            case (2) :
                cell3.lblInfo.text = data["title"]
            
                break
            default:
                break
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print(indexPath.section)
        print(indexPath.row)
        if(indexPath.section == 2 && indexPath.row == 0){
            showVersionInfo()
        }
        if(indexPath.section == 1 && indexPath.row == 0){
            NotificationCenter.default.post(name: NSNotification.Name("deviceManageSegue"), object: nil)
        }
        

        if(indexPath.section == 1 && indexPath.row == 1){
            NotificationCenter.default.post(name: NSNotification.Name("showSettingSegue"), object: nil)
        }
        
        if(indexPath.section == 2 && indexPath.row == 2) {
            NotificationCenter.default.post(name: NSNotification.Name("openLicenseSegue"), object: nil)
        }
        tableScrollTop()
    }
    func showVersionInfo(){
        var version = "1.0"
        if let ver = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            version = ver
        }
        let alertController = UIAlertController(title: "App Version : \(version)",message: "", preferredStyle: UIAlertControllerStyle.alert)
        let cancelButton = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelButton)
        self.present(alertController,animated: true,completion: nil)

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height:CGFloat = 80.0
        
        if indexPath.section == 0 {
          
            height = (collectionViewWidth / 4) * CGFloat(DeviceArray.count / 3 + 1)
            print("height : \(height)")
        } else  {
            height = 80
        }
        return height
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
//        print("count : \(data[.device]?.count)")
        return DeviceArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SlideMenuCVCell", for: indexPath) as! SlideMenuCVCell
//        var h:CGFloat = collectionView.contentSize.height;
//        print("collection view size : \(h)")
        
        
        let imageString = Util.getDeviceImageString(osNm: DeviceArray[indexPath.row].osNm, onoff: DeviceArray[indexPath.row].onoff)
        cell.ivIcon.image = UIImage(named: imageString)
        cell.lblTitle.text = DeviceArray[indexPath.row].devNm
//        print("title:\(indexPath.item)")
//
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        NotificationCenter.default.post(name: NSNotification.Name("toggleSideMenu"), object: nil)
        
        containViewController?.clickDeviceFromSlideMenu(indexPath: indexPath)
        
    }

    @objc func tableScrollTop() {
        tableView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    
    @objc func clickBtn(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            NotificationCenter.default.post(name: NSNotification.Name("deviceManageSegue"), object: nil)
        case 1:
            NotificationCenter.default.post(name: NSNotification.Name("showSettingSegue"), object: nil)
        default:
            break
        }
    }

    @objc func reloadSlideDev() {
        self.DeviceArray = DbHelper().listSqlite(sortBy: DbHelper.sortByEnum.none)
        self.sortData()
        self.tableView.reloadData()
    }
  
}

