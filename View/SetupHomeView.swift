//
//  SetupHomeView.swift
//  KT
//
//  Created by 이다한 on 2018. 2. 21..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit

class SetupHomeView {
   
    class func setupMainNavbar(View:UIView,navBarTitle:UIButton, hamburgerButton:UIButton, listButton:UIButton,downArrowButton:UIButton){
        
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
        
        navBarTitle.setTitle("GiGA Stroage", for: .normal)
        navBarTitle.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
        navBarTitle.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        navBarTitle.centerYAnchor.constraint(equalTo: View.centerYAnchor).isActive = true
        navBarTitle.centerXAnchor.constraint(equalTo: View.centerXAnchor).isActive = true
        
        downArrowButton.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
        downArrowButton.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        downArrowButton.topAnchor.constraint(equalTo: View.topAnchor).isActive = true
        downArrowButton.leadingAnchor.constraint(equalTo: View.trailingAnchor).isActive = true
        
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
        
        navBarTitle.setTitle("GiGA Stroage", for: .normal)
        navBarTitle.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
        navBarTitle.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        navBarTitle.centerYAnchor.constraint(equalTo: View.centerYAnchor).isActive = true
        navBarTitle.centerXAnchor.constraint(equalTo: View.centerXAnchor).isActive = true
        
        downArrowButton.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
        downArrowButton.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        downArrowButton.topAnchor.constraint(equalTo: View.topAnchor).isActive = true
        downArrowButton.leadingAnchor.constraint(equalTo: View.trailingAnchor).isActive = true
        
    }
    
    
    
    class func setupLatelySearchView(View:UIView, sortButton:UIButton, sBar:UISearchBar, searchDownArrowButton:UIButton, parentViewContoller:UIViewController){
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
}

