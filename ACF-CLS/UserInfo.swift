//
//  UserInfo.swift
//  ACF-CLS
//
//  Created by AcisTek Corporation on 12/16/14.
//  Copyright (c) 2014 AcisTek Corporation. All rights reserved.
//

import Foundation

class UserInfo {
    var firstName: String
    var lastName: String
    var contactListID: String
    var title: String
    var emailAddress: String
    var cellPhone: String
    var officePhone: String
    
    
    init(firstName: String, lastName: String, contactListID: String, title: String, emailAddress: String, cellPhone: String, officePhone: String){
        self.firstName = firstName
        self.lastName = lastName
        self.contactListID = contactListID
        self.title = title
        self.emailAddress = emailAddress
        self.cellPhone = cellPhone
        self.officePhone = officePhone
    }
    
    class func usersInfoWithJSON(allResults: NSArray) -> [UserInfo] {
        
        // Create an empty array of Albums to append to from this list
        var usersInfo = [UserInfo]()
        
        // Store the results in our table data array
        if allResults.count>0 {
            
            // Sometimes iTunes returns a collection, not a track, so we check both for the 'name'
            for result in allResults {
                let firstName = result["firstName"] as? String ?? ""
                let lastName = result["lastName"] as? String ?? ""
                let contactListID = result["contactListID"] as? String ?? ""
                let title = result["title"] as? String ?? ""
                let emailAddress = result["emailAddress"] as? String ?? ""
                let cellPhone = result["cellPhone"] as? String ?? ""
                let officePhone = result["officePhone"] as? String ?? ""
                
                var newUser = UserInfo(firstName: firstName, lastName: lastName, contactListID: contactListID, title: title, emailAddress: emailAddress, cellPhone: cellPhone, officePhone: officePhone)
                usersInfo.append(newUser)
            }
        }
        return usersInfo
    }
    
}
