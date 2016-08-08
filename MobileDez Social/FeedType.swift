//
//  FeedType.swift
//  MobileDez Social
//
//  Created by David Zielski on 8/7/16.
//  Copyright © 2016 mobiledez. All rights reserved.
//

import Foundation


class FeedType {
  
  static let ft = FeedType()
  
  enum FeedTypeEnum {
    case allFeed
    case likeFeed
    case friendFeed
    case searchFeed
  }
  
  var feedTypeToShow = FeedTypeEnum.allFeed
  
}
