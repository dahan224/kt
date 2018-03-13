//
//  DeviceContainerVCA.swift
//  KT
//
//  Created by 김영은 on 2018. 2. 21..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit

class DeviceContainerVCA: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let menuNms:[String] = ["디바이스 이름 변경","폴더 설정","디바이스 제거"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuNms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DevMngTableViewCell") as! DeviceContainerACell
        let clearView = UIView()
        
        clearView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = clearView
        if indexPath.row == 1 {
            cell.isUserInteractionEnabled = false
            cell.contentView.alpha = 0.5
        }
        cell.lblMenuNm.text = menuNms[indexPath.row]
        
        return cell
    }

    let deviceManageStyle = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let Vc = parent as! DeviceManageVC
        Vc.selectMenu(indexPath.row)
    }

}
