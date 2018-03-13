//
//  HomeContainerVCC.swift
//  KT
//
//  Created by 이다한 on 2018. 1. 26..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit


class HomeContainerVCC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource   {

    @IBOutlet weak var collectionView: UICollectionView!
    var width:CGFloat = CGFloat()
    
    let imageCheck = [
        ["osNm": "GIGA Storage",  "image": "ico_device_giganas_on", "onoff": "Y"],
        ["osNm": "GIGA Storage",  "image": "ico_device_giganas", "onoff": "N"],
        ["osNm": "SHARE GIGA Storage",  "image": "ico_device_giganas_share_on", "onoff": "Y"],
        ["osNm": "SHARE GIGA Storage",  "image": "ico_device_giganas_share", "onoff": "N"],
        ["osNm": "Windows",  "image": "ico_device_pc_on", "onoff": "Y"],
        ["osNm": "Windows",  "image": "ico_device_pc", "onoff": "N"],
        ["osNm": "Android",  "image": "ico_device_mobile_on", "onoff": "Y"],
        ["osNm": "Android",  "image": "ico_device_mobile", "onoff": "N"],
        ["osNm": "iOS",  "image": "ico_device_mobile_on", "onoff": "Y"],
        ["osNm": "iOS",  "image": "ico_device_mobile", "onoff": "N"],
        ]
    var DeviceArray:[App.DeviceStruct] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        width = UIScreen.main.bounds.width
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return DeviceArray.count
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeListCell", for: indexPath) as! HomeContainerCCell
        
        var imageString = Util.getDeviceImageString(osNm: DeviceArray[indexPath.row].osNm, onoff: DeviceArray[indexPath.row].onoff)
        cell.ivIcon.image = UIImage(named: imageString)
        //        cell.deviceImage.image = UIImage(named: deviceImage[indexPath.row])
        cell.lblMain.text = DeviceArray[indexPath.row].devNm
        cell.lblSub.isHidden = true
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width:0,height: 2.0)
        cell.layer.shadowRadius = 1.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false;
        cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("item : \(indexPath.row)")
        let Vc = parent as! HomeViewController
        Vc.setupFileListNavBar(item: indexPath.row)
        
    }
    func getImageString(osNm:String, onoff:String) -> String {
        let result = imageCheck.filter({ $0["osNm"] == osNm && $0["onoff"] == onoff})
        print("result  \(String(describing: result[0]["image"]))")
        return result[0]["image"]!
    }

}
