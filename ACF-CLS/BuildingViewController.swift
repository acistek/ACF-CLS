//
//  BuildingViewController.swift
//  ACF-CLS
//
//  Created by Hung Tran on 12/22/14.
//  Copyright (c) 2014 AcisTek Corporation. All rights reserved.
//

import UIKit
import CoreLocation

class BuildingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var milesButtonItem: UIBarButtonItem!
    @IBOutlet weak var slider: UISlider!
    
    var sliderValue:Float = 7.00
    var miles = 3000.0
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        var currentValue = Int(sender.value)
        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        displayMiles(currentValue)
    }
    func displayMiles(currentValue: Int){
        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        switch currentValue{
        case 1:
            miles = 25.0
            prefs.setFloat(1, forKey: "SLIDERVALUE")
            prefs.setDouble(miles, forKey: "MILES")
        case 2:
            miles = 50.0
            prefs.setFloat(2, forKey: "SLIDERVALUE")
            prefs.setDouble(miles, forKey: "MILES")
        case 3:
            miles = 100.0
            prefs.setFloat(3, forKey: "SLIDERVALUE")
            prefs.setDouble(miles, forKey: "MILES")
        case 4:
            miles = 200.0
            prefs.setFloat(4, forKey: "SLIDERVALUE")
            prefs.setDouble(miles, forKey: "MILES")
        case 5:
            miles = 500.0
            prefs.setFloat(5, forKey: "SLIDERVALUE")
            prefs.setDouble(miles, forKey: "MILES")
        case 6:
            miles = 1000.0
            prefs.setFloat(6, forKey: "SLIDERVALUE")
            prefs.setDouble(miles, forKey: "MILES")
        default:
            miles = 3000.0
            prefs.setFloat(7, forKey: "SLIDERVALUE")
            prefs.setDouble(miles, forKey: "MILES")
        }
        milesButtonItem.title = "\(miles) miles"
        //NSLog("test miles")
    }

    @IBAction func sliderReload(sender: UISlider) {
        reloadMiles()
    }
    
    
    let manager = CLLocationManager()
    var firstLocation:CLLocation!
    var secondLocation:CLLocation!
    var milesDistance = 0.0
    var accessLocation = true
    var locationStatus : NSString = "Not Started"
    
    var jsonResult: NSDictionary = [String:String]()
    
    var buildingInfo = [BuildingInfo]()
    
    var holderBuildingInfo = [BuildingInfo]()
    
    let cellIdentifier = "buildingCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //stop display menu from swiping to right
        var rightSwipe = UISwipeGestureRecognizer(target: self, action: nil)
        rightSwipe.direction = .Right
        view.addGestureRecognizer(rightSwipe)
        
        self.tableView.separatorInset = UIEdgeInsetsZero
        self.tableView.layoutMargins = UIEdgeInsetsZero
        // Do any additional setup after loading the view.
        self.title = "Building Information"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        var reloadButton : UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "reload"), style: UIBarButtonItemStyle.Plain, target: self, action: "reloadMiles")
        self.navigationItem.rightBarButtonItem = reloadButton
        tableView.rowHeight = 90.0
        
        checkAccessLocation()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)

        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if let tMiles: Double = prefs.valueForKey("MILES") as? Double{
            self.miles = tMiles
        }
        if let tSliderValue: Float = prefs.valueForKey("SLIDERVALUE") as? Float{
            sliderValue = tSliderValue
            let sVal = Int(sliderValue)
            displayMiles(sVal)
        }
        
        self.slider.setValue(sliderValue, animated: true)
        //NSLog("inside view will appear")
        if Reachability.isConnectedToNetwork() {
            
            let authorizedJson = SharedClass().authorizedJson()
            let url = NSURL(string: SharedClass().clsLink + "/json/building_dsp.cfm?deviceIdentifier=\(authorizedJson.deviceIdentifier)&loginUUID=\(authorizedJson.loginUUID)")
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
                        var resultsArr: NSArray = self.jsonResult["resultssss"] as! NSArray
                        self.buildingInfo = BuildingInfo.buildingInfoWithJSON(resultsArr)
                        let arrayCount = self.buildingInfo.count
                        var countBuilding = 1
                        
                        for buildInfo in self.buildingInfo{
                            let address = "\(buildInfo.address) \(buildInfo.city), \(buildInfo.state) \(buildInfo.zipcode), \(buildInfo.country)"
                            CLGeocoder().geocodeAddressString(address, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
                                if let placemark = placemarks?[0] as? CLPlacemark {
                                    dispatch_async(dispatch_get_main_queue(), {
                                        self.secondLocation = placemark.location
                                        if let delta = self.firstLocation?.distanceFromLocation(self.secondLocation){
                                            self.milesDistance = delta/1000*0.621371192237334
                                            buildInfo.distance = self.milesDistance
                                        }
                                        if(countBuilding == arrayCount){
                                            self.holderBuildingInfo = self.buildingInfo
                                            self.reloadMiles()
                                        }
                                        countBuilding += 1
                                    })
                                }
                            })
                        }
                    } else {
                        SharedClass().serverAlert(self)
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        self.activityIndicatorView.stopAnimating()
                    }
                }else{
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    self.activityIndicatorView.stopAnimating()
                    let alertView = UIAlertController(title: "Connection Failed", message: "Internet Connection: Unavailable", preferredStyle: .Alert)
                    alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (alertAction) -> Void in
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                        let vc = mainStoryboard.instantiateViewControllerWithIdentifier("homeVC") as! UIViewController
                        self.navigationController?.pushViewController(vc, animated: true)
                    }))
                    self.presentViewController(alertView, animated: true, completion: nil)
                }
            })
            task.resume()
        }
        else {
            SharedClass().connectionAlert(self)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.activityIndicatorView.stopAnimating()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            
            var settingAction: UIAlertAction?
            let optionMenu = UIAlertController(title: nil, message: "Access to location is disabled", preferredStyle: .ActionSheet)
            settingAction = UIAlertAction(title: "Open Settings to enable", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                var tempStr = ""
                if let urlString = NSURL(string: UIApplicationOpenSettingsURLString){
                    UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                }
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                (alert: UIAlertAction!) -> Void in
            })
            optionMenu.addAction(settingAction!)
            optionMenu.addAction(cancelAction)
            self.presentViewController(optionMenu, animated: true, completion: nil)
        }
    }
        
    func reload(){
        checkAccessLocation()
        let arrayCount = buildingInfo.count
        self.tableView.addSubview(self.activityIndicatorView)
        self.activityIndicatorView.startAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        var countBuilding = 1
        
        if(buildingInfo.count > 0){
            for buildInfo in buildingInfo{
                let address = "\(buildInfo.address) \(buildInfo.city), \(buildInfo.state) \(buildInfo.zipcode), \(buildInfo.country)"
                CLGeocoder().geocodeAddressString(address, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
                    if let placemark = placemarks?[0] as? CLPlacemark {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.secondLocation = placemark.location
                            if let delta  = self.firstLocation?.distanceFromLocation(self.secondLocation){
                                self.milesDistance = delta/1000*0.621371192237334
                                buildInfo.distance = self.milesDistance
                                self.accessLocation = true
                            }
                            else{
                                self.accessLocation = false
                            }
                            if(countBuilding == arrayCount){
                                self.tableView!.reloadData()
                                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                                self.activityIndicatorView.stopAnimating()
                            }
                            countBuilding += 1 
                        })
                    }
                })
            }
        }
        else{
            self.tableView!.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.activityIndicatorView.stopAnimating()
        }
    }
    
    func reloadMiles(){
        buildingInfo.removeAll(keepCapacity: false)
        for (index, field) in enumerate(self.holderBuildingInfo){
            if(field.distance <= self.miles){
                buildingInfo.append(field)
            }
        }
        reload()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buildingInfo.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //NSLog("inside cell for row \(accessLocation)")
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! UITableViewCell
        cell.layoutMargins = UIEdgeInsetsZero
        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.clearColor() : SharedClass().cellBackGroundColor
        let buildInfo = self.buildingInfo[indexPath.row]
        if(accessLocation){
            if(buildInfo.distance == 0.0){
                let address = "\(buildInfo.address)\n\(buildInfo.city), \(buildInfo.state) \(buildInfo.zipcode)\n\(buildInfo.country)\nDistance: N/A"
                cell.detailTextLabel?.text = address
            }
            else{
                let t_miles = String(format: "%.1f", buildInfo.distance)
                let address = "\(buildInfo.address)\n\(buildInfo.city), \(buildInfo.state) \(buildInfo.zipcode)\n\(buildInfo.country)\nDistance: \(t_miles) miles"
                cell.detailTextLabel?.text = address
            }
        }
        else{
            let address = "\(buildInfo.address)\n\(buildInfo.city), \(buildInfo.state) \(buildInfo.zipcode)\n\(buildInfo.country)\nDistance: N/A"
            cell.detailTextLabel?.text = address
        }
        cell.textLabel?.text = buildInfo.buildingName
        let checkImage = UIImage(named: "location")
        let checkmark = UIImageView(image: checkImage)
        cell.accessoryView = checkmark
        cell.accessoryView?.sizeToFit()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        let buildInfo = self.buildingInfo[indexPath.row]
        let buildName = "\(buildInfo.buildingName)"
        let buildAddress = "\(buildInfo.address),+\(buildInfo.city),+\(buildInfo.state)+\(buildInfo.zipcode),+\(buildInfo.country)"
        let destinationAddress = buildAddress.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.LiteralSearch, range: nil)
        var appleAction: UIAlertAction?
        var googleAction: UIAlertAction?
        let optionMenu = UIAlertController(title: nil, message: "Select map for direction to this building \(buildName)", preferredStyle: .ActionSheet)
            if let escapedDaddr = destinationAddress.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
                appleAction = UIAlertAction(title: "Apple map's direction", style: .Default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    var tempStr = ""
                    if(self.accessLocation){
                        tempStr = "http://maps.apple.com/maps?daddr=\(escapedDaddr)&saddr=\(self.firstLocation.coordinate.latitude),\(self.firstLocation.coordinate.longitude)"
                    }
                    else{
                        tempStr = "http://maps.apple.com/maps?q=\(escapedDaddr)"
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
                        tempStr = "http://maps.google.com/maps?daddr=\(escapedDaddr)&saddr=\(self.firstLocation.coordinate.latitude),\(self.firstLocation.coordinate.longitude)"
                    }
                    else{
                        tempStr = "http://maps.google.com/maps?q=\(escapedDaddr)"
                    }
                    if let urlString = NSURL(string: tempStr){
                        // An the final magic ... openURL!
                        UIApplication.sharedApplication().openURL(urlString)
                    }
                })
            }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            //println("Cancelled")
        })
        optionMenu.addAction(appleAction!)
        optionMenu.addAction(googleAction!)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
        //tableView.deselectRowAtIndexPath(indexPath, animated:false)
    }
}
