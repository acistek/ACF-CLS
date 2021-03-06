//
//  poList.swift
//  ACF-CLS
//
//  Created by Acistek on 5/22/15.
//  Copyright (c) 2015 AcisTek Corporation. All rights reserved.
//

import UIKit


class POListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    var jsonResult: NSDictionary = [String:String]()
    var PoList = [PoInfo]()
    let cellIdentifier = "PoCell"
       
    @IBOutlet var PoTable: UITableView!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //stop display menu from swiping to right
        var rightSwipe = UISwipeGestureRecognizer(target: self, action: nil)
        rightSwipe.direction = .Right
        view.addGestureRecognizer(rightSwipe)
        if !Reachability.isConnectedToNetwork(){
            SharedClass().connectionAlert(self)
        }else{
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
            
            self.PoTable.addSubview(self.activityIndicatorView)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            activityIndicatorView.startAnimating()
            let authorizedJson = SharedClass().authorizedJson()
            let url = NSURL(string: SharedClass().clsLink + "/json/POList.cfm?deviceIdentifier=\(authorizedJson.deviceIdentifier)&loginUUID=\(authorizedJson.loginUUID)")
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
                            self.PoList = PoInfo.poInfoWithJSON(resultsArr)
                            self.PoTable!.reloadData()
                            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
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
        return PoList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        let poList = self.PoList[indexPath.row]
        if(poList.POShort == "header"){
            cell.backgroundColor = SharedClass().coopGroupHeaderColor
            let selectedColor = UIView()
            selectedColor.backgroundColor = SharedClass().coopGroupHeaderColor
            cell.selectedBackgroundView = selectedColor
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.textLabel?.font = UIFont.boldSystemFontOfSize(18.0)
            cell.textLabel?.textAlignment = .Left
            cell.accessoryType = .None
            cell.textLabel?.text = poList.subtitle
            cell.detailTextLabel?.text = " "
            cell.userInteractionEnabled = false;
        }
        else{
            cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.clearColor() : SharedClass().cellBackGroundColor
            let selectedColor = UIView()
            selectedColor.backgroundColor = SharedClass().selectedCellColor
            cell.selectedBackgroundView = selectedColor
            cell.textLabel?.font = UIFont.boldSystemFontOfSize(11.0)
            cell.textLabel?.textColor = UIColor.blackColor()
            if(poList.POShort != "OTHER" && poList.POShort != "invalid" && poList.POShort != "all"){
                cell.textLabel?.text = poList.POName + " - " + poList.POShort
            }
            else{
                cell.textLabel?.text = poList.POName
            }
            let cellValue = poList.subtitle + poList.totalUsers
            cell.detailTextLabel?.text = cellValue
            if(poList.totalUsers == "0"){
                cell.userInteractionEnabled = false;
                cell.accessoryType = .None
            }
            else{
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell.userInteractionEnabled = true;
            }
        }
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "PoDetailList" {
            var poDetailVIewController: PODetailVIewController = segue.destinationViewController as! PODetailVIewController
            var poIndex = PoTable!.indexPathForSelectedRow()!.row
            var selectedPO = self.PoList[poIndex]
   
            poDetailVIewController.POShort = selectedPO.POShort
            poDetailVIewController.POName = selectedPO.POName
        }
    }

}
