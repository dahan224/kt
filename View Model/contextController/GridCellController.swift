//
//  GridCellController.swift
//  KT
//
//  Created by 이다한 on 2018. 4. 24..
//  Copyright © 2018년 이다한. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage


class GridCellController {
    var dv:HomeDeviceCollectionVC?
    var hv:HomeViewController?
    var cv:UICollectionView?
    func getCell(indexPathRow:Int, folderArray:[App.FolderStruct], multiCheckListState:HomeDeviceCollectionVC.multiCheckListEnum, collectionView:UICollectionView, parentView:HomeDeviceCollectionVC, deviceName:String, viewState:HomeViewController.viewStateEnum, driveFileArray:[App.DriveFileStruct], mainContentState:HomeViewController.mainContentsStyleEnum) -> CollectionViewGridCell {
        let indexPath = IndexPath(row: indexPathRow, section: 0)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewGridCell", for: indexPath) as! CollectionViewGridCell
        
        if mainContentState == .oneViewList {
            var imageString = Util.getFileImageString(fileExtension: folderArray[indexPath.row].etsionNm)
            let fileThumbYn = folderArray[indexPath.row].fileThumbYn
            let fileId:String = "\(folderArray[indexPath.row].fileId)"
            if fileThumbYn == "Y" {
                cell.ivBackground.isHidden = false
                cell.ivMain.isHidden = true
                
                Alamofire.request("\(App.URL.thumbnailLink)\(fileId)").responseImage { response in
                    if let getImage = response.result.value {
                        print("image downloaded: \(getImage)")
                        cell.ivBackground.image = getImage
                    }
                }
            } else {
                //cell.ivMain.image = UIImage(named: imageString)
                cell.ivBackground.isHidden = true
                cell.ivMain.isHidden = false
            }
            cell.ivMain.image = UIImage(named: imageString)
            cell.lblMain.text = folderArray[indexPath.row].fileNm
            let editedDate = folderArray[indexPath.row].amdDate.components(separatedBy: " ")[0]
            var devNm = deviceName
            if devNm == "" {
                devNm = folderArray[indexPath.row].devNm
            }
            
            
            cell.lblSub.text = "\(editedDate) | \(devNm)"
            
            cell.ivSub.image = UIImage(named: imageString)
            
            
        }
        
        if multiCheckListState == .active {
            if mainContentState == .oneViewList {
                if folderArray[indexPathRow].checked {
                    cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
                } else {
                    cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
                }
            } else {
                if driveFileArray[indexPathRow].checked {
                    cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_on-1").withRenderingMode(.alwaysOriginal), for: .normal)
                } else {
                    cell.btnMultiCheck.setImage(#imageLiteral(resourceName: "multi_check_bk").withRenderingMode(.alwaysOriginal), for: .normal)
                }
            }
            
        }
        

        
       
        return cell
    }
    
    
    
    
}
