//
//  SendFolderSelectCell.swift
//  KT
//
//  Created by 이다한 on 2018. 3. 5..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit

class SendFolderSelectCell: UITableViewCell {
    
    var btnChecked:Int = 0
    var ivIcon:UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    let lblMain:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 18)
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
    let checkButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ico_24dp_done_disable").withRenderingMode(.alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.white
        self.addSubview(ivIcon)
        self.addSubview(lblMain)
        self.addSubview(checkButton)
        ivIcon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        ivIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25).isActive = true
        ivIcon.widthAnchor.constraint(equalToConstant: 40).isActive = true
        ivIcon.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        lblMain.topAnchor.constraint(equalTo: ivIcon.topAnchor).isActive = true
        lblMain.leadingAnchor.constraint(equalTo: ivIcon.trailingAnchor, constant: 15).isActive = true
        lblMain.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        lblMain.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        
        checkButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        checkButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).isActive = true
        checkButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        checkButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
