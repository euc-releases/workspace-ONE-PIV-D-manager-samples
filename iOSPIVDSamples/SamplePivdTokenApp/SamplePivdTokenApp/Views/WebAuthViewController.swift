//
//  WebAuthViewController.swift
//  SamplePivdTokenApp
//
//  Copyright 2023 VMware, Inc.
//  SPDX-License-Identifier: BSD-2-Clause
//

import UIKit
import WebKit

class WebAuthViewController: UIViewController {

    @IBOutlet weak var webview: WKWebView!

    var selectedIdentity: SecIdentity!

    #warning("Change below URL to test integrated authentication")
    let authTestUrl = Constants.iaURl
    let maxThresholdFailureAllowed = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url = URL(string: authTestUrl) else {
            print("Error: cannot create URL")
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = 15

        self.webview.load(urlRequest)
        self.webview.navigationDelegate = self
    }

    override func viewDidDisappear(_ animated: Bool) {
        WKWebView.clean()
        super.viewDidDisappear(animated)
    }
}

extension WebAuthViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("[Consumer] \(#function)")
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("[Consumer] \(#function)")
        if !webview.isLoading {
            self.presentSimpleAlert(title: Constants.successTitle, message: Constants.authSuccessMessage)
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("[Consumer] \(#function) error : \(error.localizedDescription)")
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("[Consumer] \(#function) error : \(error.localizedDescription)")
        print("[Consumer] Troubleshooting: Check if you have selected the right certificate for the operation. Access suspends automatically after defined seconds. Open the PIV-D app to resume access to certificates.")
        self.presentSimpleAlert(title: Constants.failureTitle, message: Constants.authFailureMessage)
    }

    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        if challenge.previousFailureCount > maxThresholdFailureAllowed {
            completionHandler(Foundation.URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
        }
        else if challenge.protectionSpace.serverTrust != nil {
            completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, nil)
        }
        else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate {
            var credential: URLCredential?

            credential = URLCredential(identity: selectedIdentity, certificates: nil, persistence: .none)
            if credential != nil {
                completionHandler(.useCredential, credential)
            }
            else {
                completionHandler(.useCredential, nil)
            }
            return
        }
    }
}

extension WKWebView {
    class func clean() {
        guard #available(iOS 9.0, *) else {return}

        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)

        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                #if DEBUG
                    print("WKWebsiteDataStore record deleted:", record)
                #endif
            }
        }
    }
}
