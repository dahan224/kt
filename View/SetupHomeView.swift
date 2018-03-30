//
//  SetupHomeView.swift
//  KT
//
//  Created by 이다한 on 2018. 2. 21..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit

class SetupHomeView {
   
    class func setupMainNavbar(View:UIView,navBarTitle:UIButton, hamburgerButton:UIButton, listButton:UIButton,downArrowButton:UIButton, title:String){
        
        View.addSubview(hamburgerButton)
        View.addSubview(navBarTitle)
        View.addSubview(listButton)
        View.addSubview(downArrowButton)
        
        hamburgerButton.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
        hamburgerButton.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        hamburgerButton.centerYAnchor.constraint(equalTo: View.centerYAnchor).isActive = true
        hamburgerButton.leadingAnchor.constraint(equalTo: View.leadingAnchor, constant: 20.0).isActive = true
        
        listButton.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
        listButton.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        listButton.centerYAnchor.constraint(equalTo: View.centerYAnchor).isActive = true
        listButton.trailingAnchor.constraint(equalTo: View.trailingAnchor, constant: -20.0).isActive = true
        
//        navBarTitle.setTitle("GiGA Stroage", for: .normal)
        navBarTitle.setTitle(title, for: .normal)
        navBarTitle.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
        navBarTitle.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        navBarTitle.centerYAnchor.constraint(equalTo: View.centerYAnchor).isActive = true
        navBarTitle.centerXAnchor.constraint(equalTo: View.centerXAnchor).isActive = true
        
        downArrowButton.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
        downArrowButton.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        downArrowButton.topAnchor.constraint(equalTo: navBarTitle.topAnchor).isActive = true
        downArrowButton.leadingAnchor.constraint(equalTo: navBarTitle.trailingAnchor).isActive = true
        
    }
    
    
    
    class func setupMainSearchView(View:UIView, sortButton:UIButton, sBar:UISearchBar, searchDownArrowButton:UIButton, parentViewContoller:UIViewController){
        var previous = parentViewContoller.childViewControllers.first
        if let previous = previous {
            previous.willMove(toParentViewController: nil)
            previous.view.removeFromSuperview()
            previous.removeFromParentViewController()
        }
        View.addSubview(sortButton)
        View.addSubview(sBar)
        View.addSubview(searchDownArrowButton)
        
        sortButton.translatesAutoresizingMaskIntoConstraints = false
        sortButton.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
        sortButton.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        sortButton.centerYAnchor.constraint(equalTo: View.centerYAnchor).isActive = true
        sortButton.leadingAnchor.constraint(equalTo: View.leadingAnchor, constant: 10.0).isActive = true
        
        
        
        sBar.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        sBar.centerYAnchor.constraint(equalTo: View.centerYAnchor).isActive = true
        sBar.heightAnchor.constraint(equalTo: View.heightAnchor).isActive = true
        sBar.leadingAnchor.constraint(equalTo: sortButton.trailingAnchor, constant: 20.0).isActive = true
        sBar.trailingAnchor.constraint(equalTo: View.trailingAnchor).isActive = true
        
        
        searchDownArrowButton.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
        searchDownArrowButton.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        searchDownArrowButton.centerYAnchor.constraint(equalTo: View.centerYAnchor).isActive = true
        searchDownArrowButton.trailingAnchor.constraint(equalTo: View.trailingAnchor, constant: -15.0).isActive = true
        searchDownArrowButton.isHidden = true
        
        
    }
    
    class func setuplatelyNavbar(View:UIView,navBarTitle:UIButton, hamburgerButton:UIButton, listButton:UIButton,downArrowButton:UIButton){
        View.addSubview(hamburgerButton)
        View.addSubview(navBarTitle)
        View.addSubview(listButton)
        View.addSubview(downArrowButton)
        
        hamburgerButton.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
        hamburgerButton.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        hamburgerButton.centerYAnchor.constraint(equalTo: View.centerYAnchor).isActive = true
        hamburgerButton.leadingAnchor.constraint(equalTo: View.leadingAnchor, constant: 20.0).isActive = true
        
        listButton.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
        listButton.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        listButton.centerYAnchor.constraint(equalTo: View.centerYAnchor).isActive = true
        listButton.trailingAnchor.constraint(equalTo: View.trailingAnchor, constant: -20.0).isActive = true
        
        navBarTitle.setTitle("최근 업데이트 파일", for: .normal)
        navBarTitle.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
        navBarTitle.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        navBarTitle.centerYAnchor.constraint(equalTo: View.centerYAnchor).isActive = true
        navBarTitle.centerXAnchor.constraint(equalTo: View.centerXAnchor).isActive = true
        navBarTitle.isEnabled = false
        
        downArrowButton.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
        downArrowButton.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        downArrowButton.topAnchor.constraint(equalTo: View.topAnchor).isActive = true
        downArrowButton.leadingAnchor.constraint(equalTo: View.trailingAnchor).isActive = true
        
    }
    
    
    
    class func setupLatelySearchView(searchView:UIView, multiButton:UIButton){
       
        
        for view in searchView.subviews {
            view.removeFromSuperview()
        }
        
        let label = UILabel()
        searchView.addSubview(label)
        searchView.addSubview(multiButton)
        label.textAlignment = .left
        label.text = ">최근 업데이트 파일"
        label.textColor = HexStringToUIColor().getUIColor(hex: "4f4f4f")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 200.0).isActive = true
        label.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        label.centerYAnchor.constraint(equalTo: searchView.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: searchView.leadingAnchor, constant: 10.0).isActive = true
        
        
        multiButton.isHidden = false
        multiButton.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
        multiButton.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        multiButton.centerYAnchor.constraint(equalTo: searchView.centerYAnchor).isActive = true
        multiButton.trailingAnchor.constraint(equalTo: searchView.trailingAnchor, constant: -10.0).isActive = true
      
        
    }
}

