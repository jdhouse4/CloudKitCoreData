//
//  CitiesTableViewController.swift
//  CloudKitCoreData
//
//  Created by James Hillhouse IV on 3/22/19.
//  Copyright © 2019 PortableFrontier. All rights reserved.
//

import UIKit
import CloudKit




class CitiesTableViewController: UITableViewController
{

    override func viewDidLoad()
    {
        super.viewDidLoad()

        let center  = NotificationCenter.default
        let name    = Notification.Name("Update Interface")

        center.addObserver(self, selector: #selector(updateInterface(notification:)), name: name, object: nil)

        AppData.readCities()
    }



    override func updateInterface(notification: Notification)
    {
        tableView.reloadData()
    }
}
