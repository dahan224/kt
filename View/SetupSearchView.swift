//
//  SetupSearchView.swift
//  KT
//
//  Created by 이다한 on 2018. 2. 22..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit

class SetupSearchView {
    class func setupSearchNavbar(View:UIView,navBarTitle:UIButton, backBUtton:UIButton, title:String){
        
        View.addSubview(backBUtton)
        View.addSubview(navBarTitle)
        
        backBUtton.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
        backBUtton.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        backBUtton.centerYAnchor.constraint(equalTo: View.centerYAnchor).isActive = true
        backBUtton.leadingAnchor.constraint(equalTo: View.leadingAnchor, constant: 20.0).isActive = true
        
        
        navBarTitle.setTitle(title, for: .normal)
        navBarTitle.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
        navBarTitle.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        navBarTitle.centerYAnchor.constraint(equalTo: View.centerYAnchor).isActive = true
        navBarTitle.centerXAnchor.constraint(equalTo: View.centerXAnchor).isActive = true
    }
    
    class func showFileCountLabel(count:Int, view:UIView, searchCountLabel:UILabel,searchCategoryView:UIStackView ){
        
        view.addSubview(searchCountLabel)
        searchCountLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        searchCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        searchCountLabel.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
        searchCountLabel.topAnchor.constraint(equalTo: searchCategoryView.bottomAnchor, constant: 7).isActive = true
        searchCountLabel.backgroundColor = UIColor.white
        
        let attrs1 = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15), NSAttributedStringKey.foregroundColor : HexStringToUIColor().getUIColor(hex: "4F4F4F")]
        
        let attrs2 = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15), NSAttributedStringKey.foregroundColor :HexStringToUIColor().getUIColor(hex: "ff0000")]
        
        let attrs3 = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15), NSAttributedStringKey.foregroundColor : HexStringToUIColor().getUIColor(hex: "4F4F4F")]
        
        let attributedString1 = NSMutableAttributedString(string:"  검색결과 ", attributes:attrs1)
        let attributedString2 = NSMutableAttributedString(string:"\(count)", attributes:attrs2)
        let attributedString3 = NSMutableAttributedString(string:"건", attributes:attrs3)
        attributedString1.append(attributedString2)
        attributedString1.append(attributedString3)
        
        searchCountLabel.attributedText = attributedString1
        
        
    }
    
  
}
