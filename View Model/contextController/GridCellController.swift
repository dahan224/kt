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
    func getCell(indexPathRow:Int, folderArray:[App.FolderStruct], multiCheckListState:HomeDeviceCollectionVC.multiCheckListEnum, collectionView:UICollectionView, parentView:HomeDeviceCollectionVC, deviceName:String, viewState:HomeViewController.viewStateEnum) -> CollectionViewGridCell {
        let indexPath = IndexPath(row: indexPathRow, section: 0)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewGridCell", for: indexPath) as! CollectionViewGridCell
        var imageString = Util.getFileImageString(fileExtension: folderArray[indexPath.row].etsionNm)
        let fileThumbYn = folderArray[indexPath.row].fileThumbYn
        let fileId:String = "\(folderArray[indexPath.row].fileId)"
        if fileThumbYn == "Y" {
            Alamofire.request("https://araise.iptime.org/GIGA_Storage/imgFileThum.do?fileId=\(fileId)").responseImage { response in
                print(response.request)
                print(response.response)
                
                if let getImage = response.result.value {
                    print("image downloaded: \(getImage)")
                    cell.ivMain.image = getImage
                }
            }
        } else {
            cell.ivMain.image = UIImage(named: imageString)
        }
        
        cell.lblMain.text = folderArray[indexPath.row].fileNm
        let editedDate = folderArray[indexPath.row].amdDate.components(separatedBy: " ")[0]
        var devNm = deviceName
        if devNm == "" {
            devNm = folderArray[indexPath.row].devNm
        }
        
        cell.lblSub.text = "\(editedDate) | \(devNm)"
        
        cell.ivSub.image = UIImage(named: imageString)
        
        
        return cell
    }
    

    
    
}
