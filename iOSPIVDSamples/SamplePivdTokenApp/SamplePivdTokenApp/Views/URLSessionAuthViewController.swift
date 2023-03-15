//
//  URLSessionAuthViewController.swift
//  SamplePivdTokenApp
//
//  Copyright 2023 VMware, Inc.
//  SPDX-License-Identifier: BSD-2-Clause
//

import UIKit

enum RequestOption {
    case wkwebview
    case urlsession
}

typealias UrlResponseHandler = (Data?, URLResponse?, Error?) -> Void
class URLSessionAuthViewController: UIViewController {
    
    var selectedIdentity: SecIdentity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Using URLSession"
        URLSessionRequest().createRequest(selectedIdentity) { data, urlResponse, error in
            var title = Constants.successTitle
            var message = ""
            DispatchQueue.main.async {
                if ((error) != nil) {
                    title = Constants.errorTitle
                    message = error?.localizedDescription ?? "Failed with error"
                }
                else {
                    title = Constants.successTitle
                    message = Constants.authSuccessMessage
                }
                self.presentSimpleAlert(title: title, message: message)
            }
        }
    }
}

class URLSessionRequest: NSObject {
    
    var selectedIdentity: SecIdentity!
    override init() {
        super.init()
    }
    
    func createRequest(_ identity: SecIdentity, handler: @escaping UrlResponseHandler) {
        
        self.selectedIdentity = identity
        #warning("Change below URL to test integrated authentication")
        let url = URL(string: Constants.iaURl)
        let request = URLRequest(url: url!)
        
        let session = URLSession(configuration: URLSessionConfiguration.directSession, delegate: self, delegateQueue: .main)
        let task = session.dataTask(with: request, completionHandler: handler)
        task.resume()
    }
}

extension URLSessionConfiguration {
    static var directSession : URLSessionConfiguration {
        let config = defaultSession
        return config
    }

    static var defaultSession : URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .useProtocolCachePolicy
        config.urlCache = nil
        return config
    }
}

extension RunLoop {
    var vm_calculatedModes : [Mode] {
        var retVal: [Mode] = [.default]
        if let mode = currentMode, !retVal.contains(mode) {
            retVal.append(mode)
        }
        return  retVal
    }
}

extension URLSessionRequest : URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("[URLSession] didBecomeInvalidWithError: \(String(describing: error))")
    }

    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("[URLSession] didReceive challenge")
        
        if challenge.previousFailureCount > 3 {
            completionHandler(Foundation.URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
        }
        else if challenge.protectionSpace.serverTrust != nil {
            print("[URLSession] didReceive server trust challenge")
            completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, nil)
        }
        else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate {
            var credential: URLCredential?
            print("[URLSession] didReceive certificate challenge")
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
