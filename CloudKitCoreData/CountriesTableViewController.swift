//
//  CountriesTableViewController.swift
//  CloudKitCoreData
//
//  Created by James Hillhouse IV on 3/6/19.
//  Copyright © 2019 PortableFrontier. All rights reserved.
//

import UIKit
import CloudKit




class CountriesTableViewController: UITableViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()

        let center  = NotificationCenter.default
        let name    = Notification.Name("UpdateInterface")
        center.addObserver(self, selector: #selector(updateInterface(notification:)), name: name, object: nil)

        AppData.readCountries()
    }



    @objc func updateInterface(notification: Notification)
    {
        print("CountriesTableViewController func updateInterface(notification: Notification)")
        tableView.reloadData()
    }



    // MARK: Table View Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("AppData.listCountries.count = \(AppData.listCountries.count)")
        return AppData.listCountries.count
    }



    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Cranking-out tableview cells...")
        let cell    = tableView.dequeueReusableCell(withIdentifier: "countriesCell", for: indexPath)
        let record  = AppData.listCountries[indexPath.row]

        if let name = record["name"] as? String
        {
            cell.textLabel?.text = name
        }

        print("Finished reading countries!")

        return cell
    }



    // MARK: Target and Action Functions
    @IBAction func addCountry(_ sender: UIBarButtonItem)
    {
        print("Adding a country")
        let alert   = UIAlertController(title: "Insert Country", message: nil, preferredStyle: .alert)
        let cancel  = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        print("Displaying Save Country alert.")

        let action = UIAlertAction(title: "Save", style: .default, handler: { (action) in
            if let fields = alert.textFields
            {
                let name = fields[0].text!
                AppData.insertCountry(name: name)
                print("Saving a country")
            }
        })

        alert.addAction(action)
        alert.addTextField(configurationHandler: nil)
        present(alert, animated: true, completion: nil)
    }



    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        print("\n\nCountriesTableViewController prepare(for segue:, sender:)")

        if segue.identifier == "showCities"
        {
            if let indexPath = self.tableView.indexPathForSelectedRow
            {
                let record = AppData.listCountries[indexPath.row]
                AppData.selectedCountry = record.recordID
            }
        }
    }
}

