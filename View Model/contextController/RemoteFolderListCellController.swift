//
//  RemoteFolderListCellController.swift
//  KT
//
//  Created by 이다한 on 2018. 3. 20..
//  Copyright © 2018년 이다한. All rights reserved.
//


import UIKit
import SwiftyJSON

class RemoteFolderListCellController {
    var dv:HomeDeviceCollectionVC?
    
    func getCell(indexPathRow:Int, folderArray:[App.FolderStruct], multiCheckListState:HomeDeviceCollectionVC.multiCheckListEnum, collectionView:UICollectionView, parentView:HomeDeviceCollectionVC) -> RemoteFolderListCell {
        let indexPath = IndexPath(row: indexPathRow, section: 0)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RemoteFolderListCell", for: indexPath) as! RemoteFolderListCell
        cell.btnMultiCheck.isHidden = true
        if (multiCheckListState == .active){
             cell.btnOption.isHidden = true
            
        } else {
            cell.btnOption.isHidden = false
            
        }
        cell.btnOption.isHidden = true
        cell.ivSub.image = UIImage(named: "ico_folder")
        cell.optionSHowCheck = 0
        cell.lblMain.text = folderArray[indexPath.row].foldrNm
        cell.lblSub.text = folderArray[indexPath.row].amdDate
        
        return cell
    }
    
    
}

