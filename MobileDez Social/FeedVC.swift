//
//  FeedVC.swift
//  MobileDez Social
//
//  Created by David Zielski on 7/30/16.
//  Copyright © 2016 mobiledez. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

  @IBOutlet weak var tableView: UITableView!
  
  var posts = [Post]()
  
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
      
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
          if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
            for snap in snapshot {
              print("SNAP: \(snap)")
              if let postDict = snap.value as? Dictionary<String, AnyObject> {
                let id = snap.key
                let post = Post(postID: id, postData: postDict)
                self.posts.append(post)
              }
            }
          }
          self.tableView.reloadData()
      })
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return posts.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let post = posts[indexPath.row]
   
    if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
      cell.configureCell(post: post)
      return cell
    } else {
      //should never happen
      return PostCell()
    }
    
    
  }
  
  
  @IBAction func signOutTapped(_ sender: AnyObject) {
    let keychainResult = KeychainWrapper.removeObjectForKey(KEY_UID)
    print("DZ: ID removed from keychain \(keychainResult)")
    try! FIRAuth.auth()?.signOut()
    performSegue(withIdentifier: "goToLogin", sender: nil)
  }

    /*
    // MARK: - Navigation
    */

}
