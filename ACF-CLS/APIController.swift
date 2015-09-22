//
//  APIController.swift
//  ACF-CLS
//
//  Created by AcisTek Corporation on 12/16/14.
//  Copyright (c) 2014 AcisTek Corporation. All rights reserved.
//

import Foundation

protocol APIControllerProtocol{
    func didReveiveAPIResults(results: NSDictionary)
}

class APIController{
    
    var delegate: APIControllerProtocol
    
    init(delegate:APIControllerProtocol){
        self.delegate = delegate
    }
    
    func searchUserFor(searchTerm: String, fromRow: Int, toRow: Int) {
        
        // The user API wants multiple terms separated by + symbols, so replace spaces with + signs
        let userSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        
        // Now escape anything else that isn't URL-friendly
        if let escapedSearchTerm = userSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            let authorizedJson = SharedClass().authorizedJson()
            let urlPath = SharedClass().clsLink + "/json/search_dsp.cfm?term=\(escapedSearchTerm)&from=\(fromRow)&to=\(toRow)&deviceIdentifier=\(authorizedJson.deviceIdentifier)&loginUUID=\(authorizedJson.loginUUID)"
            let url = NSURL(string: urlPath)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
                //println("Task completed")
                if(error != nil) {
                    // If there is an error in the web request, print it to the console
                    println(error.localizedDescription)
                }
                var err: NSError?
                
                var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as! NSDictionary
                if(err != nil) {
                    // If there is an error parsing JSON, print it to the console
                    println("JSON Error \(err!.localizedDescription)")
                }
                let res = response as! NSHTTPURLResponse!
                if(res != nil){
                    if (res.statusCode >= 200 && res.statusCode < 300){
                        self.delegate.didReveiveAPIResults(jsonResult)
                    }else{
                        var jsonResult: NSDictionary = ["resultCount":0,"error_message":"System is Temporarily Unavailable","results":[]] as NSDictionary
                        self.delegate.didReveiveAPIResults(jsonResult)
                    }
                }else{
                    var jsonResult: NSDictionary = ["resultCount":0,"error_message":"System is Temporarily Unavailable","results":[]] as NSDictionary
                    self.delegate.didReveiveAPIResults(jsonResult)
                }
            })
            task.resume()
        }
    }
}