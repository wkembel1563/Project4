//
//  ViewController.swift
//  Project4
//
//  Created by Will Kembel on 3/25/24.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    
    var webView = WKWebView()
    var progressView: UIProgressView!
    let allowedWebSites = ["wikipedia.org", "google.com", "apnews.com"]
    
    override func loadView() {
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation to set websites
        //
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
        
        // progress bar and refresh
        //
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(webView.reload))
        
        toolbarItems = [progressButton, spacer, refreshButton]
        navigationController?.isToolbarHidden = false
        
        // update progress bar
        //
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        let url = URL(string: "https://" + allowedWebSites[0])!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        
    }

    // offer set websites to navigate
    //
    @objc func openTapped() {
        let ac = UIAlertController(title: "Select Site", message: nil, preferredStyle: .actionSheet)
        
        for website in allowedWebSites {
            ac.addAction(UIAlertAction(title: website, style: .default, handler: loadWebPage))
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        
        present(ac, animated: true)
    }
    
    // load tapped webpage
    //
    func loadWebPage(_ alert: UIAlertAction) {
        guard let webPageHost = alert.title else { return }
        guard let webPageURL = URL(string: "https://" + webPageHost) else { return }
        webView.load(URLRequest(url: webPageURL))
    }
    
    // update progress view with webpage load progress
    //
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
        
        if progressView.progress == 1 {
            progressView.isHidden = true
        }
        else {
            progressView.isHidden = false
        }
    }
    
    // only allow navigation to allowed sites
    //
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        
        if let urlHost = url?.host() {
            for website in allowedWebSites {
                if urlHost.contains(website) {
                    decisionHandler(.allow)
                    return
                }
            }
        }
        
        decisionHandler(.cancel)
//        let ac = UIAlertController(title: "Invalid URL", message: "Navigation is blocked for external URLs", preferredStyle: .alert)
//        ac.addAction(UIAlertAction(title: "OK", style: .default))
//        present(ac, animated: true)
    }

}

