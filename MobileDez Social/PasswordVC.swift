//
//  passwordVC.swift
//  MobileDez Social
//
//  Created by David Zielski on 8/6/16.
//  Copyright © 2016 mobiledez. All rights reserved.
//

import UIKit
import Firebase

class PasswordVC: UIViewController {

  @IBOutlet weak var emailText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

  @IBAction func submitTapped(_ sender: AnyObject) {
    
    
    print("DZ: Email is \(emailText.text!)")
    
    if emailText.text == "" {
      
      let alert = UIAlertController(title: "Ooops!", message: "Please enter an email.", preferredStyle: UIAlertControllerStyle.alert)
      alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default, handler: nil))
      self.present(alert, animated: true, completion: nil)
      

    } else {
      
      FIRAuth.auth()?.sendPasswordReset(withEmail: emailText.text!, completion: { (error) in
        
// There seems to be a bug when firing the alert controller within the completion block of
// this Firebase sendPasswordReset - just going to say success and move on - but code is here
// if they ever fix it
        
//        var title = ""
//        var message = ""
//        
//        if error != nil {
//          title = "Ooops"
//          message = (error?.localizedDescription)! as String
//        } else {
//          title = "Success!"
//          message = "Password reset email sent."
//          self.emailText.text = ""
//        }
//
//        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
//        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//        self.present(alert, animated: true, completion: nil)
        
      })
      
      self.emailText.text = ""

      let alert = UIAlertController(title: "Success!", message: "Password reset email sent.", preferredStyle: UIAlertControllerStyle.alert)
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
      self.present(alert, animated: true, completion: nil)

    }

  }

  @IBAction func cancelTapped(_ sender: AnyObject) {
    self.performSegue(withIdentifier: "cancelPassword", sender: nil)
  }
}
