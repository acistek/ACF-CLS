//
//  NotificationInfo.swift
//  ACF-CLS
//
//  Created by AcisTek Corporation on 2/24/15.
//  Copyright (c) 2015 AcisTek Corporation. All rights reserved.
//

import Foundation

class NotificationInfo {
    var systemID: String
    var systemName: String
    var description: String
    var systemURL: String
    
    init(systemID: String, systemName: String, description: String, systemURL: String){
        self.systemID = systemID
        self.systemName = systemName
        self.description = description
        self.systemURL = systemURL
    }
    
    class func notificationInfoWithJSON(allResults: NSArray) -> [NotificationInfo] {
        
        // Create an empty array of results to append to from this list
        var notificationInfo = [NotificationInfo]()
        
        // Store the results in our table data array
        if allResults.count>0 {
            
            for result in allResults {
                let systemID = result["systemID"] as? String ?? ""
                let systemName = result["systemName"] as? String ?? ""
                let description = result["description"] as? String ?? ""
                let systemURL = result["systemURL"] as? String ?? ""
                
                var newField = NotificationInfo(systemID: systemID, systemName: systemName, description: description, systemURL: systemURL)
                notificationInfo.append(newField)
            }
        }
        return notificationInfo
    }
    
}
