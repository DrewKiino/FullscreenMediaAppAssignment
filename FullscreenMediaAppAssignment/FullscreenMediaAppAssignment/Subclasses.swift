//
//  Subclasses.swift
//  FullscreenMediaAppAssignment
//
//  Created by Andrew Aquino on 2/9/17.
//  Copyright © 2017 Andrew Aquino. All rights reserved.
//

import Foundation
import UIKit

public class BasicViewConroller: UIViewController {
  public override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.isTranslucent = false
    navigationController?.navigationBar.barTintColor = .black
    navigationController?.navigationBar.tintColor = .white
    navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    view.backgroundColor = .white
  }
}
