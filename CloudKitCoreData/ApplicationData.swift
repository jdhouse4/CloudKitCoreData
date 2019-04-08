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
        //let container   = CKContainer.default()
        let container   = CKContainer(identifier: "iCloud.com.portablefrontier.CloudKitCoreData")
        database        = container.publicCloudDatabase
    }



    func configureDatabase(executeClosure: @escaping () -> Void)
    {
        print("AppData configureDatabase(executeClosure: @escaping () -> Void)")

        let userSettings = UserDefaults.standard

        if !userSettings.bool(forKey: "subscriptionSaved")
        {
            print("Since there are no subscriptions, a new subscription is needed.")

            let newSubscription = CKDatabaseSubscription(subscriptionID: "updateDatabase")
            print("AppData configureDatabase updateDatabase")

            let info = CKSubscription.NotificationInfo()
            info.shouldSendContentAvailable = true

            newSubscription.notificationInfo = info

            database.save(newSubscription, completionHandler: { (subscription, error) in
                if error != nil
                {
                    print("Error Creating Subscription")
                }
                else
                {
                    userSettings.set(true, forKey: "subscriptionSaved")
                }
            })
        }

        if !userSettings.bool(forKey: "zoneCreated")
        {
            let newZone = CKRecordZone(zoneName: "listPlaces")

            database.save(newZone, completionHandler: { (zone, error) in
                if error != nil
                {
                    print("Error Creating Zone")
                }
                else
                {
                    userSettings.set(true, forKey: "zoneCreated")
                    executeClosure()
                }
            })
        }
        else
        {
            executeClosure()
        }
    }



    func checkUpdates(finishClosure: @escaping (UIBackgroundFetchResult) -> Void)
    {
        configureDatabase(executeClosure: {
            let mainQueue = OperationQueue.main
            mainQueue.addOperation ({
                self.downloadUpdates(finishClosure: finishClosure)
            })
        })
    }



    func downloadUpdates(finishClosure: @escaping (UIBackgroundFetchResult) -> Void)
    {
        var changeToken: CKServerChangeToken!
        var changeZoneToken: CKServerChangeToken!

        let userSettings = UserDefaults.standard

        if let data = userSettings.value(forKey: "changeToken") as? Data
        {
            if let token = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: data)
            {
                changeToken = token
            }
        }

        if let data = userSettings.value(forKey: "changeZoneToken") as? Data
        {
            if let token = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: data)
            {
                changeZoneToken = token
            }
        }

        var zonesIDs: [CKRecordZone.ID] = []

        let operation = CKFetchDatabaseChangesOperation(previousServerChangeToken: changeToken)
        operation.recordZoneWithIDChangedBlock = { (zoneID) in
            zonesIDs.append(zoneID)
        }

        operation.changeTokenUpdatedBlock = { (token) in
            changeToken = token
        }

        operation.fetchDatabaseChangesCompletionBlock = { (token, more, error) in
            if error != nil
            {
                finishClosure(UIBackgroundFetchResult.failed)
            }

            else if !zonesIDs.isEmpty
            {
                changeToken = token

                let configuration = CKFetchRecordZoneChangesOperation.ZoneConfiguration()
                configuration.previousServerChangeToken = changeZoneToken

                let fetchOperation = CKFetchRecordZoneChangesOperation(recordZoneIDs: zonesIDs, configurationsByRecordZoneID: [zonesIDs[0]: configuration])

                fetchOperation.recordChangedBlock = { (record) in
                    if record.recordType == "Countries"
                    {
                        let index = self.listCountries.firstIndex(where: { (item) in
                            return item.recordID == record.recordID
                        })

                        if index != nil
                        {
                            self.listCountries[index!] = record
                        }
                        else
                        {
                            self.listCountries.append(record)
                        }
                    }
                    else if record.recordType == "Cities"
                    {
                        if let country = record["country"] as? CKRecord.Reference
                        {
                            if country.recordID == self.selectedCountry
                            {
                                let index = self.listCities.firstIndex(where: { (item) in
                                    return item.recordID == record.recordID
                                })
                                if index != nil
                                {
                                    self.listCities[index!] = record
                                }
                                else
                                {
                                    self.listCities.append(record)
                                }
                            }
                        }
                    }
                }

                fetchOperation.recordWithIDWasDeletedBlock = { ( recordID, recordType) in
                    if recordType == "Countries"
                    {
                        let index = self.listCountries.firstIndex(where: { ( item ) in
                            return item.recordID == recordID
                        })
                        if index != nil
                        {
                            self.listCountries.remove(at: index!)
                        }
                    }
                    else if recordType == "Cities"
                    {
                        let index = self.listCities.firstIndex(where: { ( item ) in
                            return item.recordID == recordID
                        })
                        if index != nil
                        {
                            self.listCities.remove(at: index!)
                        }
                    }
                }

                fetchOperation.recordZoneChangeTokensUpdatedBlock = { ( zoneID, token, data) in
                    changeZoneToken = token
                }

                fetchOperation.recordZoneFetchCompletionBlock = { ( zoneID, token, data, more, error ) in
                    if error != nil
                    {
                        print("Error")
                    }
                    else
                    {
                        changeZoneToken = token
                    }
                }

                fetchOperation.fetchRecordZoneChangesCompletionBlock = { ( error ) in
                    if error != nil
                    {
                        finishClosure(UIBackgroundFetchResult.failed)
                    }
                    else
                    {
                        if changeToken != nil
                        {
                            if let data = try? NSKeyedArchiver.archivedData(withRootObject: changeToken!, requiringSecureCoding: false)
                            {
                                userSettings.set(data, forKey: "changeToken")
                            }
                        }

                        if changeZoneToken != nil
                        {
                            if let data = try? NSKeyedArchiver.archivedData(withRootObject: changeZoneToken!, requiringSecureCoding: false)
                            {
                                userSettings.set(data, forKey: "changeZoneToken")
                            }
                        }

                        self.updateInterface()

                        finishClosure(UIBackgroundFetchResult.newData)
                    }
                }

                self.database.add(fetchOperation)
            }

            else
            {
                finishClosure(UIBackgroundFetchResult.noData)
            }
        }

        database.add(operation)
    }



    func insertCountry(name: String)
    {
        configureDatabase(executeClosure: {

            let mainQueue = OperationQueue.main
            mainQueue.addOperation( {

                let text    = name.trimmingCharacters(in: .whitespaces)

                if text != ""
                {
                    let zone    = CKRecordZone(zoneName: "listPlaces")
                    let id      = CKRecord.ID(recordName: "idcountry-\(UUID())", zoneID: zone.zoneID)
                    let record  = CKRecord(recordType: "Countries", recordID: id)
                    record.setObject(text as NSString, forKey: "name")

                    self.database.save(record, completionHandler: {(recordSaved, error) in
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
            })
        })
    }



    func insertCity(name: String)
    {
        configureDatabase(executeClosure: {

            let mainQueue = OperationQueue.main
            mainQueue.addOperation( {

                let text = name.trimmingCharacters(in: .whitespaces)

                if text != ""
                {
                    let zone    = CKRecordZone(zoneName: "listPlaces")
                    let id      = CKRecord.ID(recordName: "idcity-\(UUID())", zoneID: zone.zoneID)
                    let record  = CKRecord(recordType: "Cities", recordID: id)
                    record.setObject(text as NSString, forKey: "name")

                    let reference = CKRecord.Reference(recordID: self.selectedCountry, action: .deleteSelf)
                    record.setObject(reference, forKey: "country")

                    let bundle = Bundle.main

                    if let fileURL = bundle.url(forResource: "KSC", withExtension: "png")
                    {
                        let asset = CKAsset(fileURL: fileURL)
                        record.setObject(asset, forKey: "picture")
                        print("We've got picture!")
                    }

                    self.database.save(record, completionHandler: { (recordSaved, error) in
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
            })
        })
    }



    func readCountries()
    {
        print("Reading countries")
        //let predicate   = NSPredicate(format: "TRUEPREDICATE")
        let predicate   = NSPredicate(value: true)
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
                    print("self.listCountries.append(record): \(record)")
                }
                self.updateInterface()
            }
        })
    }



    func readCities()
    {
        print("Reading cities")

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
                        print("readCities \(record)")
                    }
                    self.updateInterface()
                }
            })
        }
    }



    func updateInterface()
    {
        print("ApplicationData func updateInterface()")
        let main = OperationQueue.main
        main.addOperation ({
            let center  = NotificationCenter.default
            let name    = Notification.Name("UpdateInterface")
            center.post(name: name, object: nil, userInfo: nil)
            print("Posting: \(name)")
        })
    }
}




var AppData = ApplicationData()
