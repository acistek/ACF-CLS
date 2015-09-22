//
//  PoInfo.swift
//  ACF-CLS
//
//  Created by Acistek on 5/27/15.
//  Copyright (c) 2015 AcisTek Corporation. All rights reserved.
//

import Foundation

class PoInfo {
    var POName: String
    var POShort: String
    var totalUsers: String
    var subtitle: String
    
    init(POName: String, POShort: String, totalUsers:String, subtitle:String){
        self.POName = POName
        self.POShort = POShort
        self.totalUsers = totalUsers
        self.subtitle = subtitle
    }
    
    class func poInfoWithJSON(allResults: NSArray) -> [PoInfo] {
        
        // Create an empty array of Albums to append to from this list
        var poLists = [PoInfo]()
        
        // Store the results in our table data array
        if allResults.count>0 {
            
            // Sometimes iTunes returns a collection, not a track, so we check both for the 'name'
            for result in allResults {
                let POName = result["POName"] as? String ?? ""
                let POShort = result["POShort"] as? String ?? ""
                let totalUsers = result["totalUsers"] as? String ?? ""
                let subtitle = result["subtitle"] as? String ?? ""
                var poList = PoInfo(POName: POName, POShort: POShort, totalUsers: totalUsers, subtitle: subtitle)
                poLists.append(poList)
            }
        }
        return poLists
    }

}