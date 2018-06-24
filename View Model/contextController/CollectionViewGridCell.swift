//
//  FileCollectionViewCell.swift
//  KT
//
//  Created by 이다한 on 2018. 2. 22..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit

class CollectionViewGridCell: UICollectionViewCell {
    
    var ivMain:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
        
    }()
    var ivSub:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
        
    }()

    var bottomView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
//        view.alpha = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view;
    }()
    
    var ivFlagNew:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
        
    }()
    
    let lblMain:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textColor = HexStringToUIColor().getUIColor(hex: "4f4f4f")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        return label
    }()
    let lblSub:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 9)
        label.textColor = HexStringToUIColor().getUIColor(hex: "4f4f4f")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var ivBackground:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
        
    }()

    let btnMultiCheck:UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var btnMultiChecked = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupView(){
        
        btnMultiChecked = false
        
        backgroundColor = UIColor.white
        addSubview(ivBackground)
        addSubview(ivMain)
        addSubview(bottomView)
        addSubview(btnMultiCheck)
        addSubview(ivFlagNew)
        
        btnMultiCheck.widthAnchor.constraint(equalToConstant: 36).isActive = true
        btnMultiCheck.heightAnchor.constraint(equalToConstant:  36).isActive = true
        btnMultiCheck.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        btnMultiCheck.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        btnMultiCheck.isHidden = true
        
        
        
        ivBackground.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        ivBackground.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        ivBackground.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        ivBackground.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        ivMain.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        ivMain.widthAnchor.constraint(equalToConstant: 55).isActive = true
        ivMain.heightAnchor.constraint(equalToConstant: 55).isActive = true
        
        if App.screenHeight > 600 {
            ivMain.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        } else { // se,5s
            ivMain.topAnchor.constraintEqualToSystemSpacingBelow(topAnchor, multiplier: 4).isActive = true
        }
        
        
        bottomView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        bottomView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        bottomView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        bottomView.addSubview(ivSub)
        bottomView.addSubview(lblMain)
        bottomView.addSubview(lblSub)
        
        ivSub.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor).isActive = true
        ivSub.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 8).isActive = true
        ivSub.widthAnchor.constraint(equalToConstant: 30).isActive = true
        ivSub.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        lblMain.topAnchor.constraint(equalTo: ivSub.topAnchor).isActive = true
        lblMain.leadingAnchor.constraint(equalTo: ivSub.trailingAnchor, constant: 8).isActive = true
        lblMain.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor).isActive = true
        lblMain.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        lblSub.topAnchor.constraint(equalTo: lblMain.bottomAnchor).isActive = true
        lblSub.leadingAnchor.constraint(equalTo: ivSub.trailingAnchor, constant: 8).isActive = true
        lblSub.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor).isActive = true
        lblSub.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        
        ivFlagNew.topAnchor.constraint(equalTo: topAnchor).isActive = true
        ivFlagNew.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        ivFlagNew.widthAnchor.constraint(equalToConstant: 30).isActive = true
        ivFlagNew.heightAnchor.constraint(equalToConstant: 30).isActive = true
        ivFlagNew.image = UIImage(named: "new_img")
        ivFlagNew.isHidden = true
        
        
        
    }
    func resetMultiCheck(){
        btnMultiChecked = false
        btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    
}
