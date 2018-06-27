//
//  NasFileCellController.swift
//  KT
//
//  Created by 이다한 on 2018. 3. 12..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit

class NasFileCellController {
    func setFileListCellController(indexPathRow:Int, collectionView:UICollectionView, multiCheckListState: HomeDeviceCollectionVC.multiCheckListEnum, folderArray:[App.FolderStruct]) -> NasFileListCell {
        let indexPath = IndexPath(row: indexPathRow, section: 0)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NasFileListCell", for: indexPath) as! NasFileListCell
        
        if (multiCheckListState == .active){
            cell.btnMultiCheck.isHidden = false
            cell.btnMultiCheck.tag = indexPath.row
            cell.btnMultiCheck.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnMultiCheckClicked(sender:)), for: .touchUpInside)
            cell.btnOption.isHidden = true
            
        } else {
            cell.btnOption.isHidden = false
            cell.btnMultiCheck.isHidden = true
        }
        if(folderArray[indexPath.row].foldrNm == "..."){
            cell.btnOption.isHidden = true
        }
        let imageString = Util.getFileImageString(fileExtension: folderArray[indexPath.row].etsionNm)
        
        cell.ivSub.image = UIImage(named: imageString)
        cell.optionSHowCheck = 0
        cell.optionHide()
        cell.lblMain.text = folderArray[indexPath.row].fileNm
        cell.lblSub.text = folderArray[indexPath.row].amdDate
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(HomeDeviceCollectionVC.cellSwipeToLeft(sender:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        cell.btnOption.addGestureRecognizer(swipeLeft)
        cell.btnOption.tag = indexPath.row
        cell.btnOption.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnNasOptionClicked(sender:)), for: .touchUpInside)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(HomeDeviceCollectionVC.cellSwipeToLeft(sender:)))
        rightSwipe.direction = UISwipeGestureRecognizerDirection.right
        cell.btnOptionRed.addGestureRecognizer(rightSwipe)
        cell.btnOptionRed.tag = indexPath.row
        cell.btnOptionRed.addTarget(self, action: #selector(HomeDeviceCollectionVC.btnNasOptionClicked(sender:)), for: .touchUpInside)
        
        
        cell.btnOption.isHidden = false
        cell.btnShow.tag = indexPath.row
        cell.btnShow.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionNasFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnAction.tag = indexPath.row
        cell.btnAction.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionNasFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnDwnld.tag = indexPath.row
        cell.btnDwnld.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionNasFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnNas.tag = indexPath.row
        cell.btnNas.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionNasFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnGDrive.tag = indexPath.row
        cell.btnGDrive.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionNasFileShowClicked(sender:)), for: .touchUpInside)
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(HomeDeviceCollectionVC.optionNasFileShowClicked(sender:)), for: .touchUpInside)
        return cell
    }

}


