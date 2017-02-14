//
//  FMPlayer.swift
//  FullscreenMediaAppAssignment
//
//  Created by Andrew Aquino on 2/9/17.
//  Copyright © 2017 Andrew Aquino. All rights reserved.
//

import Foundation
import MediaPlayer

public class FMPlayer: NSObject {
  
  private static let singleton = FMPlayer()
  public class func sharedInstance() -> FMPlayer { return singleton }
  
  public var videoURL: String?
  
  public var avPlayer: AVPlayer!
  public var avPlayerItem: AVPlayerItem!
  
  public func load(videoURL: String?) -> Self {
    self.videoURL = videoURL
    if let videoURL = videoURL, let url = URL(string: videoURL) {
      avPlayer = AVPlayer(url: url)
      avPlayerItem = avPlayer.currentItem
    }
    return self
  }
  
  public func play() -> Self? {
    avPlayer?.play()
    return self
  }
}
