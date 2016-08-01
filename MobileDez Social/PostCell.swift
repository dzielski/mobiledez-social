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
  
  var post: Post!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
  
  func configureCell(post: Post, img: UIImage? = nil) {
    
    self.post = post
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
  }
  
  


}
