//
//  CitiesViewController.swift
//  CloudKitCoreData
//
//  Created by James Hillhouse IV on 4/1/19.
//  Copyright © 2019 PortableFrontier. All rights reserved.
//

import UIKit




final class CitiesViewController: UIViewController
{

    private var citiesTableViewController: CitiesTableViewController?
    @IBOutlet weak var citiesActivityIndicator: UIActivityIndicatorView!
    


    override func viewDidLoad() {
        super.viewDidLoad()

        guard let citiesController = children.first as? CitiesTableViewController else {
            fatalError("Check storyboard for missing CitiesTableViewController")
        }

        citiesTableViewController = citiesController

        citiesActivityIndicator.layer.cornerRadius = 5
    }

}
