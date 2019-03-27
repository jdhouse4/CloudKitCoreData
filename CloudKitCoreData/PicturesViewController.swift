//
//  PicturesViewController.swift
//  CloudKitCoreData
//
//  Created by James Hillhouse IV on 3/26/19.
//  Copyright © 2019 PortableFrontier. All rights reserved.
//

import UIKit
import CloudKit




class PicturesViewController: UIViewController
{

    @IBOutlet weak var cityPicture: UIImageView!
    var selectedCity: CKRecord!



    override func viewDidLoad()
    {
        if selectedCity != nil
        {
            if let asset = selectedCity["picture"] as? CKAsset
            {
                self.cityPicture.image  = UIImage(contentsOfFile: asset.fileURL!.path)
            }
        }
    }
}
