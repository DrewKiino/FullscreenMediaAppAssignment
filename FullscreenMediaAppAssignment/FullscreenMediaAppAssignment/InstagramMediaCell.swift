//
//  InstagramMediaCell.swift
//  FullscreenMediaAppAssignment
//
//  Created by Andrew Aquino on 2/9/17.
//  Copyright © 2017 Andrew Aquino. All rights reserved.
//

import Foundation
import UIKit
import Neon
import MediaPlayer

public class InstagramMediaCell: UITableViewCell {
  
  public var avPlayer: AVPlayer!
  public var avPlayerItem: AVPlayerItem!
  public let avPlayerLayer = AVPlayerLayer()
  
  public let mediaImageView = UIImageView()
  public let mediaLabel = UILabel()
  
  public var imageURL: String?
  public var videoURL: String?
  public var caption: String?
  
  private let gradientContainer = UIView()
  private let topGradient: CAGradientLayer = CAGradientLayer()
  private let bottomGradient: CAGradientLayer = CAGradientLayer()
  
  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    addSubview(mediaImageView)
    
    layer.addSublayer(avPlayerLayer)
    
    addSubview(gradientContainer)
    topGradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
    topGradient.locations = [0.0, 1.0]
    topGradient.startPoint = CGPoint(x: 0.5, y: 0.0)
    topGradient.endPoint = CGPoint(x: 0.5, y: 1.0)
    gradientContainer.layer.insertSublayer(topGradient, at: 0)
    bottomGradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
    bottomGradient.locations = [0.0, 1.0]
    bottomGradient.startPoint = CGPoint(x: 0.5, y: 1.0)
    bottomGradient.endPoint = CGPoint(x: 0.5, y: 0.0)
    gradientContainer.layer.insertSublayer(bottomGradient, at: 0)
    
    mediaLabel.backgroundColor = .clear
    mediaLabel.numberOfLines = 0
    mediaLabel.textColor = .white
    addSubview(mediaLabel)
    
    backgroundColor = .black
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    // image
    mediaImageView.fillSuperview()
    mediaImageView.imageFromSource(imageURL, fitMode: .crop)
    
    // captions
    mediaLabel.text = caption
    mediaLabel.anchorAndFillEdge(.bottom, xPad: 16, yPad: 8, otherSize: AutoHeight)
    
    // gradient
    gradientContainer.fillSuperview()
    topGradient.anchorToEdge(.top, padding: 0, width: frame.width, height: 50)
    bottomGradient.anchorToEdge(.bottom, padding: 0, width: frame.width, height: max(100, mediaLabel.height))
    
    // avPlayer
    loadVideoPlayer()
    avPlayerLayer.fillSuperview()
    avPlayer?.play()
  }
  
  private func loadVideoPlayer() {
    if let videoURL = videoURL, let url = URL(string: videoURL) {
      avPlayer = AVPlayer(url: url)
      avPlayerLayer.player = avPlayer
      avPlayerItem = avPlayer.currentItem
    }
  }
  
  public override func prepareForReuse() {
    super.prepareForReuse()
    
    avPlayerLayer.player = nil
    avPlayer = nil
    avPlayerItem = nil
    imageURL = nil
    videoURL = nil
    caption = nil
    mediaImageView.image = nil
  }
}






