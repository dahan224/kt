//
//  FileInfoTagEditVC.swift
//  KT
//
//  Created by 이다한 on 2018. 3. 4..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class FileInfoTagEditVC: UIViewController, UITextFieldDelegate {

    
    var fileId = ""
    @IBOutlet weak var customNavBar: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnFinish: UIButton!
    
    @IBOutlet weak var btnAdd: UIButton!
    
    @IBOutlet weak var txtTag: UITextField!{
        didSet{
            txtTag.delegate = self
        }
    }
    
    @IBOutlet weak var tagAddView: UIView!{
        didSet{
    
        }
    }
    var tagAddedWidth:CGFloat = 10
    var tagAddedHeight:CGFloat = 10
    
    var fileTagArray:[App.FileTagStruct] = [App.FileTagStruct]()
   var tagArrayToUpdate:[[String:Any]] = []
    
    var savedPath = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        customNavBar.layer.shadowColor = UIColor.lightGray.cgColor
        customNavBar.layer.shadowOffset = CGSize(width:0,height: 2.0)
        customNavBar.layer.shadowRadius = 1.0
        customNavBar.layer.shadowOpacity = 1.0
        customNavBar.layer.masksToBounds = false;
        customNavBar.layer.shadowPath = UIBezierPath(roundedRect:customNavBar.bounds, cornerRadius:customNavBar.layer.cornerRadius).cgPath
        
        
        btnBack.addTarget(self, action: #selector(btnBackClicked), for: .touchUpInside)
        btnAdd.addTarget(self, action: #selector(addTag), for: .touchUpInside)
        resetTagVIew()
        print("savedPath : \(savedPath)")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func btnBackClicked(){
        print("back")
        Util().dismissFromLeft(vc:self)
//        self.dismiss(animated: false, completion: nil)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        for textField in self.view.subviews where textField is UITextField {
            textField.resignFirstResponder()
        }
        return true
    }
    @objc func addTag(){
        if (txtTag.text?.isEmpty ?? true){
            print("textField is empty")
            
            let alertController = UIAlertController(title: nil, message: "태그 정보를 입력해 주세요.", preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel) {
                UIAlertAction in
                //Do you Success button Stuff here
             
            }
            alertController.addAction(yesAction)
            
            self.present(alertController, animated: true)
            
        } else {
            let tag = txtTag.text!
            let tagStruct = App.FileTagStruct(fileId: fileId, fileTag: tag)
            fileTagArray.append(tagStruct)
            let index = fileTagArray.count - 1
            self.showFileTags(index:index)
            self.txtTag.text = ""
        }
    }
    
    func showFileTags(index:Int){
        
            DispatchQueue.main.async {
                
                let tagView:UIView = {
                    let view = UIView()
                    view.translatesAutoresizingMaskIntoConstraints = false
                    return view;
                }()
                let tagLabel:UILabel = {
                    let label = UILabel()
                    label.textAlignment = .left
                    label.backgroundColor = HexStringToUIColor().getUIColor(hex: "f5f5f5")
                    label.font = UIFont.systemFont(ofSize: 20)
                    label.translatesAutoresizingMaskIntoConstraints = false
                    return label
                }()
                
                let delButton:UIButton = {
                    let button = UIButton(type: .system)
                    button.setImage(#imageLiteral(resourceName: "ico_24dp_tag_del").withRenderingMode(.alwaysOriginal), for: .normal)
                    button.translatesAutoresizingMaskIntoConstraints = false
                    return button
                }()
                self.tagAddView.addSubview(tagView)
                let stringTag = self.fileTagArray[index].fileTag
                let Font =  UIFont.systemFont(ofSize: 20.0)
                let labelWidth = stringTag.witdthOfString(font: Font)
                let totalWidth = self.tagAddView.frame.size.width
                if(totalWidth <= self.tagAddedWidth + labelWidth + 50){
                    
                    self.tagAddedWidth = 10
                    self.tagAddedHeight += 30
                    
                }
                
                tagView.topAnchor.constraint(equalTo: self.tagAddView.topAnchor, constant: self.tagAddedHeight).isActive = true
                tagView.leadingAnchor.constraint(equalTo: self.tagAddView.leadingAnchor, constant: self.tagAddedWidth).isActive = true
                tagView.widthAnchor.constraint(equalToConstant: labelWidth + 40).isActive = true
                tagView.heightAnchor.constraint(equalToConstant: 30).isActive = true
                tagView.tag = index

                tagView.addSubview(tagLabel)
                tagView.addSubview(delButton)

                tagLabel.textAlignment = .left
                tagLabel.text = "#\(stringTag)"
                tagLabel.widthAnchor.constraint(equalToConstant: labelWidth+20).isActive = true
                tagLabel.leftAnchor.constraint(equalTo: tagView.leftAnchor).isActive = true
                tagLabel.centerYAnchor.constraint(equalTo: tagView.centerYAnchor).isActive = true
                tagLabel.heightAnchor.constraint(equalTo: tagView.heightAnchor).isActive = true

                delButton.leadingAnchor.constraint(equalTo: tagLabel.trailingAnchor, constant: 5).isActive = true
                delButton.centerYAnchor.constraint(equalTo: tagView.centerYAnchor).isActive = true
                delButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
                delButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
                delButton.tag = index
                delButton.addTarget(self, action: #selector(self.deleteTag(sender:)), for: .touchUpInside)
                
                self.tagAddedWidth += (labelWidth + 50)
               
                print("totalWidth: \(totalWidth), \(self.tagAddedWidth)")
                
            
        }
    }
    @objc func deleteTag(sender:UIButton){
        print("tag : \(sender.tag)")
        fileTagArray.remove(at: sender.tag)
        resetTagVIew()
    }
    func resetTagVIew(){
        for view in tagAddView.subviews{
            view.removeFromSuperview()
        }
        
        tagAddedHeight = 10
        tagAddedWidth = 10
        
        DispatchQueue.main.async {
            for (index, file) in self.fileTagArray.enumerated(){
                
                let tagView:UIView = {
                    let view = UIView()
                    view.translatesAutoresizingMaskIntoConstraints = false
                    return view;
                }()
                let tagLabel:UILabel = {
                    let label = UILabel()
                    label.textAlignment = .left
                    label.backgroundColor = HexStringToUIColor().getUIColor(hex: "f5f5f5")
                    label.font = UIFont.systemFont(ofSize: 20)
                    label.translatesAutoresizingMaskIntoConstraints = false
                    return label
                }()
                
                let delButton:UIButton = {
                    let button = UIButton(type: .system)
                    button.setImage(#imageLiteral(resourceName: "ico_24dp_tag_del").withRenderingMode(.alwaysOriginal), for: .normal)
                    button.translatesAutoresizingMaskIntoConstraints = false
                    return button
                }()
                self.tagAddView.addSubview(tagView)
                let stringTag = self.fileTagArray[index].fileTag
                let Font =  UIFont.systemFont(ofSize: 20.0)
                let labelWidth = stringTag.witdthOfString(font: Font)
                let totalWidth = self.tagAddView.frame.size.width
                if(totalWidth <= self.tagAddedWidth + labelWidth + 50){
                    
                    self.tagAddedWidth = 10
                    self.tagAddedHeight += 30
                    
                }
                
                tagView.topAnchor.constraint(equalTo: self.tagAddView.topAnchor, constant: self.tagAddedHeight).isActive = true
                tagView.leadingAnchor.constraint(equalTo: self.tagAddView.leadingAnchor, constant: self.tagAddedWidth).isActive = true
                tagView.widthAnchor.constraint(equalToConstant: labelWidth + 40).isActive = true
                tagView.heightAnchor.constraint(equalToConstant: 30).isActive = true
                tagView.tag = index
                
                tagView.addSubview(tagLabel)
                tagView.addSubview(delButton)
                
                tagLabel.textAlignment = .left
                tagLabel.text = "#\(stringTag)"
                tagLabel.widthAnchor.constraint(equalToConstant: labelWidth+20).isActive = true
                tagLabel.leftAnchor.constraint(equalTo: tagView.leftAnchor).isActive = true
                tagLabel.centerYAnchor.constraint(equalTo: tagView.centerYAnchor).isActive = true
                tagLabel.heightAnchor.constraint(equalTo: tagView.heightAnchor).isActive = true
                
                delButton.leadingAnchor.constraint(equalTo: tagLabel.trailingAnchor, constant: 5).isActive = true
                delButton.centerYAnchor.constraint(equalTo: tagView.centerYAnchor).isActive = true
                delButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
                delButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
                delButton.tag = index
                delButton.addTarget(self, action: #selector(self.deleteTag(sender:)), for: .touchUpInside)
                
                self.tagAddedWidth += (labelWidth + 50)
                
                print("totalWidth: \(totalWidth), \(self.tagAddedWidth)")
            }
            
        }
    }
    
    @IBAction func btnFilnishClicked(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: nil, message: "태그를 저장 하시겠습니까?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
            UIAlertAction in
            //Do you Success button Stuff here
            self.updateTage()
        }
        let noAction = UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel)
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        self.present(alertController, animated: true)
        
        
    }
    func updateTage(){
        tagArrayToUpdate.removeAll()
        if(self.fileTagArray.count>0){
            for fileTag in fileTagArray {
                tagArrayToUpdate.append(fileTag.getParameter)
            }
            print(tagArrayToUpdate)
            ContextMenuWork().editFileTag(parameters: tagArrayToUpdate){ responseObject, error in
                let json = JSON(responseObject!)
                let message = responseObject?.object(forKey: "message")
                print("\(message), \(json["statusCode"].int)")
                
                if let statusCode = json["statusCode"].int, statusCode == 100 {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: nil, message: "요청 처리가 완료되었습니다.", preferredStyle: .alert)
                        
                        let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) {
                            UIAlertAction in
                            //Do you Success button Stuff here
                            NotificationCenter.default.post(name: Notification.Name("showFileInfo"), object: self)
                            self.dismiss(animated: false, completion: nil)
                            
                        }
                        alertController.addAction(yesAction)
                        self.present(alertController, animated: true)
                        
                    }
                }
                return
            }
        }
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
extension String {
    func witdthOfString( font: UIFont) -> CGFloat {
        let fontAttribute = [NSAttributedStringKey.font: font]
        let size = self.size(withAttributes: fontAttribute)  // for Single Line
        return size.width;
    }
}
