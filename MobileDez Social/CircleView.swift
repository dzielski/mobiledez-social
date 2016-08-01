//
//  CircleView.swift
//  MobileDez Social
//
//  Created by David Zielski on 7/30/16.
//  Copyright © 2016 mobiledez. All rights reserved.
//

import UIKit

class CircleView: UIImageView {
  
  override func layoutSubviews() {

    layer.cornerRadius = self.frame.width / 2
    clipsToBounds = true
  }

}
