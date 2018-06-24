//
//  MultiStatusViewController.swift
//  KT
//
//  Created by 김영은 on 2018. 4. 30..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit

class MultiStatusViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var totalNum = 0
    var completeNum = 0
    
    var fileIdArry:[String] = []
    var fileNmArry:[String] = []
    var fileSizeArry:[String] = []
    var fileEtsionmArry:[String] = []
    var isCompleteArry:[Bool] = []
    var containerViewController:ContainerViewController?
    
    
    var failYn:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.post(name: Notification.Name("inActiveMultiCheckFromMultiFileProcess"), object: self, userInfo: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(completeFileProcess),
                                               name: NSNotification.Name("completeFileProcess"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(failFileProcess),
                                               name: NSNotification.Name("failFileProcess"),
                                               object: nil)
        
        for _ in 0...fileIdArry.count-1 {
            isCompleteArry.append(false)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MultiProgressCell.self, forCellReuseIdentifier: "MultiProgressCell")
        tableView.reloadData()
        
        totalNum = fileIdArry.count
        lblTitle.text = "멀티 진행상태(\(completeNum)/\(totalNum) 완료)"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("inActiveMultiCheckFromMultiFileProcess"), object: self, userInfo: nil)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fileIdArry.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MultiProgressCell") as! MultiProgressCell
        
        cell.lblMain.text = fileNmArry[indexPath.row]
        let etsionm = fileEtsionmArry[indexPath.row]
        var imageString = ""
        if etsionm == "nil" {
            imageString = "ico_folder"
            cell.lblSize.isHidden = true
        } else {
            imageString = Util.getFileImageString(fileExtension: fileEtsionmArry[indexPath.row])
            cell.lblSize.isHidden = false
        }
        
        cell.ivIcon.image = UIImage(named: imageString)
        
        if isCompleteArry[indexPath.row] {
            cell.ivSub.image = UIImage(named:"progress_complete")
            if failYn {
                cell.lblMain.textColor = HexStringToUIColor().getUIColor(hex: "D1D2D4")
                cell.lblSize.textColor = HexStringToUIColor().getUIColor(hex: "D1D2D4")
            } else {
                cell.lblMain.textColor = HexStringToUIColor().getUIColor(hex: "4F4F4F")
                cell.lblSize.textColor = HexStringToUIColor().getUIColor(hex: "4F4F4F")
            }
        } else {
            cell.ivSub.image = UIImage.gifImageWithName(name: "progress_bar")
            
            cell.lblMain.textColor = HexStringToUIColor().getUIColor(hex: "D1D2D4")
            cell.lblSize.textColor = HexStringToUIColor().getUIColor(hex: "D1D2D4")
        }
        let fileSize = FileUtil().covertFileSize(getSize: fileSizeArry[indexPath.row])
        cell.lblSize.text = fileSize
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height:CGFloat = 100.0
        
        return height
    }
    
    @IBAction func fnBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name("homeViewStopIndicator"), object: self, userInfo: nil)
        
        
    }
    
    @objc func completeFileProcess(fileDict:NSNotification) {
        if let getFileId = fileDict.userInfo?["fileId"] as? String {
            failYn = false
            if let index = fileIdArry.index(of: getFileId) {
                isCompleteArry[index] = true
            }
            completeNum += 1
            lblTitle.text = "멀티 진행상태(\(completeNum)/\(totalNum) 완료)"
            tableView.reloadData()
        }
    }
    
    @objc func failFileProcess(fileDict:NSNotification) {
        for index in 0...fileIdArry.count-1 {
            isCompleteArry[index] = true
        }
        failYn = true
        
        lblTitle.text = "멀티 진행상태(\(completeNum)/\(totalNum) 실패)"
        tableView.reloadData()
    }
}
