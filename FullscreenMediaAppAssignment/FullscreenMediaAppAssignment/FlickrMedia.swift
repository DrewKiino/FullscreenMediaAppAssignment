//
//  FlickrMedia.swift
//  FullscreenMediaAppAssignment
//
//  Created by Andrew Aquino on 2/13/17.
//  Copyright © 2017 Andrew Aquino. All rights reserved.
//

import Foundation

public class FlickrMedia: NSObject {
  
  public var id: String?
  public var imageURL: String?
  public var title: String?
  public var uploadDate: String?
  public var takenDate: String?
  
  public convenience init(data: [String: Any]?) {
    self.init()
    
    self.id = data?["id"] as? String
    self.imageURL = data?["url_l"] as? String
    self.title = data?["title"] as? String
    self.uploadDate = data?["dateupload"] as? String
    self.takenDate = (data?["datetaken"] as? String)?.replacingOccurrences(of: " ", with: "%20")
  }
}
