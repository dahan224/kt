//
//  SetupFolderInsideCollectionView.swift
//  KT
//
//  Created by 이다한 on 2018. 2. 23..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit

class SetupFolderInsideCollectionView {
    
    class func searchView(searchView:UIView, searchButton:UIButton, sortButton:UIButton, customNavBar:UIView, hamburgerButton:UIButton, listButton:UIButton, multiButton:UIButton, navBarTitle:UIButton, getFolerName:String, getDeviceName:String, listStyle:HomeViewController.listViewStyleEnum){
        
        
        for view in searchView.subviews {
            view.removeFromSuperview()
        }
        
        let label = UILabel()
        searchView.addSubview(label)
        searchView.addSubview(sortButton)
        searchView.addSubview(searchButton)
        searchView.addSubview(multiButton)
        label.textAlignment = .left
        label.text = ">GiGA NAS"
        label.textColor = HexStringToUIColor().getUIColor(hex: "4f4f4f")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 200.0).isActive = true
        label.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        label.centerYAnchor.constraint(equalTo: searchView.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: searchView.leadingAnchor, constant: 10.0).isActive = true
        
        
        
        searchButton.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
        searchButton.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        searchButton.centerYAnchor.constraint(equalTo: searchView.centerYAnchor).isActive = true
        searchButton.trailingAnchor.constraint(equalTo: searchView.trailingAnchor, constant: -34.0).isActive = true
        
        sortButton.translatesAutoresizingMaskIntoConstraints = false
        sortButton.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
        sortButton.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        sortButton.centerYAnchor.constraint(equalTo: searchView.centerYAnchor).isActive = true
        sortButton.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -5.0).isActive = true
        
        if(listStyle == .list) {
            multiButton.isHidden = false
            multiButton.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
            multiButton.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
            multiButton.centerYAnchor.constraint(equalTo: searchView.centerYAnchor).isActive = true
            multiButton.trailingAnchor.constraint(equalTo: sortButton.leadingAnchor, constant: -5.0).isActive = true
        } else {
            multiButton.isHidden = true
        }
        
        for view in customNavBar.subviews {
            view.removeFromSuperview()
        }
        
        customNavBar.addSubview(hamburgerButton)
        customNavBar.addSubview(navBarTitle)
        customNavBar.addSubview(listButton)
        
        hamburgerButton.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
        hamburgerButton.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        hamburgerButton.centerYAnchor.constraint(equalTo: customNavBar.centerYAnchor).isActive = true
        hamburgerButton.leadingAnchor.constraint(equalTo: customNavBar.leadingAnchor, constant: 20.0).isActive = true
        
        listButton.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
        listButton.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        listButton.centerYAnchor.constraint(equalTo: customNavBar.centerYAnchor).isActive = true
        listButton.trailingAnchor.constraint(equalTo: customNavBar.trailingAnchor, constant: -20.0).isActive = true
        
        navBarTitle.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
        navBarTitle.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        navBarTitle.centerYAnchor.constraint(equalTo: customNavBar.centerYAnchor).isActive = true
        navBarTitle.centerXAnchor.constraint(equalTo: customNavBar.centerXAnchor).isActive = true      
        label.text = "> \(getFolerName)"
        navBarTitle.setTitle(getDeviceName, for: .normal)
  
    }
}
