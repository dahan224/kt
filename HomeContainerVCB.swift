//
//  HomeContainerBViewController.swift
//  KT
//
//  Created by 이다한 on 2018. 1. 25..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class HomeContainerVCB: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let image = ["kasm11","kasm11","kasm11",  "kasm11"]
    let icons = ["kasm11","kasm11","kasm11",  "kasm11"]
    let main = ["kasm1_1.jpg","kasm1_1.jpg","kasm1_1.jpg",  "kasm1_1.jpg"]
    let sub = ["2017-09-15 | JUN-PC","2017-09-15 | JUN-PC","2017-09-15 | JUN-PC",  "2017-09-15 | JUN-PC"]
    var LatelyUpdatedFileArray:[App.LatelyUpdatedFileStruct] = []
    var cookie = ""
    var token = ""
    
    var listViewStyleState = ContainerViewController.listViewStyleEnum.grid
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        print("HomeContainerVCB : \(LatelyUpdatedFileArray)")
        cookie = UserDefaults.standard.string(forKey: "cookie")!
        token = UserDefaults.standard.string(forKey: "token")!
        collectionView.reloadData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return LatelyUpdatedFileArray.count
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeFileCell", for: indexPath) as! HomeContainerBCell
        
//        var fileId = LatelyUpdatedFileArray[indexPath.row].fileId
//        let headers =  [
//            "X-Auth-Token": self.token,
//            "Cookie": self.cookie
//        ]
//        let imageUrl = App.URL.hostIpServer+"imgFileThum.do?fileId=\(fileId)"
//        print("imageUrl: \(imageUrl)")
//
//        Alamofire.request(imageUrl, method: .get, encoding: URLEncoding.default, headers: headers).responseData { (response) in
//            if response.error == nil {
//                print("image request response : \(response)")
//                if let data = response.data {
//
//                    cell.ivFile.image = UIImage(data: response.result.value!)
//                    cell.ivIcon.image = UIImage(data: data)
//                    print(response.data)
//                    }
//                }
//            }
       
        
        
//        cell.ivFile.image = UIImage(named: "kasm11")
        
        var fileExtension = LatelyUpdatedFileArray[indexPath.row].etsionNm
        print("fileExtension : \(fileExtension)")
        cell.ivFile.image = UIImage(named: Util.getFileImageString(fileExtension: fileExtension))
        cell.ivIcon.image = UIImage(named: Util.getFileImageString(fileExtension: fileExtension))
        
        
        cell.lblMain.text = LatelyUpdatedFileArray[indexPath.row].fileNm
        cell.lblSub.text = LatelyUpdatedFileArray[indexPath.row].amdDate
        
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width:0,height: 2.0)
        cell.layer.shadowRadius = 1.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false;
        cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var fileId = "\(self.LatelyUpdatedFileArray[indexPath.row].fileId)"
        print("fileid : \(fileId)")
        var fileIdDict = ["fileId":fileId]
        NotificationCenter.default.post(name: Notification.Name("toggleBottomMenu"), object: self, userInfo: fileIdDict)
        
        
        
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
