//
//  RoundBtnNoShadow.swift
//  MobileDez Social
//
//  Created by David Zielski on 8/10/16.
//  Copyright © 2016 mobiledez. All rights reserved.
//

import UIKit

class RoundBtnNoShadow: UIButton {
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    imageView?.contentMode = .scaleAspectFit
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    layer.cornerRadius = self.frame.width / 2
  }
  
}
