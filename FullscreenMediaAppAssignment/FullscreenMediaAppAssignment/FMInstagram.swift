//
//  FMInstagram.swift
//  FullscreenMediaAppAssignment
//
//  Created by Andrew Aquino on 2/8/17.
//  Copyright © 2017 Andrew Aquino. All rights reserved.
//

import Foundation
import Alamofire
import Neon

/*
 CLIENT ID:   f20a91ee829c4820b431d149332b197e
 SECRET KEY:  745eba989cba475798fa303d7e53983f
 */

public class FMInstagram: NSObject {
  
  fileprivate var requestLock = false
  
  private let authenticationURL = "https://www.instagram.com/oauth/authorize/?client_id=f20a91ee829c4820b431d149332b197e&redirect_uri=https://fullscreenmedia.co&response_type=token&scope=public_content"
  private let clientKey = "f20a91ee829c4820b431d149332b197e"
  private let secretkey = "745eba989cba475798fa303d7e53983f"
  
  private static let singleton = FMInstagram()
  public class func sharedInstance() -> FMInstagram { return singleton }
  
  public override init() {
    super.init()
  }
  
  public func authenticate(completionHandler: (() -> Void)? = nil) {
    if  let vc = UIApplication.shared.keyWindow?.rootViewController,
        let authURL = URL(string: authenticationURL),
        DataStore.sharedInstance().instagram.accessToken == nil
    {
      
      let webView = UIWebView()
      webView.delegate = self
      let nsurlRequest = URLRequest(url: authURL)
      webView.loadRequest(nsurlRequest)
      
      let vcWebView = UIViewController()
      vcWebView.view.addSubview(webView)
      vcWebView.view.backgroundColor = .white
      vcWebView.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.didTapDoneButton(button:)))
      webView.fillSuperview()
      
      let navVC = UINavigationController(rootViewController: vcWebView)
      
      vc.present(navVC, animated: true) {
      }
    }
  }
  
  public func isAuthorized() -> Bool { return DataStore.sharedInstance().instagram.accessToken != nil }
}

// MARK: User Interaction
extension FMInstagram {
  
  public func didTapDoneButton(button: UIButton) {
    if  let vc = UIApplication.shared.keyWindow?.rootViewController { vc.dismiss(animated: true, completion: nil) }
  }
}

extension FMInstagram: UIWebViewDelegate {
  public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    return true
  }
  public func webViewDidStartLoad(_ webView: UIWebView) {
  }
  public func webViewDidFinishLoad(_ webView: UIWebView) {
    // grab the access token once we have authorized the app
    if let accessToken = webView.request?.url?.absoluteString.components(separatedBy: "#access_token=").last, webView.request?.url?.absoluteString.contains("#access_token=") == true {
      log.debug(accessToken)
      DataStore.sharedInstance().instagram.accessToken = accessToken
      if let vc = UIApplication.shared.keyWindow?.rootViewController {
        vc.dismiss(animated: true, completion: nil)
      }
    }
  }
  public func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
    log.error(error)
  }
}

extension FMInstagram {
  public func getUserProfile(completionHandler: @escaping ([String: AnyObject]) -> Void) {
    if  let accessToken = DataStore.sharedInstance().instagram.accessToken {
      let requestURL: String! = "https://api.instagram.com/v1/users/self/?access_token=\(accessToken)"
      Alamofire.request(requestURL).responseJSON { response in
        if let dictionary = response.result.value as? [String: AnyObject] {
          completionHandler(dictionary)
        }
      }
    }
  }
  public func getUserMedia(afterMediaID: String? = nil, completionHandler: @escaping ([String: AnyObject]) -> Void) {
    if  let accessToken = DataStore.sharedInstance().instagram.accessToken, !requestLock { requestLock = true
      log.debug("loading instagram media")
      // base url string
      var requestURL: String! = "https://api.instagram.com/v1/users/self/media/recent/?access_token=\(accessToken)&count=5"
      // if the user has specified an after media id, then we append it to the url string
      if let afterMediaID = afterMediaID { requestURL.append("&max_id=\(afterMediaID)") }
      // begin requsst
      Alamofire.request(requestURL).responseJSON { [weak self] response in
        log.debug(response)
        self?.requestLock = false
        if let dictionary = response.result.value as? [String: AnyObject] {
          completionHandler(dictionary)
        }
      }
    }
  }
}
