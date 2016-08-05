//
//  PostCell.swift
//  MobileDez Social
//
//  Created by David Zielski on 7/31/16.
//  Copyright © 2016 mobiledez. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {
  
  @IBOutlet weak var profileImg: UIImageView!
  @IBOutlet weak var userNameLbl: UILabel!
  @IBOutlet weak var postImg: UIImageView!
  @IBOutlet weak var caption: UITextView!
  @IBOutlet weak var likesLbl: UILabel!
  @IBOutlet weak var likeImg: UIImageView!
  
  var likesRef: FIRDatabaseReference!
  var postOwner: FIRDatabaseReference!
  
  var post: Post!
  
    override func awakeFromNib() {
      super.awakeFromNib()
      
      // add tap gesture recognizer to all like images in the table
      let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
      tap.numberOfTapsRequired = 1
      likeImg.addGestureRecognizer(tap)
      likeImg.isUserInteractionEnabled = true
      
    }
  
  func configureCell(post: Post, img: UIImage? = nil) {
    
    self.post = post
    likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postID)

    DataService.ds.REF_USERS.child(post.postOwner).observe(.value, with: { (snapshot) in
    
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
    self.likesLbl.text = "\(post.likes)"
    
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
    
  }
  
  func likeTapped(sender: UITapGestureRecognizer) {
    likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
      if let _ = snapshot.value as? NSNull {
        self.likeImg.image = UIImage(named: "filled-heart")
        self.post.adjustLikes(addLike: true)
        self.likesRef.setValue(true)
      } else {
        self.likeImg.image = UIImage(named: "empty-heart")
        self.post.adjustLikes(addLike: false)
        self.likesRef.removeValue()
      }
    })
    
  }
  
  
  
}
