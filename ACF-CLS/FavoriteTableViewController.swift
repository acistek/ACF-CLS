//
//  FavoriteTableViewController.swift
//  ACF-CLS
//
//  Created by tran on 1/23/15.
//  Copyright (c) 2015 AcisTek Corporation. All rights reserved.
//

import UIKit
import CoreData

class FavoriteTableViewController: UITableViewController, UITextFieldDelegate {
    
    // Create an empty array of LogItem's
    var logUsers = [FavoriteInfo]()
    var jsonResult: NSDictionary = [String:String]()
    
    let activityIndicatorView = UIActivityIndicatorView()
    var t_userName = ""
    var t_emailAddress = ""
    var t_groupName = ""
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBOutlet var groupEmail: UIButton!
    var sectionTitleArray: NSArray = NSArray()
    var sectionContentDict : NSMutableDictionary = NSMutableDictionary()
    var arrayForBool: NSMutableArray = NSMutableArray()
    var tmp1: [String] = []
    var string1: NSString = ""
    var isEditTapped: Bool = false
    
    var textMessage = "There are no users in your Favorites list."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.tableView.separatorInset = UIEdgeInsetsZero
        self.tableView.layoutMargins = UIEdgeInsetsZero
        
        activityIndicatorView.activityIndicatorViewStyle = .WhiteLarge
        activityIndicatorView.color = UIColor.grayColor()
        activityIndicatorView.center = view.center
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fetchLog("", groupName: "", isDeleteGroup: 0, isDeleteUser: 0, indexPath: NSIndexPath())
        //println("array1: \(arrayForBool)")
        //println("array2: \(sectionTitleArray)")
        //println("array3: \(sectionContentDict)")
    }
    
    func setGroup(isDeleteUser: Int, indexPath: NSIndexPath){
        if (logUsers.count == 0){
            sectionTitleArray = NSArray()
            sectionContentDict = NSMutableDictionary()
            arrayForBool = NSMutableArray()
            self.tableView.reloadData()
            self.navigationItem.rightBarButtonItem?.enabled = false
            let alertView = UIAlertController(title: textMessage, message: "", preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (alertAction) -> Void in
                self.navBack()
            }))
            self.presentViewController(alertView, animated: true, completion: nil)
        }
        else{
            var groupArray: [String] = []
            for user in logUsers{
                groupArray += [user.groupName]
            }
            
            sectionTitleArray = uniq(groupArray) as NSArray
            for index in 1...sectionTitleArray.count{
                arrayForBool.insertObject("0", atIndex: index-1)
            }
            
            var groupName: String = ""
            var groupIndex: Int = 0
            for (index, user) in enumerate(logUsers){
                if(groupName != user.groupName){
                    if(groupName != ""){
                        string1 = (sectionTitleArray.objectAtIndex(groupIndex) as? NSString)!
                        [sectionContentDict.setValue(tmp1, forKey:string1 as String )]
                        groupIndex += 1
                        tmp1 = []
                        tmp1.append(user.firstName + " " + user.lastName + ":" + user.emailAddress + ":" + user.contactListID)
                        if(index == logUsers.count-1){
                            string1 = (sectionTitleArray.objectAtIndex(groupIndex) as? NSString)!
                            [sectionContentDict.setValue(tmp1, forKey:string1 as String )]
                        }
                    }
                    else{
                        tmp1.append(user.firstName + " " + user.lastName + ":" + user.emailAddress + ":" + user.contactListID)
                        if(index == logUsers.count-1){
                            string1 = (sectionTitleArray.objectAtIndex(groupIndex) as? NSString)!
                            [sectionContentDict.setValue(tmp1, forKey:string1 as String )]
                        }
                    }
                }
                else{
                    tmp1.append(user.firstName + " " + user.lastName + ":" + user.emailAddress + ":" + user.contactListID)
                    if(index == logUsers.count-1){
                        string1 = (sectionTitleArray.objectAtIndex(groupIndex) as? NSString)!
                        [sectionContentDict.setValue(tmp1, forKey:string1 as String )]
                    }
                }
                groupName = user.groupName
            }
            tmp1 = []
            self.tableView.reloadData()
            for index in 1...sectionTitleArray.count{
                sectionToggle(index-1, isTapped: false)
            }
            if(isDeleteUser == 1){
                var t_indexPath = NSIndexPath()
                var groupArray = NSArray()
                if(self.sectionTitleArray.count > 0){
                    //if section is not the only section or else the only section
                    if(indexPath.section <= self.sectionTitleArray.count-1){
                        if(self.arrayForBool.objectAtIndex(indexPath.section).boolValue == true)
                        {
                            var groupTitle = self.sectionTitleArray .objectAtIndex(indexPath.section) as! NSString
                            groupArray = (self.sectionContentDict .valueForKey(groupTitle as String)) as! NSArray
                        }
                        t_indexPath = NSIndexPath(forRow: indexPath.row > groupArray.count-1 ? groupArray.count-1 : indexPath.row, inSection: indexPath.section)
                    }
                    else{
                        if(self.arrayForBool.objectAtIndex(self.sectionTitleArray.count-1).boolValue == true)
                        {
                            var groupTitle = self.sectionTitleArray .objectAtIndex(self.sectionTitleArray.count-1) as! NSString
                            groupArray = (self.sectionContentDict .valueForKey(groupTitle as String)) as! NSArray
                        }
                        t_indexPath = NSIndexPath(forRow: groupArray.count-1, inSection: self.sectionTitleArray.count-1)
                    }
                    self.tableView.scrollToRowAtIndexPath(t_indexPath, atScrollPosition: .Middle, animated: false)
                }
            }
        }
    }
    
    //this func is to delete duplicate array element
    func uniq<S: SequenceType, E: Hashable where E==S.Generator.Element>(source: S) -> [E] {
        var seen: [E:Bool] = [:]
        return filter(source) { seen.updateValue(true, forKey: $0) == nil }
    }
    
    func navBack(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchLog(userContactListID: String, groupName: String, isDeleteGroup: Int, isDeleteUser: Int, indexPath: NSIndexPath) {
        if Reachability.isConnectedToNetwork() {
            view.addSubview(activityIndicatorView)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            activityIndicatorView.startAnimating()
            if let groupName = groupName.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
                var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                let contactListID: NSString = prefs.valueForKey("contactListID") as! NSString
                var queryString = "acfcode=clsmobile&contactlistid=\(contactListID)&userContactListID=\(userContactListID)&groupName=\(groupName)&deleteGroup=\(isDeleteGroup)"
                let url = NSURL(string: SharedClass().clsLink + "/json/favorite_dsp.cfm?\(queryString)")
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
                            self.textMessage = self.jsonResult.valueForKey("message") as! String
                            var resultsArr: NSArray = self.jsonResult["results"] as! NSArray
                            dispatch_async(dispatch_get_main_queue(), {
                                self.logUsers = FavoriteInfo.favoriteInfoWithJSON(resultsArr)
                                self.setGroup(isDeleteUser, indexPath: indexPath)
                                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                                self.activityIndicatorView.stopAnimating()
                            })
                        } else {
                            SharedClass().serverAlert(self)
                            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                            self.activityIndicatorView.stopAnimating()
                        }
                    }else{
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        self.activityIndicatorView.stopAnimating()
                        SharedClass().connectionAlert(self)
                    }
                })
                task.resume()
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), {
                //self.tableView!.reloadData()
            })
            SharedClass().connectionAlert(self)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionTitleArray.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        
        if(arrayForBool.objectAtIndex(section).boolValue == true)
        {
            var groupTitle = sectionTitleArray .objectAtIndex(section) as! NSString
            var groupArray = (sectionContentDict .valueForKey(groupTitle as String)) as! NSArray
            return groupArray.count
        }
        return 0
    }
    
    /*
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "ABCdef"
    }*/
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.5
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(arrayForBool .objectAtIndex(indexPath.section).boolValue == true){
            return 50
        }
        return 1;
    }

    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width - 10, 40))
        headerView.backgroundColor = SharedClass().headerColor
        headerView.tag = section
        
        let headerString = UILabel(frame: CGRect(x: 10, y: 10, width: tableView.frame.size.width - 100, height: 30)) as UILabel
        headerString.font = UIFont.boldSystemFontOfSize(16.0)
        headerString.text = sectionTitleArray.objectAtIndex(section) as! NSString as String
        
        let mailGroup = UIButton(frame: CGRect(x: tableView.frame.size.width - 60, y: 10, width: 30
            , height: 30))
        var optionImg1 = UIImage(named: "mailgroup")
        mailGroup.backgroundColor = UIColor.clearColor()
        mailGroup.setImage(optionImg1, forState: UIControlState.Normal)
        mailGroup.tag = section
        mailGroup.addTarget(self, action: "emailToGroup:", forControlEvents: UIControlEvents.TouchUpInside|UIControlEvents.TouchUpOutside)
        
        let deleteGroup = UIButton(frame: CGRect(x: tableView.frame.size.width - 30, y: 10, width: 30, height: 30))
        var optionImg2 = UIImage(named: "delete")
        deleteGroup.backgroundColor = UIColor.clearColor()
        deleteGroup.setImage(optionImg2, forState: UIControlState.Normal)
        deleteGroup.tag = section
        deleteGroup.addTarget(self, action: "deleteGroup:", forControlEvents: UIControlEvents.TouchUpInside|UIControlEvents.TouchUpOutside)
        
        let editGroup = UIButton(frame: CGRect(x: tableView.frame.size.width - 90, y: 10, width: 30, height: 30))
        var optionImg3 = UIImage(named: "edit")
        editGroup.backgroundColor = UIColor.clearColor()
        editGroup.setImage(optionImg3, forState: UIControlState.Normal)
        editGroup.tag = section
        editGroup.addTarget(self, action: "editGroupName:", forControlEvents: UIControlEvents.TouchUpInside|UIControlEvents.TouchUpOutside)
        
        headerView.addSubview(editGroup)
        headerView.addSubview(mailGroup)
        headerView.addSubview(deleteGroup)
        headerView.addSubview(headerString)
        
        let headerTapped = UITapGestureRecognizer (target: self, action:"sectionHeaderTapped:")
        headerView.addGestureRecognizer(headerTapped)

        return headerView
    }
    
    func sectionHeaderTapped(recognizer: UITapGestureRecognizer) {
        var indexPath : NSIndexPath = NSIndexPath(forRow: 0, inSection:(recognizer.view?.tag as Int!)!)
        if (indexPath.row == 0) {
            sectionToggle(indexPath.section, isTapped: true)
        }
    }
    
    //this func to expand or shrink the group. first load is expand the group
    func sectionToggle(sectionNo: Int, isTapped: Bool){
        var collapsed = arrayForBool.objectAtIndex(sectionNo).boolValue
        collapsed = !collapsed;
        arrayForBool.replaceObjectAtIndex(sectionNo, withObject: collapsed)
        //reload specific section animated
        var range = NSMakeRange(sectionNo, 1)
        var sectionToReload = NSIndexSet(indexesInRange: range)
        self.tableView.reloadSections(sectionToReload, withRowAnimation:UITableViewRowAnimation.Fade)
        /*if (isTapped && collapsed == true){
            var t_indexPath = NSIndexPath()
            var groupArray = NSArray()
            var groupTitle = self.sectionTitleArray .objectAtIndex(sectionNo) as! NSString
            groupArray = (self.sectionContentDict .valueForKey(groupTitle as String)) as! NSArray
            t_indexPath = NSIndexPath(forRow: groupArray.count-1, inSection: sectionNo)
            self.tableView.scrollToRowAtIndexPath(t_indexPath, atScrollPosition: .Middle, animated: false)
        }*/
    }
    
    func emailToGroup(sender:UIButton!){
        t_groupName = sectionTitleArray.objectAtIndex(sender.tag) as! NSString as String
        self.performSegueWithIdentifier("groupEmail", sender: self)
    }
    
    func deleteGroup(sender:UIButton!){
        t_groupName = sectionTitleArray.objectAtIndex(sender.tag) as! NSString as String
        let alertView = UIAlertController(title: "Are you sure you want to delete the \"\(t_groupName)\" group?", message: "", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alertView.addAction(UIAlertAction(title: "Delete", style: .Default, handler: { (alertAction) -> Void in
            self.fetchLog("", groupName: self.t_groupName, isDeleteGroup: 1, isDeleteUser: 0, indexPath: NSIndexPath())
        }))
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    func editGroupName(sender:UIButton!){
        t_groupName = sectionTitleArray.objectAtIndex(sender.tag) as! NSString as String
        
        var alert = UIAlertController(title: "Edit Group Name", message: "", preferredStyle: .Alert)
        //2. Add the text field. You can configure it however you need.
        alert.addTextFieldWithConfigurationHandler({(textField) -> Void in
            textField.delegate = self
            textField.text = self.t_groupName
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            
            let textField = alert.textFields![0] as! UITextField
            
            var groupName:NSString = textField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            
            if (groupName.isEqualToString("")) {
                var alertView:UIAlertView = UIAlertView()
                alertView.title = ""
                alertView.message = "Please enter a Group Name"
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
                self.editGroupName(sender)
            }
            else{
                //get group name from popup text field and then submit to update the group name
                self.tableView.addSubview(self.activityIndicatorView)
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                self.activityIndicatorView.startAnimating()
                
                var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                let contactListID: NSString = prefs.valueForKey("contactListID") as! NSString
                self.updateGroupName(contactListID as String, oldGroupName: self.t_groupName, newGroupName: groupName as String)
                self.fetchLog("", groupName: "", isDeleteGroup: 0, isDeleteUser: 0, indexPath: NSIndexPath())
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.activityIndicatorView.stopAnimating()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        
        
        // 4. Present the alert.
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var isGood = true
        let checkText = SharedClass().validateText(textField, range: range, string: string, length: 35, characterSet: "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ-' ")
        if(!checkText){
            isGood = false
        }
        return isGood
    }
    
    func updateGroupName(contactListID: String, oldGroupName: String, newGroupName: String) {
        var post: NSString = ""
        post = "contactListID=\(contactListID)&acfcode=clsmobile&oldGroupName=\(oldGroupName)&newGroupName=\(newGroupName)"
        var url:NSURL = NSURL(string: SharedClass().clsLink + "/json/favorite_group_act.cfm")!
        var postData:NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
        var postLength:NSString = String( postData.length )
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        var reponseError: NSError?
        var response: NSURLResponse?
        var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        if (urlData != nil) {
            let res = response as! NSHTTPURLResponse!;
            if (res.statusCode >= 200 && res.statusCode < 300)
            {
                var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                var error: NSError?
                let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers , error: &error) as! NSDictionary
                let message:String = jsonData.valueForKey("message") as! String
                let isError:Int = jsonData.valueForKey("isError") as! Int
                if(isError == 1){
                    self.actionSheet(message)
                }
            }else{
                SharedClass().serverAlert(self)
            }
        } else {
            SharedClass().serverAlert(self)
        }
    }
    
    func actionSheet(message: String){
        var alertView:UIAlertView = UIAlertView()
        alertView.message = message
        alertView.delegate = self
        alertView.addButtonWithTitle("OK")
        alertView.show()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let CellIdentifier = "Cell"
        var cell :UITableViewCell
        cell = self.tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! UITableViewCell
        cell.layoutMargins = UIEdgeInsetsZero
        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.clearColor() : SharedClass().cellBackGroundColor
        var manyCells : Bool = arrayForBool.objectAtIndex(indexPath.section).boolValue
        
        if (manyCells) {
            var content = sectionContentDict .valueForKey(sectionTitleArray.objectAtIndex(indexPath.section) as! String) as! NSArray
            var myArray = content.objectAtIndex(indexPath.row).componentsSeparatedByString(":")
            cell.textLabel?.text = myArray[0] as? String
            cell.detailTextLabel?.text = myArray[1] as? String
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    @IBAction func startEditing(sender: UIBarButtonItem) {
        if(sender.title == "Done"){
            sender.title = "Edit"
            self.editing = false
        }else{
            sender.title = "Done"
            self.editing = true
            isEditTapped = true
        }
    }
    
    override func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
        editButton.title = "Done"
    }
    
    override func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
        editButton.title = "Edit"
    }
    
    override func tableView(tableView: (UITableView!), commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete ) {
            var manyCells : Bool = arrayForBool.objectAtIndex(indexPath.section).boolValue
            var favoriteContactListID = ""
            if (!manyCells) {
                favoriteContactListID = "0"
            }
            else{
                var content = sectionContentDict .valueForKey(sectionTitleArray.objectAtIndex(indexPath.section) as! String) as! NSArray
                var myArray = content.objectAtIndex(indexPath.row).componentsSeparatedByString(":")
                favoriteContactListID = myArray[2] as! String
                for (index, value) in enumerate(logUsers){
                    if(value.contactListID == favoriteContactListID){
 
                        //delete selected favorite user within a group then refresh the table view
                        dispatch_async(dispatch_get_main_queue(), {
                            if(self.isEditTapped){
                                self.editButton.title = "Done"
                                self.editing = true
                            }else{
                                self.editButton.title = "Edit"
                                self.editing = false
                            }
                            var groupName = self.sectionTitleArray.objectAtIndex(indexPath.section) as! NSString as String
                            self.fetchLog(favoriteContactListID, groupName: groupName, isDeleteGroup: 0, isDeleteUser: 1, indexPath: indexPath)
                        })
                    }
                }
            }
        }
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "groupEmail" {
            var detailViewController: MailViewController = segue.destinationViewController as! MailViewController
            detailViewController.groupName = t_groupName
        }
        else{
            var detailViewController: DetailViewController = segue.destinationViewController as! DetailViewController
            
            var position: CGPoint = sender!.convertPoint(CGPointZero, toView: self.tableView)
            if let indexPath = self.tableView.indexPathForRowAtPoint(position)
            {
                let section = indexPath.section
                let row = indexPath.row
                var manyCells : Bool = arrayForBool.objectAtIndex(indexPath.section).boolValue
                
                if (!manyCells) {
                    detailViewController.userContactListID = "0"
                }
                else{
                    var content = sectionContentDict .valueForKey(sectionTitleArray.objectAtIndex(indexPath.section) as! String) as! NSArray
                    var myArray = content.objectAtIndex(indexPath.row).componentsSeparatedByString(":")
                    detailViewController.userContactListID = myArray[2] as! String
                }
            }
        }
    }
}
