//
//  SetupSearchView.swift
//  KT
//
//  Created by 이다한 on 2018. 2. 22..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit

class SetupSearchView {
    class func setupSearchNavbar(View:UIView,navBarTitle:UIButton, backBUtton:UIButton, title:String, listButton:UIButton){
        
        
        View.addSubview(backBUtton)
        View.addSubview(navBarTitle)
        View.addSubview(listButton)
        
        backBUtton.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
        backBUtton.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        backBUtton.centerYAnchor.constraint(equalTo: View.centerYAnchor).isActive = true
        backBUtton.leadingAnchor.constraint(equalTo: View.leadingAnchor, constant: 20.0).isActive = true
        
        
        navBarTitle.setTitle(title, for: .normal)
        navBarTitle.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
        navBarTitle.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        navBarTitle.centerYAnchor.constraint(equalTo: View.centerYAnchor).isActive = true
        navBarTitle.centerXAnchor.constraint(equalTo: View.centerXAnchor).isActive = true
        
        listButton.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
        listButton.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        listButton.centerYAnchor.constraint(equalTo: View.centerYAnchor).isActive = true
        listButton.trailingAnchor.constraint(equalTo: View.trailingAnchor, constant: -20.0).isActive = true
        
    }
    
    class func showFileCountLabel(count:Int, view:UIView, searchCountLabel:UILabel,searchCategoryView:UIStackView, multiButton:UIButton, multiButtonChecked:Bool, selectAllButton:UIButton){
//        multiButton.removeFromSuperview()
        
        print("showFileCountLabel called")
       
        view.addSubview(searchCountLabel)
        view.addSubview(multiButton)
        view.addSubview(selectAllButton)
        searchCountLabel.padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
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
        view.bringSubview(toFront: searchCountLabel)
        
        multiButton.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
        multiButton.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        multiButton.centerYAnchor.constraint(equalTo: searchCountLabel.centerYAnchor).isActive = true
        multiButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        
        if(count > 0) {
            multiButton.isHidden = false
        } else {
            multiButton.isHidden = true
        }
       
        selectAllButton.widthAnchor.constraint(equalToConstant: 80.0).isActive = true
        selectAllButton.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        selectAllButton.centerYAnchor.constraint(equalTo: searchCountLabel.centerYAnchor).isActive = true
        selectAllButton.trailingAnchor.constraint(equalTo: multiButton.leadingAnchor, constant: -20).isActive = true
        
        if(multiButtonChecked){
            selectAllButton.isHidden = false
            
        } else {
            selectAllButton.isHidden = true
        }
        
        
    }
    
  
}
