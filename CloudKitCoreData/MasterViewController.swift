//
//  MasterViewController.swift
//  CloudKitCoreData
//
//  Created by James Hillhouse IV on 3/31/19.
//  Copyright © 2019 PortableFrontier. All rights reserved.
//

import UIKit




class MasterViewController: UIViewController
{

    private var countriesTableViewController: CountriesTableViewController?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addCountryBarButton: UIBarButtonItem!



    override func viewDidLoad() {
        super.viewDidLoad()

        guard let countriesController = children.first as? CountriesTableViewController else {
            fatalError("Check storyboard for missing CountriesTableViewController")
        }

        countriesTableViewController = countriesController

        activityIndicator.layer.cornerRadius = 5
    }



    @IBAction func addCountry(_ sender: Any)
    {
        countriesTableViewController?.addCountry(addCountryBarButton)
    }
}
