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

class SignInVC: UIViewController {

  @IBOutlet weak var emailField: FancyFieldTextBox!
  @IBOutlet weak var pwdField: FancyFieldTextBox!
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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
      }
    })
  }

  @IBAction func signInTapped(_ sender: AnyObject) {
    if let email = emailField.text, let pwd = pwdField.text {
      FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
        if error == nil {
          print("DZ: Email user authenticated with Firebase")
        } else {
          FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
            if error != nil {
              print("DZ: Unable to authenticate user with emailwith Firebase - \(error)")
            } else {
              print("DZ: Sussusfully authenticated user with email with Firebase")
            }
          })
        }
      })
    }
  }
  
}

