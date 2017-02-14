//
//  FlickrMediaCollectionViewCell.swift
//  FullscreenMediaAppAssignment
//
//  Created by Andrew Aquino on 2/13/17.
//  Copyright © 2017 Andrew Aquino. All rights reserved.
//

import Foundation
import UIKit

public class FlickrMediaCollectionViewCell: UICollectionViewCell {
  
  public let mediaImageView = UIImageView()
  public var imageURL: String?
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    addSubview(mediaImageView)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    mediaImageView.fillSuperview()
    
    mediaImageView.imageFromSource(imageURL, fitMode: .crop)
  }
  
  public override func prepareForReuse() {
    super.prepareForReuse()
    
    imageURL = nil
    mediaImageView.image = nil
  }
}
