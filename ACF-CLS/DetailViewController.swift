//
//  DetailViewController.swift
//  ACF-CLS
//
//  Created by Hung Tran on 12/30/14.
//  Copyright (c) 2014 AcisTek Corporation. All rights reserved.
//

import UIKit
import CoreData
import MessageUI
import CoreLocation

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    let manager = CLLocationManager()
    var firstLocation:CLLocation!
    var secondLocation:CLLocation!
    var milesDistance = 0.0
    var accessLocation = true
    var locationStatus : NSString = "Not Started"
    
    @IBOutlet var groupTextField: UITextField!
    var groupPicker: UIPickerView!
    
    var delegate: WriteValueBackDelegate?
    
    // Create an empty array of LogItem's
    
    //var userInfo: UserInfo?
    
    var userContactListID = "0"
    var myContactListID = "0"
    
    var t_phoneNumber: NSString = ""
    var t_emailAddress = ""
    var t_address = ""
    var t_telPhone: NSString = ""
    var t_officePhone = ""
    var t_cellPhone = ""
    var t_groupName = ""
    
    var t_profile = 0
    
    let authorizedJson = SharedClass().authorizedJson()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var addFavTabBar: UITabBarItem!
    @IBOutlet weak var callTabBar: UITabBarItem!
    @IBOutlet weak var textTabBar: UITabBarItem!
    @IBOutlet weak var emailTabBar: UITabBarItem!
    @IBOutlet weak var directionTabBar: UITabBarItem!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var sendEmail: UIButton!
    
    var myMail: MFMailComposeViewController!
    var myMessage: MFMessageComposeViewController!

    let cellIdentifier = "detailCell"
    
    var jsonResult: NSDictionary = [String:String]()
    
    var detailInfo = [DetailInfo]()
    
    var areaPhone = ""
    var prefixPhone = ""
    var linePhone = ""
    
    var groupPickerValues: NSArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //stop display menu from swiping to right
        var rightSwipe = UISwipeGestureRecognizer(target: self, action: nil)
        rightSwipe.direction = .Right
        view.addGestureRecognizer(rightSwipe)
        sendEmail.hidden = true
        
        groupTextField.hidden = true
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        myContactListID = prefs.valueForKey("contactListID") as! String
        
        groupPicker = UIPickerView(frame: CGRectMake(0, 200, view.frame.width, 300))
        groupPicker.backgroundColor = .whiteColor()
        groupPicker.showsSelectionIndicator = true
        
        var toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.sizeToFit()
        
        var doneButton = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "donePicker")
        var spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        var cancelButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelPicker")

        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        groupPicker.dataSource = self
        groupPicker.delegate = self
        
        groupTextField.inputView = groupPicker
        groupTextField.inputAccessoryView = toolBar
        
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.title = t_profile == 0 ? "User's Profile" : "My Profile"
        self.tableView.separatorInset = UIEdgeInsetsZero
        self.tableView.layoutMargins = UIEdgeInsetsZero
        for item in tabBar.items as! [UITabBarItem] {
            if let image = item.image {
                item.image = image.imageWithColor(SharedClass().tabBarImageColor).imageWithRenderingMode(.AlwaysOriginal)
            }
        }
        
        checkAccessLocation()
        // Do any additional setup after loading the view.
        if Reachability.isConnectedToNetwork() {
            //NSLog("view did load")
            self.tableView.addSubview(self.activityIndicatorView)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            activityIndicatorView.startAnimating()
            
            let url = NSURL(string: SharedClass().clsLink + "/json/user_dsp.cfm?contactListID=\(userContactListID)&adminID=\(myContactListID)&deviceIdentifier=\(authorizedJson.deviceIdentifier)&loginUUID=\(authorizedJson.loginUUID)")
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
                            self.detailInfo = DetailInfo.detailInfoWithJSON(resultsArr)
                            for (index, field) in enumerate(self.detailInfo){
                                if(field.fieldName == "Phone:"){
                                    let phone:NSString = field.fieldValue
                                    if(phone.length >= 10){
                                        self.areaPhone = phone.substringWithRange(NSRange(location: 0, length: 3))
                                        self.prefixPhone = phone.substringWithRange(NSRange(location: 3, length: 3))
                                        self.linePhone = phone.substringWithRange(NSRange(location: 6, length: 4))
                                        self.t_phoneNumber = "(" + self.areaPhone + ") " + self.prefixPhone + "-" + self.linePhone
                                        self.t_telPhone = phone as String
                                        self.t_officePhone = phone as String
                                    }
                                    else{
                                        self.callTabBar.enabled = false
                                        self.textTabBar.enabled = false
                                    }
                                }
                                if(field.fieldName == "Cell Phone:"){
                                    let phone:NSString = field.fieldValue
                                    if(phone.length >= 10){
                                        self.t_cellPhone = phone as String
                                    }
                                }
                                if(field.fieldName == "groupList"){
                                    var arrayGroupList = field.fieldValue.componentsSeparatedByString("|~|")
                                    self.groupPickerValues = arrayGroupList
                                    self.groupTextField.text = self.groupPickerValues[0] as! String
                                }
                            }
                            self.tableView!.reloadData()
                            //NSLog("done populating copy \(self.coopInfo.count)")
                            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                            self.activityIndicatorView.stopAnimating()
                        })
                    } else {
                        self.accessLocation = false
                        self.addFavTabBar.enabled = false
                        self.callTabBar.enabled = false
                        self.textTabBar.enabled = false
                        self.emailTabBar.enabled = false
                        self.directionTabBar.enabled = false
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        self.activityIndicatorView.stopAnimating()
                        SharedClass().serverAlert(self)
                    }
                }else{
                    self.accessLocation = false
                    self.addFavTabBar.enabled = false
                    self.callTabBar.enabled = false
                    self.textTabBar.enabled = false
                    self.emailTabBar.enabled = false
                    self.directionTabBar.enabled = false
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    self.activityIndicatorView.stopAnimating()
                    SharedClass().connectionAlert(self)
                }
            })
            task.resume()
        }else {
            accessLocation = false
            addFavTabBar.enabled = false
            callTabBar.enabled = false
            textTabBar.enabled = false
            emailTabBar.enabled = false
            directionTabBar.enabled = false
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.activityIndicatorView.stopAnimating()
            SharedClass().connectionAlert(self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return groupPickerValues.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return groupPickerValues[row] as! String
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        groupTextField.text = groupPickerValues[row] as! String
    }
    
    //this func to save the user to favorite after pick a group name and end editing. the action sheet to display alert is save or not
    func donePicker(){
        self.t_groupName = groupTextField.text
        self.saveToFavorite(myContactListID, favorite_ContactListID: self.userContactListID, groupName: self.t_groupName)
        groupTextField.resignFirstResponder()
    }
    
    func cancelPicker(){
        groupTextField.resignFirstResponder()
        groupPicker.reloadAllComponents()
        groupPicker.selectRow(0, inComponent: 0, animated: true)
        groupTextField.text = self.groupPickerValues[0] as! String
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailInfo.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! UITableViewCell
        cell.layoutMargins = UIEdgeInsetsZero
        let detailInfo = self.detailInfo[indexPath.row]
        if(detailInfo.fieldName == "header"){
            cell.backgroundColor = SharedClass().headerColor
            let selectedColor = UIView()
            selectedColor.backgroundColor = SharedClass().headerColor
            cell.selectedBackgroundView = selectedColor
            
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.textLabel?.font = UIFont.boldSystemFontOfSize(18.0)
            cell.textLabel?.textAlignment = .Center
            let t_header = "\(detailInfo.fieldValue)"
            cell.textLabel?.text = t_header
            cell.detailTextLabel?.text = ""
        }
        else if(detailInfo.fieldName == "contactListID" || detailInfo.fieldName == "groupList"){
            cell.hidden = true
        }
        else{
            cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.clearColor() : SharedClass().cellBackGroundColor
            let selectedColor = UIView()
            selectedColor.backgroundColor = SharedClass().selectedCellColor
            cell.selectedBackgroundView = selectedColor
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.textLabel?.font = UIFont.boldSystemFontOfSize(14.0)
            let t_header = "\(detailInfo.fieldName)"
            cell.textLabel?.text = t_header
            if(detailInfo.fieldName.rangeOfString("Phone") != nil){
                
                if(detailInfo.fieldValue != "" && detailInfo.fieldValue != "N/A"){
                    let phone:NSString = detailInfo.fieldValue
                    if(phone.length >= 10){
                        areaPhone = phone.substringWithRange(NSRange(location: 0, length: 3))
                        prefixPhone = phone.substringWithRange(NSRange(location: 3, length: 3))
                        linePhone = phone.substringWithRange(NSRange(location: 6, length: 4))
                        t_phoneNumber = "(" + areaPhone + ") " + prefixPhone + "-" + linePhone
                        t_telPhone = detailInfo.fieldName == "Phone:" ? phone : t_telPhone
                        cell.detailTextLabel?.text = t_phoneNumber as String
                    }
                    else{
                        if(detailInfo.fieldName == "Phone:"){
                            callTabBar.enabled = false
                            textTabBar.enabled = false
                        }
                        cell.detailTextLabel?.text = "N/A"
                    }
                }
                else{
                    cell.detailTextLabel?.text = "N/A"
                }
            }
            else if(detailInfo.fieldName == "Fax:"){
                
                if (detailInfo.fieldValue != "" && detailInfo.fieldValue != "N/A"){
                    let phone:NSString = detailInfo.fieldValue
                    if(phone.length >= 10){
                        areaPhone = phone.substringWithRange(NSRange(location: 0, length: 3))
                        prefixPhone = phone.substringWithRange(NSRange(location: 3, length: 3))
                        linePhone = phone.substringWithRange(NSRange(location: 6, length: 4))
                        cell.detailTextLabel?.text = "(" + areaPhone + ") " + prefixPhone + "-" + linePhone
                    }
                    else{
                        cell.detailTextLabel?.text = "N/A"
                    }
                }
                else{
                    cell.detailTextLabel?.text = "N/A"
                }
            }
            else{
                let t_value = "\(detailInfo.fieldValue)"
                cell.detailTextLabel?.text = t_value
                
                if(detailInfo.fieldName == "Email Address:"){
                    t_emailAddress = detailInfo.fieldValue
                }
                else if(detailInfo.fieldName == "Building Address:"){
                    t_address = detailInfo.fieldValue
                    if(count(t_address.utf16) < 10){
                        directionTabBar.enabled = false
                    }else{
                        directionTabBar.enabled = true
                        let address = "\(t_address)"
                        CLGeocoder().geocodeAddressString(address, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
                            if let placemark = placemarks?[0] as? CLPlacemark {
                                self.secondLocation = placemark.location
                            }
                        })
                    }
                }
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailInfo = self.detailInfo[indexPath.row]
        if(detailInfo.fieldName.rangeOfString("Phone") != nil){
            if (detailInfo.fieldValue != "" && detailInfo.fieldValue != "N/A"){
                let phone:NSString = detailInfo.fieldValue
                if(phone.length >= 10){
                    t_telPhone = phone as String
                    callTabBar.enabled = true
                    textTabBar.enabled = true
                }
                else{
                    callTabBar.enabled = false
                    textTabBar.enabled = false
                }
            }
            else{
                callTabBar.enabled = false
                textTabBar.enabled = false
            }
        }
        else if(detailInfo.fieldName.rangeOfString("Email") != nil){
            if (detailInfo.fieldValue != "" && detailInfo.fieldValue != "N/A"){
                t_emailAddress = detailInfo.fieldValue
                emailTabBar.enabled = true
            }
            else{
                emailTabBar.enabled = false
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var t_height: CGFloat = 47.00
        let detailInfo = self.detailInfo[indexPath.row]
        if(detailInfo.fieldName == "header"){
            t_height = 40.0
        }
        return t_height
    }
    
    func addFavorite(){
        //get data from array group pick. the alert controller display differently depending on if there is any group yet
        var checkGroup = groupPickerValues[0] as! String
        var alert = UIAlertController(title: checkGroup != "" ? "Enter a New Group Name or Select From Group List" : "Please enter a Group Name", message: "", preferredStyle: .Alert)
        //2. Add the text field. You can configure it however you need.
        alert.addTextFieldWithConfigurationHandler({(textField) -> Void in
            textField.delegate = self
            textField.placeholder = "Enter a Group Name..."
            textField.text = ""
            //textField.addTarget(self, action: "checkGroupName", forControlEvents: UIControlEvents.EditingChanged)
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            
            self.groupTextField.resignFirstResponder()
            let textField = alert.textFields![0] as! UITextField
            
            var groupName:NSString = textField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            
            if (groupName.isEqualToString("")) {
                var alertView:UIAlertView = UIAlertView()
                alertView.title = ""
                alertView.message = "Please enter a Group Name"
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
                self.addFavorite()
            }
            else{
                //get group name from popup text field and then check favorite table if the user is existed or not to take action
                self.t_groupName = textField.text
                self.saveToFavorite(self.myContactListID, favorite_ContactListID: self.userContactListID, groupName: self.t_groupName)
            }
        }))
        if(checkGroup != ""){
            alert.addAction(UIAlertAction(title: "Group List", style: .Default, handler: { (action) -> Void in
                groupTextField.becomeFirstResponder()
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        
        
        // 4. Present the alert.
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func saveToFavorite(myContactListID: String, favorite_ContactListID: String, groupName: String) {
        var post: NSString = ""
        self.tableView.addSubview(self.activityIndicatorView)
        self.activityIndicatorView.startAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        post = "contactListID=\(myContactListID)&favorite_ContactListID=\(favorite_ContactListID)&groupName=\(groupName)&deviceIdentifier=\(authorizedJson.deviceIdentifier)&loginUUID=\(authorizedJson.loginUUID)"
        var url:NSURL = NSURL(string: SharedClass().clsLink + "/json/favorite_act.cfm")!
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
                let groupList:String = jsonData.valueForKey("groupList") as! String
                dispatch_async(dispatch_get_main_queue(), {
                    var arrayGroupList = groupList.componentsSeparatedByString("|~|")
                    self.groupPickerValues = arrayGroupList
                    self.groupPicker.reloadAllComponents()
                    self.groupPicker.selectRow(0, inComponent: 0, animated: true)
                    self.groupTextField.text = self.groupPickerValues[0] as! String
                    self.activityIndicatorView.stopAnimating()
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                })
                delegate?.writeValueBack("Added to group")
                self.actionSheet(message)
            }else{
                self.activityIndicatorView.stopAnimating()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                SharedClass().serverAlert(self)
            }
        } else {
            self.activityIndicatorView.stopAnimating()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            SharedClass().serverAlert(self)
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var isGood = true
        let checkText = SharedClass().validateText(textField, range: range, string: string, length: 35, characterSet: "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ-' ")
        if(!checkText){
            isGood = false
        }
        return isGood
    }
    
    //there are 5 tab bars. depending on which tab is touch then trigger an action or event for that tab
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        var selectedTag = tabBar.selectedItem?.tag
        if(selectedTag == 0){
            if Reachability.isConnectedToNetwork() {
                addFavorite()
            }
            else {
                SharedClass().connectionAlert(self)
            }
            
        }
        else if(selectedTag == 1){
            if let phoneNo = NSURL(string: "tel://\(t_telPhone)") {
                UIApplication.sharedApplication().openURL(phoneNo)
            }
            else{
                var alert = UIAlertController(title: "Alert", message: "Your device cannot make a phone call", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        else if(selectedTag == 2){
            if let phoneNo = NSURL(string: "sms:\(t_telPhone)") {
                UIApplication.sharedApplication().openURL(phoneNo)
            }
            /*
            if(MFMessageComposeViewController.canSendText()){
                let messageVC = MFMessageComposeViewController()
                messageVC.messageComposeDelegate = self
                messageVC.navigationBar.tintColor = UIColor.whiteColor()
                messageVC.recipients = [t_telPhone]
                self.presentViewController(messageVC, animated: true, completion: nil)
            }
            else{
                var alert = UIAlertController(title: "Alert", message: "Your device cannot text message", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }*/
        }
        else if(selectedTag == 3){
            self.performSegueWithIdentifier("sendEmail", sender: self)
            /*
            if(MFMailComposeViewController.canSendMail()){
                myMail = MFMailComposeViewController()
                myMail.mailComposeDelegate = self
                myMail.navigationBar.tintColor = UIColor.whiteColor()
                
                //myMail.mailComposeDelegate
                
                //To recipients
                var toRecipients = [t_emailAddress]
                myMail.setToRecipients(toRecipients)
                
                //Display the view controller
                self.presentViewController(myMail, animated: true, completion: nil)
            }
            else{
                var alert = UIAlertController(title: "Alert", message: "Your device cannot send emails", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            */
        }
        else if(selectedTag == 4){
            var appleAction: UIAlertAction?
            var googleAction: UIAlertAction?
            let optionMenu = UIAlertController(title: nil, message: "Select map for direction to this building \(t_address)", preferredStyle: .ActionSheet)
            appleAction = UIAlertAction(title: "Apple map's direction", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                var tempStr = ""
                if(self.accessLocation){
                    tempStr = "http://maps.apple.com/maps?daddr=\(self.secondLocation.coordinate.latitude),\(self.secondLocation.coordinate.longitude)&saddr=\(self.firstLocation.coordinate.latitude),\(self.firstLocation.coordinate.longitude)"
                }
                else{
                    tempStr = "http://maps.apple.com/maps?q=\(self.secondLocation.coordinate.latitude),\(self.secondLocation.coordinate.longitude)"
                }
                if let urlString = NSURL(string: tempStr){
                    // An the final magic ... openURL!
                    UIApplication.sharedApplication().openURL(urlString)
                }
            })
            googleAction = UIAlertAction(title: "Google map's direction", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                var tempStr = ""
                if(self.accessLocation){
                    tempStr = "http://maps.google.com/maps?daddr=\(self.secondLocation.coordinate.latitude),\(self.secondLocation.coordinate.longitude)&saddr=\(self.firstLocation.coordinate.latitude),\(self.firstLocation.coordinate.longitude)"
                }
                else{
                    tempStr = "http://maps.google.com/maps?q=\(self.secondLocation.coordinate.latitude),\(self.secondLocation.coordinate.longitude)"
                }
                if let urlString = NSURL(string: tempStr){
                    // An the final magic ... openURL!
                    UIApplication.sharedApplication().openURL(urlString)
                }
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                //println("Cancelled")
            })
            optionMenu.addAction(appleAction!)
            optionMenu.addAction(googleAction!)
            optionMenu.addAction(cancelAction)
            self.presentViewController(optionMenu, animated: true, completion: nil)
        }
    }
    
    func actionSheet(message: String){
        var alertView:UIAlertView = UIAlertView()
        alertView.message = message
        alertView.delegate = self
        alertView.addButtonWithTitle("OK")
        alertView.show()
    }
    
    func checkAccessLocation(){
        manager.delegate = self
        CLLocationManager.locationServicesEnabled()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        self.manager.stopUpdatingLocation()
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, error)->Void in
            if (error != nil) {
                println("Reverse geocoder failed with error" + error.localizedDescription)
                return
            }
            if placemarks.count > 0 {
                let containsPlacemark = placemarks[0] as! CLPlacemark
                self.firstLocation = containsPlacemark.location
                //manager()
            }
            else {
                println("Problem with the data received from geocoder")
            }
        })
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error while updating location " + error.localizedDescription)
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        var shouldIAllow = false
        
        switch status {
        case CLAuthorizationStatus.Restricted:
            locationStatus = "Restricted Access to location"
        case CLAuthorizationStatus.Denied:
            locationStatus = "User denied access to location"
        case CLAuthorizationStatus.NotDetermined:
            locationStatus = "Status not determined"
        default:
            locationStatus = "Allowed to location Access"
            shouldIAllow = true
        }
        NSNotificationCenter.defaultCenter().postNotificationName("LabelHasbeenUpdated", object: nil)
        if (shouldIAllow == true) {
            //NSLog("Location to Allowed")
            // Start location services
            accessLocation = true
            manager.startUpdatingLocation()
            
        } else {
            //NSLog("Denied access: \(locationStatus)")
            accessLocation = false
            
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController!,didFinishWithResult result: MFMailComposeResult,error: NSError!){
        switch(result.value){
        case MFMailComposeResultSent.value:
            println("Email sent")
        default:
            println("Whoops")
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "sendEmail" {
            var detailViewController: MailViewController = segue.destinationViewController as! MailViewController
            detailViewController.toEmail = t_emailAddress
        }
    }
    
}
