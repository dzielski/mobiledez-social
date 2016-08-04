//
//  profileVC.swift
//  MobileDez Social
//
//  Created by David Zielski on 8/2/16.
//  Copyright © 2016 mobiledez. All rights reserved.
//

import UIKit
import Firebase

class profileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  
  @IBOutlet weak var profileImg: CircleView!
  @IBOutlet weak var profileName: FancyFieldTextBox!
  var profileImagePicker: UIImagePickerController!
  var imageSelected = false
  
  @IBOutlet weak var profileSaveBtn: FancyButton!
  
  
    override func viewDidLoad() {
      super.viewDidLoad()
      
      profileImagePicker = UIImagePickerController()
      profileImagePicker.allowsEditing = true
      profileImagePicker.delegate = self
      
      
      DataService.ds.REF_USER_CURRENT.observe(.value, with: { (snapshot) in

        self.profileName.text = snapshot.value!["userName"] as? String
        
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
   
    }

  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
      profileImg.image = image
      imageSelected = true
    } else {
      print("DZ: A valid image was not selected")
    }
    profileImagePicker.dismiss(animated: true, completion: nil)
  }
  
  
  func postToFirebase (imgURL: String) {
    
    let profile: Dictionary<String, AnyObject> = [
      "userName": profileName.text!,
      "imageURL": imgURL,
    ]
    
    let firebasePost = DataService.ds.REF_USER_CURRENT
    firebasePost.setValue(profile)
    
    imageSelected = false
  }

  
  @IBAction func saveBtnTapped(_ sender: AnyObject) {
    guard let userName = profileName.text, userName != "" else {
      print("DZ: User Name must be entered")
      return
    }
    
    guard let img = profileImg.image, imageSelected == true else {
      print("DZ: Image must be selected")
      return
    }
    
    if let imgData = UIImageJPEGRepresentation(img, 0.2) {
      
      let imgUid = NSUUID().uuidString
      let metadata = FIRStorageMetadata()
      metadata.contentType = "image/jpeg"
      
      DataService.ds.REF_PROFILE_IMAGES.child(imgUid).put(imgData, metadata: metadata) {(metadata, error) in
        if error != nil {
          print("DZ: Unabel to upload image to Firebase")
        } else {
          print("DZ: Successfully uploaded image to Firebase")
          self.imageSelected = false
          let downloadURL = metadata?.downloadURL()?.absoluteString
          if let url = downloadURL {
            self.postToFirebase(imgURL: url)
          }
          
          // flush cache as we changed a profile image
          FeedVC.profileImageCache.removeAllObjects()
          self.performSegue(withIdentifier: "goToFeedFrProfile", sender: nil)
        }
      }
    }
    
  }

  
  
  @IBAction func cancelBtnTapped(_ sender: AnyObject) {
    
    performSegue(withIdentifier: "goToFeedFrProfile", sender: nil)
    
  }
  
  @IBAction func clkImgBtnTapped(_ sender: AnyObject) {
    present(profileImagePicker, animated: true, completion: nil)

  }
  

}
