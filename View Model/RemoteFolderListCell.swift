//
//  RemoteFolderListCell.swift
//  KT
//
//  Created by 이다한 on 2018. 3. 20..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit

class RemoteFolderListCell: UICollectionViewCell {
    
    
    var ivSub:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
        
    }()
    
    
    
    let lblMain:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = HexStringToUIColor().getUIColor(hex: "4f4f4f")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let lblSub:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = HexStringToUIColor().getUIColor(hex: "919191")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let lblDevice:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = HexStringToUIColor().getUIColor(hex: "919191")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    let btnOption:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ico_36dp_context_open").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let btnOptionRed:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ico_36dp_context_close").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let optionView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view;
    }()
    let btnShow:UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let btnAction:UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let btnDwnld:UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let btnNas:UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let btnGDrive:UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let btnDelete:UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let btnMultiCheck:UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var btnMultiChecked = false
    
    var optionViewTrailingAnchor:NSLayoutConstraint?
    var btnDwnldTrailingAnchor:NSLayoutConstraint?
    var btnShowTrailingAnchor:NSLayoutConstraint?
    var btnActionTrailingAnchor:NSLayoutConstraint?
    var btnNasTrailingAnchor:NSLayoutConstraint?
    var btnMultiCheckLeadingAnchor:NSLayoutConstraint?
    
    var optionSHowCheck = 0
    var spacing:CGFloat = 0
    
    var contextMenuStyle = HomeDeviceCollectionVC.contextMenuEnum.nas
    
    var deviceShow = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if(subviews.contains(ivSub)){
            for view in subviews{
                view.removeFromSuperview()
            }
            
        }
        
        
        optionSHowCheck = 0
        btnMultiChecked = false
        backgroundColor = UIColor.white
        addSubview(ivSub)
        addSubview(lblMain)
        addSubview(lblSub)
        addSubview(lblDevice)
        addSubview(btnMultiCheck)
        addSubview(btnOption)
        addSubview(optionView)
        
        
        btnMultiCheck.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        btnMultiCheck.widthAnchor.constraint(equalToConstant: 36).isActive = true
        btnMultiCheck.heightAnchor.constraint(equalToConstant:  36).isActive = true
        btnMultiCheckLeadingAnchor = btnMultiCheck.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 36)
        btnMultiCheckLeadingAnchor?.isActive = true
        
        btnMultiCheck.isHidden = true
        
        ivSub.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        ivSub.leadingAnchor.constraint(equalTo: btnMultiCheck.trailingAnchor, constant: 25).isActive = true
        ivSub.widthAnchor.constraint(equalToConstant: 20).isActive = true
        ivSub.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        
        
        
        lblMain.topAnchor.constraint(equalTo: ivSub.topAnchor).isActive = true
        lblMain.leadingAnchor.constraint(equalTo: ivSub.trailingAnchor, constant: 20).isActive = true
        lblMain.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 20).isActive = true
        
        
        lblSub.topAnchor.constraint(equalTo: lblMain.bottomAnchor).isActive = true
        lblSub.leadingAnchor.constraint(equalTo: ivSub.trailingAnchor, constant: 20).isActive = true
        lblSub.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        let width = App.Size.screenWidth / 2
        lblDevice.topAnchor.constraint(equalTo: lblMain.bottomAnchor).isActive = true
        lblDevice.leadingAnchor.constraint(equalTo: lblMain.leadingAnchor, constant: width).isActive = true
        lblDevice.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 20).isActive = true
        
        btnOption.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        btnOption.widthAnchor.constraint(equalToConstant: 36).isActive = true
        btnOption.heightAnchor.constraint(equalToConstant:  36).isActive = true
        btnOption.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        btnOption.isHidden = true
        let layoutGuide = contentView.layoutMarginsGuide
        
       
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func multiCheck(){
        
    }
    
    func resetMultiCheck(){
        btnMultiChecked = false
        btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
}

