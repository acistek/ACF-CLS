//
//  PODtailInfo.swift
//  ACF-CLS
//
//  Created by Acistek on 5/29/15.
//  Copyright (c) 2015 AcisTek Corporation. All rights reserved.
//

import Foundation

class PODetailInfo {
    var LastName: String
    var FirstName: String
    var Division: String
    var DaysNotResponded: String
    var CLSID: String
    
    
    init(LastName: String, FirstName: String, Division:String, DaysNotResponded: String, CLSID: String){
        self.LastName = LastName
        self.FirstName = FirstName
        self.Division = Division
        self.DaysNotResponded = DaysNotResponded
        self.CLSID = CLSID
    }
    
    class func poDetailInfoWithJSON(allResults: NSArray) -> [PODetailInfo] {
        
        // Create an empty array of Albums to append to from this list
        var poDetailLists = [PODetailInfo]()
        
        // Store the results in our table data array
        if allResults.count>0 {
            
            // Sometimes iTunes returns a collection, not a track, so we check both for the 'name'
            for result in allResults {
                let LastName = result["LastName"] as? String ?? ""
                let FirstName = result["FirstName"] as? String ?? ""
                let Division = result["Division"] as? String ?? ""
                let DaysNotResponded = result["DaysNotResponded"] as? String ?? ""
                let CLSID = result["CLSID"] as? String ?? ""
                
                var poDetailList = PODetailInfo(LastName: LastName, FirstName: FirstName, Division: Division, DaysNotResponded:DaysNotResponded, CLSID:CLSID)
                poDetailLists.append(poDetailList)
            }
        }
        return poDetailLists
    }

}