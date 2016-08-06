//
//  ViewController.swift
//  EasyBrowser
//
//  Created by My Nguyen on 8/6/16.
//  Copyright © 2016 My Nguyen. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!
    var progressView: UIProgressView!
    var websites = ["apple.com", "hackingwithswift.com", "google.com"]

    override func loadView() {
        webView = WKWebView()
        // delegate to self whenever any webpage navigation occurs
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // use a string title instead of a system icon for the bar button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .Plain, target: self, action: #selector(openTapped))

        // createa a UIProgressView with the default style
        progressView = UIProgressView(progressViewStyle: .Default)
        // fit the full content of the UIProgressView
        progressView.sizeToFit()
        // wrap the UIProgressView in a UIBarButtonItem, so it can be placed on the toolbar
        let progressButton = UIBarButtonItem(customView: progressView)

        /// register an observer using KVO (key-value observing)
        // addObserver() takes 4 parameters
        // the observer (self)
        // forKeyPath: what property to observe (webView.estimatedProgress)
        // options: which value (the one that was just changed, so .New)
        // context
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)

        // create a UIBarButtonItem with a special system item type that creates flexible space
        let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        // create a UIBarButtonItem that refreshes by calling webView.reload() method
        let refresh = UIBarButtonItem(barButtonSystemItem: .Refresh, target: webView, action: #selector(webView.reload))
        // store all buttons in the array toolbarItems, which comes with the UIViewController
        toolbarItems = [progressButton, spacer, refresh]
        // show the toolbar, with all its buttons
        navigationController?.toolbarHidden = false

        // turn a string into an NSURL, then put the NSURL into an NSURLRequest, and WKWebView will load it
        let url = NSURL(string: "https://" + websites[0])!
        webView.loadRequest(NSURLRequest(URL: url))
        // allow swiping from the left or right edge to move backward or forward
        webView.allowsBackForwardNavigationGestures = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // this method informs when an observed value has changed; it must be overriden if a KVO observer has been registered
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        // we only care if keyPath is set to estimatedProgress
        if keyPath == "estimatedProgress" {
            // set progressView.progress to the new estimatedProgress value
            progressView.progress = Float(webView.estimatedProgress)
        }
    }

    func openTapped() {
        // message = nil: no message
        // preferredStyle = .ActionSheet: prompt user for information
        let alertController = UIAlertController(title: "Open page...", message: nil, preferredStyle: .ActionSheet)
        // add a button for each string in websites
        for website in websites {
            alertController.addAction(UIAlertAction(title: website, style: .Default, handler: openPage))
        }
        // add a Cancel button
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))

        presentViewController(alertController, animated: true, completion: nil)
    }

    // UIAlertAction is the object selected by user
    func openPage(action: UIAlertAction) {
        // construct an NSURL
        let url = NSURL(string: "https://" + action.title!)!
        webView.loadRequest(NSURLRequest(URL: url))
    }

    // set the title in the navigation bar
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        title = webView.title
    }

    // control on whether to allow navigation every time something happens
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        // fetch the URL of the navigation
        let url = navigationAction.request.URL
        // extract the URL host
        if let host = url!.host {
            // go thru each website in the safe list
            for website in websites {
                // check if website contains host
                if host.rangeOfString(website) != nil {
                    // allow browser to load website
                    decisionHandler(.Allow)
                    return
                }
            }
        }

        // otherwise, cancel loading the URL host
        decisionHandler(.Cancel)
    }
}

