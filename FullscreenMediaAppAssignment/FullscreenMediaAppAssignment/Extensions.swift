//
//  Extensions.swift
//  FullscreenMediaAppAssignment
//
//  Created by Andrew Aquino on 2/9/17.
//  Copyright © 2017 Andrew Aquino. All rights reserved.
//

import Foundation
import UIKit

extension String {
  public func asInt() -> Int? { return Int(self) }
}

extension UIView {
  func roundCorners(corners:UIRectCorner, radius: CGFloat) {
    let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    layer.mask = mask
  }
}

extension UIViewController {
  public func showSpinnerIndicator() {
    hideSpinnerIndicator()
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    spinner.center = view.center
    view.addSubview(spinner)
    spinner.startAnimating()
  }
  
  public func hideSpinnerIndicator() {
    view.subviews.forEach {
      if let spinner = $0 as? UIActivityIndicatorView {
        spinner.stopAnimating()
        spinner.removeFromSuperview()
      }
    }
  }
}
