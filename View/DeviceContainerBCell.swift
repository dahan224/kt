//
//  DeviceContainerBCell.swift
//  KT
//
//  Created by 김영은 on 2018. 2. 21..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit

class DeviceContainerBCell: UITableViewCell {
    

  
    var ivIcon:UIImageView = {
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
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = HexStringToUIColor().getUIColor(hex: "D1D2D4")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let lblMain2:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = HexStringToUIColor().getUIColor(hex: "3f3f3f")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.white
        self.addSubview(ivIcon)
        self.addSubview(lblMain)
        self.addSubview(lblSub)
        self.addSubview(lblMain2)
        ivIcon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        ivIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25).isActive = true
        ivIcon.widthAnchor.constraint(equalToConstant: 40).isActive = true
        ivIcon.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        lblMain.topAnchor.constraint(equalTo: ivIcon.topAnchor).isActive = true
        lblMain.leadingAnchor.constraint(equalTo: ivIcon.trailingAnchor, constant: 15).isActive = true
        lblMain.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        lblMain2.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        lblMain2.leadingAnchor.constraint(equalTo: ivIcon.trailingAnchor, constant: 15).isActive = true
        lblMain2.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        lblSub.topAnchor.constraint(equalTo: lblMain.bottomAnchor).isActive = true
        lblSub.leadingAnchor.constraint(equalTo: ivIcon.trailingAnchor, constant: 15).isActive = true
        lblSub.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
