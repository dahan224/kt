//
//  SlideMenuCell1.swift
//  KT
//
//  Created by 이다한 on 2018. 1. 25..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit

class SlideMenuCell1: UITableViewCell {

    @IBOutlet weak var collectionVIew: UICollectionView!
    var DeviceArray:[App.DeviceStruct] = []
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
extension SlideMenuCell1{
    
    func setCollectionViewDataSourceDelegate
        <D: UICollectionViewDataSource & UICollectionViewDelegate>
        (dataSource: D, forRow row: Int) {
        
        collectionVIew.delegate = dataSource
        collectionVIew.dataSource = dataSource
        collectionVIew.tag = row
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.itemSize = CGSize(width: width / 4, height: width / 4 )
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionVIew.collectionViewLayout = layout
        
        collectionVIew.reloadData()
        
  
        
    }

}
