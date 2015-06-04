//
//  PODetailVIewController.swift
//  ACF-CLS
//
//  Created by Acistek on 5/29/15.
//  Copyright (c) 2015 AcisTek Corporation. All rights reserved.
//

import UIKit

class PODetailVIewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var POShort:String = ""
    var POName:String = ""
    var jsonResult: NSDictionary = [String:String]()
    var PODetailList = [PODetailInfo]()
    let cellIdentifier = "poDetailCell"
    
    @IBOutlet weak var detailView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        if !Reachability.isConnectedToNetwork(){
            SharedClass().connectionAlert(self)
        }else{
            self.detailView.addSubview(self.activityIndicatorView)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            activityIndicatorView.startAnimating()
            let authorizedJson = SharedClass().authorizedJson()
            var url = NSURL(string: SharedClass().clsLink + "/json/PODetail.cfm?office=\(POShort)&deviceIdentifier=\(authorizedJson.deviceIdentifier)&loginUUID=\(authorizedJson.loginUUID)")
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
                if(error != nil) {
                    // If there is an error in the web request, print it to the console
                    println(error.localizedDescription)
                }
                var err: NSError?
                let res = response as! NSHTTPURLResponse!
                if(res != nil){
                    if (res.statusCode >= 200 && res.statusCode < 300){
                        self.jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as! NSDictionary
                        if(err != nil) {
                            // If there is an error parsing JSON, print it to the console
                            println("JSON Error \(err!.localizedDescription)")
                        }
                        var resultsArr: NSArray = self.jsonResult["results"] as! NSArray
                        dispatch_async(dispatch_get_main_queue(), {
                            self.PODetailList = PODetailInfo.poDetailInfoWithJSON(resultsArr)
                            self.detailView!.reloadData()
                            self.activityIndicatorView.stopAnimating()
                            self.activityIndicatorView.hidden = true
                        })
                    }
                    else{
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        self.activityIndicatorView.stopAnimating()
                        SharedClass().serverAlert(self)
                    }
                }else{
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    self.activityIndicatorView.stopAnimating()
                    SharedClass().serverAlert(self)
                }
            })
            task.resume()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PODetailList.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var t_height: CGFloat = 55.00
        let poDetailList = self.PODetailList[indexPath.row]
        if(poDetailList.LastName == "POName"){
            t_height = 40.0
        }else if(poDetailList.LastName == "WithEmail" || poDetailList.LastName == "ExternalEmail" || poDetailList.LastName == "noEmail"){
            t_height = 20.0
        }
        else if(poDetailList.LastName == "officeTitle"){
            t_height = 20.0
        }
        else{
            t_height = 40.0
        }
        return t_height
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let SecondTitleColor = UIColor(red: 222/255.0, green: 229/255.0, blue: 222/255.0, alpha: 1.0)
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.textLabel?.textAlignment = NSTextAlignment.Center
        let poDetailList = self.PODetailList[indexPath.row]
        if(poDetailList.LastName == "POName"){
            cell.backgroundColor = SharedClass().coopGroupHeaderColor
            let selectedColor = UIView()
            selectedColor.backgroundColor = SharedClass().coopGroupHeaderColor
            cell.selectedBackgroundView = selectedColor
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.textLabel?.font = UIFont.boldSystemFontOfSize(14.0)
            cell.textLabel?.textAlignment = .Left
            cell.accessoryType = .None
            var t_header = ""
            t_header = POName
            cell.textLabel?.text = t_header
            cell.detailTextLabel?.text = ""
            cell.userInteractionEnabled = false;
        }else if(poDetailList.LastName == "WithEmail" || poDetailList.LastName == "ExternalEmail" || poDetailList.LastName == "noEmail"){
            cell.backgroundColor = SecondTitleColor
            let selectedColor = UIView()
            let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
            let underlineAttributedString = NSAttributedString(string: poDetailList.FirstName, attributes: underlineAttribute)
            cell.textLabel?.attributedText = underlineAttributedString
            selectedColor.backgroundColor = SharedClass().coopGroupHeaderColor
            cell.selectedBackgroundView = selectedColor
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.textLabel?.font = UIFont.boldSystemFontOfSize(13.0)
            cell.textLabel?.textAlignment = NSTextAlignment.Center
            cell.accessoryType = .None
            var t_header = poDetailList.FirstName
            cell.detailTextLabel?.text = ""
            cell.userInteractionEnabled = false;
        }
        else if(poDetailList.LastName == "officeTitle"){
            cell.backgroundColor = SharedClass().coopCardHeaderColor
            let selectedColor = UIView()
            selectedColor.backgroundColor = SharedClass().coopGroupHeaderColor
            cell.selectedBackgroundView = selectedColor
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.textLabel?.font = UIFont.boldSystemFontOfSize(13.0)
            cell.textLabel?.textAlignment = NSTextAlignment.Center
            cell.accessoryType = .None
            var t_header = poDetailList.FirstName
            cell.textLabel?.text = "Division - " + poDetailList.FirstName
            cell.detailTextLabel?.text = ""
            cell.userInteractionEnabled = false;
        }
        else{
            cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.clearColor() : SharedClass().cellBackGroundColor
            let selectedColor = UIView()
            selectedColor.backgroundColor = SharedClass().selectedCellColor
            cell.selectedBackgroundView = selectedColor
            cell.textLabel?.font = UIFont.systemFontOfSize(13.5)
            cell.textLabel?.textAlignment = .Left
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            var t_header = poDetailList.FirstName
            cell.textLabel?.text = poDetailList.FirstName + " " + poDetailList.LastName
            cell.detailTextLabel?.text = "Not Responded In Days:" + poDetailList.DaysNotResponded
            cell.userInteractionEnabled = true;
        }
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "notRespondDetail" {
            var detailViewController: DetailViewController = segue.destinationViewController as! DetailViewController
            var userIndex = detailView!.indexPathForSelectedRow()!.row
            var selectedUser = self.PODetailList[userIndex]
            
            detailViewController.userContactListID = selectedUser.CLSID
            detailViewController.t_profile = 0
        }
        
        
    }

}
