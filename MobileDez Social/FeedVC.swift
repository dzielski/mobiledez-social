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

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var imageAdd: CircleView!
  @IBOutlet weak var captionField: FancyFieldTextBox!

  var posts = [Post]()
  var imagePicker: UIImagePickerController!
  static var imageCache: Cache<NSString, UIImage> = Cache()
  static var profileImageCache: Cache<NSString, UIImage> = Cache()
  
//  let feedRedrawName = Notification.Name("NotificationIdentifier")
  
  // DZ Todo - fix this cheesy method to prevent camera image saving to database
  var imageSelected = false
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignInVC.dismissKeyboard))
      view.addGestureRecognizer(tap)

        tableView.delegate = self
        tableView.dataSource = self
      
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self

        captionField.delegate = self
      
        // setup a redraw feed notification we can call from table cell
        NotificationCenter.default.addObserver(self, selector: #selector(FeedVC.redrawFeedTable), name: feedRedrawName, object: nil)
      
        redrawFeedTable()

  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.view.endEditing(true)
    return false
  }
  
  //Calls this function when the tap is recognized.
  func dismissKeyboard() {
    //Causes the view (or one of its embedded text fields) to resign the first responder status.
    view.endEditing(true)
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    print("DZ - In numberOfRowsInSection - \(posts.count)")
    
    if posts.count == 0 {

      let messageLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
      messageLabel.text = "There are no posts to show you in this feed. Please select another feed type below."
      messageLabel.textColor = UIColor.black()
      messageLabel.numberOfLines = 0
      messageLabel.textAlignment = .center
      messageLabel.font = UIFont(name: "Avenir", size: 20)
      messageLabel.sizeToFit()
      self.tableView.backgroundView = messageLabel
      self.tableView.separatorStyle = .none
      
      return 0
    } else {
      return posts.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let post = posts[indexPath.row]
   
    if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
      
      cell.delegate = self
      
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
      self.captionField.becomeFirstResponder();
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
      let alert = UIAlertController(title: "Caption Is Empty", message: "You need to add a caption for a post. Please enter one now.", preferredStyle: UIAlertControllerStyle.alert)
      alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: nil))
      self.present(alert, animated: true, completion: nil)
      self.captionField.becomeFirstResponder();
      return
    }

    dismissKeyboard()
    
    guard let img = imageAdd.image, imageSelected == true else {
      let alert = UIAlertController(title: "Picture Is Missing", message: "You need to add an image to post. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
      alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: nil))
      self.present(alert, animated: true, completion: nil)
      print("DZ: Image must be selected")
      return
    }
    
    if let imgData = UIImageJPEGRepresentation(img, 0.2) {
      
      let imgUid = NSUUID().uuidString
      let metadata = FIRStorageMetadata()
      metadata.contentType = "image/jpeg"
      
      DataService.ds.REF_POST_IMAGES.child(imgUid).put(imgData, metadata: metadata) {(metadata, error) in
        if error != nil {
          print("DZ: Unable to upload image to Firebase")
          let alert = UIAlertController(title: "Error Saving Post", message: "Something went wrong saving your post to the database.", preferredStyle: UIAlertControllerStyle.alert)
          alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: nil))
          self.present(alert, animated: true, completion: nil)

        } else {
          print("DZ: Successfully uploaded image to Firebase")
          self.imageSelected = false
          let downloadURL = metadata?.downloadURL()?.absoluteString
          if let url = downloadURL {
            self.postToFirebase(imgURL: url, imgID: imgUid)
          }
        }
      }
    }

  }
  
  
  func postToFirebase (imgURL: String, imgID: String) {
    
    let uid = KeychainWrapper.stringForKey(KEY_UID)
    
    let post: Dictionary<String, AnyObject> = [
      "caption": captionField.text!,
      "imageURL": imgURL,
      "likes": 0,
      "postOwner": uid!,
      "imgID": imgID,
      "date": FIRServerValue.timestamp()
    ]
  
    let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
    firebasePost.setValue(post)

    let newPostRef = DataService.ds.REF_USER_CURRENT.child("postList").child(firebasePost.key)
    newPostRef.setValue(true)

    print("DZ: New Post ID - \(firebasePost.key)")
    
    captionField.text = ""
    imageSelected = false
    imageAdd.image = UIImage(named: "add-image")
    
    redrawFeedTable()
    
  }
  
  @IBAction func profileBtnTapped(_ sender: AnyObject) {
    
    performSegue(withIdentifier: "goToProfile", sender: nil)
  }


  @IBAction func likeFeedBtnTapped(_ sender: AnyObject) {
    
    // only do if is not the like feed
    if FeedType.ft.feedTypeToShow != FeedType.FeedTypeEnum.likeFeed {
      FeedType.ft.feedTypeToShow = FeedType.FeedTypeEnum.likeFeed
      redrawFeedTable()
    }
  }
  
  
  @IBAction func allFeedBtnTapped(_ sender: AnyObject) {

    // only do if is not the all feed
    if FeedType.ft.feedTypeToShow != FeedType.FeedTypeEnum.allFeed {
      FeedType.ft.feedTypeToShow = FeedType.FeedTypeEnum.allFeed
      redrawFeedTable()
    }
  
  }
  
  
  @IBAction func friendFeedBtnTapped(_ sender: AnyObject) {

    // only do if is not the friend feed
    if FeedType.ft.feedTypeToShow != FeedType.FeedTypeEnum.friendFeed {
      FeedType.ft.feedTypeToShow = FeedType.FeedTypeEnum.friendFeed
      redrawFeedTable()
    }
  }
  
  
  func redrawFeedTable() {

    self.posts = []
    tableView.reloadData()
    
    switch FeedType.ft.feedTypeToShow {
      
    case .likeFeed:
      
      DataService.ds.REF_POSTS.queryOrdered(byChild: "date").observeSingleEvent(of: .value, with: { (snapshot) in
        if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
          for snap in snapshot {
            print("DZ: SNAP: \(snap)")
            if let postDict = snap.value as? Dictionary<String, AnyObject> {
              let id = snap.key
              
              DataService.ds.REF_USER_CURRENT.child("likeList").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                if let _ = snapshot.value as? NSNull {
                  print("DZ: Will not add this post because current user did not like it = \(id)")
                } else {
                  print("DZ: Adding this post because current user did like it = \(id)")
                  let post = Post(postID: id, postData: postDict)
                  self.posts.append(post)
                }
                self.posts.sort(isOrderedBefore: {$0.date > $1.date})
                self.tableView.reloadData()
              })
            }
          }
        }
      })

    case .allFeed:
      
      DataService.ds.REF_POSTS.queryOrdered(byChild: "date").observeSingleEvent(of: .value, with: { (snapshot) in
        if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
          for snap in snapshot {
            print("DZ: SNAP: \(snap)")
            if let postDict = snap.value as? Dictionary<String, AnyObject> {
              let id = snap.key
              let post = Post(postID: id, postData: postDict)
              self.posts.append(post)
            }
          }
        }
        self.posts.sort(isOrderedBefore: { $0.date > $1.date })
        self.tableView.reloadData()
      })
    
    case .friendFeed:
  
      // first find the friend list of the current user
      // next read each friends post list
      // get the friends posts
      // sort the posts
      // display
      
      DataService.ds.REF_USER_CURRENT.child("friendList").observeSingleEvent(of: .value, with: { snapshot in
        if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
          for child in snapshots {
            print("DZ: Friend = \(child.key)")

          
            DataService.ds.REF_USERS.child(child.key).child("postList").observeSingleEvent(of: .value, with: { snapshot in
              if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for child in snapshots {
                  print("DZ: Friend's Post = \(child.key)")

                  DataService.ds.REF_POSTS.child(child.key).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                      let id = snapshot.key
                      let post = Post(postID: id, postData: postDict)
                      self.posts.append(post)
                      print("DZ: Appending Friend's Post = \(id)")
                    }
                    self.posts.sort(isOrderedBefore: {$0.date > $1.date})
                    self.tableView.reloadData()
                  })
                  
                }
              }
              
            })
          
          
          }
        }
      })


    

      break
    
    case .searchFeed:
      break
      
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
