/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:

A view controller that demonstrates how to use UIWebView.

*/

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate, UITabBarDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    var webSiteAddress = "https://www.acf.hhs.gov"
    
    var navigationTitle = "ACF Web"
    var isCoopWeb = false
    
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var backTabBar: UITabBarItem!
    @IBOutlet weak var refreshTabBar: UITabBarItem!
    @IBOutlet weak var forwardTabBar: UITabBarItem!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //stop display menu from swiping to right
        var rightSwipe = UISwipeGestureRecognizer(target: self, action: nil)
        rightSwipe.direction = .Right
        view.addGestureRecognizer(rightSwipe)
        
        webView.scrollView.delegate = self
        
        for item in tabBar.items as! [UITabBarItem] {
            if let image = item.image {
                item.image = image.imageWithColor(UIColor(red: 52/255.0, green: 123/255.0, blue: 216/255.0, alpha: 1.0)).imageWithRenderingMode(.AlwaysOriginal)
            }
        }
        
        // Do any additional setup after loading the view.
        self.title = navigationTitle
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        backTabBar.enabled = false
        forwardTabBar.enabled = false
        configureWebView()
        loadAddressURL()
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
            webView.loadRequest(request)
        }
    }
    
    func configureWebView() {
        webView.backgroundColor = UIColor.whiteColor()
        webView.scalesPageToFit = true
        if(!isCoopWeb){
            webView.dataDetectorTypes = .All
        }
        else{
            webView.dataDetectorTypes = .None
        }
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        activityIndicatorView.startAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicatorView.stopAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        if(!webView.canGoBack){
            backTabBar.enabled = false
        }
        else{backTabBar.enabled = true}
        if(!webView.canGoForward){
            forwardTabBar.enabled = false
        }
        else{forwardTabBar.enabled = true}
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        // Report the error inside the web view.
        let localizedErrorMessage = NSLocalizedString("An error occured:", comment: "")
        
        let errorHTML = "<!doctype html><html><body><div style=\"width: 100%%; text-align: center; font-size: 36pt;\">\(localizedErrorMessage) \(error.localizedDescription)</div></body></html>"
        
        webView.loadHTMLString(errorHTML, baseURL: nil)
        activityIndicatorView.stopAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}