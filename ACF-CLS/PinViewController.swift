//
//  PinViewController.swift
//  ACF-CLS
//
//  Created by AcisTek Corporation on 8/7/15.
//  Copyright (c) 2015 AcisTek Corporation. All rights reserved.
//

import UIKit

class PinViewController: UIViewController, UITextFieldDelegate, UIWebViewDelegate {
    
    @IBOutlet weak var editPhoneImg: UIImageView!
    @IBOutlet weak var txtCell3: UITextField!
   
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var loginIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var sendPinButton: UIButton!
    
    @IBOutlet weak var unwindHome: UIButton!
    
    var delegate: WriteValueBackDelegate?
    
    let authorizedJson = SharedClass().authorizedJson()
    
    var enterTxtField = 1
    
    var comeFrom = 1
    
    var range:String = ""
    var tcellPhone:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
        self.view.backgroundColor = UIColor(red: 218/255.0, green: 205/255.0, blue: 183/255.0, alpha: 1.0)
        
        let aSelector : Selector = "updateTapped"
        let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        tapGesture.numberOfTapsRequired = 1
        editPhoneImg.addGestureRecognizer(tapGesture)
        
        editPhoneImg.userInteractionEnabled = true
        txtCell3.delegate = self
        txtCell3.keyboardType = UIKeyboardType.NumberPad
        
        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()

