//
//  CoopInfo.swift
//  ACF-CLS
//
//  Created by AcisTek Corporation on 12/30/14.
//  Copyright (c) 2014 AcisTek Corporation. All rights reserved.
//

import Foundation

class CoopInfo {
    var orderID: String
    var contactListID: String
    var groupName: String
    var coopName: String
    var cellPhone: String
    var officePhone: String
    var dataTypeID: String
    var coopTitle: String
    var emailAddress: String
    
    init(orderID: String, contactListID: String, groupName: String, coopName: String, cellPhone: String, officePhone: String, dataTypeID: String, coopTitle: String, emailAddress: String){
        self.orderID = orderID
        self.contactListID = contactListID
        self.groupName = groupName
        self.coopName = coopName
        self.cellPhone = cellPhone
        self.officePhone = officePhone
        self.dataTypeID = dataTypeID
        self.coopTitle = coopTitle
        self.emailAddress = emailAddress
    }
    
    class func coopInfoWithJSON(allResults: NSArray) -> [CoopInfo] {
        
        // Create an empty array of results to append to from this list
        var coopInfo = [CoopInfo]()
        
        // Store the results in our table data array
        if allResults.count>0 {
            
            for result in allResults {
                let orderID = result["orderID"] as? String ?? ""
                let contactListID = result["contactListID"] as? String ?? ""
                let groupName = result["groupName"] as? String ?? ""
                let coopName = result["coopName"] as? String ?? ""
                let cellPhone = result["cellPhone"] as? String ?? ""
                let officePhone = result["officePhone"] as? String ?? ""
                let dataTypeID = result["dataTypeID"] as? String ?? ""
                let coopTitle = result["coopTitle"] as? String ?? ""
                let emailAddress = result["emailAddress"] as? String ?? ""
                
                var newCoop = CoopInfo(orderID: orderID, contactListID: contactListID, groupName: groupName, coopName: coopName, cellPhone: cellPhone, officePhone: officePhone, dataTypeID: dataTypeID, coopTitle: coopTitle, emailAddress: emailAddress)
                coopInfo.append(newCoop)
            }
        }
        return coopInfo
    }
    
}