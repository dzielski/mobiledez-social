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
      
      
      DataService.ds.REF_USER_CURRENT.observeSingleEvent(of: .value, with: { (snapshot) in
        
        self.profileName.text = snapshot.value!["userName"] as? String
        
        // see if there is a image that exists and if so lets use it
        
        if let _ = snapshot.value!["imageURL"]! {
       
          self.imageSelected = true
          
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

    let usrname = self.profileName.text!

    DataService.ds.REF_USERS.queryOrdered(byChild: "userName").queryEqual(toValue: usrname).observeSingleEvent(of: .value, with: { (snapshot) in

      if snapshot.exists() {
        print("DZ: snapshot exists for \(usrname)")
        
        let alert = UIAlertController(title: "Duplicate User Name Found", message: "Your User Name needs to be unique like you are, please think of another User Name to use.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
        
      }
      else {
        print("DZ: snapshot doesnt exist for \(usrname)")
        
        guard let userName = self.profileName.text, userName != "" else {
          print("DZ: User Name must be entered")
          
          let alert = UIAlertController(title: "User Name Is Empty", message: "Your User Name needs to be present like you are, please think of a User Name to use.", preferredStyle: UIAlertControllerStyle.alert)
          alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: nil))
          self.present(alert, animated: true, completion: nil)
          return
        }
        
        guard let img = self.profileImg.image, self.imageSelected == true else {
          print("DZ: Image must be selected")
          let alert = UIAlertController(title: "Profile Picture Is Empty", message: "Your Profile Picture needs to be present like you are, please add a picture of yourself.", preferredStyle: UIAlertControllerStyle.alert)
          alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: nil))
          self.present(alert, animated: true, completion: nil)
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
    })
//    { (error) in
//      print("DZ: Error - \(error.localizedDescription)")
//    }

  }

  
  
  @IBAction func cancelBtnTapped(_ sender: AnyObject) {
    
    // DZ Todo - right now a back door exists to allow users that come here for the first
    // time and do not set a profile image or name and hit cancel - they will go to the
    // feed without setting a profile. Have to think whether to let them see the feed
    // but when they try and post to thr feed send them back here to set up a profile or
    // force them to stay here and set up profile first. If this second choice is selected
    // then maybe hide cancel button until a profile is set up or was already set up
    
    performSegue(withIdentifier: "goToFeedFrProfile", sender: nil)
    
  }
  
  @IBAction func clkImgBtnTapped(_ sender: AnyObject) {
    present(profileImagePicker, animated: true, completion: nil)

  }
  

}
