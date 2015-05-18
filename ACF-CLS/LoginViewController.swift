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
        // Dispose of any resources that can be recreated.
    }
    
    
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
        // Authentication Code
        
        dismissKeyboard()
        
        var t_username:NSString = txtUsername.text
        var t_password:NSString = txtPassword.text
        
        var username:NSString = t_username.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        var password:NSString = t_password.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if ( username.isEqualToString("") || password.isEqualToString("") ) {
            loginIndicatorView.stopAnimating()
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
            var identifier = UIDevice.currentDevice().identifierForVendor.UUIDString
            
            
            let deviceInfo: NSString = "System Name: " + UIDevice.currentDevice().systemName + "; System Version: " + UIDevice.currentDevice().systemVersion
            
            if(prefs.objectForKey("DEVICETOKEN") != nil){
                let devicetoken = prefs.valueForKey("DEVICETOKEN") as! NSString
                post = "domainSelect=\(domainSelect)&username=\(username)&password=\(password)&acfcode=clsmobile&devicetoken=\(devicetoken)&devicetype=\(deviceType)&deviceinfo=\(deviceInfo)&identifier=\(identifier)"
            }
                
            else{
                let devicetoken = "0"
                post = "domainSelect=\(domainSelect)&username=\(username)&password=\(password)&acfcode=clsmobile&devicetoken=\(devicetoken)&devicetype=\(deviceType)&deviceinfo=\(deviceInfo)&identifier=\(identifier)"
            }
            
            var url:NSURL = NSURL(string: SharedClass().clsLink + "/json/login_act.cfm")!
            
            var postData:NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
            
            var postLength:NSString = String( postData.length )
            
            //NSLog("PostData2: %@",postData);
            
            var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.HTTPBody = postData
            request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            
            var reponseError: NSError?
            var response: NSURLResponse?
            
            var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
            
            self.scrollView.addSubview(self.loginIndicatorView)
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            loginIndicatorView.startAnimating()
            
            if ( urlData != nil ) {
                let res = response as! NSHTTPURLResponse!;
                
                //NSLog("Response code: %ld", res.statusCode);
                
                if (res.statusCode >= 200 && res.statusCode < 300)
                {
                    var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                    
                    //NSLog("Response ==> %@", responseData);
                    
                    var error: NSError?
                    
                    let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers , error: &error) as! NSDictionary
                    
                    
                    let success:NSInteger = jsonData.valueForKey("success") as! NSInteger
                    
                    
                    //[jsonData[@"success"] integerValue];
                    
                    //NSLog("Success: %ld", success);
                    
                    if(success == 1)
                    {
                        let coopID:NSString = jsonData.valueForKey("coopID") as! NSString
                        let empName:NSString = jsonData.valueForKey("userName") as! NSString
                        let contactListID:NSString = jsonData.valueForKey("contactListID") as! NSString
                        //NSLog("Login SUCCESS");
                        
                        //let loggedInDate = NSDate(); this is has time element
                        let loggedInDate = NSCalendar.currentCalendar().startOfDayForDate(NSDate()) //this is without time
                        
                        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                        prefs.setObject(coopID, forKey: "COOPID")
                        prefs.setObject(loggedInDate, forKey: "LOGGINEDDATE")
                        prefs.setObject(empName, forKey: "EMPNAME")
                        //the below vars to check credential
                        prefs.setObject(loggedInDate, forKey: "credentialDate")
                        prefs.setObject(contactListID, forKey: "contactListID")
                        prefs.setObject(username, forKey: "username")
                        prefs.setObject(password, forKey: "password")
                        prefs.setObject(domainSelect, forKey: "domainSelect")
                        //use the synchronize() command for NSUserDefaults to make sure your stuff is saved, but in iOS 8 and on, you should not call synchronize() in most situations.
                        //prefs.synchronize()
                        
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        var error_msg:NSString
                        
                        if jsonData["error_message"] as? NSString != nil {
                            error_msg = jsonData["error_message"] as! NSString
                        } else {
                            error_msg = "Unknown Error"
                        }
                        var alertView:UIAlertView = UIAlertView()
                        alertView.title = "Sign in Failed"
                        alertView.message = error_msg as String
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                    }
                    
                } else {
                    //NSLog("error \(res.statusCode)")
                    SharedClass().serverAlert(self)
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
            }
            loginIndicatorView.stopAnimating()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
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
