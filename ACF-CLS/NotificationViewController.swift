//
//  NotificationViewController.swift
//  ACF-CLS
//
//  Created by AcisTek Corporation on 2/24/15.
//  Copyright (c) 2015 AcisTek Corporation. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var jsonResult: NSDictionary = [String:String]()
    
    var notificationInfo = [NotificationInfo]()
    let cellIdentifier = "systemCell"
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        self.title = "Notifications"
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.estimatedRowHeight = 68.0
        tableView.rowHeight = UITableViewAutomaticDimension
        //self.tableView.rowHeight = 105.0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        if Reachability.isConnectedToNetwork() {
            self.tableView.addSubview(self.activityIndicatorView)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            activityIndicatorView.startAnimating()
            let url = NSURL(string: SharedClass().clsLink + "/json/dms_dsp.cfm?acfcode=clsmobile")
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
                        var resultCount: Int = self.jsonResult["resultCount"] as! Int
                        dispatch_async(dispatch_get_main_queue(), {
                            if(resultCount > 0){
                                self.notificationInfo = NotificationInfo.notificationInfoWithJSON(resultsArr)
                                self.tableView!.reloadData()
                            }else{
                                self.notificationInfo = NotificationInfo.notificationInfoWithJSON(resultsArr)
                                let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
                                let alertView = UIAlertController(title: "All systems are operational as of \(timestamp)", message: "", preferredStyle: .Alert)
                                alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (alertAction) -> Void in
                                    self.navBack()
                                }))
                                self.presentViewController(alertView, animated: true, completion: nil)
                            }
                            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                            self.activityIndicatorView.stopAnimating()
                        })
                        
                    } else {
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        self.activityIndicatorView.stopAnimating()
                        SharedClass().serverAlert(self)
                    }
                }else{
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    self.activityIndicatorView.stopAnimating()
                    SharedClass().connectionAlert(self)
                }
                
            })
            task.resume()
        }
        else {
            SharedClass().connectionAlert(self)
        }
    }
    
    func navBack(){
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationInfo.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! CustomTableViewCell
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! CustomNotificationCell
        cell.layoutMargins = UIEdgeInsetsZero
        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.clearColor() : SharedClass().cellBackGroundColor
        
        let notificationInfo = self.notificationInfo[indexPath.row]
        cell.nameLabel.text = "\(notificationInfo.systemName)"
        cell.descriptionLabel.text = "\(notificationInfo.description)"
        cell.actButton.tag = indexPath.row
        if let image  = UIImage(named: "info") {
            cell.actButton.setImage(image, forState: .Normal)
        }
        cell.actButton.addTarget(self, action: "btnTouched:", forControlEvents: (.TouchUpOutside | .TouchUpInside))
        return cell
    }
    
    func btnTouched(sender: AnyObject){
        var position: CGPoint = sender.convertPoint(CGPointZero, toView: self.tableView)
        let indexPath = self.tableView.indexPathForRowAtPoint(position)
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
        self.performSegueWithIdentifier("systemURL", sender: self)
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
        self.performSegueWithIdentifier("systemURL", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "systemURL" {
            var detailViewController: WebViewController = segue.destinationViewController as! WebViewController
            var notificationIndex = tableView!.indexPathForSelectedRow()!.row
            var selectedSystem = self.notificationInfo[notificationIndex]
            detailViewController.webSiteAddress = selectedSystem.systemURL
            detailViewController.navigationTitle = selectedSystem.systemName        }
    }

}
