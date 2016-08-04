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

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var imageAdd: CircleView!
  @IBOutlet weak var captionField: FancyFieldTextBox!
  
  var posts = [Post]()
  var imagePicker: UIImagePickerController!
  static var imageCache: Cache<NSString, UIImage> = Cache()
  static var profileImageCache: Cache<NSString, UIImage> = Cache()
  
  // DZ Todo - fix this cheesy method to prevent camera image saving to database
  var imageSelected = false
  
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
      
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
      
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
          self.posts = [] //gets rid of the doubling of post problem
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
      
      if let img = FeedVC.imageCache.object(forKey: post.imageURL) {
        cell.configureCell(post: post, img: img)
      } else {
        cell.configureCell(post: post)
      }
      return cell

    } else {
      //should never happen
      return PostCell()
    }
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
      imageAdd.image = image
      imageSelected = true
    } else {
      print("DZ: A valid image was not selected")
    }
    imagePicker.dismiss(animated: true, completion: nil)
  }
  
  
  
  @IBAction func cameraIconTapped(_ sender: AnyObject) {
    present(imagePicker, animated: true, completion: nil)
  }
  
  @IBAction func postBtnTapped(_ sender: AnyObject) {
    
    guard let caption = captionField.text, caption != "" else {
      print("DZ: Caption must be entered")
      return
    }
    
    guard let img = imageAdd.image, imageSelected == true else {
      print("DZ: Image must be selected")
      return
    }
    
    if let imgData = UIImageJPEGRepresentation(img, 0.2) {
      
      let imgUid = NSUUID().uuidString
      let metadata = FIRStorageMetadata()
      metadata.contentType = "image/jpeg"
      
      DataService.ds.REF_POST_IMAGES.child(imgUid).put(imgData, metadata: metadata) {(metadata, error) in
        if error != nil {
          print("DZ: Unabel to upload image to Firebase")
        } else {
          print("DZ: Successfully uploaded image to Firebase")
          self.imageSelected = false
          let downloadURL = metadata?.downloadURL()?.absoluteString
          if let url = downloadURL {
            self.postToFirebase(imgURL: url)
          }
        }
      }
    }

  }
  
  
  func postToFirebase (imgURL: String) {
    
 //   let firebaseUser = DataService.ds.REF_USER_CURRENT

    let uid = KeychainWrapper.stringForKey(KEY_UID)
//    let user = DataService.ds.REF_USERS.child(uid!)
//  
//    print("DZ: uid = \(uid)")
//    print("DZ: user = \(user)")
    
    let post: Dictionary<String, AnyObject> = [
      "caption": captionField.text!,
      "imageURL": imgURL,
      "likes": 0,
      "postOwner": uid!
    ]
    
    let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
    firebasePost.setValue(post)

    captionField.text = ""
    imageSelected = false
    imageAdd.image = UIImage(named: "add-image")
    
    tableView.reloadData()
    
  }
  
  @IBAction func profileBtnTapped(_ sender: AnyObject) {
    
    performSegue(withIdentifier: "goToProfile", sender: nil)
    
    
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
