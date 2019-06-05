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
        //let container   = CKContainer(identifier: "iCloud.com.portablefrontier.CloudKitCoreData")
        database        = container.publicCloudDatabase

        self.setSubscriptions()
    }



    func setSubscriptions() -> Void
    {
        //
        // Detail the process:
        //
        // 1. Fetch all, if any, existing subscriptions on the public database.
        // 2.
        // First, let's find out if I can read the recordType of the existing CKQuerySubscription instances
        database.fetchAllSubscriptions(completionHandler: { /*[unowned self]*/ (iCloudServerSubscriptions, error) in
            if error != nil
            {
                print("Error Reading Subscriptions")
                print(error?.localizedDescription as Any)

                // Might be a good point at which to create some ckQuerySubscriptions
                self.createCountriesCKQuerySubscription()
            }
            else
            {
                // Good news! There are subscriptions. Now let's see if we can read them as CKQuerySubscription instances.
                if let subscriptions = iCloudServerSubscriptions
                {
                    print("Number of subscriptions: \(subscriptions.count)")

                    for subscription in subscriptions // Iteration
                    {
                        //print("Subscription: \(subscription)")

                        // Read subsciption as a CKQuerySubscription instance
                        if let ckQuerySubscription = subscription as? CKQuerySubscription {
                            print("ckQuerySubscription for \(String(describing: ckQuerySubscription.recordType!))")

                            //
                            // This might be a really good place to create a function that takes a trailing closure
                            //
                            // func checkSubscription(completionHandler:{})
                            //
                            // That checks for whether subscriptions from the Subscriptions enum have been created
                            // and, if not, creates the missing subscriptions.
                            //
                            if String(describing: ckQuerySubscription.recordType!) == "Countries" // Recursion
                            {
                                print("You have \(subscriptions.count) CKQuerySubscription instances")
                            }

                            // Maybe do this with all the CKQuerySubscription instances...

                            //
                            // if a ckQuerySubscription with desired recordType exist, say Cheers!
                            // else create such a subscpription...
                            //
                            // But this needs to be at the end of this function and outside of this
                        }


                        // Delete existing subscriptions and start anew!
                        //
                        // Ummm...why?

                        /*
                         // Blow-out the existing subscription
                         self.database.delete(withSubscriptionID: subscription.subscriptionID, completionHandler: { (message, error) in
                         if error != nil
                         {
                         print("Could Not Delete Subscriptions From Public Database")
                         print(error?.localizedDescription as Any)
                         }
                         else
                         {
                         print("I have a message: \(String(describing: message))")
                         }
                         })
                         */

                    }

                    self.createCountriesCKQuerySubscription()
                }
            }
        })
    }


    /*
    enum SubscriptionCheckError: Error
    {
        case subscriptionDoesNotExist
        case cannotReadSubscriptionAsCKQuerySubscription
    }



    func checkCKQuerySubscriptions(subscriptions: [CKSubscription], completionHandler: (CKQuerySubscription?, Error?) -> Void)
    {
        var ckSubscript: CKSubscription?

        for ckSubscript in subscriptions // Iteration
        {
            //print("Subscription: \(subscription)")

            // Read subsciption as a CKQuerySubscription instance
            if let ckQuerySubscription = ckSubscription as? CKQuerySubscription
            {
                print("ckQuerySubscription for \(String(describing: ckQuerySubscription.recordType!))")

                //
                // This might be a really good place to create a function that takes a trailing closure
                //
                // func checkSubscription(completionHandler:{})
                //
                // That checks for whether subscriptions from the Subscriptions enum have been created
                // and, if not, creates the missing subscriptions.
                //
                if String(describing: ckQuerySubscription.recordType!) == "Countries" // Recursion
                {
                    print("You have \(subscriptions.count) CKQuerySubscription instances")
                }

                // Maybe do this with all the CKQuerySubscription instances...

                // Could do an
                //
                // if a ckQuerySubscription with desired recordType exist, say Cheers!
                // else create such a subscpription...
                //
                // But this needs to be at the end of this function and outside of this
            }
            else
            {
                var error = SubscriptionCheckError.cannotReadSubscriptionAsCKQuerySubscription
            }
            /*
            completionHandler()
            {
            }
            */

            print(error)
        }
    }
    */





    func createCountriesCKQuerySubscription() -> Void
    {
        /*
         let predicate       = NSPredicate(value: true)

         let subscription    = CKQuerySubscription(recordType: "Countries", predicate: predicate, options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion])
         let subscriptionID  = subscription.subscriptionID
         let subscriptionType    = subscription.subscriptionType.hashValue
         print("Subscription ID = \(subscriptionID), subscriptionType = \(subscriptionType)")


         let info                        = CKSubscription.NotificationInfo()
         info.shouldSendContentAvailable = true
         info.alertBody                  = "Updates to Countries"
         info.shouldBadge                = true
         subscription.notificationInfo   = info

         database.save(subscription, completionHandler: {
         (subscription, error) in

         if error != nil
         {
         print("Error Creating Subscription")
         print(error?.localizedDescription as Any)
         }
         else
         {
         print("Subscription Saved")
         }
         })
         */
    }



    func insertCountry(name: String)
    {
        let text    = name.trimmingCharacters(in: .whitespaces)

        if text != ""
        {
            let id      = CKRecord.ID(recordName: "idcountry-\(text)-\(UUID())")
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
            let id      = CKRecord.ID(recordName: "idcity-\(text)-\(UUID())")
            let record  = CKRecord(recordType: "Cities", recordID: id)
            record.setObject(text as NSString, forKey: "name")

            let reference = CKRecord.Reference(recordID: selectedCountry, action: .deleteSelf)
            record.setObject(reference, forKey: "country")

            let bundle = Bundle.main

            if let fileURL = bundle.url(forResource: "KSC", withExtension: "png")
            {
                let asset = CKAsset(fileURL: fileURL)
                record.setObject(asset, forKey: "picture")
                print("We've got picture!")
            }

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
        print("ApplicationData updateInterface()")
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
