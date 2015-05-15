//
//  MailViewController.swift
//  ACF-CLS
//
//  Created by AcisTek Corporation on 3/20/15.
//  Copyright (c) 2015 AcisTek Corporation. All rights reserved.
//

import UIKit
import WebKit

class MailViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {
    
    @IBOutlet var containerView : UIView! = nil
    
    @IBOutlet weak var progressView: UIProgressView!
    
    var webView: WKWebView
    
    var toEmail = ""
    var groupName = ""
    
    required init(coder aDecoder: NSCoder) {
        self.webView = WKWebView(frame: CGRectZero)
        super.init(coder: aDecoder)
        
        self.webView.navigationDelegate = self
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        let sendMail = UIBarButtonItem(title: "Send", style: .Plain, target: self, action: Selector("sendEmail"))
        self.navigationItem.rightBarButtonItem = sendMail
        self.title = "Mail"
        
        var userScript = WKUserScript(
            source: "sendMail(0)",
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
            frame: self.containerView.bounds,
            configuration: config
        )
        
        
        view.insertSubview(webView, belowSubview: progressView)
        
        webView.setTranslatesAutoresizingMaskIntoConstraints(false)
        let height = NSLayoutConstraint(item: webView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: webView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
        view.addConstraints([height, width])
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        
        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let contactListID: NSString = prefs.valueForKey("contactListID") as! NSString
        if let groupName = groupName.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            var url = NSURL(string:SharedClass().clsLink + "/?switchID=email_dsp&contactlistid=\(contactListID)&toEmail=\(toEmail)&groupName=\(groupName)")
            var req = NSURLRequest(URL:url!)
            self.webView.loadRequest(req)
        }
    }
    
    func sendEmail(){
        webView.evaluateJavaScript("sendMail(1)", completionHandler: nil)
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        progressView.setProgress(0.0, animated: false)
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<()>) {
        if (keyPath == "estimatedProgress") {
            progressView.hidden = webView.estimatedProgress == 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
    func navBack(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage){
        if(message.name == "callbackHandler") {
            if(message.body.containsString("successfully")){
                let alertView = UIAlertController(title: "\(message.body)", message: "", preferredStyle: .Alert)
                alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (alertAction) -> Void in
                    self.navBack()
                }))
                self.presentViewController(alertView, animated: true, completion: nil)
            }
            else{
                var alertView:UIAlertView = UIAlertView()
                alertView.title = "\(message.body)"
                alertView.message = ""
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
