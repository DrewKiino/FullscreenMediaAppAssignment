//
//  FMFlickr.swift
//  FullscreenMediaAppAssignment
//
//  Created by Andrew Aquino on 2/8/17.
//  Copyright © 2017 Andrew Aquino. All rights reserved.
//

import Foundation
import OAuthSwift
import OAuthSwiftAlamofire
import Alamofire
import SwiftyJSON

/*
 KEY:       2cd502bf490339f5b35aa8e04bc27280
 SECRET:    de11bb6f5fe6237f
 
 FLICKR ID: 58397009@N06
 
 SIGNATURE: de11bb6f5fe6237fapi_key2cd502bf490339f5b35aa8e04bc27280formatjsonuserid8397009@N06

 */
public class FMFlickr: NSObject {
  
  private let clientKey = "2cd502bf490339f5b35aa8e04bc27280"
  private let secretKey = "de11bb6f5fe6237f"
  
  private var oauth: OAuth1Swift!
  
  private static let singleton = FMFlickr()
  public class func sharedInstance() -> FMFlickr { return singleton }
  
  fileprivate static var currentPage = 1
  
  public override init() {
    super.init()
  }
  
  public func authenticate(completionHandler: (() -> Void)? = nil) {
    if  let vc = UIApplication.shared.keyWindow?.rootViewController,
        let flickrCallbackURL = URL(string: "FullscreenMediaAppAssignment://oauth-callback"),
        DataStore.sharedInstance().flickr.oauthToken == nil
    {
      
      oauth = OAuth1Swift(
        consumerKey:    clientKey,
        consumerSecret: secretKey,
        requestTokenUrl: "https://www.flickr.com/services/oauth/request_token",
        authorizeUrl:    "https://www.flickr.com/services/oauth/authorize",
        accessTokenUrl:  "https://www.flickr.com/services/oauth/access_token"
      )
      
      oauth.authorizeURLHandler = SafariURLHandler(viewController: vc, oauthSwift: oauth)

      oauth.authorize(withCallbackURL: flickrCallbackURL, success: { (credential, response, parameters) in
        let datastore = DataStore.sharedInstance().flickr
        datastore.oauthToken = parameters["oauth_token"] as? String
        datastore.oauthSecretToken = parameters["oauth_token_secret"] as? String
        datastore.usernsid = parameters["user_nsid"] as? String
        datastore.username = parameters["username"] as? String
        completionHandler?()
      }) { (error) in
        log.error(error)
      }
      
    }
  }
  
  public func getInterestingPhotos(resetPage: Bool = false, completionHandler: @escaping ([[String: Any]]) -> Void) {
    
    if resetPage { FMFlickr.currentPage = 1 }
    
    // integrate the request signer with alamofire's api
    let sessionManager = SessionManager.default
    sessionManager.adapter = oauth.requestAdapter
    
    let urlString = "https://api.flickr.com/services/rest?method=flickr.interestingness.getList&extras=url_l,media,date_upload,date_taken&format=json&per_page=20&page=\(FMFlickr.currentPage)"
    
    sessionManager.request(urlString, method: .get)
    .responseString() { result in
      // parse the data
      if  let jsonString = result.value?.replacingOccurrences(of: "jsonFlickrApi(", with: "").characters.dropLast(),
          let data = String(jsonString).data(using: .utf8),
          let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
      {
        // increment the current page
        FMFlickr.currentPage += 1
        
        // and convert to flickr media objects
        if let photos = (json?["photos"] as? [String: Any])?["photo"] as? [[String: Any]] {
          completionHandler(photos)
        }
      }
    }
  }
  
  public func isAuthorized() -> Bool { return DataStore.sharedInstance().flickr.oauthToken != nil }
}

// MARK: User Interaction
extension FMFlickr {
  
  public func didTapDoneButton(button: UIButton) {
    if  let vc = UIApplication.shared.keyWindow?.rootViewController { vc.dismiss(animated: true, completion: nil) }
  }
}

extension String {
  
  func urlEncodedString() -> String! {
    let ignoredCharacters = NSCharacterSet(charactersIn: "% /'\"?=&+<>;:!").inverted
    return addingPercentEncoding(withAllowedCharacters: ignoredCharacters)
  }
  
  func oauthEncodedString() -> String! {
    let ignoredCharacters = NSCharacterSet(charactersIn: "%:/?#[]@!$&'()*+,;=").inverted
    return addingPercentEncoding(withAllowedCharacters: ignoredCharacters)
  }
  
}


