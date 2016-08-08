//
//  PostCell.swift
//  MobileDez Social
//
//  Created by David Zielski on 7/31/16.
//  Copyright © 2016 mobiledez. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class PostCell: UITableViewCell {
  
  @IBOutlet weak var profileImg: UIImageView!
  @IBOutlet weak var userNameLbl: UILabel!
  @IBOutlet weak var postImg: UIImageView!
  @IBOutlet weak var caption: UITextView!
  @IBOutlet weak var likesLbl: UILabel!
  @IBOutlet weak var likeImg: UIImageView!
  @IBOutlet weak var removeBtnView: UIButton!
  @IBOutlet weak var friendImg: UIImageView!
  
  var delegate: UIViewController?
  
  var likesRef: FIRDatabaseReference!
  var friendRef: FIRDatabaseReference!
  
  var post: Post!
  
    override func awakeFromNib() {
      super.awakeFromNib()
      
      // add tap gesture recognizer to all like images in the table
      let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
      tap.numberOfTapsRequired = 1
      likeImg.addGestureRecognizer(tap)
      likeImg.isUserInteractionEnabled = true
      
      let tapFriend = UITapGestureRecognizer(target: self, action: #selector(friendTapped))
      tapFriend.numberOfTapsRequired = 1
      friendImg.addGestureRecognizer(tapFriend)
      friendImg.isUserInteractionEnabled = true
    }
  
  func configureCell(post: Post, img: UIImage? = nil) {
    
    self.post = post
    likesRef = DataService.ds.REF_USER_CURRENT.child("likeList").child(post.postID)
    friendRef = DataService.ds.REF_USER_CURRENT.child("friendList").child(post.postOwner)
    
    DataService.ds.REF_USERS.child(post.postOwner).observeSingleEvent(of: .value, with: { (snapshot) in
    
        self.userNameLbl.text = snapshot.value!["userName"] as? String

        let profileImage = snapshot.value!["imageURL"] as? String
        
        if let img = FeedVC.profileImageCache.object(forKey: profileImage!) {
          self.profileImg.image = img
        
        } else {
      
          let ref = FIRStorage.storage().reference(forURL: profileImage!)
          ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
            if error != nil {
              print("DZ: Unable to download profile image from Firebase storage")
            } else {
              print("DZ: Downloaded profile image from Firebase storage")
              if let imgData = data {
                if let img = UIImage(data: imgData) {
                  self.profileImg.image = img
                  FeedVC.profileImageCache.setObject(img, forKey: profileImage!)
                }
              }
            }
          })
        }
    
      })
 
    self.caption.text = post.caption
    self.caption.isUserInteractionEnabled = false
    self.likesLbl.text = "\(post.likes)"
    
    // if post owner equals current user then display remove button and remove friend image
    let uid = KeychainWrapper.stringForKey(KEY_UID)

    if post.postOwner == uid {
      self.removeBtnView.isHidden = false
      self.friendImg.isHidden = true
    } else {
      self.removeBtnView.isHidden = true
      self.friendImg.isHidden = false
    }
    
    if img != nil {
      self.postImg.image = img
    } else {
      
      let ref = FIRStorage.storage().reference(forURL: post.imageURL)
      ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
        if error != nil {
          print("DZ: Unable to download image from Firebase storage")
        } else {
          print("DZ: Downloaded image from Firebase storage")
          if let imgData = data {
            if let img = UIImage(data: imgData) {
              self.postImg.image = img
              FeedVC.imageCache.setObject(img, forKey: post.imageURL)
            }
          }
        }
      })
    }
    
    likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
      if let _ = snapshot.value as? NSNull {
        self.likeImg.image = UIImage(named: "empty-heart")
      } else {
        self.likeImg.image = UIImage(named: "filled-heart")
      }
    })

    friendRef.observeSingleEvent(of: .value, with: { (snapshot) in
      if let _ = snapshot.value as? NSNull {
        self.friendImg.image = UIImage(named: "empty-friends")
      } else {
        self.friendImg.image = UIImage(named: "filled-friends")
      }
    })
    
    
    
  }
  
  func likeTapped(sender: UITapGestureRecognizer) {
    likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
      if let _ = snapshot.value as? NSNull {
        self.likeImg.image = UIImage(named: "filled-heart")
        self.post.adjustLikes(addLike: true)
        self.likesRef.setValue(true)
        self.likesLbl.text = "\(self.post.likes)"
      } else {
        self.likeImg.image = UIImage(named: "empty-heart")
        self.post.adjustLikes(addLike: false)
        self.likesRef.removeValue()
        
        // if we are in the likes screen and a user unlikes post - we need to redraw
        self.likesLbl.text = "\(self.post.likes)"
        if FeedType.ft.feedTypeToShow == FeedType.FeedTypeEnum.likeFeed {
          NotificationCenter.default.post(name: feedRedrawName, object: nil)
        }
      }
    })
  }
  
    func friendTapped(sender: UITapGestureRecognizer) {
      friendRef.observeSingleEvent(of: .value, with: { (snapshot) in
        if let _ = snapshot.value as? NSNull {
          self.friendImg.image = UIImage(named: "filled-friends")
          self.friendRef.setValue(true)
        } else {
          self.friendImg.image = UIImage(named: "empty-friends")
          self.friendRef.removeValue()
          
          // if we are in the likes screen and a user unlikes post - we need to redraw
//          self.likesLbl.text = "\(self.post.likes)"
//          if DataService.ds.feedTypeAll != true {
//            NotificationCenter.default.post(name: feedRedrawName, object: nil)
//          }
        }
      })
  }
  
  @IBAction func removeBtnTapped(_ sender: AnyObject) {

    // button only visible if this is the current users post so delete it

    // Would like to do a "Are You Sure You Want To Delete"
    let alert = UIAlertController(title: "Are You Sure You Want To Remove This Post?", message: "This will be deleted forever and ever if you select Yes.", preferredStyle: UIAlertControllerStyle.alert)

    let actionYes = UIAlertAction(title: "Yes", style: .default) { (action:UIAlertAction) in
      print("DZ: You've pressed the Yes button");
      
      //     try and remove it from FB storage
      DataService.ds.REF_POST_IMAGES.child(self.post.imgID).delete(completion: { (error) in
        if error != nil {
          print("DZ: Unable to delete image from Firebase storage")
        } else {
          print("DZ: Deleted image from Firebase storage")
          // OK deleted from storage so delete from cache and then from posts
          FeedVC.imageCache.removeObject(forKey: self.post.imageURL)
          DataService.ds.REF_POSTS.child(self.post.postID).removeValue()
          NotificationCenter.default.post(name: feedRedrawName, object: nil)
        }
      })

    }
    
    let actionNo = UIAlertAction(title: "No", style: .default) { (action:UIAlertAction) in
      print("DZ: You've pressed No button");
    }
    
    alert.addAction(actionYes)
    alert.addAction(actionNo)
    delegate?.present(alert, animated: true, completion: nil)
  
  }
  
  
}
