//
//  FancyView.swift
//  MobileDez Social
//
//  Created by David Zielski on 7/29/16.
//  Copyright © 2016 mobiledez. All rights reserved.
//

import UIKit

class FancyView: UIView {

  override func awakeFromNib() {
      super.awakeFromNib()
    
    layer.shadowColor = UIColor(red: SHADOW_GREY, green: SHADOW_GREY, blue: SHADOW_GREY, alpha: 0.6).cgColor
    layer.shadowOpacity = 0.8
    layer.shadowRadius = 5.0
    layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
    layer.cornerRadius = 2.0
    
  }

}
