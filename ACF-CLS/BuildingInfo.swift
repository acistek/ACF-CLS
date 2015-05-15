//
//  buildingInfo.swift
//  ACF-CLS
//
//  Created by AcisTek Corporation on 12/23/14.
//  Copyright (c) 2014 AcisTek Corporation. All rights reserved.
//

import Foundation

class BuildingInfo {
    var buildingName: String
    var address: String
    var city: String
    var state: String
    var zipcode: String
    var country: String
    var distance: Double
    
    
    init(buildingName: String, address: String, city: String, state: String, zipcode: String, country: String, distance: Double){
        self.buildingName = buildingName
        self.address = address
        self.city = city
        self.state = state
        self.zipcode = zipcode
        self.country = country
        self.distance = distance
    }
    
    class func buildingInfoWithJSON(allResults: NSArray) -> [BuildingInfo] {
        
        // Create an empty array of Albums to append to from this list
        var buildingInfo = [BuildingInfo]()
        
        // Store the results in our table data array
        if allResults.count>0 {
            
            // Sometimes iTunes returns a collection, not a track, so we check both for the 'name'
            for result in allResults {
                let buildingName = result["building"] as? String ?? ""
                let address = result["address"] as? String ?? ""
                let city = result["city"] as? String ?? ""
                let state = result["state"] as? String ?? ""
                let zipcode = result["zipcode"] as? String ?? ""
                let country = result["country"] as? String ?? ""
                let distance = 0.0
                var newBuilding = BuildingInfo(buildingName: buildingName, address: address, city: city, state: state, zipcode: zipcode, country: country, distance: distance)
                buildingInfo.append(newBuilding)
            }
        }
        return buildingInfo
    }
    
}