        tcellPhone = prefs.valueForKey("tcellPhone") as! String
        if(tcellPhone != ""){
            range = String(Array(tcellPhone)[6...9])
            txtCell3.text = "(xxx) xxx-" + range
            txtCell3.enabled = false
        }else{
            editPhoneImg.hidden = true
            var alertView:UIAlertView = UIAlertView()
            alertView.title = ""
            alertView.message = "Please enter your cell phone number to receive a PIN"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
        configureWebView()
        loadAddressURL()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //check if there is verify pin
        if(NSUserDefaults.standardUserDefaults().valueForKey("tverifyPin") != nil){
            verifyPin()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //This function to verify cell phone before allow user to change the cell number
    func updateTapped(){
        self.activityIndicatorView.stopAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        enterTxtField = 2
        var alert = UIAlertController(title: "Cell Phone Verification", message: "Please enter the cell phone number associated with your account", preferredStyle: .Alert)
        //2. Add the text field. You can configure it however you need.
        alert.addTextFieldWithConfigurationHandler({(verifyTxtCell) -> Void in
            verifyTxtCell.delegate = self
            verifyTxtCell.placeholder = "Enter number"
            verifyTxtCell.text = ""
            verifyTxtCell.keyboardType = UIKeyboardType.NumberPad
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as! UITextField
            //strip non numeric
            let stringArray = textField.text.componentsSeparatedByCharactersInSet(
                NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            let phoneFactor:NSString = NSArray(array: stringArray).componentsJoinedByString("")
            
            var phoneLength = count(String(phoneFactor).utf16)
            
            if (phoneFactor.isEqualToString("")) {
                var alertView:UIAlertView = UIAlertView()
                alertView.title = ""
                alertView.message = "Please enter your 10-digit cell phone number"
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
                self.updateTapped()
            }
            else if(phoneLength != 10){
                var alertView:UIAlertView = UIAlertView()
                alertView.title = ""
                alertView.message = "Please enter your 10-digit cell phone number"
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
                self.updateTapped()
            }
            else{
                self.checkCellPhone(self.authorizedJson.deviceIdentifier as String, loginUUID: self.authorizedJson.loginUUID as String, cellPhone: phoneFactor as String)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in
            self.enterTxtField = 1
        }))
        
        // 4. Present the alert.
        self.presentViewController(alert, animated: true, completion: nil)

    }
    
    //This function to cancel the pin verify screen to go back to login screen. Keep device token intact when remove user settings
    @IBAction func cancelButton(sender: AnyObject) {
        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let devicetoken: AnyObject? = prefs.valueForKey("DEVICETOKEN")
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        prefs.setObject(devicetoken, forKey: "DEVICETOKEN")
        if(comeFrom == 1){
            self.dismissViewControllerAnimated(true, completion: nil)
        }else{
            self.performSegueWithIdentifier("back_login", sender: self)
        }
    }
    
    func dismissKeyboard(){
        txtCell3.resignFirstResponder()
    }

    func textFieldDidEndEditing(textField: UITextField) {
        enterTxtField = 1
        scrollView.setContentOffset(CGPointZero, animated: true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var isGood = true
        var checkText: Bool
        
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).stringByReplacingCharactersInRange(range, withString: string)
        //check if text field is for phone or not
        if(enterTxtField <= 2 && count(String(prospectiveText).utf16) <= 14){
            textField.text = SharedClass().formatUSPhone(currentText, range: range, string: string)
            checkText = false
        }else{
            checkText = prospectiveText.containsOnlyCharactersIn("0123456789") &&
                count(String(prospectiveText).utf16) <= 6
            
        }
        if(!checkText){
            isGood = false
        }
        return isGood
    }
    
    //this func to verify cell number is matched or not through post http
    func checkCellPhone(deviceIdentifier: String, loginUUID: String, cellPhone: String) {
        dismissKeyboard()
        var post: NSString = ""
        
        let range1 = String(Array(tcellPhone)[0...2])
        let range2 = String(Array(tcellPhone)[3...5])
        let range3 = String(Array(tcellPhone)[6...9])
        
        self.scrollView.addSubview(self.activityIndicatorView)
        self.activityIndicatorView.startAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        post = "deviceIdentifier=\(deviceIdentifier)&loginUUID=\(loginUUID)&cellPhone=\(cellPhone)&verifyPhone=yes"
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
                    dispatch_async(dispatch_get_main_queue(), {
                        self.activityIndicatorView.stopAnimating()
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        self.txtCell3.text = "(" + range1 + ") " + range2 + "-" + range3
                        self.txtCell3.enabled = true
                        self.editPhoneImg.hidden = true
                        var success_msg: String
                        if jsonData["error_message"] as? NSString != nil {
                            success_msg = jsonData["error_message"] as! String
                        } else {
                            success_msg = "You have successfully verified the cell phone number associated with your account. You may now edit your cell phone number"
                        }
                        var alertView:UIAlertView = UIAlertView()
                        alertView.title = "Verification Successful"
                        alertView.message = success_msg
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                        self.txtCell3.becomeFirstResponder()
                    })
                }
                else{
                    var error_msg: String
                    if jsonData["error_message"] as? NSString != nil {
                        error_msg = jsonData["error_message"] as! String
                    } else {
                        error_msg = "The number you entered does not match the number associated with your account"
                    }
                    var alertView:UIAlertView = UIAlertView()
                    alertView.title = "Verification Failed"
                    alertView.message = error_msg
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                    self.activityIndicatorView.stopAnimating()
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    self.updateTapped()
                }
                
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

    //this func trigger when click send pin button
    @IBAction func sendPinTapped(sender: UIButton) {
        sendPinCode(self.authorizedJson.deviceIdentifier as String, loginUUID: self.authorizedJson.loginUUID as String)
    }
    
    //this func to ask system to send pin based on the cell provided
    func sendPinCode(deviceIdentifier: String, loginUUID: String) {
        dismissKeyboard()
        var cellStr = ""
        var post: NSString = ""
        if (txtCell3.text.rangeOfString("xxx") == nil) {
            cellStr = txtCell3.text
        }else{
            cellStr = tcellPhone
        }
        //strip non numeric
        let stringArray = cellStr.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        let phoneFactor:NSString = NSArray(array: stringArray).componentsJoinedByString("")
        
        var phoneLength = count(String(phoneFactor).utf16)
        
        if (phoneFactor.isEqualToString("")) {
            var alertView:UIAlertView = UIAlertView()
            alertView.title = ""
            alertView.message = "Please enter a 10-digit cell phone number"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
        else if(phoneLength != 10){
            var alertView:UIAlertView = UIAlertView()
            alertView.title = ""
            alertView.message = "Please enter a 10-digit cell phone number"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }
        else{
            self.scrollView.addSubview(self.activityIndicatorView)
            self.activityIndicatorView.startAnimating()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            post = "deviceIdentifier=\(deviceIdentifier)&loginUUID=\(loginUUID)&cellPhone=\(phoneFactor)&sendPin=yes"
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
                    var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                    if(success == 1){
                        dispatch_async(dispatch_get_main_queue(), {
                            prefs.setObject(1, forKey: "tverifyPin")
                            prefs.setObject(phoneFactor, forKey: "tcellPhone")
                            self.verifyPin()
                            self.activityIndicatorView.stopAnimating()
                            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        })
                    }
                    else{
                        prefs.setObject(phoneFactor, forKey: "tcellPhone")
                        var error_msg: String
                        var error_title: String
                        if jsonData["error_message"] as? NSString != nil {
                            error_msg = jsonData["error_message"] as! String
                            error_title = jsonData["error_title"] as! String
                        } else {
                            error_msg = "The Two-Step Authentication service is currently unavailable. Please try again later."
                            error_title = "Authentication Error"
                        }
                        var alertView:UIAlertView = UIAlertView()
                        alertView.title = error_title
                        alertView.message = error_msg
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                        self.activityIndicatorView.stopAnimating()
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    }
                    
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
    }
    
    //this func to pop up a text to enter pin number
    func verifyPin() {
        self.enterTxtField = 3
        var alert = UIAlertController(title: "Verify PIN", message: "A PIN has been sent to your phone", preferredStyle: .Alert)
        //2. Add the text field. You can configure it however you need.
        alert.addTextFieldWithConfigurationHandler({(verifyTxtPin) -> Void in
            verifyTxtPin.delegate = self
            verifyTxtPin.placeholder = "Enter PIN"
            verifyTxtPin.text = ""
            verifyTxtPin.keyboardType = UIKeyboardType.NumberPad
        })
        
        alert.addAction(UIAlertAction(title: "Verify", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as! UITextField
            
            var phoneFactor:NSString = textField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            var phoneLength = count(String(phoneFactor).utf16)
            
            if (phoneFactor.isEqualToString("")) {
                var alertView:UIAlertView = UIAlertView()
                alertView.title = "Verify PIN"
                alertView.message = "Enter your 6-digit PIN"
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
                self.verifyPin()
            }
            else{
                self.checkPinCode(self.authorizedJson.deviceIdentifier as String, loginUUID: self.authorizedJson.loginUUID as String, pinCode: textField.text)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in
            var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            prefs.removeObjectForKey("tverifyPin")
            self.enterTxtField = 1
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //this func is to verify pin provided throught post http
    func checkPinCode(deviceIdentifier: String, loginUUID: String, pinCode: String) {
        dismissKeyboard()
        var post: NSString = ""
        self.scrollView.addSubview(self.activityIndicatorView)
        self.activityIndicatorView.startAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        post = "deviceIdentifier=\(deviceIdentifier)&loginUUID=\(loginUUID)&pinCode=\(pinCode)"
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
                    dispatch_async(dispatch_get_main_queue(), {
                        self.activityIndicatorView.stopAnimating()
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        
                        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                        prefs.setObject(prefs.valueForKey("tcoopID"), forKey: "coopID")
                        prefs.setObject(prefs.valueForKey("tlogginedDate"), forKey: "logginedDate")
                        prefs.setObject(prefs.valueForKey("temployeeName"), forKey: "employeeName")
                        prefs.setObject(prefs.valueForKey("tcredentialDate"), forKey: "credentialDate")
                        prefs.setObject(prefs.valueForKey("tcontactListID"), forKey: "contactListID")
                        prefs.setObject(prefs.valueForKey("tdomainSelect"), forKey: "domainSelect")
                        
                        prefs.removeObjectForKey("tcoopID")
                        prefs.removeObjectForKey("tlogginedDate")
                        prefs.removeObjectForKey("temployeeName")
                        prefs.removeObjectForKey("tcredentialDate")
                        prefs.removeObjectForKey("tcontactListID")
                        prefs.removeObjectForKey("tdomainSelect")
                        prefs.removeObjectForKey("tverifyPin")
                        prefs.synchronize()
                        self.delegate?.writeValueBack("Pin matched")
                        //self.dismissViewControllerAnimated(true, completion: nil)
                        self.unwindHome.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                    })
                }
                else{
                    var error_msg: String
                    var error_title: String
                    
                    if jsonData["error_message"] as? NSString != nil {
                        error_msg = jsonData["error_message"] as! String
                        error_title = jsonData["error_title"] as! String
                    } else {
                        error_msg = "You have entered an incorrect PIN. Please try again"
                        error_title = "Verify PIN"
                    }
                    var alertView:UIAlertView = UIAlertView()
                    alertView.title = error_title
                    alertView.message = error_msg
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                    // check if success return 0 then re-open pin enter
                    if(success == 0){
                        verifyPin()
                    }
                    self.activityIndicatorView.stopAnimating()
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }
                
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

    
    func loadAddressURL() {
        if let requestURL = NSURL(string: SharedClass().clsLink + "/?switchID=pinverify_dsp") {
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

}
