//
//  ViewController.swift
//  ACF-CLS
//
//  Created by AcisTek Corporation on 12/16/14.
//  Copyright (c) 2014 AcisTek Corporation. All rights reserved.
//

import UIKit
import WebKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UISearchBarDelegate, UITabBarDelegate, WKScriptMessageHandler, WKNavigationDelegate, APIControllerProtocol{
    
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
    
    var webView: WKWebView
    
    var isWebError = false
    
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var myProfile: UITabBarItem!
    @IBOutlet weak var favoriteList: UITabBarItem!
    @IBOutlet weak var notification: UITabBarItem!
    @IBOutlet weak var signOut: UITabBarItem!
    
    var totalCount: Int = 0
    
    required init(coder aDecoder: NSCoder) {
        self.webView = WKWebView(frame: CGRectZero)
        super.init(coder: aDecoder)
        //call function update badge if did recieved push notification when home screen is open
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateBadge", name: "updateBadge", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "building", name: "building", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "acfWeb", name: "acfWeb", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "contactUs", name: "contactUs", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "module", name: "module", object: nil)
        
        self.webView.navigationDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtSearchBar.placeholder = "Enter a name to search...                            "
        self.navigationController?.popoverPresentationController?.backgroundColor = UIColor.redColor()
        // Do any additional setup after loading the view.
        for item in tabBar.items as! [UITabBarItem] {
            if let image = item.image {
                item.image = image.imageWithColor(SharedClass().tabBarImageColor).imageWithRenderingMode(.AlwaysOriginal)
            }
        }

        self.tableView.separatorInset = UIEdgeInsetsZero
        self.tableView.layoutMargins = UIEdgeInsetsZero
        
        var userScript = WKUserScript(
            source: "",
            injectionTime: WKUserScriptInjectionTime.AtDocumentEnd,
            forMainFrameOnly: true
        )
        var contentController = WKUserContentController()
        contentController.addUserScript(userScript)
        contentController.addScriptMessageHandler(
            self,
            name: "callbackHandler"
        )
        
        var config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        self.webView = WKWebView(
            frame: UIScreen.mainScreen().bounds,
            configuration: config
        )
        
        webView.center = self.view.center
        configureWebView()
        loadAddressURL()
        tableView.backgroundView = webView

        self.txtSearchBar.delegate = self
        tableView.rowHeight = 45.0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //check if there is web error before then refresh it
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
            isWebError = false // this line to refresh chart when go back from login
            self.performSegueWithIdentifier("goto_login", sender: self)
        }
        else{
            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            if let username = prefs.valueForKey("employeeName") as? String{
                self.usernameLabel.text = username
            }
            if(self.txtSearchBar.text == ""){self.totalrecordLabel.text = ""}
            let isCoopable: Int = prefs.integerForKey("coopID") as Int
            if (isCoopable > 0) {
                self.navigationItem.rightBarButtonItem?.title = "COOP"
            }
            else{
                self.navigationItem.rightBarButtonItem?.title = ""
            }
        }
    }
    
    func updateBadge(){
        //check if notification turn on or not
        var notificationCount = UIApplication.sharedApplication()
        var badgeNumber = String(notificationCount.applicationIconBadgeNumber)
        if(notificationCount.applicationIconBadgeNumber > 0){
            if((notification) != nil){
                notification.badgeValue = badgeNumber
            }
        }
    }
    
    func building(){
        hideSideMenuView()
        self.performSegueWithIdentifier("building", sender: self)
    }
    
    func acfWeb(){
        hideSideMenuView()
        self.performSegueWithIdentifier("acfWeb", sender: self)
    }
    
    func contactUs(){
        hideSideMenuView()
        self.performSegueWithIdentifier("contactUs", sender: self)
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
            hideSideMenuView()
            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let isCoopable: Int = prefs.integerForKey("coopID") as Int
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
            if Reachability.isConnectedToNetwork() {
                webView.loadRequest(request)
            }else{
                let errorHTML = "<!doctype html><html><body><div style=\"width: 100%%; text-align: center; font-size: 36pt;\"><br /><br /><br />You are currently offline</div></body></html>"
                webView.loadHTMLString(errorHTML, baseURL: nil)
                isWebError = true
            }
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            activityIndicatorView.stopAnimating()
        }
    }
    
    func configureWebView() {
        webView.backgroundColor = UIColor.whiteColor()
    }
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage){
        if(message.name == "callbackHandler") {
            if(message.body.containsString("notResponded")){
                performSegueWithIdentifier("PoList", sender: self)
            }
        }
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        hideSideMenuView()
        var selectedTag = tabBar.selectedItem?.tag
        if(selectedTag == 0){
            self.performSegueWithIdentifier("myProfile", sender: self)
        }
        if(selectedTag == 1){
            self.performSegueWithIdentifier("favorites", sender: self)
        }
        if(selectedTag == 2){
            notification.badgeValue = nil
            var notificationCount = UIApplication.sharedApplication()
            notificationCount.applicationIconBadgeNumber = 0
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