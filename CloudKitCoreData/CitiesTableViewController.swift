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
        let name    = Notification.Name("UpdateInterface")

        center.addObserver(self, selector: #selector(updateInterface(notification:)), name: name, object: nil)

        AppData.readCities()
    }



    @objc func updateInterface(notification: Notification)
    {
        print("CiiesTableViewController func updateInterface(notification: Notification)")
        tableView.reloadData()
    }



    // MARK: Table View Controller Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        print("AppData.listCiies.count = \(AppData.listCities.count)")
        return AppData.listCities.count
    }



    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "citiesCell", for: indexPath)
        let record = AppData.listCities[indexPath.row]

        if let name = record["name"] as? String
        {
            cell.textLabel?.text = name
        }

        return cell
    }



    // MARK: Target and Action Functions
    @IBAction func addCity(_sender: UIBarButtonItem)
    {
        let alert = UIAlertController(title: "Insert City", message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)

        let action = UIAlertAction(title: "Save", style: .default, handler: { (action) in
            if let fields = alert.textFields
            {
                let name = fields[0].text!
                AppData.insertCity(name: name)
            }
        })

        alert.addAction(action)
        alert.addTextField(configurationHandler: nil)
        present(alert, animated: true, completion: nil)
    }
}
