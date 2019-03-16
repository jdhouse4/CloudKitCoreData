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


    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var counter: UILabel!
    var kvStorage: NSUbiquitousKeyValueStore!


    override func viewDidLoad()
    {
        super.viewDidLoad()
        kvStorage       = NSUbiquitousKeyValueStore()
        let control     = kvStorage.double(forKey: "control")
        stepper.value   = control
        counter.text    = String(control)

        let center      = NotificationCenter.default
        center.addObserver(self, selector: #selector(valueReceived(notification:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: kvStorage)
    }


    // MARK: Target and Action Functions

    @IBAction func changeValue(_ sender: UIStepper)
    {
        let current     = stepper.value
        counter.text    = String(current)
        kvStorage.set(current, forKey: "control")
        kvStorage.synchronize()
    }


    @objc func valueReceived(notification: Notification)
    {
        let control     = kvStorage.double(forKey: "control")
        stepper.value   = control
        counter.text    = String(control)
    }
}

