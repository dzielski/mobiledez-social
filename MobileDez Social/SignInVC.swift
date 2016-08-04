//
//  SignInVC.swift
//  MobileDez Social
//
//  Created by David Zielski on 7/29/16.
//  Copyright © 2016 mobiledez. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import SwiftKeychainWrapper

class SignInVC: UIViewController {

  @IBOutlet weak var emailField: FancyFieldTextBox!
  @IBOutlet weak var pwdField: FancyFieldTextBox!
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func viewDidAppear(_ animated: Bool) {
    if let _ = KeychainWrapper.stringForKey(KEY_UID) {
      print("DZ: ID found in keychain")
      performSegue(withIdentifier: "goToFeed", sender: nil)
    }
  }
  
  

  @IBAction func facebookBtnTapped(_ sender: AnyObject) {
    
    let facebookLogin = FBSDKLoginManager()
    
    facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
      if error != nil {
        print("DZ: Unable to authenticate with Facebook - \(error)")
      } else if result?.isCancelled == true {
        print("DZ: User cancelled authentication with Facebook")
      } else {
        print("DZ: Successfully authenticated with Facebook")
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        self.firebaseAuth(credential)
      }
    }
  }

  func firebaseAuth(_ credential: FIRAuthCredential) {
    FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
      if error != nil {
        print("DZ: Unable to authenticate Facebook user with Firebase - \(error)")
      } else {
        print("DZ: Successfully authenticated Facebook user with Firebase")
        if let user = user {
          let userData = ["provider": credential.provider]
          self.completeSignIn(id: user.uid, userData: userData)
        }
      }
    })
  }

  @IBAction func signInTapped(_ sender: AnyObject) {
    if let email = emailField.text, let pwd = pwdField.text {
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
              print("DZ: Unable to authenticate user with emailwith Firebase - \(error)")
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
  }
  
  func completeSignIn(id: String, userData: Dictionary<String, String>) {
    DataService.ds.createFirebaseDBUser(uid: id, userData: userData )
    let keychainResult = KeychainWrapper.setString(id, forKey: KEY_UID)
    print("DZ: Data saved to keychain = \(keychainResult)")

    
    //DZ: Todo - Have to test the code below the first time they sign in
    // I want them to create a profile name and select an image
    
    DataService.ds.REF_USER_CURRENT.observe(.value, with: { (snapshot) in
    
      print("DZ: Snap userName = \(snapshot.value!["userName"])")
      print("DZ: Snap profileImage = \(snapshot.value!["profileImg"])")
      
      guard let _ = snapshot.value!["userName"] else {
        print("DZ: No Username Selected")
        self.performSegue(withIdentifier: "noUserName", sender: nil)
        return
      }
      
      self.performSegue(withIdentifier: "goToFeed", sender: nil)
      
    })
    
  }
  
  
  
  
}

