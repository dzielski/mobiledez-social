//
//  User.swift
//  MobileDez Social
//
//  Created by David Zielski on 8/3/16.
//  Copyright © 2016 mobiledez. All rights reserved.
//

import Foundation
import Firebase


class User {
  
  private var _likeList: String!
  private var _imageURL: String!
  private var _provider: String!
  private var _userName: String!
  private var _friendList: String!
  private var _userID: String!
  private var _userRef: FIRDatabaseReference!
  
  var likeList: String {
    return _likeList
  }
  
  var imageURL: String {
    return _imageURL
  }
  
  var provider: String {
    return _provider
  }
  
  var userName: String {
    return _userName
  }
  var friendList: String {
    return _friendList
  }
  
  
  init(likeList: String, imageURL: String, provider: String, userName: String, friendList: String) {
    self._likeList = likeList
    self._imageURL = imageURL
    self._provider = provider
    self._userName = userName
    self._friendList = friendList
  }
  
  
  init(userID: String, userData: Dictionary<String, AnyObject>) {
    
    self._userID = userID
    
    if let likeList = userData["likeList"] as? String {
      self._likeList = likeList
    }
    
    if let imageURL = userData["imageURL"] as? String {
      self._imageURL = imageURL
    }
    
    if let provider = userData["provider"] as? String {
      self._provider = provider
    }
    
    if let userName = userData["userName"] as? String {
      self._userName = userName
    }
    
      if let friendList = userData["friendList"] as? String {
        self._friendList = friendList
        
    }
      
    _userRef = DataService.ds.REF_USER_CURRENT.child(userID)
  }
  
}
