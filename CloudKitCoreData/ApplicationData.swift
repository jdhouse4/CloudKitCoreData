//
//  ApplicationData.swift
//  CloudKitCoreData
//
//  Created by James Hillhouse IV on 3/7/19.
//  Copyright © 2019 PortableFrontier. All rights reserved.
//

import UIKit
import CloudKit




class ApplicationData
{
    var database: CKDatabase!
    var selectedCountry: CKRecord.ID!
    var listCountries: [CKRecord]   = []
    var listCities: [CKRecord]      = []



    init()
    {
        let container   = CKContainer.default()
        database        = container.publicCloudDatabase
    }



    func insertCountry(name: String)
    {
        let text    = name.trimmingCharacters(in: .whitespaces)

        if text != ""
        {
            let id      = CKRecord.ID(recordName: "idcountry-\(UUID())")
            let record  = CKRecord(recordType: "Countries", recordID: id)
            record.setObject(text as NSString, forKey: "name")

            database.save(record, completionHandler: {(recordSaved, error) in
                if error != nil
                {
                    print("Error: reecord not saved")
                }
                else
                {
                    self.listCountries.append(record)
                    self.updateInterface()
                }
            })
        }
    }



    func insertCity(name: String)
    {
        let text = name.trimmingCharacters(in: .whitespaces)

        if text != ""
        {
            let id      = CKRecord.ID(recordName: "idcity-](UUID())")
            let record  = CKRecord(recordType: "Cities", recordID: id)
            record.setObject(text as NSString, forKey: "name")

            let reference = CKRecord.Reference(recordID: selectedCountry, action: .deleteSelf)
            record.setObject(reference, forKey: "country")

            database.save(record, completionHandler: { (recordSaved, error) in
                if error != nil
                {
                    print("Error: record not saved")
                }
                else
                {
                    self.listCities.append(record)
                    self.updateInterface()
                }
            })
        }
    }



    func readCountries()
    {
        let predicate   = NSPredicate(format: "TRUEPREDICATE")
        let query       = CKQuery(recordType: "Countries", predicate: predicate)

        database.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            if error != nil
            {
                print("Records not found")
            }
            else if let list = records
            {
                self.listCountries = []

                for record in list
                {
                    self.listCountries.append(record)
                }
                self.updateInterface()
            }
        })
    }



    func readCities()
    {
        if selectedCountry != nil
        {
            let predicate   = NSPredicate(format: "country = %@", selectedCountry)
            let query       = CKQuery(recordType: "Cities", predicate: predicate)

            database.perform(query, inZoneWith: nil, completionHandler: {(records, error) in
                if error != nil
                {
                    print("Error: Records not found")
                }
                else if let list = records
                {
                    self.listCities = []

                    for record in list
                    {
                        self.listCities.append(record)
                    }
                    self.updateInterface()
                }
            })
        }
    }



    func updateInterface()
    {
        let main = OperationQueue.main
        main.addOperation ({
            let center  = NotificationCenter.default
            let name    = Notification.Name("UpdateInterface")
            center.post(name: name, object: nil, userInfo: nil)
        })
    }
}




var AppData = ApplicationData()
