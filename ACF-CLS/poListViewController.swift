//
//  poList.swift
//  ACF-CLS
//
//  Created by Acistek on 5/22/15.
//  Copyright (c) 2015 AcisTek Corporation. All rights reserved.
//

import UIKit


class poListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    var jsonResult: NSDictionary = [String:String]()
    var PoList = [PoInfo]()
    let cellIdentifier = "PoCell"
       
    @IBOutlet var PoTable: UITableView!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
//        let backButton = UIBarButtonItem(title: "<", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
//        navigationItem.leftBarButtonItem = backButton
        if !Reachability.isConnectedToNetwork(){
            SharedClass().connectionAlert(self)
        }else{
            self.PoTable.separatorStyle = UITableViewCellSeparatorStyle(rawValue: 0)!
            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
            
            PoTable.delegate = self
            PoTable.dataSource = self
            
            self.PoTable.addSubview(self.activityIndicatorView)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            activityIndicatorView.startAnimating()
            
            let url = NSURL(string: SharedClass().clsLink + "/json/POList.cfm")
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
//                        println(resultsArr)
                        self.PoList = PoInfo.poInfoWithJSON(resultsArr)
                        self.PoTable!.reloadData()
                        self.activityIndicatorView.stopAnimating()
                        self.activityIndicatorView.hidden = true
                    }
                    else{
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
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
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let url = NSURL(string: SharedClass().clsLink + "/json/POList.cfm")
        let session = NSURLSession.sharedSession()

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
            let t_header = "Program Office"
            cell.textLabel?.text = t_header
            cell.detailTextLabel?.text = ""
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
            let cellValue = "Total number of staff not responded - " + poList.totalUsers
            cell.detailTextLabel?.text = cellValue
            if(poList.totalUsers == "0"){
                cell.userInteractionEnabled = false;
                cell.accessoryType = .None
            }
            else{
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            }
        }
        
        
        return cell
    }
    

  
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
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
