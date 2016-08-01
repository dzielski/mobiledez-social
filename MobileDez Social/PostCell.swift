//
//  PostCell.swift
//  MobileDez Social
//
//  Created by David Zielski on 7/31/16.
//  Copyright © 2016 mobiledez. All rights reserved.
//

import UIKit

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
  
  func configureCell(post: Post) {
    
    self.post = post
    self.caption.text = post.caption
    self.likesLbl.text = "\(post.likes)"
  }
  
  


}
