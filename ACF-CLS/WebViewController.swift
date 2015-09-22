/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:

A view controller that demonstrates how to use UIWebView.

*/

import WebKit

class WebViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate, UITabBarDelegate {
    
    var webView: WKWebView
    
    var webSiteAddress = "https://www.acf.hhs.gov"
    
    var navigationTitle = "ACF Web"
    var isCoopWeb = false
    
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var backTabBar: UITabBarItem!
    @IBOutlet weak var refreshTabBar: UITabBarItem!
    @IBOutlet weak var forwardTabBar: UITabBarItem!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    required init(coder aDecoder: NSCoder) {
        self.webView = WKWebView(frame: CGRectZero)
        super.init(coder: aDecoder)
        self.webView.navigationDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //stop display menu from swiping to right
        var rightSwipe = UISwipeGestureRecognizer(target: self, action: nil)
        rightSwipe.direction = .Right
        view.addGestureRecognizer(rightSwipe)
        
        for item in tabBar.items as! [UITabBarItem] {
            if let image = item.image {
                item.image = image.imageWithColor(UIColor(red: 52/255.0, green: 123/255.0, blue: 216/255.0, alpha: 1.0)).imageWithRenderingMode(.AlwaysOriginal)
            }
        }
        
        let userScript = WKUserScript(
            source: "sendMail(0)",
            injectionTime: WKUserScriptInjectionTime.AtDocumentEnd,
            forMainFrameOnly: true
        )
        let contentController = WKUserContentController()
        contentController.addUserScript(userScript)
        contentController.addScriptMessageHandler(
            self,
            name: "callbackHandler"
        )
        
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        self.webView = WKWebView(
            frame: UIScreen.mainScreen().bounds,
            configuration: config
        )
        
        view.addSubview(webView)
        
        webView.setTranslatesAutoresizingMaskIntoConstraints(false)
        let top = NSLayoutConstraint(item: webView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: +64)
        let bottom = NSLayoutConstraint(item: webView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: -44)
        let width = NSLayoutConstraint(item: webView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
        view.addConstraints([top, bottom, width])
        
        webView.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        
        // Do any additional setup after loading the view.
        self.title = navigationTitle
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        backTabBar.enabled = false
        forwardTabBar.enabled = false
        configureWebView()
        loadAddressURL()
    }
    
    override func viewWillDisappear(animated: Bool) {
        webView.removeFromSuperview()
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        NSURLCache.sharedURLCache().memoryCapacity = 0
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        var selectedTag = tabBar.selectedItem?.tag
        //NSLog("\(selectedTag)")
        if(selectedTag == 0){
            webView.goBack()
        }
        else if(selectedTag == 1){
            webView.reload()
        }
        else if(selectedTag == 2){
            webView.goForward()
        }
    }
    
    func loadAddressURL() {
        if let requestURL = NSURL(string: webSiteAddress) {
            let request = NSURLRequest(URL: requestURL)
            if Reachability.isConnectedToNetwork() {
                webView.loadRequest(request)
            }else{
                SharedClass().connectionAlert(self)
            }
        }
    }
    
    func configureWebView() {
        webView.backgroundColor = UIColor.whiteColor()
    }
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage){
        if(message.name == "callbackHandler") {
            if(message.body.containsString("notResponded")){
                performSegueWithIdentifier("myProfile", sender: self)
            }
        }
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<()>) {
        if (keyPath == "loading") {
            backTabBar.enabled = webView.canGoBack
            forwardTabBar.enabled = webView.canGoForward
        }
        
        webView.addSubview(self.activityIndicatorView)
        if (keyPath == "estimatedProgress") {
            if(webView.estimatedProgress < 1){
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                activityIndicatorView.startAnimating()
            }else{
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                activityIndicatorView.stopAnimating()
            }
        }
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        /*let alert = UIAlertController(title: "Error", message:  error.localizedDescription, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default,  handler: nil))
        presentViewController(alert, animated: true, completion: nil)*/
        SharedClass().connectionAlert(self)
    }
}