//
//  ViewController.swift
//  ACF-CLS
//
//  Created by AcisTek Corporation on 12/16/14.
//  Copyright (c) 2014 AcisTek Corporation. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UISearchBarDelegate, UITabBarDelegate, UIWebViewDelegate, APIControllerProtocol {
    
    var api: APIController?
    
    var usersInfo = [UserInfo]()
    
    var currentUrl = NSURL()
    
    var viewController = 0
    
    var toRow = 25
    
    let kCellIdentifier: String = "SearchResultCell"
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var txtSearchBar: UISearchBar!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalrecordLabel: UILabel!
    
    @IBOutlet weak var menuButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var webView: UIWebView!
    var isWebError = false
    
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var myProfile: UITabBarItem!
    @IBOutlet weak var favoriteList: UITabBarItem!
    @IBOutlet weak var notification: UITabBarItem!
    @IBOutlet weak var signOut: UITabBarItem!
    
    
    var totalCount: Int = 0
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //call function update badge if did recieved push notification when home screen is open
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateBadge", name: "updateBadge", object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        for item in tabBar.items as! [UITabBarItem] {
            if let image = item.image {
                item.image = image.imageWithColor(SharedClass().tabBarImageColor).imageWithRenderingMode(.AlwaysOriginal)
            }
        }
        
        self.tableView.separatorInset = UIEdgeInsetsZero
        self.tableView.layoutMargins = UIEdgeInsetsZero
        
        webView.frame = UIScreen.mainScreen().bounds
        
        webView.center = self.view.center
        configureWebView()
        loadAddressURL()
        tableView.backgroundView = webView
        
        self.txtSearchBar.delegate = self
        tableView.rowHeight = 45.0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if(isWebError){
            configureWebView()
            loadAddressURL()
            tableView.backgroundView = webView
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        updateBadge()
        if (SharedClass().isLoginExpired()){
            navigationItem.rightBarButtonItem?.title = ""
            usernameLabel.text = ""
            //keep device token if login expired
            var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let devicetoken: AnyObject? = prefs.valueForKey("DEVICETOKEN")
            
            let appDomain = NSBundle.mainBundle().bundleIdentifier
            NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
            
            prefs.setObject(devicetoken, forKey: "DEVICETOKEN")
            
            self.performSegueWithIdentifier("goto_login", sender: self)
        }
        else{
            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            if let username = prefs.valueForKey("EMPNAME") as? String{
                self.usernameLabel.text = username
            }
            if(self.txtSearchBar.text == ""){self.totalrecordLabel.text = ""}
            let isCoopable: Int = prefs.integerForKey("COOPID") as Int
            if (isCoopable > 0) {
                self.navigationItem.rightBarButtonItem?.title = "COOP"
            }
            else{
                self.navigationItem.rightBarButtonItem?.title = ""
            }
        }
    }
    
    func updateBadge(){
        var notificationCount = UIApplication.sharedApplication()
        var badgeNumber = String(notificationCount.applicationIconBadgeNumber)
        if(notificationCount.applicationIconBadgeNumber > 0){
            notification.badgeValue = badgeNumber
        }
    }

    @IBAction func signoutTapped(sender: UIBarButtonItem) {
        navigationItem.rightBarButtonItem?.title = ""
        totalrecordLabel.text = ""
        txtSearchBar.text = ""
        usernameLabel.text = ""
        //keep device token if sign out
        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let devicetoken = prefs.valueForKey("DEVICETOKEN") as! NSString
        
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        
        prefs.setObject(devicetoken, forKey: "DEVICETOKEN")
        self.performSegueWithIdentifier("goto_login", sender: self)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didReveiveAPIResults(results: NSDictionary) {
        var resultsArr: NSArray = results["results"] as! NSArray
        dispatch_async(dispatch_get_main_queue(), {
            self.usersInfo = UserInfo.usersInfoWithJSON(resultsArr)
            self.tableView!.reloadData()
            if let totalRow: Int = results["resultCount"] as? Int {
                //println("the total records return value are \(totalRow)")
                if totalRow > 0{
                    self.totalrecordLabel.text = "\(totalRow) record(s)"
                    self.totalCount = totalRow
                }
                else{self.totalrecordLabel.text = ""}
            }
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.activityIndicatorView.stopAnimating()
        })
    }
    
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool{
        let newLength = count(txtSearchBar.text!) + count(text) - range.length
        return newLength <= 25 //Bool
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        toRow = 25
        var searchTerm:NSString = txtSearchBar.text
        var trimmedStr:NSString = searchTerm.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if (trimmedStr.isEqualToString("")) {
            txtSearchBar.text = ""
            trimmedStr = "~~~"
        }
        pullList(trimmedStr as String, fromRow: 1, toRow: toRow)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        hideSideMenuView()
    }
    
    func searchBar(searchBar: UISearchBar,textDidChange searchText: String){
        hideSideMenuView()
        toRow = 25
        var searchTerm:NSString = txtSearchBar.text
        var trimmedStr:NSString = searchTerm.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if (trimmedStr.isEqualToString("")) {
            txtSearchBar.text = ""
            trimmedStr = "~~~"
        }
        pullList(trimmedStr as String, fromRow: 1, toRow: toRow)
    }
    
    func pullList(strData: String, fromRow: Int, toRow: Int){
        if Reachability.isConnectedToNetwork() {
            api = APIController(delegate: self)
            self.tableView.addSubview(self.activityIndicatorView)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            activityIndicatorView.startAnimating()
            api!.searchUserFor(strData,fromRow: 1,toRow: toRow)
        }else {
            SharedClass().connectionAlert(self)
        }
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(usersInfo.count == 0){
            tableView.backgroundView?.hidden = false
        }
        else{
            tableView.backgroundView?.hidden = true
        }
        /*
        if(usersInfo.count == 0){
            let checkImage = UIImage(named: "welcome.png")
            let checkmark = UIImageView(image: checkImage)
            tableView.backgroundView = checkmark
        }
        else{
            tableView.backgroundView = nil
        }*/
        return usersInfo.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as! UITableViewCell
        cell.layoutMargins = UIEdgeInsetsZero
        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.clearColor() : SharedClass().cellBackGroundColor
        let userInfo = self.usersInfo[indexPath.row]
        cell.textLabel?.text = "\(userInfo.firstName) \(userInfo.lastName)"
        let emailAddress = userInfo.emailAddress
        cell.detailTextLabel?.text = emailAddress
        
        return cell
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        hideSideMenuView()
    }

    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        var currentOffset:CGFloat = scrollView.contentOffset.y
        var maximumOffset:CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
        if (maximumOffset - currentOffset <= -40){
            //NSLog("reload\(NSDate())")
            var searchTerm:NSString = txtSearchBar.text
            var trimmedStr:NSString = searchTerm.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            if (trimmedStr.isEqualToString("")) {
                trimmedStr = "~~~"
            }
            if(toRow < SharedClass().rowLimit && trimmedStr != "~~~"){
                toRow += 25
                pullList(trimmedStr as String, fromRow: 1, toRow: toRow)
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String!, sender: AnyObject!) -> Bool {
        if identifier == "coopView" {
            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let isCoopable: Int = prefs.integerForKey("COOPID") as Int
            if (isCoopable == 0) {
                return false
            }
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "showDetails" {
            var detailViewController: DetailViewController = segue.destinationViewController as! DetailViewController
            var userIndex = tableView!.indexPathForSelectedRow()!.row
            var selectedUser = self.usersInfo[userIndex]
            detailViewController.userContactListID = selectedUser.contactListID
            detailViewController.t_profile = 0
        }
        if segue.identifier == "myProfile" {
            var detailViewController: DetailViewController = segue.destinationViewController as! DetailViewController
            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let contactListID:String = prefs.valueForKey("contactListID") as! String
            detailViewController.userContactListID = contactListID
            detailViewController.t_profile = 1
        }
        hideSideMenuView()
        txtSearchBar.resignFirstResponder()
    }
    
    
    @IBAction func toggleSideMenu(sender: AnyObject) {
        txtSearchBar.resignFirstResponder()
        toggleSideMenuView()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
    }

    func loadAddressURL() {
        if let requestURL = NSURL(string: SharedClass().clsLink + "/?switchID=staffGraph_dsp") {
            let request = NSURLRequest(URL: requestURL)
            webView.loadRequest(request)
        }
    }
    
    func configureWebView() {
        webView.backgroundColor = UIColor.whiteColor()
        webView.scalesPageToFit = true
        webView.dataDetectorTypes = .All
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        tableView.addSubview(self.activityIndicatorView)
        activityIndicatorView.startAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicatorView.stopAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        currentUrl = request.URL!
        return true
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        // Report the error inside the web view.
        let localizedErrorMessage = NSLocalizedString("An error occured:", comment: "")
        
        //let errorHTML = "<!doctype html><html><body><div style=\"width: 100%%; text-align: center; font-size: 36pt;\">\(localizedErrorMessage) \(error.localizedDescription)</div></body></html>"
        
        let errorHTML = "<!doctype html><html><body><div style=\"width: 100%%; text-align: center; font-size: 36pt;\"><br /><br /><br />You are currently offline</div></body></html>"
        isWebError = true
        webView.loadHTMLString(errorHTML, baseURL: nil)
        activityIndicatorView.stopAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        
        var selectedTag = tabBar.selectedItem?.tag
        if(selectedTag == 0){
            self.performSegueWithIdentifier("myProfile", sender: self)
        }
        if(selectedTag == 1){
            self.performSegueWithIdentifier("favorites", sender: self)
        }
        if(selectedTag == 2){
            let settings = UIApplication.sharedApplication().currentUserNotificationSettings()
            //println(settings)
            if settings.types.rawValue & UIUserNotificationType.Badge.rawValue != 0 {
                var notificationCount = UIApplication.sharedApplication()
                notificationCount.applicationIconBadgeNumber = 0
                notification.badgeValue = nil
            }
            else{
                NSLog("not allow notification")
            }
            self.performSegueWithIdentifier("notification", sender: self)
        }
        if(selectedTag == 3){
            let alertView = UIAlertController(title: "Sign Out Alert", message: "Are you sure you want to Sign Out?", preferredStyle: .Alert)
            alertView.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            alertView.addAction(UIAlertAction(title: "Sign Out", style: .Default, handler: { (alertAction) -> Void in
                self.navigationItem.rightBarButtonItem?.title = ""
                self.totalrecordLabel.text = ""
                self.txtSearchBar.text = ""
                self.usernameLabel.text = ""
                
                var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                var devicetoken:NSString = ""
                if(prefs.valueForKey("DEVICETOKEN") != nil){
                    devicetoken = prefs.valueForKey("DEVICETOKEN") as! NSString
                }
                else{
                    devicetoken = "0"
                }
                let appDomain = NSBundle.mainBundle().bundleIdentifier
                NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
                
                prefs.setObject(devicetoken, forKey: "DEVICETOKEN")
                self.performSegueWithIdentifier("goto_login", sender: self)
            }))
            presentViewController(alertView, animated: true, completion: nil)
        }
    }
    
}