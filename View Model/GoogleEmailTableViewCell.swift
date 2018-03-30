//
//  GoogleEmailTableViewCell.swift
//  
//
//  Created by 이다한 on 2018. 3. 29..
//

import UIKit
import BEMCheckBox

class GoogleEmailTableViewCell: UITableViewCell {
    var btnCheck:BEMCheckBox = {
        let button = BEMCheckBox()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        return button
    }()
    
    
    let lblMain:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 18)
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
        self.addSubview(btnCheck)
        self.addSubview(lblMain)
        self.backgroundColor = UIColor.clear
        btnCheck.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        btnCheck.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        btnCheck.widthAnchor.constraint(equalToConstant: 25).isActive = true
        btnCheck.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        lblMain.leadingAnchor.constraint(equalTo: btnCheck.trailingAnchor, constant : 10).isActive = true
        lblMain.trailingAnchor.constraint(equalTo: trailingAnchor, constant : 10).isActive = true
        lblMain.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
