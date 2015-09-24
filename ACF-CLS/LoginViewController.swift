//
//  LoginVC.swift
//  ACF_CLS
//
//  Created by AcisTek Corporation on 12/16/14.
//  Copyright (c) 2014 Acistek Corporation. All rights reserved.
//

import UIKit
import CoreLocation

class LoginViewController: UIViewController, UITextFieldDelegate, UIWebViewDelegate, CLLocationManagerDelegate {
    
    let manager = CLLocationManager()
    var domainSelect = "ITSC"
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var loginIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var webView: UIWebView!
    var deviceIdentifier = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        CLLocationManager.locationServicesEnabled()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        self.view.backgroundColor = UIColor(red: 218/255.0, green: 205/255.0, blue: 183/255.0, alpha: 1.0)
        
        // Do any additional setup after loading the view.
        var tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
        //txtUsername.becomeFirstResponder()
        configureWebView()
        loadAddressURL()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    /*
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //check if there is temp contact list value
        if(NSUserDefaults.standardUserDefaults().valueForKey("tcontactListID") != nil){
            self.performSegueWithIdentifier("pin_verify", sender: self)
        }
        if(NSUserDefaults.standardUserDefaults().valueForKey("contactListID") != nil){
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }*/
    
    @IBAction func userType(sender: AnyObject) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            domainSelect = "ITSC"
        case 1:
            domainSelect = "external"
        default:
            break; 
        }
    }
    
    func dismissKeyboard(){
        txtUsername.resignFirstResponder()
        txtPassword.resignFirstResponder()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var passLimit = true
        var lengthLimit = 30
        if (textField == txtUsername) {
            let newLength = count(txtUsername.text!) + count(string) - range.length
            if (newLength > lengthLimit){
                passLimit = false
            }
        }
        else if (textField == txtPassword) {
            let newLength = count(txtPassword.text!) + count(string) - range.length
            if (newLength > lengthLimit){
                passLimit = false
            }
        }
        if(!passLimit){
            var alertView:UIAlertView = UIAlertView()
            //alertView.title = "Entry Limit"
            alertView.message = "Please enter less than \(lengthLimit) characters."
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
            return false
        }
        return true
        
        //let newLength = countElements(txtUsername.text!) + countElements(string!) - range.length
        //return newLength <= 25 //Bool
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        //var scrollPoint: CGPoint = CGPointMake(0, textField.frame.origin.y-40.0)
        //scrollView.setContentOffset(scrollPoint, animated: true)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        scrollView.setContentOffset(CGPointZero, animated: true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        checkLogin()
        return true
    }
    
    @IBAction func signinTapped(sender: UIButton) {
        checkLogin()
    }
    
    func checkLogin(){
        dismissKeyboard()
        
        var t_username:NSString = txtUsername.text
        var t_password:NSString = txtPassword.text
        
        var username:NSString = t_username.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        var password:NSString = t_password.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        self.scrollView.addSubview(self.activityIndicatorView)
        self.activityIndicatorView.startAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        if (username.isEqualToString("") || password.isEqualToString("") ) {
            activityIndicatorView.stopAnimating()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Sign in Failed"
            alertView.message = "Please enter Username and Password"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
        else {
            var post:NSString = ""
            var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let deviceType = platformString()
            if let getIdentifier = TegKeychain.get("deviceIdentifier"){
                deviceIdentifier = getIdentifier
            }else{
                deviceIdentifier = UIDevice.currentDevice().identifierForVendor.UUIDString
                TegKeychain.set("deviceIdentifier", value: deviceIdentifier)
            }
            
            let deviceInfo: NSString = "System Name: " + UIDevice.currentDevice().systemName + "; System Version: " + UIDevice.currentDevice().systemVersion
            
            if(prefs.objectForKey("DEVICETOKEN") != nil){
                let deviceToken = prefs.valueForKey("DEVICETOKEN") as! NSString
                post = "domainSelect=\(domainSelect)&username=\(username)&password=\(password)&acfcode=clsmobile&deviceToken=\(deviceToken)&deviceType=\(deviceType)&deviceInfo=\(deviceInfo)&deviceIdentifier=\(deviceIdentifier)"
            }else{
                let deviceToken = "0"
                
                post = "domainSelect=\(domainSelect)&username=\(username)&password=\(password)&acfcode=clsmobile&deviceToken=\(deviceToken)&deviceType=\(deviceType)&deviceInfo=\(deviceInfo)&deviceIdentifier=\(deviceIdentifier)"
            }
            var url:NSURL = NSURL(string: SharedClass().clsLink + "/json/login_act.cfm")!
            
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
                if (res.statusCode >= 200 && res.statusCode < 300){
                    
                    var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                    var error: NSError?
                    let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers , error: &error) as! NSDictionary
                    let success:NSInteger = jsonData.valueForKey("success") as! NSInteger
                    if(success == 1){
                        //grap all info and put in a temp default setting for user to go to two step authentication
                        let tcoopID:String = jsonData.valueForKey("coopID") as! String
                        let temployeeName:String = jsonData.valueForKey("userName") as! String
                        let tcontactListID:String = jsonData.valueForKey("contactListID") as! String
                        let tloginUUID: String = jsonData.valueForKey("loginUUID") as! String
                        let tcellPhone: String = jsonData.valueForKey("cellPhone") as! String
                        let tisDemoAccount: NSInteger = jsonData.valueForKey("isDemoAccount") as! NSInteger
                        //NSLog("Login SUCCESS");
                        
                        //let loggedInDate = NSDate(); this one has time element
                        let tloggedInDate = NSCalendar.currentCalendar().startOfDayForDate(NSDate()) //this is without time
                        
                        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                        
                        if(tisDemoAccount == 1){
                            prefs.setObject(tcoopID, forKey: "coopID")
                            prefs.setObject(tloggedInDate, forKey: "logginedDate")
                            prefs.setObject(temployeeName, forKey: "employeeName")
                            prefs.setObject(tloggedInDate, forKey: "credentialDate")
                            prefs.setObject(tcontactListID, forKey: "contactListID")
                            prefs.setObject(self.domainSelect, forKey: "domainSelect")
                            prefs.synchronize()
                            TegKeychain.set("username", value: username as! String)
                            TegKeychain.set("password", value: password as! String)
                            TegKeychain.set("loginUUID", value: tloginUUID)
                            self.activityIndicatorView.stopAnimating()
                            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }else{
                            prefs.setObject(tcoopID, forKey: "tcoopID")
                            prefs.setObject(tloggedInDate, forKey: "tlogginedDate")
                            prefs.setObject(temployeeName, forKey: "temployeeName")
                            //the below vars to check credential
                            prefs.setObject(tloggedInDate, forKey: "tcredentialDate")
                            prefs.setObject(tcontactListID, forKey: "tcontactListID")
                            prefs.setObject(tcellPhone, forKey: "tcellPhone")
                            prefs.setObject(self.domainSelect, forKey: "tdomainSelect")
                            prefs.synchronize()
                            TegKeychain.set("username", value: username as! String)
                            TegKeychain.set("password", value: password as! String)
                            TegKeychain.set("loginUUID", value: tloginUUID)
                            self.activityIndicatorView.stopAnimating()
                            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                            self.performSegueWithIdentifier("pin_verify", sender: self)
                        }
                    } else {
                        var error_msg: String
                        
                        if jsonData["error_message"] as? NSString != nil {
                            error_msg = jsonData["error_message"] as! String
                        } else {
                            error_msg = "Unknown Error"
                        }
                        var alertView:UIAlertView = UIAlertView()
                        alertView.title = "Sign in Failed"
                        alertView.message = error_msg
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                        self.activityIndicatorView.stopAnimating()
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    }
                    
                } else {
                    SharedClass().serverAlert(self)
                    self.activityIndicatorView.stopAnimating()
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }
            } else {
                var alertView:UIAlertView = UIAlertView()
                alertView.title = "Sign in Failed"
                alertView.message = "Connection Failure"
                if let error = reponseError {
                    alertView.message = (error.localizedDescription)
                }
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
                self.activityIndicatorView.stopAnimating()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
        }
    }
    
    func loadAddressURL() {
        if let requestURL = NSURL(string: SharedClass().clsLink + "/?switchID=term_dsp") {
            let request = NSURLRequest(URL: requestURL)
            webView.loadRequest(request)
        }
    }
    
    func configureWebView() {
        webView.backgroundColor = UIColor.clearColor()
        webView.scalesPageToFit = true
        webView.dataDetectorTypes = .All
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        scrollView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicatorView.stopAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        // Report the error inside the web view.
        let localizedErrorMessage = NSLocalizedString("An error occured:", comment: "")
        
        let errorHTML = "<!doctype html><html><body><div style=\"width: 100%%; text-align: center; font-size: 36pt;\">\(localizedErrorMessage) \(error.localizedDescription)</div></body></html>"
        
        webView.loadHTMLString(errorHTML, baseURL: nil)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    
    func platform() -> String {
        var size : Int = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](count: Int(size), repeatedValue: 0)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String.fromCString(machine)!
    }
    
    /********************************************/
    
    func platformString() -> String {
        
        var devSpec : String
        var caseDefault: String = platform()
        
        switch platform()
        {
        case "iPhone1,2": devSpec = "iPhone 3G"
        case "iPhone2,1": devSpec = "iPhone 3GS"
        case "iPhone3,1": devSpec = "iPhone 4"
        case "iPhone3,3": devSpec = "Verizon iPhone 4"
        case "iPhone4,1": devSpec = "iPhone 4S"
        case "iPhone5,1": devSpec = "iPhone 5 (GSM)"
        case "iPhone5,2": devSpec = "iPhone 5 (GSM+CDMA)"
        case "iPhone5,3": devSpec = "iPhone 5c (GSM)"
        case "iPhone5,4": devSpec = "iPhone 5c (GSM+CDMA)"
        case "iPhone6,1": devSpec = "iPhone 5s (GSM)"
        case "iPhone6,2": devSpec = "iPhone 5s (GSM+CDMA)"
        case "iPhone7,1": devSpec = "iPhone 6 Plus"
        case "iPhone7,2": devSpec = "iPhone 6"
        case "iPod1,1": devSpec = "iPod Touch 1G"
        case "iPod2,1": devSpec = "iPod Touch 2G"
        case "iPod3,1": devSpec = "iPod Touch 3G"
        case "iPod4,1": devSpec = "iPod Touch 4G"
        case "iPod5,1": devSpec = "iPod Touch 5G"
        case "iPad1,1": devSpec = "iPad"
        case "iPad2,1": devSpec = "iPad 2 (WiFi)"
        case "iPad2,2": devSpec = "iPad 2 (GSM)"
        case "iPad2,3": devSpec = "iPad 2 (CDMA)"
        case "iPad2,4": devSpec = "iPad 2 (WiFi)"
        case "iPad2,5": devSpec = "iPad Mini (WiFi)"
        case "iPad2,6": devSpec = "iPad Mini (GSM)"
        case "iPad2,7": devSpec = "iPad Mini (GSM+CDMA)"
        case "iPad3,1": devSpec = "iPad 3 (WiFi)"
        case "iPad3,2": devSpec = "iPad 3 (GSM+CDMA)"
        case "iPad3,3": devSpec = "iPad 3 (GSM)"
        case "iPad3,4": devSpec = "iPad 4 (WiFi)"
        case "iPad3,5": devSpec = "iPad 4 (GSM)"
        case "iPad3,6": devSpec = "iPad 4 (GSM+CDMA)"
        case "iPad4,1": devSpec = "iPad Air (WiFi)"
        case "iPad4,2": devSpec = "iPad Air (Cellular)"
        case "iPad4,4": devSpec = "iPad mini 2G (WiFi)"
        case "iPad4,5": devSpec = "iPad mini 2G (Cellular)"
            
        case "iPad4,7": devSpec = "iPad mini 3 (WiFi)"
        case "iPad4,8": devSpec = "iPad mini 3 (Cellular)"
        case "iPad4,9": devSpec = "iPad mini 3 (China Model)"
            
        case "iPad5,3": devSpec = "iPad Air 2 (WiFi)"
        case "iPad5,4": devSpec = "iPad Air 2 (Cellular)"
            
        case "i386": devSpec = "Simulator"
        case "x86_64": devSpec = "Simulator"
            
        default: devSpec = caseDefault
        }
        
        return devSpec
    }
    
}
