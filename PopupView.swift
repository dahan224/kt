//
//  PopupView.swift
//  KT
//
//  Created by 김영은 on 2018. 3. 16..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class PopupView: UIView {

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var lblTop: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var btnReSend: UIButton!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var txtSmsNum: UITextField!
    
    @IBOutlet weak var btnAuth: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    var countDownTimer:Timer!
    var totalTime = 179
    
    var devBas:App.DeviceStruct!
    var data:App.smsInfo!
    
    var jsonHeader:[String:String] = [
        "Content-Type": "application/json",
        "X-Auth-Token": UserDefaults.standard.string(forKey: "token") ?? "nil",
        "Cookie": UserDefaults.standard.string(forKey: "cookie") ?? "nil"
    ]
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    //let Vc:LoginViewController = LoginViewController()
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        txtSmsNum.borderStyle = UITextBorderStyle.none
        txtSmsNum.addBorderBottom(height: 1, color: HexStringToUIColor().getUIColor(hex: App.Color.listBorder))
        
        btnReSend.addTarget(self, action: #selector(fnReSendSms), for: .touchUpInside) // 추가
        lblTop.textColor = HexStringToUIColor().getUIColor(hex: "ffffff")
        lblTop.font = lblTop.font.withSize(24)
        lblInfo.text = "- 발송된 인증번호를 유효시간 안에 입력하세요.\n- 인증번호를 입력 후 확인 버튼을 클릭하세요.\n- 인증번호 미 수신시 재발송 버튼을 클릭하세요."
        lblInfo.font = lblInfo.font.withSize(13)
        lblInfo.setLineHeight(lineHeight: 8)
        btnReSend.backgroundColor = HexStringToUIColor().getUIColor(hex: "717171")
        lblTimer.textColor = HexStringToUIColor().getUIColor(hex: "f39c12")
        
        btnAuth.backgroundColor = HexStringToUIColor().getUIColor(hex: "ff0000")
        btnAuth.setTitleColor(HexStringToUIColor().getUIColor(hex: "ffffff"), for: .normal)
        btnCancel.backgroundColor = HexStringToUIColor().getUIColor(hex: "333333")
        btnCancel.setTitleColor(HexStringToUIColor().getUIColor(hex: "ffffff"), for: .normal)
        startTimer()
    }
    
    func substring(txt:String, start:Int, len:Int) -> String {
        let startIndex = txt.index(txt.startIndex, offsetBy: start)
        let endIndex = txt.index(startIndex, offsetBy: len)
        
        return String(txt[startIndex..<endIndex])
    }
    
    @IBAction func fnAuth(_ sender: Any) {

        let Vc = parentViewController as! LoginViewController
        
        if lblTimer.text == "00:00" {
            
            let alertView = UIAlertController(title: nil, message: "인증 시간이 만료되었습니다. 재발송 버튼을 눌러주세요.", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel)
            alertView.addAction(confirmAction)
            
            UIApplication.shared.keyWindow?.rootViewController?.present(alertView, animated: true, completion: nil)
        } else {
            if txtSmsNum.text == "" {
                
                let alertView = UIAlertController(title: nil, message: "인증번호를 입력해주세요.", preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel)
                alertView.addAction(confirmAction)
                UIApplication.shared.keyWindow?.rootViewController?.present(alertView, animated: true, completion: nil)
                
            } else {
                
                if txtSmsNum.text != data.smsCrtfcNo {
                    let alertView = UIAlertController(title: nil, message: "인증번호가 틀렸습니다. 다시 입력해 주세요.", preferredStyle: .alert)
                    let confirmAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel)
                    alertView.addAction(confirmAction)
                    UIApplication.shared.keyWindow?.rootViewController?.present(alertView, animated: true, completion: nil)
                } else {
                    let ymd = substring(txt: data.today, start: 0, len: 8)
                    var todayTime = Int(substring(txt: data.today, start: 10, len: 4)) ?? 0
                    todayTime += 180
                    
                    let smsYmd = substring(txt: data.smsCrtfcKey, start: 0, len: 8)
                    let smsdayTime = Int(substring(txt: data.smsCrtfcKey, start: 10, len: 4)) ?? 0
                    
                    if ymd == smsYmd && todayTime > smsdayTime {
                        
                        let urlString = App.URL.server + "smsCmplt.do"
                        let param = ["userId":data.devBas.userId, "devUuid":data.devBas.devUuid]
                        Alamofire.request(urlString,
                                          method: .post,
                                          parameters: param,
                                          encoding : JSONEncoding.default,
                                          headers: jsonHeader).responseJSON{ (response) in
                                            switch response.result {
                                            case .success(let value):
                                                let json = JSON(value)
                                                if let statusCode = json["statusCode"].int, statusCode == 100 {
                                                    Vc.sysncFileInfo()
                                                    super.removeFromSuperview()
                                                }
                                            case .failure(let error):
                                                NSLog(error.localizedDescription)
                                            }

                        
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func fnCancel(_ sender: Any) {
        let Vc = parentViewController as! LoginViewController
        Vc.stopAnimating()
        
        super.removeFromSuperview()
    }
    @objc func fnReSendSms() {
        
        let userId:String = UserDefaults.standard.string(forKey: "userId")!
        let uuid:String = Util.getUuid()
        
         let urlString = App.URL.server+"smsReSend.do"
         Alamofire.request(urlString,
         method: .post,
         parameters: ["userId":userId,"devUuid":uuid],
         encoding : JSONEncoding.default,
         headers: jsonHeader).responseJSON{ (response) in
         switch response.result {
         case .success(let value):
             print(value)
             let json = JSON(value)
             let responseData = value as! NSDictionary
             let message = responseData.object(forKey: "message")
             print("smsAuth message : \(message)")
             if let statusCode = json["statusCode"].int, statusCode != 100 {
             
             } else {
                if let listData = responseData.object(forKey: "data") as? NSDictionary {
                    self.data = App.smsInfo(sms: listData as! AnyObject)
                    let alertView = UIAlertController(title: nil, message: "재발송 되었습니다.", preferredStyle: .alert)
                    let confirmAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.default) { UIAlertAction in
                        self.lblTimer.text = "\(self.timeFormatted(180))"
                        self.totalTime = 179
                        self.startTimer()
                    }
                    alertView.addAction(confirmAction)
                    UIApplication.shared.keyWindow?.rootViewController?.present(alertView, animated: true, completion: nil)
                } else {
                    let alertView = UIAlertController(title: nil, message: "실패하였습니다. 다시 시도해주세요.", preferredStyle: .alert)
                    let confirmAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel)
                    alertView.addAction(confirmAction)
                    UIApplication.shared.keyWindow?.rootViewController?.present(alertView, animated: true, completion: nil)
                }
             }
         case .failure(let error):
            NSLog(error.localizedDescription)
        }
        }
    }
    
    func startTimer() {
        countDownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        lblTimer.text = "\(timeFormatted(totalTime))"
        
        if totalTime > 0 {
            totalTime -= 1
        } else {
            countDownTimer.invalidate()
        }
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
}
