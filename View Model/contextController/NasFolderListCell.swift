//
//  NasFolderListCell.swift
//  KT
//
//  Created by 이다한 on 2018. 3. 11..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit

class NasFolderListCell: UICollectionViewCell {
    
    
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
        let view1:UIView = UIView(frame: CGRect(x:0,y:0, width: frame.width, height: frame.height))
        view1.layer.masksToBounds = false
        view1.layer.addBorder([UIRectEdge.bottom], color: HexStringToUIColor().getUIColor(hex: App.Color.listBorder), width: 1.0)
        
        addSubview(view1)

        
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
        ivSub.widthAnchor.constraint(equalToConstant: 30).isActive = true
        ivSub.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        lblMain.topAnchor.constraint(equalTo: ivSub.topAnchor).isActive = true
        lblMain.leadingAnchor.constraint(equalTo: ivSub.trailingAnchor, constant: 20).isActive = true
        lblMain.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50).isActive = true
        
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
        
        let layoutGuide = contentView.layoutMarginsGuide
        
        
        optionView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        optionView.widthAnchor.constraint(equalToConstant: App.Size.screenWidth).isActive = true
        optionView.heightAnchor.constraint(equalTo:  heightAnchor).isActive = true
        optionViewTrailingAnchor = optionView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: App.Size.screenWidth)
        optionViewTrailingAnchor?.isActive = true
        
        setupFoldrView()
        
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
    

    @objc func setupFoldrView(){
        for view in optionView.subviews {
            view.removeFromSuperview()
        }
        optionView.layer.addBorder([UIRectEdge.bottom], color: HexStringToUIColor().getUIColor(hex: App.Color.listBorder), width: 1.0)
        optionView.addSubview(btnOptionRed)
        optionView.addSubview(btnDwnld)
        optionView.addSubview(btnNas)
        optionView.addSubview(btnGDrive)
        optionView.addSubview(btnDelete)
        
        
        btnOptionRed.centerYAnchor.constraint(equalTo: optionView.centerYAnchor).isActive = true
        btnOptionRed.widthAnchor.constraint(equalToConstant: 36).isActive = true
        btnOptionRed.heightAnchor.constraint(equalToConstant:  36).isActive = true
        btnOptionRed.leadingAnchor.constraint(equalTo: optionView.leadingAnchor, constant: 25).isActive = true
        
        
        
        btnDwnld.centerYAnchor.constraint(equalTo: optionView.centerYAnchor).isActive = true
        btnDwnld.widthAnchor.constraint(equalToConstant: 60).isActive = true
        btnDwnld.heightAnchor.constraint(equalToConstant:  70).isActive = true
        
        
        btnDwnldTrailingAnchor = btnDwnld.leadingAnchor.constraint(equalTo: btnOptionRed.trailingAnchor, constant: spacing)
        btnDwnldTrailingAnchor?.isActive = true
        btnDwnld.setImage(textToImage(drawText: "다운로드", inImage: UIImage(named: "ico_18dp_contextmenu_dwld")!.withRenderingMode(.alwaysOriginal)), for: .normal)
        
        btnNas.centerYAnchor.constraint(equalTo: optionView.centerYAnchor).isActive = true
        btnNas.widthAnchor.constraint(equalToConstant: 60).isActive = true
        btnNas.heightAnchor.constraint(equalToConstant:  70).isActive = true
        btnNasTrailingAnchor = btnNas.leadingAnchor.constraint(equalTo: btnDwnld.trailingAnchor, constant: spacing)
        btnNasTrailingAnchor?.isActive = true
        
        btnNas.setImage(textToImage2(drawText: "GiGA NAS로\n보내기", inImage: UIImage(named: "ico_18dp_contextmenu_send")!.withRenderingMode(.alwaysOriginal)), for: .normal)
        
        
        btnGDrive.centerYAnchor.constraint(equalTo: optionView.centerYAnchor).isActive = true
        btnGDrive.widthAnchor.constraint(equalToConstant: 60).isActive = true
        btnGDrive.heightAnchor.constraint(equalToConstant:  70).isActive = true
        btnGDrive.leadingAnchor.constraint(equalTo: btnNas.trailingAnchor, constant: spacing).isActive = true
        btnGDrive.setImage(textToImage2(drawText: "G 드라이브로\n보내기", inImage: UIImage(named: "ico_18dp_contextmenu_send")!.withRenderingMode(.alwaysOriginal)), for: .normal)
        
        btnDelete.centerYAnchor.constraint(equalTo: optionView.centerYAnchor).isActive = true
        btnDelete.widthAnchor.constraint(equalToConstant: 60).isActive = true
        btnDelete.heightAnchor.constraint(equalToConstant: 70).isActive = true
        btnDelete.leadingAnchor.constraint(equalTo: btnGDrive.trailingAnchor, constant: spacing).isActive = true
        btnDelete.setImage(textToImage(drawText: "삭제", inImage: UIImage(named: "ico_18dp_contextmenu_del")!.withRenderingMode(.alwaysOriginal)), for: .normal)
        
        
        
        
        print("width: \(optionView.frame.size.width)")
        
        
    }
    
    
    
    func optionShow(spacing:CGFloat, style:Int){
        let layoutGuide = contentView.layoutMarginsGuide
        let width = App.Size.optionWidth
        let spacing = (width - 240) / 4
        
        self.spacing = spacing
        optionViewTrailingAnchor?.isActive = false
        btnDwnldTrailingAnchor?.isActive = false
        btnNasTrailingAnchor?.isActive = false
        btnShowTrailingAnchor?.isActive = false
        btnActionTrailingAnchor?.isActive = false
        print("spacing : \(spacing)")
        print("optionCheck : \(optionSHowCheck)")
        print("style : \(style)")
        //        setupNasView()
        optionViewTrailingAnchor = optionView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: 0)
        optionViewTrailingAnchor?.isActive = true
    
        setupFoldrView()
    
        
    }
    
    @objc func showFolderView(){
        let layoutGuide = contentView.layoutMarginsGuide
        let width = App.Size.optionWidth
        let spacing = (width - 240) / 4
        self.spacing = spacing
        optionViewTrailingAnchor?.isActive = false
        btnDwnldTrailingAnchor?.isActive = false
        btnNasTrailingAnchor?.isActive = false
        btnShowTrailingAnchor?.isActive = false
        btnActionTrailingAnchor?.isActive = false
        optionViewTrailingAnchor = optionView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: 0)
        optionViewTrailingAnchor?.isActive = true
        
        setupFoldrView()
        
        
        
    }
    
    func optionHide(){
        let layoutGuide = contentView.layoutMarginsGuide
        optionViewTrailingAnchor?.isActive = false
        optionViewTrailingAnchor = optionView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: App.Size.screenWidth)
        optionViewTrailingAnchor?.isActive = true
        
    }
    
    func textToImage(drawText text: String, inImage image: UIImage) -> UIImage {
        let textColor = UIColor.lightGray
        let textFont = UIFont(name: "Helvetica", size: 12)!
        let actionSize = CGSize(width: 60, height: 70)
        UIGraphicsBeginImageContextWithOptions(actionSize, false, 0.0)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let textFontAttributes = [
            NSAttributedStringKey.font: textFont,
            NSAttributedStringKey.foregroundColor: textColor,
            NSAttributedStringKey.paragraphStyle: paragraphStyle
            ] as [NSAttributedStringKey : Any]
        let newSize = CGSize(width: 20, height: 20)
        let imageX = (60-20) / 2
        let imageY = (70-20) / 2
        image.draw(in: CGRect(origin: CGPoint(x: imageX, y: imageY-7), size: newSize))
        let textSize = CGSize(width: 60, height: 36)
        let rect = CGRect(origin: CGPoint(x:0, y: imageY + 16), size: textSize)
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    func textToImage2(drawText text: String, inImage image: UIImage) -> UIImage {
        let textColor = UIColor.lightGray
        let textFont = UIFont(name: "Helvetica", size: 10)!
        let actionSize = CGSize(width: 60, height: 70)
        UIGraphicsBeginImageContextWithOptions(actionSize, false, 0.0)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let textFontAttributes = [
            NSAttributedStringKey.font: textFont,
            NSAttributedStringKey.foregroundColor: textColor,
            NSAttributedStringKey.paragraphStyle: paragraphStyle
            ] as [NSAttributedStringKey : Any]
        let newSize = CGSize(width: 20, height: 20)
        let imageX = (60-20) / 2
        let imageY = (70-20) / 2
        image.draw(in: CGRect(origin: CGPoint(x: imageX, y: imageY-13), size: newSize))
        let textSize = CGSize(width: 60, height: 36)
        let rect = CGRect(origin: CGPoint(x:0, y: imageY + 11), size: textSize)
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

