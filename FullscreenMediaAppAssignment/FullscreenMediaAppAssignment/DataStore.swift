//
//  DataStore.swift
//  FullscreenMediaAppAssignment
//
//  Created by Andrew Aquino on 2/9/17.
//  Copyright © 2017 Andrew Aquino. All rights reserved.
//

import Foundation

public class DataStore: NSObject {
  
  private static let singleton = DataStore()
  public class func sharedInstance() -> DataStore { return singleton }
  
  // MARK: Instagram Data Store
  
  public let instagram = InstagramInstance.sharedInstance()
  
  public class InstagramInstance: NSObject {
    
    private static let singleton = DataStore.InstagramInstance()
    public class func sharedInstance() -> DataStore.InstagramInstance { return DataStore.InstagramInstance.singleton }
    
    public dynamic var accessToken: String?
    public dynamic var username: String?
    public dynamic var userProfileImageURL: String?
    public dynamic var medias: [InstagramMedia] = []
  }
  
  // MARK: Flickr Data Store
  
  public let flickr = FlickrInstance.sharedInstance()
  
  public class FlickrInstance: NSObject {
    
    private static let singleton = DataStore.FlickrInstance()
    public class func sharedInstance() -> DataStore.FlickrInstance { return DataStore.FlickrInstance.singleton }
    
    public dynamic var oauthToken: String?
    public dynamic var oauthSecretToken: String?
    public dynamic var oauthVerifier: String?
    public dynamic var usernsid: String?
    public dynamic var username: String?
    
    public dynamic var medias: [FlickrMedia] = []
  }
}

