//
//  WanInfoPopupView.swift
//  KT
//
//  Created by 김영은 on 2018. 4. 30..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import BEMCheckBox

class WanInfoPopupView: UIView {
    
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblContents: UILabel!
    @IBOutlet weak var checkBox: BEMCheckBox!
    @IBOutlet weak var btnSubmit: UIButton!
    
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
    
    var isAgree = false
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        checkBox.boxType = BEMBoxType.square
        
        lblTitle.text = "3G / LTE 데이터 이용안내"
        lblContents.text = "3G / LTE 환경에서는 데이터 요금이\n 발생할 수 있습니다."
        
        //lblTitle.font = lblTitle.font.withSize(20)
        lblContents.font = lblContents.font.withSize(16)
        lblTitle.font = UIFont.boldSystemFont(ofSize: 20)
        
        btnSubmit.backgroundColor = HexStringToUIColor().getUIColor(hex: "000000")
        btnSubmit.setTitleColor(HexStringToUIColor().getUIColor(hex: "ffffff"), for: .normal)
    }
    
    @IBAction func submit(_ sender: Any) {
        print("isAgree : \(isAgree)")
        if !isAgree {
            let alertView = UIAlertController(title: nil, message: "데이터 허용 확인을 체크해 주세요.", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel, handler: nil)
            alertView.addAction(yesAction)
            UIApplication.shared.keyWindow?.rootViewController?.present(alertView, animated: true, completion: nil)
        } else {
            let Vc = parentViewController as! LoginViewController
            Vc.autoLogin()
            super.removeFromSuperview()
        }
    }
    
    @IBAction func setCheckVal(_ sender: Any) {
        isAgree = checkBox.on
        UserDefaults.standard.set(isAgree, forKey: "isAgree")
    }
    
    
}
