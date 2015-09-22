//
//  MyMenuTableViewController.swift
//  ACF-CLS
//
//  Created by AcisTek Corporation on 12/17/14.
//  Copyright (c) 2014 AcisTek Corporation. All rights reserved.
//

import UIKit

class CLSMenuTableViewController: UITableViewController {
    
    var selectedMenuItem : Int = 0
    var menuArr = ["Menu","Search","ACF Buildings","ACF Web Site","Support","Contact Us"]
    var menuImg = ["blank","search","building","web","blank","help"]
    var rowNo = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorInset = UIEdgeInsetsZero
        self.tableView.layoutMargins = UIEdgeInsetsZero
        // Customize apperance of table view
        tableView.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0) //
        //tableView.separatorStyle = .SingleLine
        //tableView.separatorColor = UIColor.grayColor()
        tableView.backgroundColor = UIColor(red: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 1.0)
        tableView.scrollsToTop = false
        
        // Preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        //tableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedMenuItem, inSection: 0), animated: false, scrollPosition: .Middle)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return 6
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as? UITableViewCell
        rowNo += 1
        cell?.layoutMargins = UIEdgeInsetsZero
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CELL")
            cell!.backgroundColor = UIColor.clearColor()
            cell!.textLabel?.textColor = UIColor.darkGrayColor()
            let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell!.frame.size.width, cell!.frame.size.height))
            selectedBackgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
            cell!.selectedBackgroundView = selectedBackgroundView
        }
        if(menuArr[indexPath.row] == "Menu" || menuArr[indexPath.row] == "Support"){
            rowNo = 1
            cell!.backgroundColor = SharedClass().headerColor
            let selectedColor = UIView()
            selectedColor.backgroundColor = SharedClass().headerColor
            cell!.selectedBackgroundView = selectedColor
            
            cell!.textLabel?.textColor = UIColor.blackColor()
            cell!.textLabel?.font = UIFont.boldSystemFontOfSize(18.0)
            cell!.textLabel?.textAlignment = .Center
            cell!.textLabel?.text = menuArr[indexPath.row]
        }
        else{
            cell!.backgroundColor = rowNo % 2 == 0 ? UIColor.clearColor() : SharedClass().cellBackGroundColor
            cell!.textLabel?.textColor = UIColor.blackColor()
            cell!.textLabel?.font = UIFont.boldSystemFontOfSize(14.0)
            cell!.textLabel?.text = menuArr[indexPath.row]
            cell!.imageView?.image = UIImage(named: menuImg[indexPath.row])
        }
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var isRefresh = false
        switch (indexPath.row) {
        case 1:
            isRefresh = true
            break
        case 2:
            NSNotificationCenter.defaultCenter().postNotificationName("building", object: nil)
            break
        case 3:
            NSNotificationCenter.defaultCenter().postNotificationName("acfWeb", object: nil)
            break
        case 5:
            NSNotificationCenter.defaultCenter().postNotificationName("contactUs", object: nil)
            break
        default:
            break
        }
        if(isRefresh){
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
            var destViewController : UIViewController
            destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("homeVC") as! UIViewController
            sideMenuController()?.setContentViewController(destViewController)
        }
    }
}

