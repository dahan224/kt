//
//  DeviceManageVC.swift
//  KT
//
//  Created by 이다한 on 2018. 2. 1..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class DeviceManageVC: UIViewController  {

    @IBOutlet weak var customNavBar: UIView!
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var containerViewA: UIView! // 디바이스관리 메뉴
     // 디바이스 이름변경, 디바이스 제거
    
    var DeviceArray:[App.DeviceStruct] = []
    
    var loginCookie = ""
    var loginToken = ""
    var userId = ""
    var uuid = ""
    
    var menuIndex = 0 // 0:디바이스 이름변경, 2: 디바이스 제거
    
    let menuNms:[String] = ["디바이스 이름 변경","폴더 설정","디바이스 제거"]
    let changeView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let folderView:UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let deleteView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let changeLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let folderLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let deleteLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let changeButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ico_36dp_nxt").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let folderButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ico_36dp_nxt").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let deleteButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ico_36dp_nxt").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var deviceManageStyle = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customNavBar.layer.shadowColor = UIColor.lightGray.cgColor
        customNavBar.layer.shadowOffset = CGSize(width:0,height: 2.0)
        customNavBar.layer.shadowRadius = 1.0
        customNavBar.layer.shadowOpacity = 1.0
        customNavBar.layer.masksToBounds = false;
        customNavBar.layer.shadowPath = UIBezierPath(roundedRect:customNavBar.bounds, cornerRadius:customNavBar.layer.cornerRadius).cgPath
        
        loginCookie = UserDefaults.standard.string(forKey: "cookie")!
        loginToken = UserDefaults.standard.string(forKey: "token")!
        uuid = Util.getUuid()
        userId = UserDefaults.standard.string(forKey: "userId")!
        
        self.view.addSubview(changeView)
        self.view.addSubview(folderView)
        self.view.addSubview(deleteView)
        
        changeView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        changeView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        changeView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        changeView.topAnchor.constraint(equalTo: self.customNavBar.bottomAnchor, constant: 5).isActive = true
        addLeftLabel(view: changeView, label: changeLabel, text: menuNms[0])
        changeView.addSubview(changeButton)
        changeButton.widthAnchor.constraint(equalToConstant: 36).isActive = true
        changeButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        changeButton.trailingAnchor.constraint(equalTo: changeView.trailingAnchor, constant: -20).isActive = true
        changeButton.centerYAnchor.constraint(equalTo: changeView.centerYAnchor).isActive = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(menuTapped(recognizer:)))
        changeView.isUserInteractionEnabled = true
        changeView.tag = 0
        changeView.addGestureRecognizer(gesture)

        folderView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        folderView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        folderView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        folderView.topAnchor.constraint(equalTo: self.changeView.bottomAnchor, constant: 1).isActive = true
        addLeftLabel(view: folderView, label: folderLabel, text: menuNms[1])
        folderView.addSubview(folderButton)
        folderButton.widthAnchor.constraint(equalToConstant: 36).isActive = true
        folderButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        folderButton.trailingAnchor.constraint(equalTo: folderView.trailingAnchor, constant: -20).isActive = true
        folderButton.centerYAnchor.constraint(equalTo: folderView.centerYAnchor).isActive = true
        folderView.alpha = 0.5
        
        deleteView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        deleteView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        deleteView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        deleteView.topAnchor.constraint(equalTo: self.folderView.bottomAnchor, constant: 1).isActive = true
        addLeftLabel(view: deleteView, label: deleteLabel, text: menuNms[2])
        deleteView.addSubview(deleteButton)
        deleteButton.widthAnchor.constraint(equalToConstant: 36).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        deleteButton.trailingAnchor.constraint(equalTo: deleteView.trailingAnchor, constant: -20).isActive = true
        deleteButton.centerYAnchor.constraint(equalTo: deleteView.centerYAnchor).isActive = true
        
        let gesture3 = UITapGestureRecognizer(target: self, action: #selector(menuTapped(recognizer:)))
        deleteView.tag = 2
        deleteView.addGestureRecognizer(gesture3)

        
        btnBack.addTarget(self, action: #selector(fnBack), for: .touchUpInside)
    }
    
    func addLeftLabel(view:UIView, label:UILabel, text:String){
        view.addSubview(label)
        label.textAlignment = .left
        label.text = text
        label.textColor = HexStringToUIColor().getUIColor(hex: "4f4f4f")
        label.widthAnchor.constraint(equalToConstant: 200).isActive = true
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
    }
    @objc func menuTapped(recognizer: UITapGestureRecognizer){
        if let viewTag = recognizer.view?.tag {
                print("viewTag : \(viewTag)")
            deviceManageStyle = viewTag
            performSegue(withIdentifier: "deviceDetailSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "deviceDetailSegue" {
            if let vc = segue.destination as? DeviceContainerVCB {
                vc.menuNum = self.deviceManageStyle                
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func fnBack() { // 뒤로가기
        dismiss(animated: true, completion: nil)
    }


}
