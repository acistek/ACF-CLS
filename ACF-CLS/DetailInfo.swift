//
//  DetailInfo.swift
//  ACF-CLS
//
//  Created by tran on 2/2/15.
//  Copyright (c) 2015 AcisTek Corporation. All rights reserved.
//

import Foundation

class DetailInfo {
    var fieldName: String
    var fieldValue: String
    
    
    init(fieldName: String, fieldValue: String){
        self.fieldName = fieldName
        self.fieldValue = fieldValue
    }
    
    class func detailInfoWithJSON(allResults: NSArray) -> [DetailInfo] {
        
        // Create an empty array of results to append to from this list
        var detailInfo = [DetailInfo]()
        
        // Store the results in our table data array
        if allResults.count>0 {
            
            for result in allResults {
                let fieldName = result["fieldName"] as? String ?? ""
                let fieldValue = result["fieldValue"] as? String ?? ""
                
                var newField = DetailInfo(fieldName: fieldName, fieldValue: fieldValue)
                detailInfo.append(newField)
            }
        }
        return detailInfo
    }
    
}
