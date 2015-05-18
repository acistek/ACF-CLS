//
//  FavoriteInfo.swift
//  ACF-CLS
//
//  Created by AcisTek Corporation on 5/8/15.
//  Copyright (c) 2015 AcisTek Corporation. All rights reserved.
//

import Foundation

class FavoriteInfo {
    var contactListID: String
    var firstName: String
    var lastName: String
    var groupName: String
    var emailAddress: String
    var officePhone: String
    var cellPhone: String
    
    
    init(contactListID: String, firstName: String, lastName: String, groupName: String, emailAddress: String, officePhone: String, cellPhone: String){
        self.contactListID = contactListID
        self.firstName = firstName
        self.lastName = lastName
        self.groupName = groupName
        self.emailAddress = emailAddress
        self.officePhone = officePhone
        self.cellPhone = cellPhone
    }
    
    class func favoriteInfoWithJSON(allResults: NSArray) -> [FavoriteInfo] {
        
        // Create an empty array of results to append to from this list
        var favoriteInfo = [FavoriteInfo]()
        
        // Store the results in our table data array
        if allResults.count>0 {
            
            for result in allResults {
                let contactListID = result["contactListID"] as? String ?? ""
                let firstName = result["firstName"] as? String ?? ""
                let lastName = result["lastName"] as? String ?? ""
                let groupName = result["groupName"] as? String ?? ""
                let emailAddress = result["emailAddress"] as? String ?? ""
                let officePhone = result["officePhone"] as? String ?? ""
                let cellPhone = result["cellPhone"] as? String ?? ""
                
                var newField = FavoriteInfo(contactListID: contactListID, firstName: firstName, lastName: lastName, groupName: groupName, emailAddress: emailAddress, officePhone: officePhone, cellPhone: cellPhone)
                favoriteInfo.append(newField)
            }
        }
        return favoriteInfo
    }
    
}
