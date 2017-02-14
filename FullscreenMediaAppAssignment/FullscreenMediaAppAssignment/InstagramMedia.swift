//
//  InstagramMedia.swift
//  FullscreenMediaAppAssignment
//
//  Created by Andrew Aquino on 2/9/17.
//  Copyright © 2017 Andrew Aquino. All rights reserved.
//

import Foundation

public class InstagramMedia: NSObject {
  
  public var id: String?
  public var type: String?
  public var imageURL: String?
  public var caption: String?
  public var videoURL: String?
  
  public convenience init(data: [String: AnyObject]?) {
    self.init()
    
    self.id = data?["id"] as? String
    self.type = data?["type"] as? String
    self.imageURL = (data?["images"]?["standard_resolution"] as AnyObject?)?["url"] as? String
    self.videoURL = (data?["videos"]?["standard_resolution"] as AnyObject?)?["url"] as? String
    self.caption = data?["caption"]?["text"] as? String
  }
}
