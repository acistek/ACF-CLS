//
//  CoopTable.swift
//  ACF-CLS
//
//  Created by AcisTek Corporation on 3/23/15.
//  Copyright (c) 2015 AcisTek Corporation. All rights reserved.
//

import Foundation
import CoreData

class CoopTable: NSManagedObject {

    @NSManaged var orderID: String
    @NSManaged var groupName: String
    @NSManaged var coopName: String
    @NSManaged var emailAddress: String
    @NSManaged var cellPhone: String
    @NSManaged var officePhone: String
    @NSManaged var homePhone: String
    @NSManaged var coopTitle: String
    @NSManaged var dataTypeID: String
    @NSManaged var contactListID: String
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, coopName: String, emailAddress: String, groupName: String, coopTitle: String, cellPhone: String, officePhone: String, homePhone: String, orderID: String, dataTypeID: String, contactListID: String) -> CoopTable {
        let newUser = NSEntityDescription.insertNewObjectForEntityForName("CoopTable", inManagedObjectContext: moc) as! CoopTable
        newUser.groupName = groupName
        newUser.emailAddress = emailAddress
        newUser.coopName = coopName
        newUser.coopTitle = coopTitle
        newUser.cellPhone = cellPhone
        newUser.officePhone = officePhone
        newUser.homePhone = homePhone
        newUser.orderID = orderID
        newUser.dataTypeID = dataTypeID
        newUser.contactListID = contactListID
        return newUser
    }


}
