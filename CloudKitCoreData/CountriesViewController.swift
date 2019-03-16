//
//  CountriesViewController.swift
//  CloudKitCoreData
//
//  Created by James Hillhouse IV on 3/6/19.
//  Copyright © 2019 PortableFrontier. All rights reserved.
//

import UIKit
import CloudKit




class CountriesViewController: UIViewController
{



    override func viewDidLoad()
    {
        super.viewDidLoad()

        let center      = NotificationCenter.default
        center.addObserver(self, selector: #selector(valueReceived(notification:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: kvStorage)
    }


    // MARK: Target and Action Functions

}

