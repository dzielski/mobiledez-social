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
  private var _profileImage: String!
  private var _provider: String!
  private var _userName: String!
  private var _friendList: String!
  private var _userRef: FIRDatabaseReference!
  
  var likeList: String {
    return _likeList
  }
  
  var profileImage: String {
    return _profileImage
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
  
  
  init(likeList: String, profileImage: String, provider: String, userName: String, friendList: String) {
    self._likeList = likeList
    self._profileImage = profileImage
    self._provider = provider
    self._userName = userName
    self._friendList = friendList
  }
  
  
  init(userID: String, userData: Dictionary<String, AnyObject>) {
    
//    self._postID = postID
    
    if let likeList = userData["likeList"] as? String {
      self._likeList = likeList
    }
    
    if let profileImage = userData["profileImage"] as? String {
      self._profileImage = profileImage
    }
    
//    if let likes = postData["likes"] as? Int {
//      self._likes = likes
//    }
    
    _userRef = DataService.ds.REF_USER_CURRENT.child(userID)
  }
  
}
