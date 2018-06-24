//
//  MultiProgressCell.swift
//  KT
//
//  Created by 김영은 on 2018. 4. 30..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit

class MultiProgressCell: UITableViewCell {
    
    var ivIcon:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    let lblMain:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = HexStringToUIColor().getUIColor(hex: "D1D2D4")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        return label
    }()
    
    var ivSub:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var lblSize:UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = HexStringToUIColor().getUIColor(hex: "D1D2D4")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
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
        self.addSubview(ivSub)
        self.addSubview(lblSize)
        
        ivIcon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        ivIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30).isActive = true
        ivIcon.widthAnchor.constraint(equalToConstant: 30).isActive = true
        ivIcon.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        lblMain.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -18).isActive = true
        lblMain.leadingAnchor.constraint(equalTo: ivIcon.trailingAnchor, constant: 25).isActive = true
        lblMain.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -100).isActive = true
        
        ivSub.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 12).isActive = true
        ivSub.leadingAnchor.constraint(equalTo: ivIcon.trailingAnchor, constant: 25).isActive = true
        ivSub.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        ivSub.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        lblSize.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -18).isActive = true
        lblSize.leadingAnchor.constraint(equalTo: lblMain.trailingAnchor, constant: 15).isActive = true
        lblSize.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
