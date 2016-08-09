//
//  SignInVC.swift
//  MobileDez Social
//
//  Created by David Zielski on 7/29/16.
//  Copyright © 2016 mobiledez. All rights reserved.
//

import UIKit
//import FBSDKCoreKit
//import FBSDKLoginKit
import Firebase
import SwiftKeychainWrapper

class SignInVC: UIViewController {

  @IBOutlet weak var emailField: FancyFieldTextBox!
  @IBOutlet weak var pwdField: FancyFieldTextBox!
  @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

  override func viewDidLoad() {
    super.viewDidLoad()

    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignInVC.dismissKeyboard))
    view.addGestureRecognizer(tap)

  }

  //Calls this function when the tap is recognized.
  func dismissKeyboard() {
    //Causes the view (or one of its embedded text fields) to resign the first responder status.
    view.endEditing(true)
  }

  
  override func viewDidAppear(_ animated: Bool) {
       
    if let _ = KeychainWrapper.stringForKey(KEY_UID) {
      print("DZ: ID found in keychain")
      self.sendThemOnTheirWay()
    }
  }
  
  
  @IBAction func logInBtnTapped(_ sender: AnyObject) {

    guard let email = emailField.text, email != "" else {
      print("DZ: User Name must be entered")

      let alert = UIAlertController(title: "Email Address Is Empty", message: "You need to add a valid email address to log into the system or create an account.", preferredStyle: UIAlertControllerStyle.alert)
      alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: nil))
      self.present(alert, animated: true, completion: nil)
      return
    }
    
    guard let pwd = pwdField.text, pwd != "", pwd.characters.count >= 6 else {
      print("DZ: Password Pre check error")
      
      let alert = UIAlertController(title: "Password Is Incorrect", message: "You need to include a password of 6 characters or longer to log into the system or create an account.", preferredStyle: UIAlertControllerStyle.alert)
      alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: nil))
      self.present(alert, animated: true, completion: nil)
      return
    }


    FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
      if error == nil {
        print("DZ: Email user authenticated with Firebase")
        if let user = user {
          let userData = ["provider": user.providerID]
          self.completeSignIn(id: user.uid, userData: userData)
        }
      } else {
        FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
          if error != nil {
            
            print("DZ: Firebase sign in error = \(error?.localizedDescription)")
            
            print("DZ: Unable to authenticate user with email with Firebase - \(error)")
            let alert = UIAlertController(title: "Login Information Incorrect", message: "There was an error with your username or password and the database. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
          } else {
            print("DZ: Sussusfully created and authenticated user with email with Firebase")
            if let user = user {
              let userData = ["provider": user.providerID]
              
              self.completeSignIn(id: user.uid, userData: userData)
            }
          }
        })
      }
    })
  
  }

  //  @IBAction func facebookBtnTapped(_ sender: AnyObject) {
//    
//    let facebookLogin = FBSDKLoginManager()
//    
//    facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
//      if error != nil {
//        print("DZ: Unable to authenticate with Facebook - \(error)")
//      } else if result?.isCancelled == true {
//        print("DZ: User cancelled authentication with Facebook")
//      } else {
//        print("DZ: Successfully authenticated with Facebook")
//        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
//        self.firebaseAuth(credential)
//      }
//    }
//
//  
//  }

  
  
//  func firebaseAuth(_ credential: FIRAuthCredential) {
//    FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
//      if error != nil {
//        print("DZ: Unable to authenticate Facebook user with Firebase - \(error)")
//      } else {
//        print("DZ: Successfully authenticated Facebook user with Firebase")
//        if let user = user {
//          let userData = ["provider": credential.provider]
//          self.completeSignIn(id: user.uid, userData: userData)
//        }
//      }
//    })
//  }

//  @IBAction func signInTapped(_ sender: AnyObject) {
//    if let email = emailField.text, let pwd = pwdField.text {
//      FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
//        if error == nil {
//          print("DZ: Email user authenticated with Firebase")
//          if let user = user {
//            let userData = ["provider": user.providerID]
//            self.completeSignIn(id: user.uid, userData: userData)
//          }
//        } else {
//          FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
//            if error != nil {
//              print("DZ: Unable to authenticate user with emailwith Firebase - \(error)")
//            } else {
//              print("DZ: Sussusfully created and authenticated user with email with Firebase")
//              if let user = user {
//                let userData = ["provider": user.providerID]
//             
//                self.completeSignIn(id: user.uid, userData: userData)
//              }
//            }
//          })
//        }
//      })
//    }
//  }
  
  func completeSignIn(id: String, userData: Dictionary<String, String>) {
    DataService.ds.createFirebaseDBUser(uid: id, userData: userData )
    let keychainResult = KeychainWrapper.setString(id, forKey: KEY_UID)
    print("DZ: Data saved to keychain = \(keychainResult)")

    // now check to see if they have a user name, if they do send them to the feed
    // if not send them to the profile page
    
    self.sendThemOnTheirWay()
    
  }
  
  
  func sendThemOnTheirWay() {

    // flush cache so we are fresssssh
    FeedVC.imageCache.removeAllObjects()
    FeedVC.profileImageCache.removeAllObjects()
    
    // start them on friends feed
    FeedType.ft.feedTypeToShow = FeedType.FeedTypeEnum.friendFeed
  
    DataService.ds.REF_USER_CURRENT.observeSingleEvent(of: .value, with: { (snapshot) in
      
      print("DZ: Snap userName = \(snapshot.value!["userName"]!)")
      print("DZ: Snap profileImage = \(snapshot.value!["imageURL"]!)")
      
      if (snapshot.value!["userName"]!) == nil {
        print("DZ: No Username associated with this user")
        self.performSegue(withIdentifier: "noUserName", sender: nil)
      } else {
        self.performSegue(withIdentifier: "goToFeed", sender: nil)
        
      }
      
    })
  }
  
  @IBAction func forgotPassTapped(_ sender: AnyObject) {
    self.performSegue(withIdentifier: "forgotPassword", sender: nil)
  }

  
  
  
  
}

