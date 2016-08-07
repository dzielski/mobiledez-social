//
//  Post.swift
//  MobileDez Social
//
//  Created by David Zielski on 7/31/16.
//  Copyright © 2016 mobiledez. All rights reserved.
//

import Foundation
import Firebase


class Post {
  
  private var _caption: String!
  private var _imageURL: String!
  private var _likes: Int!
  private var _postID: String!
  private var _postOwner: String!
  private var _imgID: String!

  private var _postRef: FIRDatabaseReference!
  
  var caption: String {
    return _caption
  }
  
  var imageURL: String {
    return _imageURL
  }
  
  var likes: Int {
    return _likes
  }
  
  var postID: String {
    return _postID
  }
  
  var postOwner: String {
    return _postOwner
  }
  
  var imgID: String {
    return _imgID
  }
  
  
  init(caption: String, imageURL: String, likes: Int, postOwner: String, imgID: String) {
    self._caption = caption
    self._imageURL = imageURL
    self._likes = likes
    self._postOwner = postOwner
    self._imgID = imgID
    
  }

  
  init(postID: String, postData: Dictionary<String, AnyObject>) {
    
    self._postID = postID
    
    if let caption = postData["caption"] as? String {
      self._caption = caption
    }
    
    if let imageURL = postData["imageURL"] as? String {
      self._imageURL = imageURL
    }
    
    if let likes = postData["likes"] as? Int {
      self._likes = likes
    }
    
    if let postOwner = postData["postOwner"] as? String {
      self._postOwner = postOwner
    }
    
    if let imgID = postData["imgID"] as? String {
      self._imgID = imgID
    }
    
    _postRef = DataService.ds.REF_POSTS.child(_postID)
    
    
  }
  
  func adjustLikes(addLike: Bool) {
    if addLike {
      _likes = _likes + 1
    } else {
      _likes = _likes - 1
    }
  
  _postRef.child("likes").setValue(_likes)

    
  }
  
  
  
}
