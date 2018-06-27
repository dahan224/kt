//
//  CollectionViewListCell.swift
//  KT
//
//  Created by 이다한 on 2018. 2. 23..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit

class DeviceListCell: UICollectionViewCell {
    
  
    var ivSub:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
        
    }()
    
  
    
    let lblMain:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = HexStringToUIColor().getUIColor(hex: "3f3f3f")
        label.translatesAutoresizingMaskIntoConstraints = false
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
  
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupView(){
        backgroundColor = UIColor.white
        addSubview(ivSub)
        addSubview(lblMain)
        
        
        ivSub.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        ivSub.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25).isActive = true
        ivSub.widthAnchor.constraint(equalToConstant: 40).isActive = true
        ivSub.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        lblMain.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        lblMain.leadingAnchor.constraint(equalTo: ivSub.trailingAnchor, constant: 30).isActive = true
        lblMain.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        
        
        
        
    }
    
    
}
