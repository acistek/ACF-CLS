
//
//  BuildingViewController.swift
//  ACF-CLS
//
//  Created by Hung Tran on 12/22/14.
//  Copyright (c) 2014 AcisTek Corporation. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class CoopViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate {
    
    var myMessage: MFMessageComposeViewController!
    
    var webSiteAddress = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var jsonResult: NSDictionary = [String:String]()
    var coopInfo = [CoopInfo]()

    var logUsers = [CoopTable]()
    
    //get online or offline bool
    var coopOnline: Bool = true
    
    let cellIdentifier = "coopCell"
    
    /*
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    */
    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //stop display menu from swiping to right
        var rightSwipe = UISwipeGestureRecognizer(target: self, action: nil)
        rightSwipe.direction = .Right
        view.addGestureRecognizer(rightSwipe)
        self.tableView.separatorInset = UIEdgeInsetsZero
        self.tableView.layoutMargins = UIEdgeInsetsZero
        
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        //coopOnline = prefs.valueForKey("COOPSWITCH") as! Bool
        if !Reachability.isConnectedToNetwork() {
            coopOnline = false
        }else{
            coopOnline = true
        }
        if(coopOnline){
            onlineCoop()
        }
        else{
            offlineCoop()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //NSLog("row count in section \(coopInfo.count)")
        if(coopOnline){
            return coopInfo.count
        }
        else{
            return logUsers.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! UITableViewCell
        
        cell.layoutMargins = UIEdgeInsetsZero
        
        //NSLog("switch is \(coopOnline)")
        if(coopOnline){
            let coopInfo = self.coopInfo[indexPath.row]
            if(coopInfo.coopName == "coop" || coopInfo.coopName == "header"){
                cell.backgroundColor = coopInfo.coopName == "coop" ? SharedClass().coopCardHeaderColor : SharedClass().coopGroupHeaderColor
                let selectedColor = UIView()
                selectedColor.backgroundColor = coopInfo.coopName == "coop" ? SharedClass().coopCardHeaderColor : SharedClass().coopGroupHeaderColor
                cell.selectedBackgroundView = selectedColor
                cell.textLabel?.textColor = UIColor.blackColor()
                cell.textLabel?.font = UIFont.boldSystemFontOfSize(18.0)
                cell.textLabel?.textAlignment = .Center
                cell.accessoryType = .None
                let t_header = "\(coopInfo.groupName)"
                cell.textLabel?.text = t_header
                cell.detailTextLabel?.text = ""
            }
            else{
                cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.clearColor() : SharedClass().cellBackGroundColor
                let selectedColor = UIView()
                selectedColor.backgroundColor = SharedClass().selectedCellColor
                cell.selectedBackgroundView = selectedColor
                cell.textLabel?.font = UIFont.boldSystemFontOfSize(14.0)
                if(coopInfo.dataTypeID == "2"){
                    cell.textLabel?.textColor = UIColor.blackColor()
                    cell.accessoryType = .None
                    cell.textLabel?.text = coopInfo.coopName
                    let cellValue = ""
                    cell.detailTextLabel?.text = cellValue
                }
                else if(coopInfo.dataTypeID == "3"){
                    cell.textLabel?.textColor = UIColor.blueColor()
                    cell.accessoryType = .DisclosureIndicator
                    cell.textLabel?.text = coopInfo.coopName
                    let cellValue = ""
                    cell.detailTextLabel?.text = cellValue
                }
                else{
                    cell.textLabel?.textColor = UIColor.blackColor()
                    cell.accessoryType = .DisclosureIndicator
                    cell.textLabel?.text = coopInfo.coopName
                    let t_phone = coopInfo.cellPhone != "" ? "Cell Phone:    \(coopInfo.cellPhone)\nOffice Phone: \(coopInfo.officePhone)" : "Office Phone: \(coopInfo.officePhone)"
                    cell.detailTextLabel?.text = t_phone
                }
            }
        }
        else{
            let coopInfo = logUsers[indexPath.row]
            if(coopInfo.coopName == "coop" || coopInfo.coopName == "header"){
                cell.backgroundColor = coopInfo.coopName == "coop" ? SharedClass().coopCardHeaderColor : SharedClass().coopGroupHeaderColor
                let selectedColor = UIView()
                selectedColor.backgroundColor = coopInfo.coopName == "coop" ? SharedClass().coopCardHeaderColor : SharedClass().coopGroupHeaderColor
                cell.selectedBackgroundView = selectedColor
                cell.textLabel?.textColor = UIColor.blackColor()
                cell.textLabel?.font = UIFont.boldSystemFontOfSize(18.0)
                cell.textLabel?.textAlignment = .Center
                cell.accessoryType = .None
                let t_header = "\(coopInfo.groupName)"
                cell.textLabel?.text = t_header
                cell.detailTextLabel?.text = ""
            }
            else{
                cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.clearColor() : SharedClass().cellBackGroundColor
                let selectedColor = UIView()
                selectedColor.backgroundColor = SharedClass().selectedCellColor
                cell.selectedBackgroundView = selectedColor
                cell.textLabel?.font = UIFont.boldSystemFontOfSize(14.0)
                if(coopInfo.dataTypeID == "2"){
                    cell.textLabel?.textColor = UIColor.blackColor()
                    cell.accessoryType = .None
                    cell.textLabel?.text = coopInfo.coopName
                    let cellValue = ""
                    cell.detailTextLabel?.text = cellValue
                }
                else if(coopInfo.dataTypeID == "3"){
                    cell.textLabel?.textColor = UIColor.blueColor()
                    cell.accessoryType = .DisclosureIndicator
                    cell.textLabel?.text = coopInfo.coopName
                    let cellValue = ""
                    cell.detailTextLabel?.text = cellValue
                }
                else{
                    cell.textLabel?.textColor = UIColor.blackColor()
                    cell.accessoryType = .DisclosureIndicator
                    cell.textLabel?.text = coopInfo.coopName
                    let t_phone = coopInfo.cellPhone != "" ? "Cell Phone:    \(coopInfo.cellPhone)\nOffice Phone: \(coopInfo.officePhone)" : "Office Phone: \(coopInfo.officePhone)"
                    cell.detailTextLabel?.text = t_phone
                }
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var t_height: CGFloat = 55.00
        if(coopOnline){
            let coopInfo = self.coopInfo[indexPath.row]
            if(coopInfo.coopName == "coop" || coopInfo.coopName == "header"){
                t_height = 40.0
            }
        }
        else{
            let coopInfo = logUsers[indexPath.row]
            if(coopInfo.coopName == "coop" || coopInfo.coopName == "header"){
                t_height = 40.0
            }
        }
        return t_height
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if(coopOnline){

            let coopInfo = self.coopInfo[indexPath.row]
            if(coopInfo.coopName != "coop" && coopInfo.coopName != "header" && coopInfo.dataTypeID != "2" && coopInfo.dataTypeID != "3"){
                let cellPhone = coopInfo.cellPhone
                let officePhone = coopInfo.officePhone
                var message = "Please select the action below"
                
                let optionMenu = UIAlertController(title: nil, message: message, preferredStyle: .ActionSheet)
                let callCellAction = UIAlertAction(title: "Call Cell \(cellPhone)", style: .Default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    let strippedPhoneNumber = "".join(cellPhone.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet))
                    if let phoneNo = NSURL(string: "tel://\(strippedPhoneNumber)") {
                        UIApplication.sharedApplication().openURL(phoneNo)
                    }
                    else{
                        var alert = UIAlertController(title: "Alert", message: "Your device cannot make a phone call", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                })
                let textCellAction = UIAlertAction(title: "Text Cell \(cellPhone)", style: .Default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    let strippedPhoneNumber = "".join(cellPhone.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet))
                    if let phoneNo = NSURL(string: "sms:\(strippedPhoneNumber)") {
                        UIApplication.sharedApplication().openURL(phoneNo)
                    }
                    /*
                    if(MFMessageComposeViewController.canSendText()){
                        let messageVC = MFMessageComposeViewController()
                        messageVC.messageComposeDelegate = self
                        messageVC.navigationBar.tintColor = UIColor.whiteColor()
                        messageVC.recipients = [cellPhone]
                        self.presentViewController(messageVC, animated: true, completion: nil)
                    }
                    else{
                        var alert = UIAlertController(title: "Alert", message: "Your device cannot text message", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    */
                })
                let callOfficeAction = UIAlertAction(title: "Call Office \(officePhone)", style: .Default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    let strippedPhoneNumber = "".join(officePhone.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet))
                    if let phoneNo = NSURL(string: "tel://\(strippedPhoneNumber)") {
                        UIApplication.sharedApplication().openURL(phoneNo)
                    }
                    else{
                        var alert = UIAlertController(title: "Alert", message: "Your device cannot make a phone call", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                    (alert: UIAlertAction!) -> Void in
                    //println("Cancelled")
                })
                if(cellPhone != ""){
                    optionMenu.addAction(callCellAction)
                    optionMenu.addAction(textCellAction)
                }
                if(officePhone != ""){
                    optionMenu.addAction(callOfficeAction)
                }
                optionMenu.addAction(cancelAction)
                self.presentViewController(optionMenu, animated: true, completion: nil)
            }
            else if(coopInfo.dataTypeID == "3"){
                webSiteAddress = coopInfo.coopName
                self.performSegueWithIdentifier("coopURL", sender: self)
                //let webSite = coopInfo.userName
                //UIApplication.sharedApplication().openURL(NSURL(string: webSite)!)
            }

        }
        else{
            let coopInfo = logUsers[indexPath.row]
             if(coopInfo.coopName != "coop" && coopInfo.coopName != "header" && coopInfo.dataTypeID != "2" && coopInfo.dataTypeID != "3"){
                let cellPhone = coopInfo.cellPhone
                let officePhone = coopInfo.officePhone
                var message = "Please select the action below"
                
                let optionMenu = UIAlertController(title: nil, message: message, preferredStyle: .ActionSheet)
                let callCellAction = UIAlertAction(title: "Call Cell \(cellPhone)", style: .Default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    let strippedPhoneNumber = "".join(cellPhone.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet))
                    if let phoneNo = NSURL(string: "tel://\(strippedPhoneNumber)") {
                        UIApplication.sharedApplication().openURL(phoneNo)
                    }
                    else{
                        var alert = UIAlertController(title: "Alert", message: "Your device cannot make a phone call", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                })
                let textCellAction = UIAlertAction(title: "Text Cell \(cellPhone)", style: .Default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    let strippedPhoneNumber = "".join(cellPhone.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet))
                    if let phoneNo = NSURL(string: "sms:\(strippedPhoneNumber)") {
                        UIApplication.sharedApplication().openURL(phoneNo)
                    }
                    /*
                    if(MFMessageComposeViewController.canSendText()){
                        let messageVC = MFMessageComposeViewController()
                        messageVC.messageComposeDelegate = self
                        messageVC.navigationBar.tintColor = UIColor.whiteColor()
                        messageVC.recipients = [cellPhone]
                        self.presentViewController(messageVC, animated: true, completion: nil)
                    }
                    else{
                        var alert = UIAlertController(title: "Alert", message: "Your device cannot text message", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }*/
                })
                let callOfficeAction = UIAlertAction(title: "Call Office \(officePhone)", style: .Default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    let strippedPhoneNumber = "".join(officePhone.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet))
                    if let phoneNo = NSURL(string: "tel://\(strippedPhoneNumber)") {
                        UIApplication.sharedApplication().openURL(phoneNo)
                    }
                    else{
                        var alert = UIAlertController(title: "Alert", message: "Your device cannot make a phone call", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                    (alert: UIAlertAction!) -> Void in
                    println("Cancelled")
                })
                if(cellPhone != ""){
                    optionMenu.addAction(callCellAction)
                    optionMenu.addAction(textCellAction)
                }
                if(officePhone != ""){
                    optionMenu.addAction(callOfficeAction)
                }
                optionMenu.addAction(cancelAction)
                self.presentViewController(optionMenu, animated: true, completion: nil)
            }
             else if(coopInfo.dataTypeID == "3"){
                //get website from username column
                webSiteAddress = coopInfo.coopName
                self.performSegueWithIdentifier("coopURL", sender: self)
                //let webSite = coopInfo.userName
                //UIApplication.sharedApplication().openURL(NSURL(string: webSite)!)
             }
             else{
                let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! UITableViewCell
                cell.backgroundColor = UIColor.grayColor()
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
    }

    
    func saveCoopTable(orderID: String, contactListID: String, dataTypeID: String, groupName: String, coopName: String, cellPhone: String, officePhone: String, homePhone: String, coopTitle: String, emailAddress: String) {
        //NSLog("start save user")
        let fetchRequest = NSFetchRequest(entityName: "CoopTable")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [CoopTable] {
            var myList = NSEntityDescription.insertNewObjectForEntityForName("CoopTable", inManagedObjectContext: self.managedObjectContext!) as! CoopTable
            
            myList.groupName = groupName
            myList.orderID = orderID
            myList.contactListID = contactListID
            myList.dataTypeID = dataTypeID
            myList.coopName = coopName
            myList.cellPhone = cellPhone
            myList.officePhone = officePhone
            myList.homePhone = homePhone
            myList.coopTitle = coopTitle
            myList.emailAddress = emailAddress
            
            var error : NSError? = nil
            if !self.managedObjectContext!.save(&error){
                NSLog("Unresolved error \(error), \(error!.userInfo)")
            }
        }
        
    }
    
    func onlineCoop(){
        if Reachability.isConnectedToNetwork() {
            self.tableView.addSubview(self.activityIndicatorView)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            activityIndicatorView.startAnimating()
            
            let authorizedJson = SharedClass().authorizedJson()
            
            var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let contactListID: NSString = prefs.valueForKey("contactListID") as! NSString
            let url = NSURL(string: SharedClass().clsLink + "/json/coop_dsp.cfm?contactlistid=\(contactListID)&deviceIdentifier=\(authorizedJson.deviceIdentifier)&loginUUID=\(authorizedJson.loginUUID)")
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
                //println("Task completed")
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
                            if(self.coopOnline){
                                let fetchRequest = NSFetchRequest(entityName: "CoopTable")
                                if let fetchResults = self.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [CoopTable] {
                                    for item in fetchResults {
                                        self.managedObjectContext?.deleteObject(item)
                                    }
                                }
                                for result in resultsArr {
                                    let orderID = result["orderID"] as? String ?? ""
                                    let contactListID = result["contactListID"] as? String ?? ""
                                    let groupName = result["groupName"] as? String ?? ""
                                    let coopName = result["coopName"] as? String ?? ""
                                    let cellPhone = result["cellPhone"] as? String ?? ""
                                    let officePhone = result["officePhone"] as? String ?? ""
                                    let homePhone = result["homePhone"] as? String ?? ""
                                    let dataTypeID = result["dataTypeID"] as? String ?? ""
                                    let coopTitle = result["coopTitle"] as? String ?? ""
                                    let emailAddress = result["emailAddress"] as? String ?? ""
                                    
                                    self.saveCoopTable(orderID, contactListID: contactListID, dataTypeID: dataTypeID, groupName: groupName, coopName: coopName,cellPhone: cellPhone,officePhone: officePhone,homePhone: homePhone, coopTitle: coopTitle, emailAddress: emailAddress)
                                }
                            }
                            self.coopInfo = CoopInfo.coopInfoWithJSON(resultsArr)
                            self.tableView!.reloadData()
                            //NSLog("done populating copy \(self.coopInfo.count)")
                            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                            self.activityIndicatorView.stopAnimating()
                        })
                    } else {
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        self.activityIndicatorView.stopAnimating()
                        SharedClass().serverAlert(self)
                    }
                }else{
                    self.coopOnline = false
                    self.offlineCoop()
                }
            })
            task.resume()
        }
        else {
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView!.reloadData()
            })
            //SharedClass().connectionAlert(self)
        }
    }
    
    func offlineCoop() {
        self.tableView.addSubview(self.activityIndicatorView)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        activityIndicatorView.startAnimating()
        
        let fetchRequest = NSFetchRequest(entityName: "CoopTable")
        
        // Create a sort descriptor object that sorts on the "title"
        // property of the Core Data object
        let sortDescriptor = NSSortDescriptor(key: "orderID", ascending: true)
        
        
        // Set the list of sort descriptors in the fetch request,
        // so it includes the sort descriptor
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [CoopTable] {
            logUsers = fetchResults
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView!.reloadData()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.activityIndicatorView.stopAnimating()
            })
        }
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: nil)
        switch (result.value) {
        case MessageComposeResultCancelled.value:
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultFailed.value:
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultSent.value:
            self.dismissViewControllerAnimated(false, completion: nil)
        default:
            break;
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String!, sender: AnyObject!) -> Bool {
        if identifier == "coopURL" {
            if (webSiteAddress == "") {
                return false
            }
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "coopURL" {
            var detailViewController: WebViewController = segue.destinationViewController as! WebViewController
            detailViewController.webSiteAddress = webSiteAddress
            detailViewController.navigationTitle = "ALL DRIVES"
            detailViewController.isCoopWeb = true
        }
    }
}
